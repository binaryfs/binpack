--- Represents a spatial cell of a bin packing container.
--- @class binpack.Cell
--- @field protected _left integer Horizontal position of upper left corner
--- @field protected _top integer Vertical position of upper left corner
--- @field protected _width integer
--- @field protected _height integer
--- @field protected _padding integer Pading around cell content
--- @field protected _firstChild binpack.Cell? Left or right child cell
--- @field protected _secondChild binpack.Cell? Top or bottom child cell
--- @field protected _boundingWidth integer Cell width plus boundingWidth of its first child
--- @field protected _boundingHeight integer Cell height plus boundingHeight of its first child
--- @field protected _data any
local Cell = {}
Cell.__index = Cell

--- @param left integer Horizontal position of upper left corner
--- @param top integer Vertical position of upper left corner
--- @param width integer Initial width
--- @param height integer Initial height
--- @param padding integer Padding around cell content
--- @return binpack.Cell
--- @nodiscard
function Cell.new(left, top, width, height, padding)
  return setmetatable({
    _left = left,
    _top = top,
    _width = width,
    _height = height,
    _boundingWidth = width,
    _boundingHeight = height,
    _padding = padding,
    _data = nil,
    _firstChild = nil,
    _secondChild = nil,
  }, Cell)
end

--- Get the position of the cell's upper left corner.
--- @return integer left
--- @return integer top
--- @nodiscard
--- @see binpack.Cell.getContentPosition
function Cell:getPosition()
  return self._left, self._top
end

--- Get the position of the cell's padded content.
---
--- If no padding is set, this function returns the same value as `Cell.getPosition`.
--- @return integer left
--- @return integer top
--- @nodiscard
--- @see binpack.Cell.getPosition
function Cell:getContentPosition()
  return self._left + self._padding, self._top + self._padding
end

--- Get the width and height of the cell, including padding.
---
--- A cell has the same size as the rectangle that was inserted into it, plus padding.
--- @return integer width
--- @return integer height
--- @nodiscard
--- @see binpack.Cell.getContentSize
function Cell:getSize()
  return self._width, self._height
end

--- Get the width and height of the cell, excluding padding.
---
--- If no padding is set, this function returns the same size as `Cell.getSize`.
--- @return integer width
--- @return integer height
--- @nodiscard
--- @see binpack.Cell.getSize
function Cell:getContentSize()
  return self._width - self._padding * 2, self._height - self._padding * 2
end

--- Get the width and height of the bounding rectangle.
--- @return integer boundingWidth
--- @return integer boundingHeight
--- @nodiscard
function Cell:getBoundingSize()
  return self._boundingWidth, self._boundingHeight
end

--- Return a bounding rectangle that encloses the cell and its descendants.
--- @return integer left Horizontal position of rectangle's upper left corner
--- @return integer top Vertical position of rectangle's upper left corner
--- @return integer width Rectangle width
--- @return integer height Rectangle height
--- @nodiscard
function Cell:getBoundingRect()
  local left, top = self._left, self._top
  -- Does the cell have a top child?
  if self._firstChild and self._firstChild._left < left then
    left = left - self._firstChild._boundingWidth
  end
  -- Does the cell have a left child?
  if self._secondChild and self._secondChild._top < top then
    top = top - self._secondChild._boundingHeight
  end
  return left, top, self._boundingWidth, self._boundingHeight
end

--- @return integer padding
--- @nodiscard
function Cell:getPadding()
  return self._padding
end

--- @return any data
--- @nodiscard
function Cell:getData()
  return self._data
end

--- @param data any
function Cell:setData(data)
  self._data = data
end

--- Find a cell large enough for the specified rectangle.
--- The search is performed recursively in this cell and its descendants.
--- @param width integer Rectangle width
--- @param height integer Rectangle height
--- @return binpack.Cell? cell A fitting cell or nil if no cell is found
--- @return string? error Error message if no cell is found
--- @nodiscard
function Cell:searchFittingCell(width, height)
  local emptyCell, err

  if width <= self._boundingWidth and height <= self._boundingHeight then
    local isOccupied = self._firstChild ~= nil

    if isOccupied then
      emptyCell, err = self._firstChild:searchFittingCell(width, height)

      if not emptyCell then
        emptyCell, err = self._secondChild:searchFittingCell(width, height)
      end
    else
      emptyCell = self
    end
  else
    err = "Rectangle does not fit in any cell"
  end

  return emptyCell, err
end

--- Split a cell along the edges of the specified rectangle.
--- The new cells that emerge from the split become children of the original cell.
--- @param width integer Rectangle width
--- @param height integer Rectangle height
function Cell:splitCell(width, height)
  local remainingWidth = self._width - width
  local remainingHeight = self._height - height

  -- Split along the shorter edge of the remaining space.
  if remainingWidth <= remainingHeight then
    self._firstChild = Cell.new(
      self._left + width, self._top, remainingWidth, height, self._padding
    )
    self._secondChild = Cell.new(
      self._left, self._top + height, self._width, remainingHeight, self._padding
    )
  else
    self._firstChild = Cell.new(
      self._left + width, self._top, remainingWidth, self._height, self._padding
    )
    self._secondChild = Cell.new(
      self._left, self._top + height, width, remainingHeight, self._padding
    )
  end

  self._width = width
  self._height = height
end

--- Expand a cell tree to the right to contain the specified rectangle.
--- @param width integer Rectangle width
--- @param height integer Rectangle height
--- @return binpack.Cell newRoot The new root cell of the tree
--- @nodiscard
function Cell:expandRight(width, height)
  local newRoot = Cell.new(self._boundingWidth, 0, width, height, self._padding)
  newRoot._firstChild = self
  newRoot._secondChild = Cell.new(
    self._boundingWidth, height, width, self._boundingHeight - height, self._padding
  )
  newRoot._boundingWidth = self._boundingWidth + width
  newRoot._boundingHeight = self._boundingHeight
  return newRoot
end

--- Expand a cell tree to the bottom to contain the specified rectangle.
--- @param width integer Rectangle width
--- @param height integer Rectangle height
--- @return binpack.Cell newRoot The new root cell of the tree
--- @nodiscard
function Cell:expandBottom(width, height)
  local newRoot = Cell.new(0, self._boundingHeight, width, height, self._padding)
  newRoot._firstChild = Cell.new(
    width, self._boundingHeight, self._boundingWidth - width, height, self._padding
  )
  newRoot._secondChild = self
  newRoot._boundingWidth = self._boundingWidth
  newRoot._boundingHeight = self._boundingHeight + height
  return newRoot
end

return Cell