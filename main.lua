function inputControl()
  -- just seeing if the up key was pressed rather than still down
  upIsDown = false

  if love.keyboard.isDown("up") then
    if not stillDown then
      upIsDown = true
    end

    stillDown = true
  else
    stillDown = false
  end

  if upIsDown then
    player.vel.y = player.vel.y + jumpHeight
  end

  if love.keyboard.isDown("right") then
    player.vel.x = player.vel.x + moveSpeed
  end

  if love.keyboard.isDown("left") then
    player.vel.x = player.vel.x - moveSpeed
  end
end

function updateVel()
  player.vel.x = player.vel.x * drag
  player.vel.y = player.vel.y + 0.1 * gravity
  inputControl()
end

function updatePos()
  player.pos.x = player.pos.x + player.vel.x

  -- Collision detection with the ground
  if player.pos.y + 20 + player.vel.y < screenDim.y then
    player.pos.y = player.pos.y + player.vel.y
  else
    player.vel.y = 0
  end
end

function love.load()
  -- Loading vars
  screenDim = {}
  screenDim.x, screenDim.y = love.graphics.getDimensions()
  player = {pos = {x = 1, y = 1}, vel = {x = 0, y = 0}}
  moveSpeed = 0.8
  jumpHeight = -5
  gravity = 0.9
  drag = 0.93
end

function love.update()
  updateVel()
  updatePos()
end

function love.draw()
  love.graphics.rectangle("fill", player.pos.x, player.pos.y, 20, 20)
end
