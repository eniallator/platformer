local display = {}

local xCounter = 0

display.loadTextures = function()

  texture = {
    block = {
      stone = love.graphics.newImage("assets/textures/blocks/stone.png"),
      dirt = love.graphics.newImage("assets/textures/blocks/dirt.png"),
      grass = love.graphics.newImage("assets/textures/blocks/grass.png"),
      sand = love.graphics.newImage("assets/textures/blocks/sand.png"),
      lava = {img = love.graphics.newImage("assets/textures/blocks/lava_animated.png"), frameHeight = 10, updateRate = 10, updateTime = 1, currFrame = 0},
      spawnPoint = love.graphics.newImage("assets/textures/blocks/checkpoint.png"),
      checkPoint = love.graphics.newImage("assets/textures/blocks/checkpoint.png")
    },

    other = {
      background = love.graphics.newImage("assets/textures/other/background.png")
    }
  }
end

display.animatedTile = function(tbl, x, y, sx, sy)
  local imgDim = {tbl.img:getDimensions()}

  if newTick then
    tbl.updateTime = (tbl.updateTime +1) %tbl.updateRate
    newTick = false
  end

  if tbl.updateTime == 0 then
    tbl.currFrame = (tbl.currFrame +1) %(imgDim[2] /tbl.frameHeight)
  end

  local quad = love.graphics.newQuad(1, tbl.currFrame *tbl.frameHeight, imgDim[1], tbl.frameHeight, imgDim[1], imgDim[2])
  love.graphics.draw(tbl.img, quad, x, y, 0, sx, sy)
end

display.map = function()
  for i=1,#mapGrid do
    for j=1,screenDim.x/blockSize + blockSize*2 do
      local cameraOffset = math.ceil(-cameraTranslation /blockSize -1)
      local currTable = mapGrid[i][j +cameraOffset]

      if type(currTable) == "table" then
        local currImage = texture.block[currTable.block]

        if type(currImage) == "table" then
          display.animatedTile(currImage, ((j +cameraOffset) -1) *blockSize, (i -1) *blockSize, screenDim.y/200, screenDim.y /200)

        else
          love.graphics.draw(currImage, ((j +cameraOffset) -1) *blockSize, (i -1) *blockSize, 0, screenDim.y/200, screenDim.y /200)
        end
      end
    end
  end
end

local function createBackgroundTable(backgroundTexture)
  local tbl = {}
  local backgroundW = screenDim.x
  local scrollSpeed = cameraTranslation*(2/3) +1
  local backgroundOffset = math.floor(scrollSpeed /backgroundW /2 +1)

  while #tbl *backgroundW - (scrollSpeed % backgroundW) < screenDim.x do
    table.insert(tbl,{backgroundTexture, 0 -scrollSpeed +(#tbl - backgroundOffset) *backgroundW, 0, 0, screenDim.x /backgroundTexture:getWidth(), screenDim.y /backgroundTexture:getHeight()})
  end

  return tbl
end

display.background = function()
  local backgroundTexture = texture.other.background
  local bgTable = createBackgroundTable(backgroundTexture)

  for i=1, #bgTable do
    local currBg = bgTable[i]
    love.graphics.draw(currBg[1], currBg[2], currBg[3], currBg[4], currBg[5], currBg[6])
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
