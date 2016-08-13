function love.load()
  display = require "lib/display"
  update = require "lib/update"

  screenDim = {}
  screenDim.x, screenDim.y = love.graphics.getDimensions()
  player = {pos = {x = 1, y = 1}, vel = {x = 0, y = 0}, col = {r = 0, g = 0, b = 255}}
  moveSpeed = 0.8
  jumpHeight = -5
  gravity = 3
  drag = 0.93
  blockSize = screenDim.y/20
  blocks = {stone = {r = 150, b = 150, g = 150}}
  map = {x10y16 = {block = "stone", w = 8, h = 1}, x5y6 = {block = "stone", w = 2, h = 2}, x21y6 = {block = "stone", w = 2, h = 2}}
end

function love.update()
  update.velocity()
  update.position()
end

function love.draw()
  love.graphics.setColor(player.col.r, player.col.g, player.col.b)
  love.graphics.rectangle("fill", player.pos.x, player.pos.y, 20, 20)
  display.map()
end
