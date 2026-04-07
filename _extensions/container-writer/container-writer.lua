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

PANDOC_VERSION:must_be_at_least( { 2, 19, 1 } )


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
    for _, item in ipairs(list) do
      local t = pandoc.utils.type(item)
      if t == 'Meta' or t == 'table' then
        -- remap entry: {note.title: notetitle}
        for k, v in pairs(item) do
          local key = pandoc.utils.stringify(k)
          local val = pandoc.utils.stringify(v)
          Whitelist[key] = val
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
    table.insert(result, inline)
  end
  table.insert(result, pandoc.RawInline(fmt, close))
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
      return {
        pandoc.RawBlock('typst', '#block['),
        el,
        pandoc.RawBlock('typst', '] <' .. environment .. '>'),
      }
    end

  elseif FORMAT == 'latex' then
    if is_inline then
      return inline_wrap('latex', '\\' .. environment .. '{', el.content, '}')
    else
      return {
        pandoc.RawBlock('latex', '\\begin{' .. environment .. '}'),
        el,
        pandoc.RawBlock('latex', '\\end{' .. environment .. '}'),
      }
    end

  elseif FORMAT == 'context' then
    if is_inline then
      return inline_wrap('context', '\\' .. environment .. '{', el.content, '}')
    else
      el = el:walk {
        SoftBreak = function()
          return pandoc.RawInline('context', '\n')
        end,
      }
      return {
        pandoc.RawBlock('context', '\\start' .. environment),
        el,
        pandoc.RawBlock('context', '\\stop' .. environment),
      }
    end

  else
    return nil
  end
end

--- Walks children looking for trigger.class whitelist matches.
--- trigger     : remaining path — current level name, used for child lookup and environment
--- accumulated : full dot-chain so far, used for whitelist wrap check
local function walk_element(el, is_inline, trigger, accumulated)
  if FORMAT ~= 'html' and FORMAT ~= 'epub' then
    el = el:walk {
      Div = function(child)
        local class = child.classes:find_if(function(c)
          return Whitelist[trigger .. '.' .. c]
        end)
        if class then
          local entry = Whitelist[trigger .. '.' .. class]
          local env = (entry == true) and class or entry
          return walk_element(child, false, env, accumulated .. '.' .. class)
        end
      end,
      Span = function(child)
        local class = child.classes:find_if(function(c)
          return Whitelist[trigger .. '.' .. c]
        end)
        if class then
          local entry = Whitelist[trigger .. '.' .. class]
          local env = (entry == true) and class or entry
          return walk_element(child, true, env, accumulated .. '.' .. class)
        end
      end,
    }
  end
  if in_whitelist(accumulated) then
    return wrap_element(el, trigger, is_inline)
  end
  return el
end

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
  local env = (entry == true or entry == nil) and environment or entry
  return walk_element(el, is_inline, env, environment)
end

-- # Entry point

local function handle_div(el)  return handle_element(el, false) end
local function handle_span(el) return handle_element(el, true)  end

return {
  { Meta = process_metadata },
  { Div  = handle_div       },
  { Span = handle_span      },
}
