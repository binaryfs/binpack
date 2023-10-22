local BASE = (...):gsub("%.init$", "")
--- @type binpack.Container
local Container = require(BASE .. ".Container")
--- @type binpack.Queue
local Queue = require(BASE .. ".Queue")

local binpack = {
  _NAME = "lua-binpack",
  _DESCRIPTION = "Simple 2D bin packing implementation for Lua",
  _VERSION = "2.0.0",
  _URL = "https://github.com/binaryfs/lua-binpack",
  _LICENSE = "MIT License",
  _COPYRIGHT = "Copyright (c) 2019-2023 Fabian Staacke"
}

--- Create a new bin packing container.
---
--- The parameter `canGrow` determines if the container's size is dynamic or static.
--- A dynamically sized container will grow if a rectangle does not fit into it.
--- @param width integer The width of the container
--- @param height integer The height of the container
--- @param padding integer? The amount of padding inside each container cell (defaults to 0)
--- @param canGrow boolean? Determines if the container size is dynamic (defaults to true)
--- @return binpack.Container
--- @nodiscard
function binpack.newContainer(width, height, padding, canGrow)
  return Container.new(width, height, padding, canGrow)
end

--- Create a new bin packing queue.
--- 
--- The optional order function `orderFunction` takes two rectangles as arguments and must
--- return `true` if the first rectangle should come first in the sorted queue. If no function
--- is specified, a default order function is used which sorts the rectangles by their size.
---
--- Example:
--- ```
--- local queue = binpack.newQueue(function(rect1, rect2)
---   return rect1.width > rect2.width
--- end)
--- ```
--- @param orderFunction binpack.QueueOrderFunc? Order function to sort the enqueued rectangles
--- @return binpack.Queue queue
--- @nodiscard
function binpack.newQueue(orderFunction)
  return Queue.new(orderFunction)
end

return binpack