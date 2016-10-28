local display = {}

local xCounter = 0

display.loadTextures = function()

  texture = {
    block = {
      stone = love.graphics.newImage("assets/textures/blocks/stone.png"),
      dirt = love.graphics.newImage("assets/textures/blocks/dirt.png"),
      grass = love.graphics.newImage("assets/textures/blocks/grass.png"),
      sand = love.graphics.newImage("assets/textures/blocks/sand.png"),
      wood = love.graphics.newImage("assets/textures/blocks/wood.png"),
      brick = love.graphics.newImage("assets/textures/blocks/brick.png"),
      lava = {img = love.graphics.newImage("assets/textures/blocks/lava_animated.png"), frameHeight = 10, updateRate = 10, updateTime = 1, currFrame = 0},
      spawnPoint = love.graphics.newImage("assets/textures/blocks/checkpoint.png"),
      checkPoint = love.graphics.newImage("assets/textures/blocks/checkpoint.png"),
      goal = love.graphics.newImage("assets/textures/blocks/goal.png")
    },

    other = {
      background = love.graphics.newImage("assets/textures/other/background.png")
    }
  }
end

display.animatedTile = function(tbl, x, y, sx, sy)
  local imgDim = {tbl.img:getDimensions()}

  if newTick then
    tbl.updateTime = (tbl.updateTime + 1) % tbl.updateRate
    newTick = false
  end

  if tbl.updateTime == 0 then
    tbl.currFrame = (tbl.currFrame + 1) % (imgDim[2] / tbl.frameHeight)
  end

  local quad = love.graphics.newQuad(1, tbl.currFrame * tbl.frameHeight, imgDim[1], tbl.frameHeight, imgDim[1], imgDim[2])
  love.graphics.draw(tbl.img, quad, x, y, 0, sx, sy)
end

display.map = function()
  for i=1, #mapGrid do
    for j=1, screenDim.x / blockSize + blockSize * 2 + 1 do
      local cameraOffset = math.ceil(- cameraTranslation / blockSize - 1)
      local currTable = mapGrid[i][j + cameraOffset - 1]

      if type(currTable) == "table" then
        local currImage = texture.block[currTable.block]
        local currBlock = blocks[collision.getBlock(currTable.block)]
        local scale = currBlock.scale or 1

        if type(currImage) == "table" then
          display.animatedTile(currImage, ((j + cameraOffset) - 2) * blockSize, (i - 1) * blockSize, screenDim.y / 200 * scale, screenDim.y / 200 * scale)

        else
          love.graphics.draw(currImage, ((j + cameraOffset) - 2) * blockSize, (i - 1) * blockSize, 0, screenDim.y / 200 * scale, screenDim.y / 200 * scale)
        end
      end
    end
  end
end

local function createBackgroundTable(backgroundTexture)
  local tbl = {}
  local backgroundW = screenDim.x
  local scrollSpeed = cameraTranslation * (2 / 3) + 1
  local backgroundOffset = math.floor(scrollSpeed / backgroundW / 2 + 1)

  while #tbl * backgroundW - (scrollSpeed % backgroundW) < screenDim.x do
    table.insert(tbl,{backgroundTexture, 0 - scrollSpeed + (#tbl - backgroundOffset) * backgroundW, 0, 0, screenDim.x / backgroundTexture:getWidth(), screenDim.y / backgroundTexture:getHeight()})
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
  love.graphics.rectangle("fill", box.x - cameraTranslation, box.y, box.w, box.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(box.name, box.x + box.w / 2 - font:getWidth(box.name) / 2 - cameraTranslation, box.y + box.h / 2 - font:getHeight(box.name) / 2, box.w)
end

local function displayTbl(tbl, condition)
  if condition then
    for _, box in pairs(tbl) do
      display.box(box)
    end
  end
end

local function displayBlockMenuButton(tbl)
  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x/60))
  display.box(tbl)
  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x/40))
end

display.blockMenu = function()
  if mapCreatorMenu then
    local blockMenuTable = optionData.blockMenu.display()
    collision.updateMouseCursor(blockMenuTable)
    love.graphics.setColor(120, 120, 120)
    love.graphics.rectangle("fill", screenDim.x / 60 - cameraTranslation, screenDim.y - screenDim.y / 9, screenDim.x - screenDim.x / 60 * 2, blockSize * 2)
    love.graphics.setColor(255, 255, 255)

    for i=1, #blockMenuTable do
      local currBlock = blockMenuTable[i]

      if type(currBlock.texture) == "table" then
        display.animatedTile(currBlock.texture, currBlock.x - cameraTranslation, currBlock.y, blockSize / currBlock.texture.img:getWidth(), blockSize / currBlock.texture.frameHeight)

      else
        love.graphics.draw(currBlock.texture, currBlock.x - cameraTranslation, currBlock.y, 0, blockSize / currBlock.texture:getWidth(), blockSize / currBlock.texture:getHeight())
      end
    end

    if blockMenuTable.nextPage then
      displayBlockMenuButton(blockMenuTable.nextPage)
    end

    if blockMenuTable.prevPage then
      displayBlockMenuButton(blockMenuTable.prevPage)
    end
  end
end

display.escMenu = function()
  displayTbl(optionData.escMenu.display(), escMenuOn)
end

display.winMenu = function()
  displayTbl(optionData.winMenu.display(), reachedGoal)
end

display.timeCounter = function()
  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x / 20))
  love.graphics.setColor(255, 255, 255)

  local time = timeCounter / 60
  love.graphics.print(time - time % 0.01, - cameraTranslation)

  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x / 40))
end

display.optionMenu = function()
  for _, box in pairs(optionData[currMenu].display()) do
    display.box(box)
  end
end

display.textBox = function()
  display.background()

  if utilsData.textBox.selected == "saveMap" then
    display.map()
  end

  local currTextBox = utilsData.textBox[utilsData.textBox.selected]
  textBox.display(currTextBox.title, textBox.currText, currTextBox.dimensions())
end

display.alert = function()
  if utilsData.alert.selected then
    local currAlert = utilsData.alert[utilsData.alert.selected]
    alert.display(currAlert.message, currAlert.buttons, currAlert.dimensions())
  end
end

display.makeScreenRed = function()
  if screenRed and screenRed > 0 then
    screenRed = screenRed - 3

  else
    screenRed = 0
  end

  love.graphics.setColor(255, 255 - screenRed, 255 - screenRed)
end

display.borders = function()
  if borders.x > 0 then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", - cameraTranslation + screenDim.x , 0, borders.x / 2, screenDim.y)
    love.graphics.rectangle("fill", - cameraTranslation - borders.x / 2, 0, borders.x / 2, screenDim.y)
  end
end

return display
