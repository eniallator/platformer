local alert = {}

local function createButtonTable(buttons, dim, display)
  local innerArea = {x = dim.x +5, y = dim.y +5, w = dim.w -10, h = dim.h -10}
  local tbl = {}

  for i=0, #buttons-1 do
    tbl[buttons[i +1].name] = {func = buttons[i +1].func, name = buttons[i +1].name, x = innerArea.x +i *((innerArea.w +5) /#buttons), y = innerArea.y +dim.h /2, w = innerArea.w /#buttons, h = innerArea.h /2 -5}
  end

  return tbl
end

alert.display = function(message, buttons, dim)
  local font = love.graphics.getFont()

  love.graphics.setColor(100, 100, 100)
  love.graphics.rectangle("fill", dim.x, dim.y, dim.w, dim.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(message, dim.x +5, dim.y +5)

  local buttonTable = createButtonTable(buttons, dim)

  for _,box in pairs(buttonTable) do
    display.box(box)
  end

  collision.updateMouseCursor(buttonTable)
end

alert.getInput = function(buttons, dim)
  local buttonTable = createButtonTable(buttons, dim)
  local buttonClicked = collision.clickBox(buttonTable)

  if buttonClicked then
    buttonTable[buttonClicked].func()
  end
end

return alert
