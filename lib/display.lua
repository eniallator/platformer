local display = {}

display.loadTextures = function()

  texture = {
    block = {
      stone = love.graphics.newImage("assets/textures/blocks/stone.png"),
      dirt = love.graphics.newImage("assets/textures/blocks/dirt.png"),
      grass = love.graphics.newImage("assets/textures/blocks/grass.png"),
      sand = love.graphics.newImage("assets/textures/blocks/sand.png"),
      wood = love.graphics.newImage("assets/textures/blocks/wood.png"),
      brick = love.graphics.newImage("assets/textures/blocks/brick.png"),
      lava = {
        img = love.graphics.newImage("assets/textures/blocks/lava_animated.png"),
        frameHeight = 10,
        updateRate = 20,
        updateTime = 1,
        currFrame = 0
      },
      spawnPoint = love.graphics.newImage("assets/textures/blocks/spawnpoint.png"),
      checkPoint = love.graphics.newImage("assets/textures/blocks/checkpoint.png"),
      goal = love.graphics.newImage("assets/textures/blocks/goal.png")
    },

    other = {
      background = love.graphics.newImage("assets/textures/other/background.png"),
      menuButton = love.graphics.newImage("assets/textures/other/menu_button.png"),
      blockMenuBackground = love.graphics.newImage("assets/textures/other/block_menu_background.png"),
      dragIcon = love.graphics.newImage("assets/textures/icons/draggable_icon.png")
    }
  }
end

display.animatedTile = function(tbl, x, y, sx, sy)
  local imgDim = {tbl.img:getDimensions()}

  if newTick then
    tbl.updateTime = (tbl.updateTime + 1) % tbl.updateRate
    newTick = false

    if tbl.updateTime == 0 then
      tbl.currFrame = (tbl.currFrame + 1) % (imgDim[2] / tbl.frameHeight)
    end
  end


  local quad = love.graphics.newQuad(1, tbl.currFrame * tbl.frameHeight, imgDim[1], tbl.frameHeight, imgDim[1], imgDim[2])
  love.graphics.draw(tbl.img, quad, x, y, 0, sx, sy)
end

local function displayGrid(level)
  for i=1, #mapGrid[level] do
    for j=1, screenDim.x / blockSize + blockSize * 2 + 1 do
      local cameraOffset = math.ceil(- cameraTranslation / blockSize - 1)
      local currTable = mapGrid[level][i][j + cameraOffset - 1]

      if type(currTable) == "table" then
        local currImage = texture.block[currTable.block]
        local currBlock = blocks[collision.getBlock(currTable.block)]
        local scale = currBlock.scale or 1

        if type(currImage) == "table" then
          display.animatedTile(
            currImage,
            ((j + cameraOffset) - 2) * blockSize,
            (i - 1) * blockSize,
            screenDim.y / 200 * scale,
            screenDim.y / 200 * scale
          )

        else
          love.graphics.draw(
            currImage,
            ((j + cameraOffset) - 2) * blockSize,
            (i - 1) * blockSize,
            0,
            screenDim.y / 200 * scale,
            screenDim.y / 200 * scale
          )
        end
      end
    end
  end
end

display.map = {}

display.map.background = function()
  love.graphics.setColor(180, 180, 180)
  displayGrid("background")
  love.graphics.setColor(255, 255 - screenRed, 255 - screenRed)
end

display.map.foreground = function()
  displayGrid("foreground")
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

local function textCut(text, maxWidth, font)
  if font:getWidth(text) < maxWidth then
    return text

  else
    while font:getWidth(text .. "...") + 20 >= maxWidth do
      text = text:sub(1,#text -1)
    end

    return text .. "..."
  end
end

local function displayBoxTexture(box)
  local font = love.graphics.getFont()
  local texture = texture.other.menuButton
  local shortName = textCut(box.name, box.w, font)

  love.graphics.draw(texture, box.x - cameraTranslation, box.y, 0, box.w / texture:getWidth(), box.h / texture:getHeight())
  love.graphics.printf(shortName, box.x + box.w / 2 - font:getWidth(shortName) / 2 - cameraTranslation, box.y + box.h / 2 - font:getHeight(shortName) / 2, box.w)
end

local function displayTbl(tbl, condition)
  if condition then
    for _, box in pairs(tbl) do
      displayBoxTexture(box)
    end
  end
end

local function displayBlockMenuButton(tbl)
  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x/60))
  displayBoxTexture(tbl)
  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x/40))
