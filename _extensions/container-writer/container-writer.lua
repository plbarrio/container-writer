--[[
container-writer.lua - translates generic Div/Span containers to format-native environments.

Reads a whitelist from YAML metadata and wraps matching Divs and Spans
in the appropriate environment for each output format.

Usage:
  pandoc --lua-filter=container-writer.lua input.md -o output.pdf

YAML configuration:
  container-writer:
    common:           # applied to all formats
      - verse
      - stanza
      - epigraph
      - note
      - note.title    # parent.child: wrap Div.title inside Div.note
    latex:            # FORMAT-specific (latex, context, typst, html...)
      - poemcol
    typst:
      - pullquote

The effective whitelist for a given format is common + FORMAT-specific.
Elements not in the whitelist are left untouched.
Explicit env= / environment= attributes bypass the whitelist check.

Parent.child entries (e.g. note.title):
  Triggers when a Div/Span with class 'note' is visited. Children matching
  class 'title' are wrapped using the child's own class name as environment:
  \begin{title} / \starttitle — mirroring the AST directly.
  HTML/EPUB: left as-is, styled via CSS descendant selectors (.note .title).
  Typst/ConTeXt: scope the title style locally inside the parent rule.
  LaTeX: \begin{title} is global — define \newenvironment{title}{}{} as no-op
  or use etoolbox for per-context definitions.
  If 'note' is not in the whitelist but 'note.title' is, the parent passes
  through unwrapped while its matching children are still processed.
  Chains are supported: note.title.icon — each level uses its own class name.

See copyright notice in file LICENSE.
]]

PANDOC_VERSION:must_be_at_least({ 2, 19, 1 })


-- # Whitelist

--- Whitelist['note']         = true        — plain entry, wrap with class name
--- Whitelist['note.title']   = true        — compound, child uses class name
--- Whitelist['note.title']   = 'notetitle' — compound, child uses remapped name
local Whitelist = {}

local function in_whitelist(name)
  return Whitelist[name] ~= nil
end

local function process_metadata(meta)
  local config = meta['container-writer']
  if not config then return meta end

  local function add_list(list)
    if not list then return end
    local items = (pandoc.utils.type(list) == 'List') and list or { list }
    for _, item in ipairs(items) do
      local t = pandoc.utils.type(item)
      if t == 'Meta' or t == 'table' then
        -- remap entry: {note.title: notetitle}
        for k, v in pairs(item) do
          Whitelist[pandoc.utils.stringify(k)] =
            pandoc.utils.stringify(v)
        end
      else
        -- plain entry: note or note.title
        Whitelist[pandoc.utils.stringify(item)] = true
      end
    end
  end

  add_list(config.common)
  add_list(config[FORMAT])

  return meta
end


-- # Wrapping

