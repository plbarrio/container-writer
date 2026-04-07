--[[
container-strip.lua - removes Div and Span elements by class.

Reads a blacklist from YAML metadata and silently removes any matching
element — content and all — from the document. Useful for stripping
editorial annotations in production builds without touching source files.

Must run before container-writer.lua — if writer runs first it converts
elements to raw format commands that strip never sees.

Blacklist entries are plain class names only. Compound (parent.child)
entries are not supported — each class to strip must be listed explicitly.

  Review build:
    pandoc --lua-filter=container-writer.lua input.md -o draft.pdf

  Production build:
    pandoc --lua-filter=container-strip.lua \
           --lua-filter=container-writer.lua \
           input.md -o final.pdf

YAML:
  container-strip:
    - marginnoteopen
    - marginnoteclosed
    - marginnoteopenblock
    - marginnoteclosedblock

See copyright notice in file LICENSE.
]]

PANDOC_VERSION:must_be_at_least({ 2, 19, 1 })


-- # Blacklist

local Blacklist = {}

--- Reads the blacklist from meta['container-strip'].
local function process_metadata(meta)
  local config = meta['container-strip']
  if not config then return meta end
  for _, item in ipairs(config) do
    Blacklist[pandoc.utils.stringify(item)] = true
  end
  return meta
end

--- Returns true if any class on the element is blacklisted.
local function in_blacklist(classes)
  return classes:find_if(function(c) return Blacklist[c] end) ~= nil
end


-- # Entry point

return {
  { Meta = process_metadata },
  { Div  = function(el) if in_blacklist(el.classes) then return pandoc.Blocks({})   end end },
  { Span = function(el) if in_blacklist(el.classes) then return pandoc.Inlines({})  end end },
}
