function love.load()
  screenDim = {}
  aspectRatio = 4/3
  love.graphics.setDefaultFilter("nearest", "nearest")
  isSmartPhone = love._os == "Android" or love._os == "iOS"
  update = require "src.update"
  debugMode = false

  update.internalWindowSize(love.graphics.getDimensions())

  defaultMaps = require "src.defaultMaps"
  optionData = require "src.optionData"
  collision = require "src.collision"
  utilsData = require "src.utilsData"
  controls = require "src.controls"
  display = require "src.display"
  credits = require "src.credits"
  entity = require "src.entity"
  debug = require "src.debug"
  map = require "src.map"
  textBox = require "src.utils.textBox"
  alert = require "src.utils.alert"
  mouse = require "src.utils.mouse"
  keys = require "src.utils.keys"

  display.loadTextures()
  textBox.reset()
  controls.loadControls()
  update.forces()

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

function love.update()
  debug.initTimes()

  if not isSmartPhone then
    love.mouse.setCursor()
  end

  controls.getKeyInput()

  if utilsData.textBox.selected or utilsData.alert.selected then
    debug.addTime('update', 'textBox/alert start')
    update.textBox()
    debug.addTime('update', 'update.textBox')
    update.alert()
    debug.addTime('update', 'update.alert')

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
    debug.addTime('update', 'menu start')
    credits.update()
    debug.addTime('update', 'credits.update')
    update.optionMenu()
    debug.addTime('update', 'update.optionMenu')

  elseif selected == "createMap" then
    debug.addTime('update', 'createMap start')
    update.mapCreatorPos()
    debug.addTime('update', 'update.mapCreatorPos')
    update.mapCreatorBlockMenu()
    debug.addTime('update', 'update.mapCreatorBlockMenu')
    update.selectedMapCreatorBlock()
    debug.addTime('update', 'update.selectedMapCreatorBlock')
    update.escMenu()
    debug.addTime('update', 'update.escMenu')
    update.mapCreatorinteract()
    debug.addTime('update', 'update.mapCreatorinteract')
  end

  keys.textInput = nil
  mouse.updateClicked()
end

function love.draw()
  love.graphics.translate(cameraTranslation + borders.x / 2, borders.y / 2)
  newTick = true
  display.makeScreenRed()

  if utilsData.textBox.selected then
    debug.addTime('draw', 'textBox start')
    display.textBox()
    debug.addTime('draw', 'display.textBox')

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
    debug.addTime('draw', 'menu start')
    display.background()
    debug.addTime('draw', 'display.background')
    credits.display()
    debug.addTime('draw', 'credits.display')
    display.optionMenu()
    debug.addTime('draw', 'display.optionMenu')

  elseif selected == "createMap" then
    debug.addTime('draw', 'createMap start')
    display.background()
    debug.addTime('draw', 'display.background')
    display.map.background()
    debug.addTime('draw', 'display.map.background')
    display.map.foreground()
    debug.addTime('draw', 'display.map.foreground')
    display.arrowButtons()
    debug.addTime('draw', 'arrowButtons')
    display.blockMenu()
    debug.addTime('draw', 'display.blockMenu')
    display.escMenu()
    debug.addTime('draw', 'display.escMenu')
  end

  display.alert()
  debug.printTimes()
  display.borders()
end
