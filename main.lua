love.graphics.setDefaultFilter("nearest", "nearest")

local function updateInternalWindowSize(w, h)
  if w/h == aspectRatio then
    borders = {x = 0, y = 0}

  elseif w/h > aspectRatio then
    borders.x = (w -(h *aspectRatio))
    borders.y = 0

  else
    borders.y = (h -(w /aspectRatio))
    borders.x = 0
  end

  screenDim.x, screenDim.y = w -borders.x +1, h -borders.y
  blockSize = screenDim.y/20
  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x/40))
end

function love.load()
  screenDim = {}
  aspectRatio = 4/3
  updateInternalWindowSize(800, 600)

  defaultMaps = require "lib/defaultMaps"
  optionData = require "lib/optionData"
  collision = require "lib/collision"
  utilsData = require "lib/utilsData"
  display = require "lib/display"
  update = require "lib/update"
  entity = require "lib/entity"
  controls = require "lib/controls"
  map = require "lib/map"
  dropMenu = require "lib/utils/dropMenu"
  textBox = require "lib/utils/textBox"
  alert = require "lib/utils/alert"
  mouse = require "lib/utils/mouse"
  keys = require "lib/utils/keys"

  display.loadTextures()
  textBox.reset()
  update.forces()
  controls.loadControls()

  mapCreatorScrollSpeed = 5
  blocks = {
    {name = "stone", solid = true},
    {name = "dirt", solid = true},
    {name = "grass", solid = true},
    {name = "sand", solid = true},
    {name = "wood", solid = true},
    {name = "brick", solid = true},
    {name = "lava", kill = true, dim = {w = 20, h = 8}, offSet = {x = 0, y = 2}, bigTexture = true},
    {name = "spawnPoint", spawnPoint = true},
    {name = "checkPoint", checkPoint = true},
    {name = "goal", goal = true, scale = 0.5, dim = {w = 8, h = 19}, offSet = {x = 1, y = 1}}
  }
  cameraTranslation = 0
  selected = "menu"
  currMenu = "main"
  mapExtension = ".map"
  timeCounter = 0

  if not love.filesystem.isDirectory("maps") then
    love.filesystem.createDirectory("maps")
  end

  for name,mapData in pairs(defaultMaps) do
    if not love.filesystem.exists("maps/" .. name .. mapExtension) then
      map.writeTable(mapData, "maps/" .. name .. mapExtension)
    end
  end
end

function love.resize(w, h)
  entity.player.pos.y = entity.player.pos.y *h /screenDim.y
  entity.player.pos.x = entity.player.pos.x *(h /20 /(screenDim.y /20))

  updateInternalWindowSize(w, h)
  update.forces()
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
  controls.getKeyInput()

  if utilsData.textBox.selected then
    textBox.getInput(utilsData.textBox[utilsData.textBox.selected])

    if utilsData.alert.selected then
      local currAlert = utilsData.alert[utilsData.alert.selected]
      alert.getInput(currAlert.buttons, currAlert.dimensions())
    end

  elseif utilsData.dropMenu.selected then
    dropMenu.getInput(utilsData.dropMenu[utilsData.dropMenu.selected], utilsData.dropMenu.mapName)

  elseif selected == "game" then
    if not reachedGoal then
      if not escMenuOn then
        entity.player.update()
        update.camera()
        timeCounter = timeCounter + 1
      end

      update.escMenu()

    else
      update.winMenu()
    end

  elseif selected == "menu" then
    local menuDisplayed = optionData[currMenu].display()
    local clickedBox = collision.clickBox(menuDisplayed, true)
    local rightClickedBox = collision.rightClickBox(menuDisplayed, true)
    collision.updateMouseCursor(menuDisplayed, true)

  if clickedBox then
      optionData[currMenu].funcs[clickedBox](menuDisplayed[clickedBox])

    elseif rightClickedBox and currMenu == "play" then
      optionData[currMenu].funcs[rightClickedBox](menuDisplayed[rightClickedBox], true)
    end

  elseif selected == "createMap" then
    update.mapCreatorPos()
    update.mapCreatorBlockMenu()

    if mapCreatorMenu then
      local blockMenuTable = optionData.blockMenu.display()
      local blockClicked = collision.clickBox(blockMenuTable)
      collision.updateMouseCursor(blockMenuTable)

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
  love.graphics.translate(cameraTranslation +borders.x /2, borders.y /2)
  newTick = true

  if screenRed and screenRed < 255 then
    screenRed = screenRed + 3

  else
    screenRed = 255
  end

  love.graphics.setColor(255, screenRed, screenRed)

  if utilsData.textBox.selected then
    display.background()

    if utilsData.textBox.selected == "saveMap" then
      display.map()
    end

    local currTextBox = utilsData.textBox[utilsData.textBox.selected]
    textBox.display(currTextBox.title, textBox.currText, currTextBox.dimensions())

    if utilsData.alert.selected then
      local currAlert = utilsData.alert[utilsData.alert.selected]
      alert.display(currAlert.message, currAlert.buttons, currAlert.dimensions())
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
    display.background()
    entity.player.display()
    display.map()
    display.timeCounter()
    display.escMenu()
    display.winMenu()

  elseif selected == "menu" then
    display.background()

    for _, box in pairs(optionData[currMenu].display()) do
      display.box(box)
    end

  elseif selected == "createMap" then
    display.background()
    display.map()
    display.blockMenu()
    display.escMenu()
  end

  if borders.x > 0 then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", -cameraTranslation +screenDim.x , 0, borders.x /2, screenDim.y)
    love.graphics.rectangle("fill", -cameraTranslation -borders.x /2, 0, borders.x /2, screenDim.y)
  end
end
