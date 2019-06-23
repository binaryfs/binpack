---
-- Return a new cell.
--
-- Parameters:
-- left   - Position along x-axis
-- top    - Position along y-axis
-- width  - Initial width
-- height - Initial height
--
-- Returns:
-- cell object
local function newCell(left, top, width, height)
  return {
    left = left,
    top = top,
    width = width,
    height = height,
    -- Left or right child cell.
    firstChild = false,
    -- Top or bottom child cell.
    secondChild = false,
    -- The cell's width plus the boundingWidth of its first child.
    boundingWidth = width,
    -- The cell's height plus the boundingHeight of its second child.
    boundingHeight = height,
    data = nil
  }
end

---
-- Find a cell large enough for the specified rectangle.
--
-- The search is performed recursively in the given cell and its descendants.
--
-- Parameters:
-- cell   - The cell to check
-- width  - The rectangle's width
-- height - The rectangle's height
--
-- Returns:
-- 1. - A fitting cell or nil if the search fails
-- 2. - Error message if the search fails
local function searchFittingCell(cell, width, height)
  local emptyCell, err

  if width <= cell.boundingWidth and height <= cell.boundingHeight then
    local isOccupied = not not cell.firstChild
    if isOccupied then
      emptyCell, err = searchFittingCell(cell.firstChild, width, height) or
        searchFittingCell(cell.secondChild, width, height)
    else
      emptyCell = cell
    end
  else
    err = "Rectangle does not fit in any cell"
  end

  return emptyCell, err
end

--- 
-- Split a cell along the edges of the specified rectangle.
--
-- The new cells that emerge from the split become children of the original cell.
--
-- Parameters:
-- cell   - The cell to split
-- width  - The rectangle's width
-- height - The rectangle's height
local function splitCell(cell, width, height)
  local remainingWidth = cell.width - width
  local remainingHeight = cell.height - height

  -- Split along the shorter edge of the remaining space.
  if remainingWidth <= remainingHeight then
    cell.firstChild = newCell(cell.left + width, cell.top, remainingWidth, height)
    cell.secondChild = newCell(cell.left, cell.top + height, cell.width, remainingHeight)
  else
    cell.firstChild = newCell(cell.left + width, cell.top, remainingWidth, cell.height)
    cell.secondChild = newCell(cell.left, cell.top + height, width, remainingHeight)
  end

  cell.width = width
  cell.height = height
end

---
-- Expand a cell tree to the right to contain the specified rectangle.
--
-- Parameters:
-- root   - The root cell of the tree
-- width  - The rectangle's width
-- height - The rectangle's height
--
-- Returns:
-- The new root cell of the tree
local function expandRight(root, width, height)
  local newRoot = newCell(root.boundingWidth, 0, width, height)
  newRoot.firstChild = root
  newRoot.secondChild = newCell(root.boundingWidth, height, width, root.boundingHeight - height)
  newRoot.boundingWidth = root.boundingWidth + width
  newRoot.boundingHeight = root.boundingHeight
  return newRoot
end

---
-- Expand a cell tree to the bottom to contain the specified rectangle.
--
-- Parameters:
-- root   - The root cell of the tree
-- width  - The rectangle's width
-- height - The rectangle's height
--
-- Returns:
-- The new root cell of the tree
local function expandBottom(root, width, height)
  local newRoot = newCell(0, root.boundingHeight, width, height)
  newRoot.firstChild = newCell(width, root.boundingHeight, root.boundingWidth - width, height)
  newRoot.secondChild = root
  newRoot.boundingWidth = root.boundingWidth
  newRoot.boundingHeight = root.boundingHeight + height
  return newRoot
end

return {
  newCell = newCell,
  searchFittingCell = searchFittingCell,
  splitCell = splitCell,
  expandRight = expandRight,
  expandBottom = expandBottom
}