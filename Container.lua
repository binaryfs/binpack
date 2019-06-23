local BASE = (...):gsub("%.[^%.]+$", "")
local cells = require(BASE .. ".internal.cells")

---
-- Class: Container
-- Bin packing container. Use <binpack.newContainer> to create one.
local Container = {}
Container.__index = Container

---
-- Method: insert
-- Insert a rectangle.
--
-- Parameters:
-- width  - The rectangle's width
-- height - The rectangle's height
-- data   - (optional) Data to store along with the rectangle (defaults to nil)
--
-- Returns:
-- 1. - Cell index if insertion succeeds, nil otherwise
-- 2. - Error message if insertions fails
--
-- Raise:
-- width and height must be positive
--
-- Example:
-- > local index, err = container:insert(200, 100)
-- > if index then
-- >   print("Rectangle inserted!")
-- > else
-- >  print(err)
-- > end
Container.insert = function(self, width, height, data)
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

---
-- Method: getSize
-- Return the size of the container.
--
-- Returns:
-- 1. - Width of the container
-- 2. - Height of the container
Container.getSize = function(self)
  return self._root.boundingWidth, self._root.boundingHeight
end

---
-- Method: hasGrown
-- Check if the last insertion caused the container to grow.
--
-- Returns:
-- true or false
Container.hasGrown = function(self)
  return self._hasGrown
end

---
-- Method: getCellCount
-- Return the number of filled cells.
--
-- Example:
-- ===Text
-- for i = 1, container:getCellCount() do
--   print(container:getCellSize(i))
-- end
-- ===
Container.getCellCount = function(self)
  return #self._filledCells
end

---
-- Method: getCellPosition
-- Return the position of the specified cell.
--
-- Parameters:
-- index - The cell's index
--
-- Returns:
-- 1. - Cell position along x-axis
-- 2. - Cell position along y-axis
--
-- Raise:
-- Invalid cell index
Container.getCellPosition = function(self, index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  return cell.left, cell.top
end

---
-- Method: getCellSize
-- Return the size of the specified cell including padding.
--
-- A cell has the same size as the rectangle that was inserted into it,
-- plus padding.
--
-- Parameters:
-- index - The cell's index
--
-- Returns:
-- 1. - The cell's width
-- 2. - The cell's height
--
-- Raise:
-- Invalid cell index
Container.getCellSize = function(self, index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  return cell.width, cell.height
end

---
-- Method: getCellContentSize
-- Return the size of the specified cell without padding.
--
-- A cell has the same size as the rectangle that was inserted into it,
-- plus padding.
--
-- Parameters:
-- index - The cell's index
--
-- Returns:
-- 1. - The cell's width
-- 2. - The cell's height
--
-- Raise:
-- Invalid cell index
Container.getCellContentSize = function(self, index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  return cell.width - self._padding * 2, cell.height - self._padding * 2
end

---
-- Method: getCellBoundings
-- Return a bounding box that encloses the specified cell and its descendants.
--
-- Parameters:
-- index - The cell's index
--
-- Returns: 
-- 1. - Bounding box position along x-axis
-- 2. - Bounding box position along y-axis
-- 3. - Bounding box width
-- 4. - Bounding box height
--
-- Raise:
-- Invalid cell index
Container.getCellBoundings = function(self, index)
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

---
-- Method: getCellData
-- Return the data that is stored in the specified cell.
--
-- Use the <insert> method to store data in cells.
--
-- Parameters:
-- index - The cell's index
--
-- Returns:
-- Data or nil if the cell doesn't store any data
--
-- Raise:
-- Invalid cell index
Container.getCellData = function(self, index)
  local cell = assert(self._filledCells[index], "Invalid cell index")
  return cell.data
end

---
-- Grow the container so it can contain the specified rectangle.
--
-- Parameters:
-- width  - The rectangle's width
-- height - The rectangle's height
--
-- Returns:
-- 1. - The cell that contains the rectangle or nil if growth fails
-- 2. - Error message if growth fails
Container._grow = function(self, width, height)
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