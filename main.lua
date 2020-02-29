-- LÖVE binpack demo script.

local binpack = require "binpack"

local container
local glyphs = {}

local function rgba(r, g, b, a)
  return {r / 255, g / 255, b / 255, a or 1}
end

local function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

local white = {1, 1, 1, 1}
local colors = {
  rgba(0, 116, 217),
  rgba(57, 204, 204),
  rgba(61, 153, 112),
  rgba(46, 204, 64),
  rgba(255, 133, 27),
  rgba(255, 65, 54),
  rgba(133, 20, 75),
  rgba(177, 13, 201)
}

function love.load()
  -- We use a queue here to insert the font glyphs into the container sorted
  -- by their size. This achieves far better results than inserting them in
  -- random order but is purely optional. You can also just insert the glyphs
  -- into the container directly.
  local queue = binpack.newQueue()
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!?0123456789"
  -- Shuffle the fonts to demonstrate that the queue does its job.
  local fontlist = shuffle{
    love.graphics.newFont("demo/Kreon-Regular.ttf", 60),
    love.graphics.newFont("demo/Kreon-Regular.ttf", 48),
    love.graphics.newFont("demo/Kreon-Regular.ttf", 24),
    love.graphics.newFont("demo/Kreon-Regular.ttf", 20),
    love.graphics.newFont("demo/Kreon-Regular.ttf", 14)
  }
  
  for i = 1, #fontlist do
    for j = 1, #chars do
      local c = chars:sub(j, j)
      queue:enqueue(
        fontlist[i]:getWidth(c),
        fontlist[i]:getHeight(),
        {font = fontlist[i], char = c}
      )
    end
  end

  container = binpack.newContainer(512, 256)
  queue:insertInto(container)
end
 
function love.draw()
  local color = 0
  
  for index = 1, container:getCellCount() do
    local x, y = container:getCellPosition(index)
    local w, h = container:getCellSize(index)
    local bx, by, bw, bh = container:getCellBoundings(index)
    local data = container:getCellData(index)
    
    love.graphics.setColor(colors[color + 1])
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(white)
    love.graphics.setFont(data.font)
    love.graphics.print(data.char, x, y)
    
    color = (color + 1) % #colors
  end
end