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
      dirt = love.graphics.newImage("assets/textures/blocks/dirt.png"),
      grass = love.graphics.newImage("assets/textures/blocks/grass.png"),
      sand = love.graphics.newImage("assets/textures/blocks/sand.png"),
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

local function createBackgroundTable()
  local tbl = {}
  local backgroundW = texture.other.background:getWidth()

  while #tbl *backgroundW - (cameraTranlation/1.5 % backgroundW) < screenDim.x do
    table.insert(tbl,{texture.other.background, 0 -cameraTranlation/1.5 +(#tbl - math.floor(cameraTranlation /1.5 /backgroundW /2 +1)) *backgroundW, 0, 0, screenDim.x /texture.other.background:getWidth(), screenDim.y /texture.other.background:getHeight()})
  end

  return tbl
end

display.background = function()
  if cameraTranlation ~= 0 then
    local bgTable = createBackgroundTable()

    for i=1, #bgTable do
      local currBg = bgTable[i]
      love.graphics.draw(currBg[1], currBg[2], currBg[3], currBg[4], currBg[5], currBg[6])
    end

  else
    love.graphics.draw(texture.other.background, 0, 0, 0, screenDim.x /texture.other.background:getWidth(), screenDim.y /texture.other.background:getHeight())
  end
end

return display
