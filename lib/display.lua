local display = {}

local xCounter = 0

display.loadTextures = function()

  texture = {
    player = {
      still = love.graphics.newImage("assets/textures/player/player.still.png"),
      glide = love.graphics.newImage("assets/textures/player/player.glide.png"),

      sprint = {
        love.graphics.newImage("assets/textures/player/player.sprint.1.png"),
        love.graphics.newImage("assets/textures/player/player.sprint.2.png")
      }
    },

    block = {
      stone = love.graphics.newImage("assets/textures/blocks/stone.png"),
    },

    other = {
      background = love.graphics.newImage("assets/textures/other/background.png")
    }
  }
end

display.map = function()
  for i=1,#mapGrid do
    for j=1,#mapGrid[i] do
      if type(mapGrid[i][j]) == "table" then

        local currImage = texture.block[mapGrid[i][j].block]
        love.graphics.draw(currImage, (j -1) *blockSize, (i -1) *blockSize, 0, blockSize /currImage:getWidth(), blockSize /currImage:getHeight())
      end
    end
  end
end

display.player = function()

  xCounter = (xCounter + player.vel.x) % 40

  if lastDir == "r" or not lastDir then
    xOffset = -1 *player.w
    scaleOffset = -1

  else
    xOffset = 0
    scaleOffset = 1
  end

  if onGround then
    if math.abs(player.vel.x) < 1 then
      currTexture = texture.player.still

    elseif xCounter >= 20 then
      currTexture = texture.player.sprint[1]

    else
      currTexture = texture.player.sprint[2]
    end

  else
    currTexture = texture.player.still
  end

  love.graphics.draw(currTexture, player.pos.x - xOffset, player.pos.y, 0, scaleOffset * (player.w /currTexture:getWidth()), player.h /currTexture:getHeight())
end

return display
