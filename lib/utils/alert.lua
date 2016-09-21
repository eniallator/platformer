local alert = {}

local function createButtonTable(buttons, dim, display)
  local innerArea = {x = dim.x +5, y = dim.y +5, w = dim.w -10, h = dim.h -10}
  local tbl = {}

  if not display then
    tbl.func = {}
    tbl.box = {}
  end

  for i=0, #buttons-1 do
    local box = {name = buttons[i +1].name, x = innerArea.x +i *((innerArea.w +5) /#buttons), y = innerArea.y +dim.h /2, w = innerArea.w /#buttons, h = innerArea.h /2 -5}
    local func = buttons[i +1].func

    if not display then
      tbl.box[buttons[i +1]] = box
      tbl.func[buttons[i +1]] = func

    else
      table.insert(tbl,{box = box, func = func})
    end
  end

  return tbl
end

alert.display = function(message, buttons, dim)
  local font = love.graphics.getFont()

  love.graphics.setColor(100, 100, 100)
  love.graphics.rectangle("fill", dim.x, dim.y, dim.w, dim.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(message, dim.x +5, dim.y +5)

  local buttonDims = createButtonTable(buttons, dim, true)

  for i=1, #buttonDims do
    display.box(buttonDims[i].box)
  end
end

alert.getInput = function(buttons, dim)
  local buttonTable = createButtonTable(buttons, dim)
  local buttonClicked = collision.clickBox(buttonTable.box)

  if buttonClicked then
    buttonTable.func[buttonClicked]()
  end
end

return alert