--- Builds a flat inline list: open RawInline + content inlines + close RawInline.
--- Avoids the double-brace problem when returning a Span in LaTeX/ConTeXt
--- (Pandoc wraps Span content in {} automatically).
local function inline_wrap(fmt, open, inlines, close)
  local result = { pandoc.RawInline(fmt, open) }
  for _, inline in ipairs(inlines) do
    result[#result + 1] = inline
  end
  result[#result + 1] = pandoc.RawInline(fmt, close)
  return result
end

--- Emits the format-native wrapping for a matched element.
---   HTML/EPUB  : nil — Pandoc renders Div/Span with classes natively.
---   LaTeX Div  : \begin{env}...\end{env}
---   LaTeX Span : \env{...}
---   ConTeXt Div: \startenv...\stopenv
---   ConTeXt Span: \env{...}
---   Typst Div  : #block[...] <env>
---   Typst Span : #[...] <env>
local function wrap_element(el, environment, is_inline)
  if FORMAT == 'html' or FORMAT == 'epub' then
    return nil

  elseif FORMAT == 'typst' then
    if is_inline then
      return inline_wrap('typst', '#[', el.content, '] <' .. environment .. '>')
    else
      local blocks = pandoc.Blocks({})
      blocks:insert(pandoc.RawBlock('typst', '#block['))
      blocks:extend(el.content)
      blocks:insert(pandoc.RawBlock('typst', '] <' .. environment .. '>'))
      return blocks
    end

  elseif FORMAT == 'latex' then
    if is_inline then
      return inline_wrap('latex', '\\' .. environment .. '{', el.content, '}')
    else
      local blocks = pandoc.Blocks({})
      blocks:insert(pandoc.RawBlock('latex', '\\begin{' .. environment .. '}'))
      blocks:extend(el.content)
      blocks:insert(pandoc.RawBlock('latex', '\\end{' .. environment .. '}'))
      return blocks
    end

  elseif FORMAT == 'context' then
    if is_inline then
      return inline_wrap('context', '\\' .. environment .. '{', el.content, '}')
    else
      -- SoftBreak must be emitted as a hard newline inside ConTeXt environments,
      -- otherwise ConTeXt collapses it to a space and breaks line-sensitive content.
      el = el:walk {
        SoftBreak = function()
          return pandoc.RawInline('context', '\n')
        end,
      }
      local blocks = pandoc.Blocks({})
      blocks:insert(pandoc.RawBlock('context', '\\start' .. environment))
      blocks:extend(el.content)
      blocks:insert(pandoc.RawBlock('context', '\\stop' .. environment))
      return blocks
    end
  end
end


-- # Child processing (two-pass)

--- Pass 1: annotate matching children with _cw_env and _cw_acc attributes.
--- Does not substitute — lets the walk descend fully into all nested levels
--- before any replacement occurs. This avoids a Pandoc 3.9+ behaviour where
--- returning a replacement from a walk handler stops further descent, which
--- would silently drop deeper chain entries (e.g. note.title.icon).
local function mark_children(el, accumulated)
  local function handle(child)
    local class = child.classes:find_if(function(c)
      return Whitelist[accumulated .. '.' .. c]
    end)
    if class then
      local entry = Whitelist[accumulated .. '.' .. class]
      local env   = (entry == true) and class or entry
      local acc   = accumulated .. '.' .. class
      child = mark_children(child, acc)
      child.attributes['_cw_env'] = env
      child.attributes['_cw_acc'] = acc
      return child
    end
  end

  return el:walk {
    Div  = handle,
    Span = handle,
  }
end

--- Pass 2: substitute marked elements with their format-native wrapping.
--- Runs bottom-up so inner elements are wrapped before outer ones.
local function wrap_marked(el)
  local function handle(child, is_inline)
    local env = child.attributes['_cw_env']
    local acc = child.attributes['_cw_acc']
    if env then
      child.attributes['_cw_env'] = nil
      child.attributes['_cw_acc'] = nil
      if in_whitelist(acc) then
        return wrap_element(child, env, is_inline)
      end
    end
  end

  return el:walk {
    Div  = function(c) return handle(c, false) end,
    Span = function(c) return handle(c, true)  end,
  }
end

--- Orchestrates the two-pass child processing and wraps the element itself.
--- trigger     : current level name, used as environment
--- accumulated : full dot-chain so far, used for whitelist wrap check
local function walk_element(el, is_inline, trigger, accumulated)
  if FORMAT ~= 'html' and FORMAT ~= 'epub' then
    el = mark_children(el, accumulated)
    el = wrap_marked(el)
  end
  if in_whitelist(accumulated) then
    return wrap_element(el, trigger, is_inline)
  end
  return el
end


-- # Entry point

--- Pandoc entry point for Div and Span elements.
--- Resolves the environment name from the whitelist or an explicit attribute,
--- then delegates to walk_element.
local function handle_element(el, is_inline)
  if FORMAT == 'json' then return nil end

  local explicit = el.attributes['env'] or el.attributes['environment']

  local environment = explicit or el.classes:find_if(function(c)
    if Whitelist[c] then return true end
    for key in pairs(Whitelist) do
      if key:match('^' .. c .. '%.') then return true end
    end
  end)

  if not environment then return nil end

  local entry = Whitelist[environment]
  local env   = (entry == true or entry == nil) and environment or entry

  return walk_element(el, is_inline, env, environment)
end

return {
  { Meta = process_metadata },
  { Div  = function(el) return handle_element(el, false) end },
  { Span = function(el) return handle_element(el, true)  end },
}
