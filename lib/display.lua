local display = {}

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

  if lastDir == "r" then
    xOffset = -1 *player.w
    scaleOffset = -1

  else
    xOffset = 0
    scaleOffset = 1
  end

  if math.abs(player.vel.y) < 1 and math.abs(player.vel.x) < 1 then
    currTexture = texture.player.still

  elseif onGround then
    if xCounter > 20 then
      currTexture = texture.player.sprint[1]

    else
      currTexture = texture.player.sprint[2]
    end

  else
    currTexture = texture.player.glide
  end

  love.graphics.draw(currTexture, player.pos.x - xOffset, player.pos.y, 0, scaleOffset * (player.w /currTexture:getWidth()), player.h /currTexture:getHeight())
end

return display
