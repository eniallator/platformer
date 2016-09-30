love.graphics.setDefaultFilter("nearest", "nearest")

local function updateInternalWindowSize()
  screenDim.x, screenDim.y = love.graphics.getDimensions()
  blockSize = screenDim.y/20
end

function love.load()
  screenDim = {}
  updateInternalWindowSize()

  defaultMaps = require "lib/defaultMaps"
  optionData = require "lib/optionData"
  collision = require "lib/collision"
  utilsData = require "lib/utilsData"
  display = require "lib/display"
  update = require "lib/update"
  entity = require "lib/entity"
  map = require "lib/map"
  dropMenu = require "lib/utils/dropMenu"
  textBox = require "lib/utils/textBox"
  alert = require "lib/utils/alert"
  mouse = require "lib/utils/mouse"
  keys = require "lib/utils/keys"

  display.loadTextures()
  textBox.reset()

  mapCreatorScrollSpeed = 5
  blocks = {
    {name = "stone", solid = true},
    {name = "dirt", solid = true},
    {name = "grass", solid = true},
    {name = "sand", solid = true},
    {name = "lava", kill = true, dim = {w = 20, h = 8}, offSet = {x = 0, y = 2}, bigTexture = true}
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

function love.resize(w, h)
  entity.player.pos.y = entity.player.pos.y *h /screenDim.y
  entity.player.pos.x = entity.player.pos.x *(h /20 /(screenDim.y /20))

  updateInternalWindowSize()
end

function love.keypressed(key)
  keys.updateState(key, true)
end

function love.keyreleased(key)
  keys.updateState(key, false)
end

function love.update()
  love.mouse.setCursor()
  mouse.updateState()

  if utilsData.textBox.selected then
    textBox.getInput(utilsData.textBox[utilsData.textBox.selected])

    if utilsData.alert.selected then
      local currAlert = utilsData.alert[utilsData.alert.selected]
      alert.getInput(currAlert.buttons, currAlert.dimensions)
    end

  elseif utilsData.dropMenu.selected then
    dropMenu.getInput(utilsData.dropMenu[utilsData.dropMenu.selected], utilsData.dropMenu.mapName)

  elseif selected == "game" then
    if not escMenuOn then
      entity.player.update()
      update.camera()
    end

    update.escMenu()

  elseif selected == "menu" then
    local menuDisplayed = optionData[currMenu].display()
    local clickedBox = collision.clickBox(menuDisplayed)
    local rightClickedBox = collision.rightClickBox(menuDisplayed)

    if clickedBox then
      optionData[currMenu].funcs[clickedBox](menuDisplayed[clickedBox])

    elseif rightClickedBox and currMenu == "play" then
      optionData[currMenu].funcs[rightClickedBox](menuDisplayed[rightClickedBox], true)
    end

    collision.updateMouseCursor(menuDisplayed)

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

  elseif utilsData.dropMenu.selected then
    if not utilsData.dropMenu.coords then
      utilsData.dropMenu.coords = {}
      utilsData.dropMenu.coords.x, utilsData.dropMenu.coords.y = love.mouse.getPosition()
    end

    display.background()

    for _, box in pairs(optionData[currMenu].display()) do
      display.box(box)
    end

    dropMenu.display(utilsData.dropMenu[utilsData.dropMenu.selected], utilsData.dropMenu.coords)

  elseif selected == "game" then
    love.graphics.setColor(255, 255, 255)
    display.background()
    entity.player.display()
    display.map()
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

      collision.updateMouseCursor(blockMenuTable)
    end

    display.escMenu()
  end
end
