local display = {}

local xCounter = 0

display.loadTextures = function()

  texture = {
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
