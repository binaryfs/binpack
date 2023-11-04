local BASE = (...):gsub("Container$", "")
--- @type binpack.Cell
local Cell = require(BASE .. ".Cell")

--- Bin packing container.
--- @class binpack.Container
--- @field protected _padding integer
--- @field protected _canGrow boolean
--- @field protected _hasGrown boolean
--- @field protected _root binpack.Cell
--- @field protected _filledCells binpack.Cell[]
local Container = {}
Container.__index = Container

--- @param width integer The width of the container
--- @param height integer The height of the container
--- @param padding integer? The amount of padding inside each container cell (defaults to 0)
--- @param canGrow boolean? Determines if the container size is dynamic (defaults to true)
--- @return binpack.Container
--- @nodiscard
function Container.new(width, height, padding, canGrow)
  return setmetatable({
    _padding = padding or 0,
    _canGrow = canGrow ~= false,
    _hasGrown = false,
    _root = Cell.new(0, 0, width, height, padding or 0),
    _filledCells = {},
  }, Container)
end

--- Insert a rectangle.
--- @param width integer Rectangle width
--- @param height integer Rectangle height
--- @param data any Optional data to store along with the rectangle (defaults to nil)
--- @return integer? index Cell index if insertion succeeds, nil otherwise
--- @return string? error Error message if insertions fails
function Container:insert(width, height, data)
  assert(width > 0 and height > 0, "width and height must be positive")

  width = width + self._padding * 2
  height = height + self._padding * 2
  self._hasGrown = false

  local cell, err = self._root:searchFittingCell(width, height)

  if cell then
    cell:splitCell(width, height)
  elseif self._canGrow then
    cell, err = self:_grow(width, height)
  end

  if cell then
    cell:setData(data)
    table.insert(self._filledCells, cell)
    return #self._filledCells
  end

  -- Insertion failed.
  return nil, err
end

--- Get the size of the container.
--- @return integer width
--- @return integer height
--- @nodiscard
function Container:getSize()
  return self._root:getBoundingSize()
end

--- Check if the last insertion caused the container to grow.
--- @return boolean
--- @nodiscard
function Container:hasGrown()
  return self._hasGrown
end

--- Get the cell at the specified index.
---
--- Raises an error if the cell index is invalid.
--- @param index integer
--- @return binpack.Cell cell
--- @nodiscard
function Container:getCell(index)
  return assert(self._filledCells[index], string.format("Invalid cell index %s", index))
end

--- Return the number of filled cells.
--- @return integer cellCount
--- @nodiscard
function Container:getCellCount()
  return #self._filledCells
end

--- Get an iterator over all filled container cells.
--- @return fun(t: binpack.Cell[], i: integer): integer, binpack.Cell
--- @return table
--- @return integer
function Container:cells()
  return ipairs(self._filledCells)
end

--- Grow the container so it can contain the specified rectangle.
--- @param width integer  Rectangle width
--- @param height integer Rectangle height
--- @return binpack.Cell? cell The cell that contains the rectangle or nil if growth fails
--- @return string? error Error message if growth fails
--- @nodiscard
function Container:_grow(width, height)
  local newRoot, err
  local oldRoot = self._root
  local boundingWidth, boundingHeight = oldRoot:getBoundingSize()

  if width <= boundingWidth or height <= boundingHeight then
    -- Expend container to the bottem if it has a horizontal format.
    if boundingWidth > boundingHeight and width <= boundingWidth then
      newRoot = oldRoot:expandBottom(width, height)
    else
      newRoot = oldRoot:expandRight(width, height)
    end
    self._root = newRoot
    self._hasGrown = true
  else
    err = "Rectangles are required to be less wide or less tall than the container"
  end

  return newRoot, err
end

return Container