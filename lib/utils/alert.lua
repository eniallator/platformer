local alert = {}

local function createButtonTable(buttons, dim, display)
  local innerArea = {x = dim.x +5, y = dim.y +5, w = dim.w -10, h = dim.h -10}
  local tbl = {}
  buttons = buttons or {}

  for i=0, #buttons-1 do
    tbl[buttons[i +1].name] = {func = buttons[i +1].func, name = buttons[i +1].name, x = innerArea.x +i *((innerArea.w +5) /#buttons), y = innerArea.y +dim.h /2, w = innerArea.w /#buttons, h = innerArea.h /2 -5}
  end

  return tbl
end

alert.display = function(currAlert)
  local font = love.graphics.getFont()
  local dim = currAlert.dimensions()
  local translatedX = dim.x -cameraTranslation

  love.graphics.setColor(100, 100, 100)
  love.graphics.rectangle("fill", translatedX, dim.y, dim.w, dim.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(currAlert.message, translatedX +5, dim.y +5)

  local buttonTable = createButtonTable(currAlert.buttons, dim)

  for _,box in pairs(buttonTable) do
    display.box(box)
  end

  collision.updateMouseCursor(buttonTable)
end

local function checkTimer(currAlert)
  if currAlert.time then
    currAlert.currTime = currAlert.currTime and currAlert.currTime + 1 or 1

    if currAlert.currTime > currAlert.time then
      utilsData.alert.selected = nil
      currAlert.currTime = nil
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
