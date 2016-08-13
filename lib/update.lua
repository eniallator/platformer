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
  end

  if love.keyboard.isDown("left") then
    player.vel.x = player.vel.x - moveSpeed
  end
end

update.velocity = function()
  player.vel.x = player.vel.x * drag
  player.vel.y = player.vel.y + 0.1 * gravity
  getInput()
end

update.position = function()
  player.pos.x = player.pos.x + player.vel.x

  if player.pos.y + 20 + player.vel.y < screenDim.y then
    player.pos.y = player.pos.y + player.vel.y

  else
    jumpsLeft = 2
    player.vel.y = 0
  end
end

return update
