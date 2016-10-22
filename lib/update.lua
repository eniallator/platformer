local update = {}

update.forces = function()
  moveSpeed = screenDim.y / (600 /0.3)
  jumpHeight = -screenDim.y /(600/4.5)
  gravity = screenDim.y /200
  drag = 1.07
  friction = 1.07
end

update.camera = function()
  local playerDim = entity.player.dim()
  if entity.player.pos.x + playerDim.w/2 > screenDim.x/2  then
    if entity.player.pos.x + playerDim.w/2 > 255*blockSize - screenDim.x/2 then
      cameraTranslation = -(255*blockSize - screenDim.x)

    else
      cameraTranslation = -entity.player.pos.x +screenDim.x /2 -playerDim.w /2
    end

  else
    cameraTranslation = 0
  end

  cameraTranslation = cameraTranslation
end

update.mapCreatorinteract = function()
  local mouseCoords = {love.mouse.getPosition()}
  mouseCoords[1] = mouseCoords[1] -cameraTranslation -borders.x /2

  if not (mapCreatorMenu and collision.hoverOverBox({{x = screenDim.x /60 -cameraTranslation, y = screenDim.y -screenDim.y /9, w = screenDim.x -screenDim.x /60 *2, h = blockSize *2}})) and mouseCoords[1] > 0 and mouseCoords[1] + cameraTranslation < screenDim.x and mouseCoords[2] > 0 and mouseCoords[2] < screenDim.y then
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

update.mapCreatorPos = function()
  if love.keyboard.isDown(controls[controls.findName("mapCreator.scrollRight")].key) and cameraTranslation > -(255*blockSize - screenDim.x) +mapCreatorScrollSpeed -1 then
    cameraTranslation = cameraTranslation - mapCreatorScrollSpeed
  end

  if love.keyboard.isDown(controls[controls.findName("mapCreator.scrollLeft")].key) and cameraTranslation < -mapCreatorScrollSpeed +1 then
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

return update
