local smartPhone = require "src.smartPhone"
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
        updateRate = 1/3
      },
      spawnPoint = love.graphics.newImage("assets/textures/blocks/spawnpoint.png"),
      checkPoint = love.graphics.newImage("assets/textures/blocks/checkpoint.png"),
      checkPoint_reached = love.graphics.newImage("assets/textures/blocks/checkpoint_reached.png"),
      goal = love.graphics.newImage("assets/textures/blocks/goal.png"),
    },

    other = {
      background = love.graphics.newImage("assets/textures/other/background.png"),
      menuButton = love.graphics.newImage("assets/textures/other/menu_button.png"),
      blockMenuBackground = love.graphics.newImage("assets/textures/other/block_menu_background.png"),
      dragIcon = love.graphics.newImage("assets/textures/icons/draggable_icon.png"),
      arrowIcon = love.graphics.newImage("assets/textures/icons/arrow_button.png")
    }
  }
end

display.animatedTile = function(tbl, x, y, sx, sy, dt)
  local imgDim = {tbl.img:getDimensions()}

  local totalCycleTime = tbl.updateRate * (imgDim[2] / tbl.frameHeight)
  local currFrame = math.floor((love.timer.getTime() % totalCycleTime) / tbl.updateRate)

  local quad = love.graphics.newQuad(1, currFrame * tbl.frameHeight, imgDim[1], tbl.frameHeight, imgDim[1], imgDim[2])
  love.graphics.draw(tbl.img, quad, x, y, 0, sx, sy)
end

local function check_cp_reached(x, y)
  local last_cp_reached = entity.player.last_checkpoint

  if last_cp_reached.x and last_cp_reached.x == x and last_cp_reached.y == y then
    love.graphics.draw(
      texture.block.checkPoint_reached,
      (x - 1) * blockSize,
      (y - 1) * blockSize,
      0,
      screenDim.y / 200,
      screenDim.y / 200
    )

    return true
  end
end

local function displayGrid(level, dt)
  for i=1, #mapGrid[level] do
    for j=1, screenDim.x / blockSize + blockSize * 2 + 1 do
      local cameraOffset = math.ceil(- cameraTranslation / blockSize - 1)
      local currTable = mapGrid[level][i][j + cameraOffset - 1]

      if type(currTable) == "table" then
        local currImage = texture.block[currTable.block]
        local currBlock = blocks[collision.getBlock(currTable.block)]
        local scale = currBlock.scale or 1

        if not check_cp_reached(j + cameraOffset - 1, i) then
          if type(currImage) == "table" then
            display.animatedTile(
              currImage,
              ((j + cameraOffset) - 2) * blockSize,
              (i - 1) * blockSize,
              screenDim.y / 200 * scale,
              screenDim.y / 200 * scale,
              dt
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
end

display.map = {}

display.map.background = function(dt)
  love.graphics.setColor(180, 180, 180)
  displayGrid("background", dt)
  display.makeScreenRed()
end

display.map.foreground = function(dt)
  displayGrid("foreground", dt)
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

local function displayBlockMenuButtons(tbl)
  for name, box in pairs(tbl) do
    love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x/60))
    displayBoxTexture(box)
    love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x/40))
  end
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

local function filterButtonsOut(tbl)
  local newTbl = {}
  local arrayIndex = 1

  for k,v in pairs(tbl) do
    if k ~= arrayIndex and k ~= "nextPage" and k ~= "prevPage" and not v.notButton then
      newTbl[k] = v
    end

    arrayIndex = arrayIndex + 1
  end

  return newTbl
end

local function blockMenuOtherButtons(blockMenuTable)
  if blockMenuTable.nextPage then
    displayBlockMenuButton(blockMenuTable.nextPage)
  end

  if blockMenuTable.prevPage then
    displayBlockMenuButton(blockMenuTable.prevPage)
  end

  displayBlockMenuButtons(filterButtonsOut(blockMenuTable), true)
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

local function blockMenuButton()
  if isSmartPhone then
    for name,box in pairs(optionData.smartPhoneMapCreator.display()) do
      displayBoxTexture(box)
    end

    local img = texture.other.dragIcon
    local iconTbl = optionData.smartPhoneMapCreator.displayIcon()

    love.graphics.setColor(180, 180, 180, 180)
    love.graphics.circle("fill", iconTbl.x - cameraTranslation, iconTbl.y, iconTbl.r)
    love.graphics.setColor(255, 255, 255)

    love.graphics.draw(img, iconTbl.x - iconTbl.r - cameraTranslation, iconTbl.y - iconTbl.r, 0, iconTbl.r * 2 / img:getWidth(), iconTbl.r * 2 / img:getHeight())
  end
end

display.blockMenu = function(dt)
  blockMenuHelpText()
  blockMenuButton()

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
          blockSize / currBlock.texture.frameHeight,
          dt
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
    local box = optionData.smartPhoneEscMenu.display()
    displayBoxTexture(box)
  end

  displayTbl(optionData.escMenu.display(), escMenuOn)
end

display.winMenu = function()
  displayTbl(optionData.winMenu.display(), reachedGoal)
end

display.timeCounter = function(dt)
  if not reachedGoal and not escMenuOn then
    timeCounter = timeCounter + dt
  end

  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x / 20))
  love.graphics.setColor(255, 255, 255)

  local time = timeCounter / tps
  love.graphics.print(time - time % 0.01, - cameraTranslation)

  love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x / 40))
end

display.optionMenu = function()
  for _, box in pairs(optionData[currMenu].display()) do
    displayBoxTexture(box)
  end
end

display.textBox = function()
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

display.makeScreenRed = function(dt)
  if dt then
    local updatedVal = screenRed - dt / 20
    screenRed = updatedVal > 0 and updatedVal or 0
  end

  redness = screenRed / screenRedMax * 100

  love.graphics.setColor(255, 255 - redness, 255 - redness)
end

display.borders = function()
  if borders.x > 0 then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", - cameraTranslation + screenDim.x , 0, borders.x / 2, screenDim.y)
    love.graphics.rectangle("fill", - cameraTranslation - borders.x / 2, 0, borders.x / 2, screenDim.y)
  else
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", - cameraTranslation, screenDim.y, screenDim.x, borders.y / 2)
    love.graphics.rectangle("fill", - cameraTranslation, - borders.y / 2, screenDim.x, borders.y / 2)
  end
end

display.arrowButtons = function()
  if selected == "game" then
    smartPhone.drawArrowButtons()

  elseif not mapCreatorMenu then
    smartPhone.drawHorzontalButtons()
  end
end

return display
