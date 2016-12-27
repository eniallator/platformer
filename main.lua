function love.load()
  screenDim = {}
  aspectRatio = 4/3
  love.graphics.setDefaultFilter("nearest", "nearest")
  isSmartPhone = love._os == "Android" or love._os == "iOS"
  update = require "lib/update"
  debugMode = false

  update.internalWindowSize(love.graphics.getDimensions())

  defaultMaps = require "lib/defaultMaps"
  optionData = require "lib/optionData"
  collision = require "lib/collision"
  utilsData = require "lib/utilsData"
  controls = require "lib/controls"
  display = require "lib/display"
  credits = require "lib/credits"
  entity = require "lib/entity"
  debug = require "lib/debug"
  map = require "lib/map"
  textBox = require "lib/utils/textBox"
  alert = require "lib/utils/alert"
  mouse = require "lib/utils/mouse"
  keys = require "lib/utils/keys"

  display.loadTextures()
  textBox.reset()
  update.forces()
  controls.loadControls()

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

function love.textinput(text)
  keys.textInput = text
end

function love.mousepressed(x, y, button, isTouch)
  mouse.updateState(true, x, y, button)
end

function love.mousereleased(x, y, button, isTouch)
  mouse.updateState(false, x, y, button)
end

function love.update()
  debug.initTimes()

  if not isSmartPhone then
    love.mouse.setCursor()
  end

  controls.getKeyInput()

  if utilsData.textBox.selected or utilsData.alert.selected then
    update.textBox()
    update.alert()

  elseif selected == "game" then
    if not reachedGoal then
      if not escMenuOn then
        debug.addTime("update", "game start")
        entity.player.update()
        debug.addTime("update", "entity.player.update")
        update.camera()
        debug.addTime("update", "update.camera")
        timeCounter = timeCounter + 1
      end

      update.escMenu()
      debug.addTime("update", "update.escMenu")

    else
      update.winMenu()
      debug.addTime("update", "update.winMenu")
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

  keys.textInput = nil
  mouse.updateClicked()
end

function love.draw()
  love.graphics.translate(cameraTranslation +borders.x /2, borders.y /2)
  newTick = true
  display.makeScreenRed()

  if utilsData.textBox.selected then
    display.textBox()

  elseif selected == "game" then
    debug.addTime("draw", "game start")
    display.background()
    debug.addTime("draw", "display.background")
    display.map.background()
    debug.addTime("draw", "display.map.background")
    entity.player.display()
    debug.addTime("draw", "entity.player.display")
    display.map.foreground()
    debug.addTime("draw", "display.map.foreground")
    display.timeCounter()
    debug.addTime("draw", "display.timeCounter")
    display.arrowButtons()
    debug.addTime("draw", "display.arrowButtons")
    display.escMenu()
    debug.addTime("draw", "display.escMenu")
    display.winMenu()
    debug.addTime("draw", "display.winMenu")

  elseif selected == "menu" then
    display.background()
    credits.display()
    display.optionMenu()

  elseif selected == "createMap" then
    display.background()
    display.map.background()
    display.map.foreground()
    display.arrowButtons()
    display.blockMenu()
    display.escMenu()
  end

  display.alert()
  debug.printTimes()
  display.borders()
end
