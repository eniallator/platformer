love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
  optionData = require "lib/optionData"
  collision = require "lib/collision"
  display = require "lib/display"
  update = require "lib/update"
  map = require "lib/map"

  display.loadTextures()

  screenDim = {}
  screenDim.x, screenDim.y = love.graphics.getDimensions()
  player = {pos = {x = 1, y = 1}, vel = {x = 0, y = 0}, w = 16, h = 32}
  moveSpeed = 0.3
  jumpHeight = -5
  gravity = 3
  drag = 0.96
  friction = 0.93
  blockSize = screenDim.y/20
  blocks = {{name = "stone", solid = true}, {name = "dirt", solid = true}, {name = "grass", solid = true}, {name = "sand", solid = true}}
  formattedMap = {x1y19 = {block = "stone", w = 16, h = 2}, x2y17 = {block = "sand", w = 14, h = 2}, x3y15 = {block = "dirt", w = 12, h = 2}, x4y13 = {block = "grass", w = 10, h = 2}}
  map.makeGrid()
  cameraTranlation = 0
  selected = "menu"
  currMenu = "main"

  love.graphics.setFont(love.graphics.newFont(screenDim.x/40))

  -- map.writeTable(formattedMap, "testMap.txt")
  -- formattedMap = map.readTable("testMap.txt")
  -- Testing if writing then reading files works and it does
end

function love.update()
  if selected == "game" then
    update.velocity()
    update.position()
    update.camera()

  elseif selected == "menu" then
    local menuDisplayed = optionData[currMenu].display()
    local clickedBox = collision.clickBox(menuDisplayed)

    if clickedBox then
      optionData[currMenu].funcs[clickedBox](menuDisplayed[clickedBox])
      debug = menuDisplayed[clickedBox].name
    end
  end
end

function love.draw()
  if selected == "game" then
    love.graphics.translate(cameraTranlation, 0)
    love.graphics.setColor(255, 255, 255)
    display.background()
    display.map()
    display.player()

  elseif selected == "menu" then
    display.background()
    for _, box in pairs(optionData[currMenu].display()) do

      display.box(box)
    end
  end
end
