local alert = {}

local function createButtonTable(buttons, dim, display)
  local innerArea = {x = dim.x + 5, y = dim.y + 5, w = dim.w - 10, h = dim.h - 10}
  local tbl = {}
  buttons = buttons or {}

  for i = 0, #buttons - 1 do
    tbl[buttons[i + 1].name] = {
      func = buttons[i + 1].func,
      name = buttons[i + 1].name,
      x = innerArea.x + i * ((innerArea.w + 5) / #buttons),
      y = innerArea.y + dim.h / 2,
      w = innerArea.w / #buttons,
      h = innerArea.h / 2 - 5
    }
  end

  return tbl
end

local function displayButton(box)
  local font = love.graphics.getFont()

  love.graphics.setColor(150, 150, 150)
  love.graphics.rectangle('fill', box.x - cameraTranslation, box.y, box.w, box.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(
    box.name,
    box.x + box.w / 2 - font:getWidth(box.name) / 2 - cameraTranslation,
    box.y + box.h / 2 - font:getHeight(box.name) / 2,
    box.w
  )
end

alert.display = function(currAlert)
  local font = love.graphics.getFont()
  local dim = currAlert.dimensions()
  local translatedX = dim.x - cameraTranslation

  love.graphics.setColor(100, 100, 100)
  love.graphics.rectangle('fill', translatedX, dim.y, dim.w, dim.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(currAlert.message, translatedX + 5, dim.y + 5)

  local buttonTable = createButtonTable(currAlert.buttons, dim)

  for _, box in pairs(buttonTable) do
    displayButton(box)
  end

  collision.updateMouseCursor(buttonTable)
end

local function checkTimer(currAlert)
  if currAlert.duration then
    currAlert.elapsedTime = currAlert.elapsedTime and currAlert.elapsedTime + 1 or 1

    if currAlert.elapsedTime > currAlert.duration then
      utilsData.alert.selected = nil
      currAlert.elapsedTime = nil
    end
  end
end

alert.getInput = function(currAlert)
  local buttonTable = createButtonTable(currAlert.buttons, currAlert.dimensions())
  local buttonClicked = collision.clickBox(buttonTable)

  if buttonClicked then
    buttonTable[buttonClicked].func()
  end

  checkTimer(currAlert)
end

return alert
