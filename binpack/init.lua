---
-- File: binpack
-- Simple 2D bin packing implementation for Lua.
--
-- Packs different-sized rectangles into a rectangular container. This implementation
-- solves the online bin packing problem where rectangles are inserted one at a time
-- in random order.

local BASE = (...):gsub("%.init$", "")
local Container = require(BASE .. ".Container")
local cells = require(BASE .. ".cells")

local binpack = {
  _NAME = "lua-binpack",
  _DESCRIPTION = "Simple 2D bin packing implementation for Lua",
  _VERSION = "1.0.0",
  _URL = "https://github.com/binaryfs/lua-binpack",
  _LICENSE = "MIT License",
  _COPYRIGHT = "Copyright (c) 2019 Fabian Staacke"
}

---
-- Function: binpack.newContainer
-- Create a new <bin packing container: Container>.
--
-- Parameters:
-- width   - The width of the container
-- height  - The height of the container
-- padding - (optional) The amount of padding inside each container cell (defaults to 0)
-- mode    - (optional) Determines if the container's size is dynamic or static.
--           A dynamically sized container will grow if a rectangle does not fit into it.
--           Pass "static" as the value to create a static-sized container (defaults to
--           "dynamic")
--
-- Returns:
-- Container object
--
-- Raise:
-- Invalid value for mode
--
-- Example:
-- Create a dynamically sized container:
-- > local container = binpack.newContainer(256, 256)
-- Create a static-sized container:
-- > local staticContainer = binpack.newContainer(32, 32, 0, "static")
binpack.newContainer = function(width, height, padding, mode)
  mode = mode or "dynamic"
  if mode ~= "static" and mode ~= "dynamic" then
    error('Value of mode expected to be "static" or "dynamic", got: ' .. tostring(mode))
  end
  return setmetatable({
    _padding = padding or 0,
    _canGrow = canGrow ~= false,
    _hasGrown = false,
    _root = cells.newCell(0, 0, width, height),
    _filledCells = {}
  }, Container)
end

return binpack