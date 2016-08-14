love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
  collision = require "lib/collision"
  display = require "lib/display"
  update = require "lib/update"
  map = require "lib/map"

  texture = {
    player = {
      still = love.graphics.newImage("assets/textures/player/player.still.png"),
      glide = love.graphics.newImage("assets/textures/player/player.glide.png"),

      sprint = {
        love.graphics.newImage("assets/textures/player/player.sprint.1.png"),
        love.graphics.newImage("assets/textures/player/player.sprint.2.png")
      }
    },

    block = {
      stone = love.graphics.newImage("assets/textures/blocks/stone.png"),
    },

    other = {
      background = love.graphics.newImage("assets/textures/other/background.png")
    }
  }

  screenDim = {}
  screenDim.x, screenDim.y = love.graphics.getDimensions()
  player = {pos = {x = 1, y = 1}, vel = {x = 0, y = 0}, col = {r = 0, g = 0, b = 255}, w = 16, h = 32}
  lastDir = "r"
  xCounter = 0
  moveSpeed = 0.8
  jumpHeight = -5
  gravity = 3
  drag = 0.93
  blockSize = screenDim.y/20
  blocks = {stone = {solid = true}}
  formattedMap = {x10y16 = {block = "stone", w = 8, h = 1}, x5y6 = {block = "stone", w = 2, h = 2}, x21y6 = {block = "stone", w = 2, h = 2}, x10y20 = {block = "stone", w = 4, h = 1}}
  map.makeGrid()
end

function love.update()
  update.velocity()
  update.position()
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(texture.other.background, 0, 0, 0, screenDim.x /texture.other.background:getWidth(), screenDim.y /texture.other.background:getHeight())
  -- love.graphics.setColor(50, 70, 80)
  display.player()
  display.map()
end
