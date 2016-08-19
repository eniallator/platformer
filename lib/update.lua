local update = {}

local function checkUp()
  upJustPressed = false

  if love.keyboard.isDown("up") then
    if not stillDown then
      upJustPressed = true
    end

    stillDown = true
  else
    stillDown = false
  end
end

local function getInput()
  checkUp()

  if upJustPressed and jumpsLeft and jumpsLeft > 0 then
    player.vel.y = player.vel.y + jumpHeight
    jumpsLeft = jumpsLeft - 1
  end

  if love.keyboard.isDown("right") then
    player.vel.x = player.vel.x + moveSpeed
    lastDir = "r"
  end

  if love.keyboard.isDown("left") then
    player.vel.x = player.vel.x - moveSpeed
    lastDir = "l"
  end
end

update.velocity = function()
  player.vel.x = player.vel.x * drag
  player.vel.y = player.vel.y + 0.1 * gravity

  if onGround then
    player.vel.x = player.vel.x * friction
  end

  getInput()
end

update.position = function()
  if not collision.detectPlayer(player.pos.x + player.vel.x, player.pos.y) and player.pos.x + player.vel.x > 0  and player.pos.x + player.vel.x + player.w <= 255*blockSize then
    player.pos.x = player.pos.x + player.vel.x

  else
    player.vel.x = 0
  end

  if player.pos.y + player.h + player.vel.y < screenDim.y and not collision.detectPlayer(player.pos.x, player.pos.y + player.vel.y) then
    player.pos.y = player.pos.y + player.vel.y
    onGround = false

  else
    jumpsLeft = 2
    player.vel.y = 0
    onGround = true
  end
end

update.camera = function()
  if player.pos.x + player.w/2 > screenDim.x/2  then
    if player.pos.x + player.w/2 > 255*blockSize - screenDim.x/2 then
      cameraTranslation = -(255*blockSize - screenDim.x)

    else
      cameraTranslation = cameraTranslation - player.vel.x
    end

  else
    cameraTranslation = 0
  end

end

update.mapCreatorinteract = function()
  local mouseCoords = {love.mouse.getPosition()}
  mouseCoords[1] = mouseCoords[1] - cameraTranslation

  if mouseCoords[1] > 0 and mouseCoords[1] + cameraTranslation < screenDim.x and mouseCoords[2] > 0 and mouseCoords[2] < screenDim.y then
    if love.mouse.isDown(1) and not firstLoad then
      map.placeBlock(mouseCoords)

    elseif not love.mouse.isDown(1) then
      firstLoad = false
    end

    if love.mouse.isDown(2) then
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
  if love.keyboard.isDown("right") and cameraTranslation > -(255*blockSize - screenDim.x) then
    cameraTranslation = cameraTranslation - mapCreatorScrollSpeed
  end

  if love.keyboard.isDown("left") and cameraTranslation < 0 then
    cameraTranslation = cameraTranslation + mapCreatorScrollSpeed
  end
end

update.escMenu = function()
  if love.keyboard.isDown("escape") then
    escMenuOn = true
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
  player.vel = {x = 0, y = 1}
end

return update
