function love.load()
  collision = require "lib/collision"
  display = require "lib/display"
  update = require "lib/update"
  map = require "lib/map"

  screenDim = {}
  screenDim.x, screenDim.y = love.graphics.getDimensions()
  player = {pos = {x = 1, y = 1}, vel = {x = 0, y = 0}, col = {r = 0, g = 0, b = 255}, w = 20, h = 20}
  moveSpeed = 0.8
  jumpHeight = -5
  gravity = 3
  drag = 0.93
  blockSize = screenDim.y/20
  blocks = {stone = {col = {r = 150, b = 150, g = 150}, solid = true}}
  formattedMap = {x10y16 = {block = "stone", w = 8, h = 1}, x5y6 = {block = "stone", w = 2, h = 2}, x21y6 = {block = "stone", w = 2, h = 2}, x10y20 = {block = "stone", w = 4, h = 1}}
  map.makeGrid()
end

function love.update()
  update.velocity()
  update.position()
end

function love.draw()
  love.graphics.setColor(player.col.r, player.col.g, player.col.b)
  love.graphics.rectangle("fill", player.pos.x, player.pos.y, player.w, player.h)
  display.map()
end