end

local function blockMenuBackground()
  local texture = texture.other.blockMenuBackground
  local dim = {
    x = screenDim.x / 60 - cameraTranslation,
    y = screenDim.y - screenDim.y / 9,
    w = screenDim.x - screenDim.x / 60 * 2,
    h = blockSize * 2
  }

  love.graphics.setColor(150, 150, 150)
  love.graphics.draw(texture, dim.x, dim.y, 0, dim.w / texture:getWidth(), dim.h / texture:getHeight())
  love.graphics.setColor(255, 255, 255)
end

local function blockMenuOtherButtons(blockMenuTable)
  if blockMenuTable.nextPage then
    displayBlockMenuButton(blockMenuTable.nextPage)
  end

  if blockMenuTable.prevPage then
    displayBlockMenuButton(blockMenuTable.prevPage)
  end

  displayBoxTexture(blockMenuTable.toggleMapGrid)
end

local function blockMenuHelpText()
  if not isSmartPhone and showBlockMenuHelpText then
    local font = love.graphics.getFont()
    local blockMenuKeyIndex = controls.findName("mapCreator.blockMenu")
    local blockMenuKey = controls[blockMenuKeyIndex].key
    local text = "Press " .. blockMenuKey .. " to open the block menu"

    love.graphics.print(text, - cameraTranslation, screenDim.y - font:getHeight(text))
  end
end

display.blockMenu = function()
  blockMenuHelpText()

  if isSmartPhone then
    for name,box in pairs(optionData.smartPhoneMapCreator.display()) do
      displayBoxTexture(box)
    end

    local coords = optionData.smartPhoneMapCreator.toggleBlockMenu
    local img = texture.other.dragIcon
    love.graphics.draw(img, coords.x, coords.y, 0, screenDim.y / 30 / img:getWidth(), screenDim.y / 30 / img:getHeight())
  end

  if mapCreatorMenu then
    local blockMenuTable = optionData.blockMenu.display()
    showBlockMenuHelpText = false
    collision.updateMouseCursor(blockMenuTable)
    blockMenuBackground()
    blockMenuOtherButtons(blockMenuTable)

    for i=1, #blockMenuTable do
      local currBlock = blockMenuTable[i]

      if type(currBlock.texture) == "table" then
        display.animatedTile(
          currBlock.texture,
          currBlock.x - cameraTranslation,
          currBlock.y,
          blockSize / currBlock.texture.img:getWidth(),
          blockSize / currBlock.texture.frameHeight
        )

      else
        love.graphics.draw(
          currBlock.texture,
          currBlock.x - cameraTranslation,
          currBlock.y,
          0,
          blockSize / currBlock.texture:getWidth(),
          blockSize / currBlock.texture:getHeight()
        )
      end
    end
  end
end

local function displayButton(box)
  local font = love.graphics.getFont()

  love.graphics.setColor(150, 150, 150)
  love.graphics.rectangle("fill", box.x - cameraTranslation, box.y, box.w, box.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(box.name, box.x + box.w / 2 - font:getWidth(box.name) / 2 - cameraTranslation, box.y + box.h / 2 - font:getHeight(box.name) / 2, box.w)
end

display.escMenu = function()
  if isSmartPhone and not escMenuOn and not reachedGoal then
    local box = {
      name = "esc",
      y = 0,
      w = screenDim.x / 15,
      h = screenDim.y / 25
    }
    box.x = screenDim.x / 2 - box.w / 2
    displayButton(box)
  end

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
    displayBoxTexture(box)
  end
end

display.textBox = function()
  display.background()

  if utilsData.textBox.selected == "saveMap" then
    display.map.background()
    display.map.foreground()
  end

  local currTextBox = utilsData.textBox[utilsData.textBox.selected]
  textBox.display(currTextBox.title, textBox.currText, currTextBox.dimensions())
end

display.alert = function()
  if utilsData.alert.selected then
    local currAlert = utilsData.alert[utilsData.alert.selected]
    alert.display(currAlert)
  end
end

display.makeScreenRed = function(tick)
  if screenRed and screenRed > 0 then
    screenRed = screenRed - 2

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
