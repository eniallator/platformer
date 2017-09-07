local smartPhone = require "src.smartPhone"
local update = {}
local newCameraTranslation = 0
local oldCameraTranslation = 0

update.internalWindowSize = function(w, h)
  if w/h == aspectRatio then
    borders = {x = 0, y = 0}

  elseif w/h > aspectRatio then
    borders = {}
    borders.x = (w - (h * aspectRatio))
    borders.y = 0

  else
    borders = {}
    borders.y = (h - (w / aspectRatio))
    borders.x = 0
  end

  screenDim.x, screenDim.y = w - borders.x + 1, h - borders.y
  blockSize = screenDim.y / 20
  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x / 40))
end

update.forces = function()
  moveSpeed = screenDim.y / (600 / 0.4) * (1.5 * (48 / tps))
  jumpHeight = -screenDim.y / (600/ 4.5) * (0.75 * (48 / tps))
  gravity = screenDim.y / 200 * (1.5 * (48 / tps))
  drag = 1 + 0.07 * 48 / tps
  friction = drag
  mapCreatorScrollSpeed = screenDim.y / 120 * 48 / tps
end

update.camera = function()
  local playerDim = entity.player.dim()
  local midPlayerX = entity.player.pos.x + playerDim.w / 2

  if midPlayerX > screenDim.x / 2  then
    if midPlayerX > 255 * blockSize - screenDim.x / 2 then
      cameraTranslation = - (255 * blockSize - screenDim.x)

    else
      cameraTranslation = - entity.player.pos.x + screenDim.x / 2 - playerDim.w / 2
    end

  else
    cameraTranslation = 0
  end

  cameraTranslation = cameraTranslation
end

local lastMousePos
local startedDragging

local function mouseOverDragIcon()
  local dragIconBox = optionData.smartPhoneMapCreator.displayIcon()

  if collision.circle(dragIconBox) then
    return true
  end

  return false
end

local function moveToggleBox()
  if mouse.left.clicked and mouseOverDragIcon() then
    startedDragging = true
  end

  if isSmartPhone then
    if mouse.left.held then
      if lastMousePos and startedDragging then
        local currMousePos = {}
        local currCoords = optionData.smartPhoneMapCreator.toggleBlockMenu
        currMousePos.x, currMousePos.y = love.mouse.getPosition()

        nextCoords = {
          x = currCoords.x + currMousePos.x - lastMousePos.x,
          y = currCoords.y + currMousePos.y - lastMousePos.y
        }

        local menu = optionData.smartPhoneMapCreator.display()
        local offset = {
          w = menu.toggleBlockMenu.w,
          h = menu.toggleBlockMenu.h
        }

        currCoords.x = nextCoords.x + offset.w < screenDim.x
          and nextCoords.x > 0
          and nextCoords.x
          or nextCoords.x > 0 and screenDim.x - offset.w
          or 0

        currCoords.y =
          nextCoords.y + offset.h < screenDim.y
          and nextCoords.y > 0
          and nextCoords.y
          or nextCoords.y > 0 and screenDim.y - offset.h
          or 0
      end

    else
      startedDragging = false
    end
  end

  lastMousePos = {}
  lastMousePos.x, lastMousePos.y = love.mouse.getPosition()

  return not (isSmartPhone and (collision.hoverOverBoxes(optionData.smartPhoneMapCreator.display()) or startedDragging))
end

update.mapCreatorinteract = function()
  local mouseCoords = {}
  mouseCoords.x, mouseCoords.y = love.mouse.getPosition()
  mouseCoords.x = mouseCoords.x - borders.x / 2 - cameraTranslation
  mouseCoords.y = mouseCoords.y - borders.y / 2

  local blockMenuDim = {
    x = screenDim.x / 60 - cameraTranslation,
    y = screenDim.y - screenDim.y / 9,
    w = screenDim.x - screenDim.x / 60 * 2,
    h = blockSize * 2
  }

  if not (mapCreatorMenu and collision.hoverOverBoxes(optionData.blockMenu.display()))
    and moveToggleBox()
    and not smartPhone.checkButtonPress("right") and not smartPhone.checkButtonPress("left")
    and mouseCoords.x > 0 and mouseCoords.x + cameraTranslation < screenDim.x
    and mouseCoords.y > 0 and mouseCoords.y < screenDim.y then

    if mouse.left.held and not firstLoad then
      if isSmartPhone and destroyMode then
        map.destroyBlock(mouseCoords)

      else
        map.placeBlock(mouseCoords)
      end

    elseif not mouse.left.held then
      firstLoad = false
    end

    if mouse.right.held then
      map.destroyBlock(mouseCoords)
    end
  end
