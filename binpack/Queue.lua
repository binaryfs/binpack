--- Bin packing queue.
-- Queues are used to insert rectangles into containers in a certain order, e.g. sorted by size.
-- Use binpack.newQueue to create one.
--
-- @classmod binpack.Queue
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local Queue = {}
Queue.__index = Queue

--- Default order function that is used to sort the enqueued rectangles by size.
Queue.defaultOrderFunction = function(rect1, rect2)
  return rect1[1] * rect1[2] > rect2[1] * rect2[2]
end

--- Add a rectangle to the queue.
--
-- @param width     The rectangle's width
-- @param height    The rectangle's height
-- @param[opt] data Data to store along with the rectangle (defaults to nil)
--
-- @raise width and height must be positive
function Queue:enqueue(width, height, data)
  assert(width > 0 and height > 0, "width and height must be positive")
  self[#self + 1] = {width, height, data}
end

--- Remove all rectangles from the queue.
function Queue:clear()
  for i = 1, #self do
    self[i] = nil
  end
end

--- Insert all enqueued rectangles into the given container.
-- This removes all rectangles from the queue.
--
-- @param container The container
-- @param[opt] callback An optional function that is called for each inserted rectangle.
--   The function expects the container and the return values from Container.insert()
--   as arguments.
--
-- @usage
-- queue:insertInto(container, function(container, index, err)
--   if index then print("Rectangle inserted")
--   else print("Error: " .. err) end
-- end)
function Queue:insertInto(container, callback)
  table.sort(self, self._orderFunction)

  for i = 1, #self do
    local index, err = container:insert(unpack(self[i]))

    if callback then
      callback(container, index, err)
    end

    self[i] = nil
  end
end

return Queue