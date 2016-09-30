local moveSpeed = 0.3
local jumpHeight = -5
local gravity = 3
local drag = 0.96
local friction = 0.93
local entity = {}

local function applyVelForces(currEntity)
  currEntity.vel.x = currEntity.vel.x * drag
  currEntity.vel.y = currEntity.vel.y + 0.1 * gravity

  if currEntity.onGround then
    currEntity.vel.x = currEntity.vel.x * friction
  end
end

local function updatePos(currEntity)
  local xBoundLimit = currEntity.pos.x +currEntity.vel.x > 0 and currEntity.pos.x +currEntity.vel.x +currEntity.dim.w <= 255 *blockSize
  local yBoundLimit = currEntity.pos.y + currEntity.dim.h + currEntity.vel.y < screenDim.y

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

  else
    currEntity.jumpsLeft = 2
    currEntity.vel.y = 0
    currEntity.onGround = true
  end
end

local function checkUp(currEntity)
  local upPressed = false

  if love.keyboard.isDown("up") then
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
    currEntity.vel.y = currEntity.vel.y + jumpHeight
    currEntity.jumpsLeft = currEntity.jumpsLeft - 1
  end

  if love.keyboard.isDown("right") then
    currEntity.vel.x = currEntity.vel.x + moveSpeed
    currEntity.lastDir = "r"
  end

  if love.keyboard.isDown("left") then
    currEntity.vel.x = currEntity.vel.x - moveSpeed
    currEntity.lastDir = "l"
  end
end

entity.player = {pos = {x = 1, y = 1}, spawnPos = {x = 1, y = 1}, vel = {x = 0, y = 0}, dim = {w = screenDim.y /37.5, h = screenDim.y /18.75}, xCounter = 0}

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
    player.spawnPos.x = checkPoint[1] *blockSize -blockSize /2 -player.dim.w /2
    player.spawnPos.y = checkPoint[2] *blockSize +blockSize -player.dim.h
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
        spawnPoint[1] = j *blockSize -blockSize /2 -entity.player.dim.w /2
        spawnPoint[2] = i *blockSize +blockSize -entity.player.dim.h
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

  if player.lastDir == "r" or not player.lastDir then
    xOffset = -1 *player.dim.w
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

  love.graphics.draw(currTexture, player.pos.x - xOffset, player.pos.y, 0, scaleOffset * (player.dim.w /currTexture:getWidth()), player.dim.h /currTexture:getHeight())
end

return entity
