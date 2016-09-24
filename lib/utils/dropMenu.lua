local dropMenuCoords = {}
local dropMenu = {}

local function tableProperties(font, tbl)
  local maxWidth = 0
  local maxLength = 0

  for i=1, #tbl do
    currWidth = font:getWidth(tbl[i].name)
    maxLength = i

    if currWidth > maxWidth then
      maxWidth = currWidth
    end
  end

  return maxWidth, maxLength
end

local function createButtonTable(tbl, coords)
  local font = love.graphics.getFont()
  local maxWidth, maxLength = tableProperties(font, tbl)
  local outTbl = {}

  for i=0, #tbl -1 do
    local name = tbl[i +1].name
    outTbl[name] =  {func = tbl[i +1].func, name = name, x = coords.x + 5, y = 5 +coords.y +i *(font:getHeight(name) +5), w = maxWidth, h = font:getHeight(name)}
  end

  return outTbl
end

dropMenu.display = function(buttons, coords)
  local font = love.graphics.getFont()
  local maxWidth, maxLength = tableProperties(font, buttons)

  if coords.x > screenDim.x - maxWidth - 10 then
    coords.x = screenDim.x -maxWidth -10
    maxWidth = tableProperties(font, buttons)
  end

  if coords.y > screenDim.y -maxLength *(font:getHeight("l") +5) -5 then
    coords.y = screenDim.y -maxLength *(font:getHeight("l") +5) -5
    _, maxLength = tableProperties(font, buttons)
  end

  dropMenuCoords = coords
  buttonTable = createButtonTable(buttons, coords)

  love.graphics.setColor(100, 100, 100)
  love.graphics.rectangle("fill", coords.x, coords.y, maxWidth +10, 5 +maxLength *(font:getHeight("l") +5))

  for _, box in pairs(buttonTable) do
    display.box(box)
  end

  love.graphics.setColor(255, 255, 255)
end

dropMenu.reset = function()
  utilsData.dropMenu.selected = nil
  utilsData.dropMenu.mapName = nil
  utilsData.dropMenu.coords = nil
end

dropMenu.getInput = function(buttons, mapName)
  local buttonTable = createButtonTable(buttons, dropMenuCoords)
  local buttonClicked = collision.clickBox(buttonTable)

  if buttonClicked then
    buttonTable[buttonClicked].func(mapName)
    dropMenu.reset()

  elseif mouse.left.clicked then
    dropMenu.reset()
  end
end

return dropMenu
