function love.load()
  tps = 20
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
  selected = "menu"
  currMenu = "main"
  mapExtension = ".map"
  timeCounter = 0
  screenRedMax = 1.5
  screenRed = 0
end

function love.resize(w, h)
  entity.player.pos.y = entity.player.pos.y *h /screenDim.y
  entity.player.pos.x = entity.player.pos.x *(h /20 /(screenDim.y /20))

  update.internalWindowSize(w, h)
  update.forces()
end

function love.update()
  debug.initTimes()
  update.resetInterpolationVal()

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
  update.setInterpolationVals()
end

function love.draw(dt)
  update.interpolationVal(dt)
  love.graphics.translate(cameraTranslation + borders.x / 2, borders.y / 2)
  display.makeScreenRed(dt)

  if not escMenuOn and not reachedGoal then
    entity.player.updateInterpolation(dt)
    debug.addTime("draw", "entity.player.updateInterpolation")
  end

  if utilsData.textBox.selected then
    debug.addTime('draw', 'textBox start')
    display.background()
    debug.addTime("draw", "display.background")
    display.textBox()
    debug.addTime('draw', 'display.textBox')

  elseif selected == "game" then
    debug.addTime("draw", "game start")
    display.background()
    debug.addTime("draw", "display.background")
    display.map.background(dt)
    debug.addTime("draw", "display.map.background")
    entity.player.display()
    debug.addTime("draw", "entity.player.display")
    display.map.foreground(dt)
    debug.addTime("draw", "display.map.foreground")
    display.timeCounter(dt)
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
    display.map.background(dt)
    debug.addTime('draw', 'display.map.background')
    display.map.foreground(dt)
    debug.addTime('draw', 'display.map.foreground')
    display.arrowButtons()
    debug.addTime('draw', 'arrowButtons')
    display.blockMenu(dt)
    debug.addTime('draw', 'display.blockMenu')
    display.escMenu()
    debug.addTime('draw', 'display.escMenu')
  end

  display.alert()
  debug.printTimes()
  display.borders()
end

function love.run()
  if love.load then love.load() end

  timer = require 'src.utils.timer'
  timer:init(tps)

  while true do
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end
    timer:clock()

    for i=1, timer.missingTicks do
      love.update()
    end

    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      if love.draw then love.draw(timer.dt) end
      love.graphics.present()
    end
  end
end