end

update.mapCreatorBlockMenu = function()
  if not isSmartPhone then
    local blockMenuKey = controls[controls.findName("mapCreator.blockMenu")].key
    local keyDown = love.keyboard.isDown(blockMenuKey)

    if not keys.state[blockMenuKey] and keyDown then
      mapCreatorMenu = not mapCreatorMenu
    end

  else
    touchedButton = collision.clickBox(optionData.smartPhoneMapCreator.display())

    if touchedButton and not mouseOverDragIcon() then
      optionData.smartPhoneMapCreator.funcs[touchedButton]()
    end
  end
end

update.selectedMapCreatorBlock = function()
  if mapCreatorMenu then
    local blockMenuTable = optionData.blockMenu.display()
    local blockClicked = collision.clickBox(blockMenuTable)
    collision.updateMouseCursor(blockMenuTable)

    if not blockClicked then
      return
    end

    if not blockMenuTable[blockClicked].notButton then
      if tonumber(blockClicked) then
        selectedBlockIndex = blockMenuTable[blockClicked].blockIndex

      else
        optionData.blockMenu.funcs[blockClicked]()
      end
    end
  end
end

update.mapCreatorPos = function()
  if (not mapCreatorMenu and smartPhone.checkButtonPress("right")
  or love.keyboard.isDown(controls[controls.findName("mapCreator.scrollRight")].key))
  and cameraTranslation > - (255 * blockSize - screenDim.x) + mapCreatorScrollSpeed - 1 then

    cameraTranslation = cameraTranslation - mapCreatorScrollSpeed
  end

  if (not mapCreatorMenu and smartPhone.checkButtonPress("left")
  or love.keyboard.isDown(controls[controls.findName("mapCreator.scrollLeft")].key))
  and cameraTranslation < - mapCreatorScrollSpeed + 1 then

    cameraTranslation = cameraTranslation + mapCreatorScrollSpeed
  end
end

update.escMenu = function()
  local box = optionData.smartPhoneEscMenu.display()

  if update.checkEscButton() or isSmartPhone and collision.clickBox({box}) and not escMenuOn then
    escMenuOn = not escMenuOn
  end

  if escMenuOn then
    firstLoad = true
    local clickedBox = collision.clickBox(optionData.escMenu.display())
    collision.updateMouseCursor(optionData.escMenu.display())

    if clickedBox then
      optionData.escMenu.funcs[clickedBox]()
      escMenuOn = false
    end
  end
end

update.resetPlayer = function()
  player.pos = {x = 1, y = 1}
  player.vel = {x = 0, y = 0}
end

update.checkEscButton = function()
  if escPressed then
    escPressed = false
    return true
  end

  return false
end

update.winMenu = function()
  local winMenuData = optionData.winMenu.display()
  local clickedBox = collision.clickBox(winMenuData, true)
  collision.updateMouseCursor(winMenuData)

  if clickedBox then
    optionData.winMenu.funcs[clickedBox]()
  end
end

update.optionMenu = function()
  local menuDisplayed = optionData[currMenu].display()
  local clickedBox = collision.clickBox(menuDisplayed, true)
  local rightClickedBox = collision.rightClickBox(menuDisplayed, true)
  collision.updateMouseCursor(menuDisplayed, true)

  if clickedBox then
    optionData[currMenu].funcs[clickedBox](menuDisplayed[clickedBox])

  elseif rightClickedBox and currMenu == "play" then
    optionData[currMenu].funcs[rightClickedBox](menuDisplayed[rightClickedBox], true)
  end
end

update.textBox = function()
  if utilsData.textBox.selected then
    textBox.getInput(utilsData.textBox[utilsData.textBox.selected])
  end
end

update.alert = function()
  if utilsData.alert.selected then
    local currAlert = utilsData.alert[utilsData.alert.selected]
    alert.getInput(currAlert)
  end
end

update.resetInterpolationVal = function()
  cameraTranslation = newCameraTranslation
end

update.setInterpolationVals = function()
  oldCameraTranslation = newCameraTranslation
  newCameraTranslation = cameraTranslation
end

update.interpolationVal = function(dt)
  cameraTranslation = oldCameraTranslation + (newCameraTranslation - oldCameraTranslation) * dt
end

return update
