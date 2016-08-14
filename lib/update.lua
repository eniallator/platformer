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
  if not collision.detectPlayer(player.pos.x + player.vel.x, player.pos.y) then
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

return update
