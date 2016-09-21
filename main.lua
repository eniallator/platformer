love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
  screenDim = {}
  screenDim.x, screenDim.y = love.graphics.getDimensions()

  defaultMaps = require "lib/defaultMaps"
  optionData = require "lib/optionData"
  textBox = require "lib/utils/textBox"
  collision = require "lib/collision"
  utilsData = require "lib/utilsData"
  alert = require "lib/utils/alert"
  display = require "lib/display"
  keys = require "lib/utils/keys"
  update = require "lib/update"
  map = require "lib/map"

  display.loadTextures()
  textBox.reset()

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
  cameraTranslation = 0
  selected = "menu"
  currMenu = "main"
  mapExtension = ".map"

  if not love.filesystem.isDirectory("maps") then
    love.filesystem.createDirectory("maps")
  end

  for name,mapData in pairs(defaultMaps) do
    if not love.filesystem.exists("maps/" .. name .. mapExtension) then
      map.writeTable(mapData, "maps/" .. name .. mapExtension)
    end
  end

  love.graphics.setFont(love.graphics.newFont(screenDim.x/40))
end

function love.keypressed(key)
  if key == "capslock" then
    keys.capslock = not keys.capslock

  else
    textBox.currChar = key
    keys[key] = true

    if key == "escape" and selected ~= "menu" then
      escPressed = true
    end
  end
end

function love.keyreleased(key)
  if key ~= "capslock" then
    if textBox.currChar == key then
      textBox.currChar = nil
    end

    keys[key] = false
  end
end

function love.update()
  if utilsData.textBox.selected then
    textBox.getInput(utilsData.textBox[utilsData.textBox.selected])

    if utilsData.alert.selected then
      local currAlert = utilsData.alert[utilsData.alert.selected]
      alert.getInput(currAlert.buttons, currAlert.dimensions)
    end

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

  if utilsData.textBox.selected then
    display.background()

    if utilsData.textBox.selected == "saveMap" then
      display.map()
    end

    local currTextBox = utilsData.textBox[utilsData.textBox.selected]
    textBox.display(currTextBox.title, textBox.currText, currTextBox.dimensions)

    if utilsData.alert.selected then
      local currAlert = utilsData.alert[utilsData.alert.selected]
      alert.display(currAlert.message, currAlert.buttons, currAlert.dimensions)
    end

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
