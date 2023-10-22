# lua-binpack
A simple 2D bin packing module for Lua and LuaJIT.

It packs different-sized rectangles into a rectangular container of either fixed or dynamic size. This particular implementation solves the online variant of the bin packing problem where rectangles are inserted one at a time in random order.

You can use this module, for example, to generate texture atlases. It is fast enough to be used in realtime applications (with LuaJIT).

Even though lua-binpack was originally developed to be used in [LÖVE](https://love2d.org/)-based projects, it doesn't depend on LÖVE.

## Example

In the following example the bin packing module was used to render glyphs of the [Kreon font](https://www.fontsquirrel.com/fonts/kreon) into an image.

![Glyphs example image](demo/example-glyphs.png?raw=true)

## Usage

Include the module, create a container and insert some rectangles:

```lua
local binpack = require "binpack"

local container = binpack.newContainer(512, 512)

local rectangles = {
  {128, 128},
  {64, 64},
  {64, 32},
  {16, 16}
}

for i = 1, #rectangles do
  local index, err = container:insert(unpack(rectangles[i]))
  if index then
    print("Rectangle inserted at:", container:getCell(index):getPosition())
    if container:hasGrown() then
      print("Container had to grow to contain the rectangle")
    end
  else
    print("Insertion failed: " .. err)
  end
end
```

Use a queue to insert the rectangles in a certain order, e.g. sorted by size (the default). This achieves better results than inserting them in random order:

```lua
local queue = binpack.newQueue()
local rectangles = {}

-- Generate some random sized rectangles.
-- The queue will sort them automatically.
for i = 1, 10 do
  rectangles[#rectangles + 1] = {
    math.random(30, 100),
    math.random(30, 100)
  }
end

for i = 1, #rectangles do
  queue:add(unpack(rectangles[i]))
end

queue:insertInto(container, function(container, index, err)
  if index then
    print("Rectangle inserted at:", container:getCell(index):getPosition())
  else
    print("Insertion failed: " .. err)
  end
end)
```

Draw the rectangles from a container with LÖVE (or any other framework):

```Lua
local colors = {
  {1, 0, 0, 1},
  {0, 1, 0, 1},
  {0, 0, 1, 1}
}
 
function love.draw()
  local color = 0
  
  for _, cell in container:cells() do
    local x, y = cell:getPosition()
    local w, h = cell:getSize()
    
    love.graphics.setColor(colors[color + 1])
    love.graphics.rectangle("fill", x, y, w, h)

    color = (color + 1) % #colors
  end
end
```

## License

Source code: MIT License (see LICENSE file in project root)

Kreon font by Julia Petretta (used in the LÖVE demo script): SIL Open Font License