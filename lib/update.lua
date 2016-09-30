local update = {}

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

end

update.mapCreatorinteract = function()
  local mouseCoords = {love.mouse.getPosition()}
  mouseCoords[1] = mouseCoords[1] - cameraTranslation

  if mouseCoords[1] > 0 and mouseCoords[1] + cameraTranslation < screenDim.x and mouseCoords[2] > 0 and mouseCoords[2] < screenDim.y then
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

  if love.keyboard.isDown("m") then
    mapCreatorMenu = true
  end
end

update.mapCreatorPos = function()
  if love.keyboard.isDown("right") and cameraTranslation > -(255*blockSize - screenDim.x) +mapCreatorScrollSpeed -1 then
    cameraTranslation = cameraTranslation - mapCreatorScrollSpeed
  end

  if love.keyboard.isDown("left") and cameraTranslation < -mapCreatorScrollSpeed +1 then
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

return update
