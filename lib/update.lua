local update = {}

update.internalWindowSize = function(w, h)
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

update.forces = function()
  moveSpeed = screenDim.y / (600 / 0.4)
  jumpHeight = - screenDim.y / (600/ 4.5)
  gravity = screenDim.y / 200
  drag = 1.07
  friction = 1.07
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

update.mapCreatorinteract = function()
  local mouseCoords = {}
  mouseCoords.x, mouseCoords.y = love.mouse.getPosition()
  mouseCoords.x = mouseCoords.x - borders.x / 2
  mouseCoords.y = mouseCoords.y - borders.y / 2

  local blockMenuDim = {
    x = screenDim.x / 60 - cameraTranslation,
    y = screenDim.y - screenDim.y / 9,
    w = screenDim.x - screenDim.x / 60 * 2,
    h = blockSize * 2
  }

  if not (mapCreatorMenu and collision.hoverOverBox(blockMenuDim)) and mouseCoords.x > 0 and mouseCoords.x + cameraTranslation < screenDim.x and mouseCoords.y > 0 and mouseCoords.y < screenDim.y then
    if mouse.left.held and not firstLoad then
      map.placeBlock(mouseCoords)

    elseif not mouse.left.held then
      firstLoad = false
    end

    if mouse.right.held then
      map.destroyBlock(mouseCoords)
    end
  end
end

update.mapCreatorBlockMenu = function()
  mapCreatorMenu = false

  if love.keyboard.isDown(controls[controls.findName("mapCreator.blockMenu")].key) then
    mapCreatorMenu = true
  end
end

update.selectedMapCreatorBlock = function()
  if mapCreatorMenu then
    local blockMenuTable = optionData.blockMenu.display()
    local blockClicked = collision.clickBox(blockMenuTable)
    collision.updateMouseCursor(blockMenuTable)

    if blockClicked == "prevPage" or blockClicked == "nextPage" then
      optionData.blockMenu.funcs[blockClicked]()

    elseif blockClicked then
      selectedBlockIndex = blockMenuTable[blockClicked].blockIndex
    end
  end
end

update.mapCreatorPos = function()
  if love.keyboard.isDown(controls[controls.findName("mapCreator.scrollRight")].key) and cameraTranslation > - (255 * blockSize - screenDim.x) + mapCreatorScrollSpeed - 1 then
    cameraTranslation = cameraTranslation - mapCreatorScrollSpeed
  end

  if love.keyboard.isDown(controls[controls.findName("mapCreator.scrollLeft")].key) and cameraTranslation < - mapCreatorScrollSpeed + 1 then
    cameraTranslation = cameraTranslation + mapCreatorScrollSpeed
  end
end

update.escMenu = function()
  if update.checkEscButton() then
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
  textBox.getInput(utilsData.textBox[utilsData.textBox.selected])
end

update.alert = function()
  if utilsData.alert.selected then
    local currAlert = utilsData.alert[utilsData.alert.selected]
    alert.getInput(currAlert)
  end
end

return update
