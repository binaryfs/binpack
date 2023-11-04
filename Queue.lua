--- @alias binpack.QueueOrderFunc fun(a: table, b: table):boolean
--- @alias binpack.QueueCallback fun(container: binpack.Container, index: integer?, error: string?)

--- Default order function that is used to sort the enqueued rectangles by their size.
--- @param rect1 table
--- @param rect2 table
--- @return boolean
--- @package
local function _defaultOrderFunction(rect1, rect2)
  return rect1[1] * rect1[2] > rect2[1] * rect2[2]
end

--- Queues are used to insert rectangles into containers in a certain order, e.g. sorted by size.
--- @class binpack.Queue
--- @field protected _orderFunction binpack.QueueOrderFunc
local Queue = {}
Queue.__index = Queue

--- @param orderFunction binpack.QueueOrderFunc? Order function to sort the enqueued rectangles
--- @return binpack.Queue queue
--- @nodiscard
function Queue.new(orderFunction)
  return setmetatable({
    _orderFunction = orderFunction or _defaultOrderFunction
  }, Queue)
end

--- Add a rectangle to the queue.
--- @param width integer Rectangle width
--- @param height integer Rectangle height
--- @param data any Optional data to store along with the rectangle (defaults to nil)
function Queue:add(width, height, data)
  assert(width > 0 and height > 0, "width and height must be positive")
  self[#self + 1] = {width, height, data}
end

--- Remove all rectangles from the queue.
function Queue:clear()
  for index = #self, 1, -1 do
    self[index] = nil
  end
end

--- Insert all enqueued rectangles into the given container and clear the queue.
---
--- The optional `callback` function expects the container and the return values from
--- `Container.insert` as arguments.
---
--- Example:
--- ```
--- queue:insertInto(container, function(container, index, err)
---   if index then print("Rectangle inserted")
---   else print("Error: " .. err) end
--- end)
--- ```
--- @param container binpack.Container
--- @param callback binpack.QueueCallback? Function to call for each inserted rectangle
function Queue:insertInto(container, callback)
  table.sort(self, self._orderFunction)

  for index = 1, #self do
    local cellIndex, err = container:insert(unpack(self[index]))

    if callback then
      callback(container, cellIndex, err)
    end
  end

  self:clear()
end

return Queue