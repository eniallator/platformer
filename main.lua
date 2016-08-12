function inputControl()
  upIsDown = false

  if love.keyboard.isDown("up") then
    if not stillDown then
      upIsDown = true
    end

    stillDown = true
  else
    stillDown = false
  end

  -- jumpsLeft idea from cran :)
  if upIsDown and jumpsLeft and jumpsLeft > 0 then
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
    jumpsLeft = 2
    player.vel.y = 0
  end
end

function displayMap()
  for coords, data in pairs(map) do
    local xNum = coords:find("x")
    local yNum = coords:find("y")

    local blockX = tonumber(coords:sub(xNum +1, yNum -1))
    local blockY = tonumber(coords:sub(yNum +1, #coords))

    local blockData = blocks[data.block]
    love.graphics.setColor(blockData.r, blockData.g, blockData.b)
    love.graphics.rectangle("fill", (blockX-1)*blockSize, (blockY-1)*blockSize, data.w*blockSize, data.h*blockSize)
  end
end

function love.load()
  screenDim = {}
  screenDim.x, screenDim.y = love.graphics.getDimensions()
  player = {pos = {x = 1, y = 1}, vel = {x = 0, y = 0}, col = {r = 0, g = 0, b = 255}}
  moveSpeed = 0.8
  jumpHeight = -5
  gravity = 3
  drag = 0.93
  blockSize = screenDim.y/20

  -- For now just using RGB colours and only using "stone" but will add more blocks and also will add textures later
  blocks = {stone = {r = 150, b = 150, g = 150}}

  -- Test map for now but it's working perfectly and map creation shouldn't be very difficult based off of this
  map = {x10y16 = {block = "stone", w = 8, h = 1}, x5y6 = {block = "stone", w = 2, h = 2}, x21y6 = {block = "stone", w = 2, h = 2}}
end

function love.update()
  updateVel()
  updatePos()
end

function love.draw()
  love.graphics.setColor(player.col.r, player.col.g, player.col.b)
  love.graphics.rectangle("fill", player.pos.x, player.pos.y, 20, 20)
  displayMap()
end
