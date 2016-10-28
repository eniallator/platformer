love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
  screenDim = {}
  aspectRatio = 4/3

  defaultMaps = require "lib/defaultMaps"
  optionData = require "lib/optionData"
  collision = require "lib/collision"
  utilsData = require "lib/utilsData"
  display = require "lib/display"
  credits = require "lib/credits"
  update = require "lib/update"
  entity = require "lib/entity"
  controls = require "lib/controls"
  map = require "lib/map"
  textBox = require "lib/utils/textBox"
  alert = require "lib/utils/alert"
  mouse = require "lib/utils/mouse"
  keys = require "lib/utils/keys"

  update.internalWindowSize(800, 600)
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

  map.syncDefaultMaps()
end

function love.resize(w, h)
  entity.player.pos.y = entity.player.pos.y *h /screenDim.y
  entity.player.pos.x = entity.player.pos.x *(h /20 /(screenDim.y /20))

  update.internalWindowSize(w, h)
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
  update.alert()

  if utilsData.textBox.selected then
    update.textBox()

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
    credits.update()
    update.optionMenu()

  elseif selected == "createMap" then
    update.mapCreatorPos()
    update.mapCreatorBlockMenu()
    update.selectedMapCreatorBlock()
    update.escMenu()
    update.mapCreatorinteract()
  end
end

function love.draw()
  love.graphics.translate(cameraTranslation +borders.x /2, borders.y /2)
  newTick = true
  display.makeScreenRed()

  if utilsData.textBox.selected then
    display.textBox()

  elseif selected == "game" then
    display.background()
    entity.player.display()
    display.map()
    display.timeCounter()
    display.escMenu()
    display.winMenu()

  elseif selected == "menu" then
    display.background()
    credits.display()
    display.optionMenu()

  elseif selected == "createMap" then
    display.background()
    display.map()
    display.blockMenu()
    display.escMenu()
  end

  display.alert()
  display.borders()
end
