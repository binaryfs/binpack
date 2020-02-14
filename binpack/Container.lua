--- Bin packing container.
-- Use binpack.newContainer to create one.
-- @classmod binpack.Container
-- @author Fabian Staacke
-- @copyright 2019
-- @license https://opensource.org/licenses/MIT

local BASE = (...):gsub("%.[^%.]+$", "")
local cells = require(BASE .. ".cells")

local Container = {}
Container.__index = Container

--- Insert a rectangle.
--
-- @param width     The rectangle's width
-- @param height    The rectangle's height
-- @param[opt] data Data to store along with the rectangle (defaults to nil)
--
-- @return[1] Cell index if insertion succeeds, nil otherwise
-- @return[2] Error message if insertions fails
--
-- @raise width and height must be positive
--
-- @usage
-- local index, err = container:insert(200, 100)
-- if index then
--   print("Rectangle inserted!")
-- else
--   print(err)
-- end
function Container:insert(width, height, data)
  assert(width > 0 and height > 0, "width and height must be positive")

  width = width + self._padding * 2
  height = height + self._padding * 2
  self._hasGrown = false

  local cell, err = cells.searchFittingCell(self._root, width, height)

  if cell then
    cells.splitCell(cell, width, height)
  elseif self._canGrow then
    cell, err = self:_grow(width, height)
  end

  if cell then
    cell.data = data
    table.insert(self._filledCells, cell)
    return #self._filledCells
  end

  -- Insertion failed.
  return nil, err
end

--- Get the size of the container.
-- @return[1] Width of the container
-- @return[2] Height of the container
function Container:getSize()
  return self._root.boundingWidth, self._root.boundingHeight
end

--- Check if the last insertion caused the container to grow.
-- @treturn bool
function Container:hasGrown()
  return self._hasGrown
end

--- Return the number of filled cells.
--
-- @usage
-- for i = 1, container:getCellCount() do
--   print(container:getCellSize(i))
-- end
function Container:getCellCount()
  return #self._filledCells
end

--- Get the position of the specified cell.
--
-- @param index The cell's index, starting with 1
--
-- @return[1] Cell position along x-axis
-- @retunr[2] Cell position along y-axis
--
-- @raise Invalid cell index
function Container:getCellPosition(index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  return cell.left, cell.top
end

--- Get the size of the specified cell including padding.
--
-- A cell has the same size as the rectangle that was inserted into it,
-- plus padding.
--
-- @param index The cell's index, starting with 1
--
-- @return[1] The cell's width
-- @return[2] The cell's height
--
-- @raise Invalid cell index
function Container:getCellSize(index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  return cell.width, cell.height
end

--- Get the size of the specified cell without padding.
--
-- A cell has the same size as the rectangle that was inserted into it,
-- plus padding.
--
-- @param index The cell's index, starting with 1
--
-- @return[1] The cell's width
-- @return[2] The cell's height
--
-- @raise Invalid cell index
function Container:getCellContentSize(index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  return cell.width - self._padding * 2, cell.height - self._padding * 2
end

--- Return a bounding box that encloses the specified cell and its descendants.
--
-- @param index The cell's index, starting with 1
-- 
-- @return[1] Bounding box position along x-axis
-- @return[2] Bounding box position along y-axis
-- @return[3] Bounding box width
-- @return[4] Bounding box height
--
-- @raise: Invalid cell index
function Container:getCellBoundings(index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  local left, top = cell.left, cell.top
  -- Does the cell have top child?
  if cell.firstChild.left < left then
    left = left- cell.firstChild.boundingWidth
  end
  -- Does the cell have a left child?
  if cell.secondChild.top < top then
    top = top - cell.secondChild.boundingHeight
  end
  return left, top, cell.boundingWidth, cell.boundingHeight
end

--- Get the data that is stored in the specified cell.
-- Use the insert method to store data in cells.
--
-- @param index The cell's index, starting with 1
-- @return The stored data or nil if the cell doesn't store any data
--
-- @raise Invalid cell index
function Container:getCellData(index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  return cell.data
end

--- Grow the container so it can contain the specified rectangle.
--
-- @param width  The rectangle's width
-- @param height The rectangle's height
--
-- @return[1] The cell that contains the rectangle or nil if growth fails
-- @return[2] Error message if growth fails
function Container:_grow(width, height)
  local newRoot, err
  local oldRoot = self._root

  if width <= oldRoot.boundingWidth or height <= oldRoot.boundingHeight then
    -- Expend container to the bottem if it has a horizontal format.
    if oldRoot.boundingWidth > oldRoot.boundingHeight and width <= oldRoot.boundingWidth then
      newRoot = cells.expandBottom(oldRoot, width, height)
    else
      newRoot = cells.expandRight(oldRoot, width, height)
    end
    self._root = newRoot
    self._hasGrown = true
  else
    err = "Rectangles are required to be less wide or less tall than the container"
  end

  return newRoot, err
end

return Container