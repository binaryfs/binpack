local BASE = (...):gsub("init$", "")
--- @type binpack.Container
local Container = require(BASE .. ".Container")
--- @type binpack.Queue
local Queue = require(BASE .. ".Queue")

local binpack = {
  _NAME = "binpack",
  _DESCRIPTION = "Simple 2D bin packing implementation for Lua",
  _VERSION = "2.0.1",
  _URL = "https://github.com/binaryfs/binpack",
  _LICENSE = [[
    MIT License

    Copyright (c) 2019 Fabian Staacke

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]],
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