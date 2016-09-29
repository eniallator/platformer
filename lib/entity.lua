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
  if not collision.detectEntity(currEntity.pos.x + currEntity.vel.x, currEntity.pos.y, currEntity) and currEntity.pos.x + currEntity.vel.x > 0  and currEntity.pos.x + currEntity.vel.x + currEntity.dim.w <= 255*blockSize then
    currEntity.pos.x = currEntity.pos.x + currEntity.vel.x

  else
    currEntity.vel.x = 0
  end

  if currEntity.pos.y + currEntity.dim.h + currEntity.vel.y < screenDim.y and not collision.detectEntity(currEntity.pos.x, currEntity.pos.y + currEntity.vel.y, currEntity) then
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

entity.player = {pos = {x = 1, y = 1}, vel = {x = 0, y = 0}, dim = {w = screenDim.y /37.5, h = screenDim.y /18.75}, xCounter = 0}

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
end

entity.player.reset = function()
  entity.player.pos, entity.player.vel = {x = 1, y = 1}, {x = 0, y = 0}
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
