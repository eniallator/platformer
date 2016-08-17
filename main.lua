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
  cameraTranslation = 0
  selected = "menu"
  currMenu = "main"
  mapExtension = ".map"

  if not love.filesystem.isDirectory("maps") then
    love.filesystem.createDirectory("maps")
  end
  
  map.writeTable(formattedMap, "maps/devMap" .. mapExtension)
  love.graphics.setFont(love.graphics.newFont(screenDim.x/40))
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

  elseif selected == "createMap" then
    update.mapCreatorPos()
    update.mapCreatorinteract()

  end
end

function love.draw()
  if selected == "game" then
    love.graphics.translate(cameraTranslation, 0)
    love.graphics.setColor(255, 255, 255)
    display.background()
    display.map()
    display.player()

  elseif selected == "menu" then
    display.background()
    for _, box in pairs(optionData[currMenu].display()) do

      display.box(box)
    end

  elseif selected == "createMap" then
    love.graphics.translate(cameraTranslation, 0)
    display.background()
    display.map()
  end
end
