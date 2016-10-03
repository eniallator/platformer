local entity = {}

local function applyVelForces(currEntity)
  currEntity.vel.x = currEntity.vel.x /drag
  currEntity.vel.y = currEntity.vel.y +0.1 *gravity

  if currEntity.onGround then
    currEntity.vel.x = currEntity.vel.x /friction
  end
end

local function updatePos(currEntity)
  local currEntityDim = currEntity.dim()
  local xBoundLimit = currEntity.pos.x +currEntity.vel.x > 0 and currEntity.pos.x +currEntity.vel.x +currEntityDim.w <= 255 *blockSize
  local yBoundLimit = currEntity.pos.y +currEntityDim.h +currEntity.vel.y < screenDim.y

  if collision.detectEntity(currEntity.pos.x + currEntity.vel.x, currEntity.pos.y + currEntity.vel.y, currEntity, "kill") and xBoundLimit and yBoundLimit then
    currEntity.kill()
    return
  end

  if not collision.detectEntity(currEntity.pos.x + currEntity.vel.x, currEntity.pos.y, currEntity, "solid") and xBoundLimit then
    currEntity.pos.x = currEntity.pos.x + currEntity.vel.x

  else
    currEntity.vel.x = 0
  end

  if not collision.detectEntity(currEntity.pos.x, currEntity.pos.y + currEntity.vel.y, currEntity, "solid") and yBoundLimit then
    currEntity.pos.y = currEntity.pos.y + currEntity.vel.y
    currEntity.onGround = false

  elseif currEntity.vel.y > 0 then
    currEntity.jumpsLeft = 2
    currEntity.vel.y = 0
    currEntity.onGround = true
  end
end

local function checkUp(currEntity)
  local upPressed = false

  if love.keyboard.isDown(config.controls.game.jump) then
    if not currEntity.stillDown then
      upPressed = true
    end

    currEntity.stillDown = true
  else
    currEntity.stillDown = false
  end

  return upPressed
end

local function getInput(currEntity)
  if checkUp(currEntity) and currEntity.jumpsLeft and currEntity.jumpsLeft > 0 then
    if currEntity.vel.y > 0 then
      currEntity.vel.y = jumpHeight

    else
      currEntity.vel.y = currEntity.vel.y + jumpHeight
    end

    currEntity.jumpsLeft = currEntity.jumpsLeft - 1
  end

  if love.keyboard.isDown(config.controls.game.right) then
    currEntity.vel.x = currEntity.vel.x + moveSpeed
    currEntity.lastDir = "r"
  end

  if love.keyboard.isDown(config.controls.game.left) then
    currEntity.vel.x = currEntity.vel.x - moveSpeed
    currEntity.lastDir = "l"
  end
end

entity.player = {pos = {x = 1, y = 1}, spawnPos = {x = 1, y = 1}, vel = {x = 0, y = 0}, dim = function() return {w = screenDim.y /37.5, h = screenDim.y /18.75} end, xCounter = 0}

entity.player.texture = {
  still = love.graphics.newImage("assets/textures/player/player.still.png"),
  glide = love.graphics.newImage("assets/textures/player/player.glide.png"),

  sprint = {
    love.graphics.newImage("assets/textures/player/player.sprint.1.png"),
    love.graphics.newImage("assets/textures/player/player.sprint.2.png")
  }
}

entity.player.update = function()
  applyVelForces(entity.player)
  getInput(entity.player)
  updatePos(entity.player)

  local player = entity.player
  local checkPoint = {collision.detectEntity(player.pos.x, player.pos.y, player, "checkPoint")}

  if checkPoint[1] then
    local playerDim = player.dim()
    player.spawnPos.x = checkPoint[1] *blockSize -blockSize /2 -playerDim.w /2
    player.spawnPos.y = checkPoint[2] *blockSize +blockSize -playerDim.h
  end

  if collision.detectEntity(player.pos.x, player.pos.y, player, "goal") then
    reachedGoal = true
  end
end

entity.player.kill = function()
  entity.player.pos = {x = entity.player.spawnPos.x, y = entity.player.spawnPos.y}
  entity.player.vel = {x = 0, y = 0}
end

entity.player.reset = function()
  local spawnPoint = {1,1}

  for i=1, #mapGrid do
    for j=1,#mapGrid[i] do
      if type(mapGrid[i][j]) == "table" and mapGrid[i][j].block == "spawnPoint" then
        local playerDim = entity.player.dim()
        spawnPoint[1] = j *blockSize -blockSize /2 -playerDim.w /2
        spawnPoint[2] = i *blockSize +blockSize -playerDim.h
      end
    end
  end

  entity.player.pos = {x = spawnPoint[1], y = spawnPoint[2]}
  entity.player.spawnPos = {x = spawnPoint[1], y = spawnPoint[2]}
  entity.player.vel = {x = 0, y = 0}
end

entity.player.display = function()
  local player = entity.player
  player.xCounter = (player.xCounter + player.vel.x) % 30
  local xOffset, scaleOffset, currTexture
  local playerDim = player.dim()

  if player.lastDir == "r" or not player.lastDir then
    xOffset = -1 *playerDim.w
    scaleOffset = -1

  else
    xOffset = 0
    scaleOffset = 1
  end

  if player.onGround then
    if math.abs(player.vel.x) < 1 then
      currTexture = player.texture.still

    elseif player.xCounter >= 15 then
      currTexture = player.texture.sprint[1]

    else
      currTexture = player.texture.sprint[2]
    end

  else
    currTexture = player.texture.still
  end

  love.graphics.draw(currTexture, player.pos.x - xOffset, player.pos.y, 0, scaleOffset * (playerDim.w /currTexture:getWidth()), playerDim.h /currTexture:getHeight())
end

return entity
