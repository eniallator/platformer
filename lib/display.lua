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
    for j=1,screenDim.x/blockSize + blockSize*2 do
      local cameraOffset = math.ceil(-cameraTranslation /blockSize -1)

      if type(mapGrid[i][j +cameraOffset]) == "table" then
        local currImage = texture.block[mapGrid[i][j +cameraOffset].block]
        love.graphics.draw(currImage, ((j +cameraOffset) -1) *blockSize, (i -1) *blockSize, 0, blockSize /currImage:getWidth(), blockSize /currImage:getHeight())
      end
    end
  end
end

display.player = function()
  xCounter = (xCounter + player.vel.x) % 30

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

    elseif xCounter >= 15 then
      currTexture = texture.player.sprint[1]

    else
      currTexture = texture.player.sprint[2]
    end

  else
    currTexture = texture.player.still
  end

  love.graphics.draw(currTexture, player.pos.x - xOffset, player.pos.y, 0, scaleOffset * (player.w /currTexture:getWidth()), player.h /currTexture:getHeight())
end

local function createBackgroundTable(backgroundTexture)
  local tbl = {}
  local backgroundW = backgroundTexture:getWidth()
  local scrollSpeed = cameraTranslation*(2/3)
  local backgroundOffset = math.floor(scrollSpeed /backgroundW /2 +1)

  while #tbl *backgroundW - (scrollSpeed % backgroundW) < screenDim.x do
    table.insert(tbl,{backgroundTexture, 0 -scrollSpeed +(#tbl - backgroundOffset) *backgroundW, 0, 0, screenDim.x /backgroundW, screenDim.y /backgroundTexture:getHeight()})
  end

  return tbl
end

display.background = function()
  local backgroundTexture = texture.other.background

  if cameraTranslation ~= 0 then
    local bgTable = createBackgroundTable(backgroundTexture)

    for i=1, #bgTable do
      local currBg = bgTable[i]
      love.graphics.draw(currBg[1], currBg[2], currBg[3], currBg[4], currBg[5], currBg[6])
    end

  else
    love.graphics.draw(backgroundTexture, 0, 0, 0, screenDim.x /backgroundTexture:getWidth(), screenDim.y /backgroundTexture:getHeight())
  end
end

display.box = function(box)
  local font = love.graphics.getFont()

  love.graphics.setColor(150, 150, 150)
  love.graphics.rectangle("fill", box.x -cameraTranslation, box.y, box.w, box.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(box.name, box.x + box.w/2 - font:getWidth(box.name)/2 -cameraTranslation, box.y + box.h/2 - font:getHeight(box.name)/2,box.w)
end

display.escMenu = function()
  if escMenuOn then
    for _, box in pairs(optionData.escMenu.display()) do

      display.box(box)
    end
  end
end

return display
