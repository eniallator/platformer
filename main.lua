love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
  screenDim = {}
  screenDim.x, screenDim.y = love.graphics.getDimensions()

  optionData = require "lib/optionData"
  collision = require "lib/collision"
  display = require "lib/display"
  update = require "lib/update"
  utils = require "lib/utils"
  map = require "lib/map"

  display.loadTextures()

  player = {pos = {x = 1, y = 1}, vel = {x = 0, y = 0}, w = 16, h = 32}
  moveSpeed = 0.3
  jumpHeight = -5
  gravity = 3
  drag = 0.96
  friction = 0.93
  mapCreatorScrollSpeed = 5
  blockSize = screenDim.y/20
  blocks = {
    {name = "stone", solid = true},
    {name = "dirt", solid = true},
    {name = "grass", solid = true},
    {name = "sand", solid = true}
  }
  formattedMap = {x1y19 = {block = "stone", w = 16, h = 2}, x2y17 = {block = "sand", w = 14, h = 2}, x3y15 = {block = "dirt", w = 12, h = 2}, x4y13 = {block = "grass", w = 10, h = 2}}
  map.makeGrid(256, screenDim.y/blockSize)
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

function love.keypressed(key)
  if key == "capslock" then
    utils.keys.capslock = not utils.keys.capslock

  else
    utils.textBox.currChar = key
    utils.keys[key] = true
  end
end

function love.keyreleased(key)
  if key ~= "capslock" then
    if utils.textBox.currChar == key then
      utils.textBox.currChar = nil
    end

    utils.keys[key] = false
  end
end

function love.update()
  if utils.textBox.selected then
    utils.textBox.getInput()

  elseif selected == "game" then
    if not escMenuOn then

      update.velocity()
      update.position()
      update.camera()
    end

    update.escMenu()

  elseif selected == "menu" then
    local menuDisplayed = optionData[currMenu].display()
    local clickedBox = collision.clickBox(menuDisplayed)

    if clickedBox then
      optionData[currMenu].funcs[clickedBox](menuDisplayed[clickedBox])
    end

  elseif selected == "createMap" then
    update.mapCreatorPos()
    update.mapCreatorBlockMenu()

    if mapCreatorMenu then
      local blockMenuTable = optionData.blockMenu.display()
      local blockClicked = collision.clickBox(blockMenuTable)

      if blockClicked == "prevPage" or blockClicked == "nextPage" then
        optionData.blockMenu.funcs[blockClicked]()

      elseif blockClicked then
        selectedBlockIndex = blockMenuTable[blockClicked].blockIndex
        firstLoad = true
      end
    end

    update.escMenu()
    update.mapCreatorinteract()
  end
end

function love.draw()
  love.graphics.translate(cameraTranslation, 0)

  if utils.textBox.selected then
    display.background()

    if utils.textBox.selected == "saveMap" then
      display.map()
    end

    local currTextBox = utils.textBox.type[utils.textBox.selected]
    utils.textBox.display(currTextBox.title, utils.textBox.currText, currTextBox.x, currTextBox.y, currTextBox.w, currTextBox.h)

  elseif selected == "game" then
    love.graphics.setColor(255, 255, 255)
    display.background()
    display.map()
    display.player()
    display.escMenu()

  elseif selected == "menu" then
    display.background()
    for _, box in pairs(optionData[currMenu].display()) do

      display.box(box)
    end

  elseif selected == "createMap" then
    display.background()
    display.map()

    if mapCreatorMenu then
      local blockMenuTable = optionData.blockMenu.display()

      for i=1, #blockMenuTable do
        local currBlock = blockMenuTable[i]
        love.graphics.draw(currBlock.texture, currBlock.x -cameraTranslation, currBlock.y, 0, blockSize /currBlock.texture:getWidth(), blockSize /currBlock.texture:getHeight())
      end
    end

    display.escMenu()
  end
end
