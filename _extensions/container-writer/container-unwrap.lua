 
--[[
container-unwrap.lua - unwraps Div and Span elements, preserving their content.

Reads a list from YAML metadata and removes matching container elements while
keeping their content in place. Useful as a post-processing step after
container-writer.lua to neutralise Divs that were not in the whitelist and
would otherwise render differently across Pandoc versions.

Must run after container-writer.lua — the writer converts whitelisted elements
to raw format commands that unwrap never sees.

  pandoc --lua-filter=container-writer.lua \
         --lua-filter=container-unwrap.lua \
         input.md -t typst

YAML accepts a scalar or a list. Two reserved keywords control bulk behaviour:

  all   — unwrap every remaining Div/Span regardless of class
  void  — unwrap elements that carry no class at all

Examples:

  container-unwrap: all

  container-unwrap: void

  container-unwrap: sidebar

  container-unwrap:
    - void
    - sidebar
    - note

See copyright notice in file LICENSE.
]]

PANDOC_VERSION:must_be_at_least({ 2, 19, 1 })


-- # Config

local Blacklist = {}
local Unclassed = false   -- true when 'void' is in the list
local UnwrapAll = false   -- true when 'all'  is in the list

--- Reads config from meta['container-unwrap'].
--- Accepts both scalar (single string) and list forms.
local function process_metadata(meta)
  local config = meta['container-unwrap']
  if not config then return meta end

  -- Normalise scalar to a one-element list so the loop below handles both.
  local list = (pandoc.utils.type(config) == 'List') and config or { config }

  for _, item in ipairs(list) do
    local s = pandoc.utils.stringify(item)
    if     s == 'all'  then UnwrapAll    = true
    elseif s == 'void' then Unclassed    = true
    else                    Blacklist[s] = true
    end
  end

  return meta
end

--- Returns true if the element should be unwrapped.
local function should_unwrap(classes)
  if UnwrapAll then return true end
  if Unclassed and #classes == 0 then return true end
  return classes:find_if(function(c) return Blacklist[c] end) ~= nil
end


-- # Entry point

return {
  { Meta = process_metadata },
  { Div  = function(el) if should_unwrap(el.classes) then return el.content end end },
  { Span = function(el) if should_unwrap(el.classes) then return el.content end end },
}
