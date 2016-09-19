local timer = 0
local lastChar = nil
local utils = {}

utils.keys = {}

utils.textBox = {
  selected = nil,
  currText = {},
  currChar = nil,
  focusedChar = 1,
  showedText = 1,
  currCharDelay = 40,
  type = {
    saveMap = {
      title ="Map Name:", acceptedKeys = "^%w$", x = screenDim.x /2 -150, y = screenDim.y /2 - 35, w = 300, h = 70,
      func = function (mapName) map.writeTable(map.transform(mapGrid), "maps/" .. mapName .. ".map") end
    }
  }
}

local function resetTextBox()
  utils.textBox.selected = nil
  utils.textBox.currText = {}
  utils.textBox.focusedChar = 1
  utils.textBox.showedText = 1
end

local function createDisplayText(text, textArea)
  local font = love.graphics.getFont()
  local displayText = ""

  for i=1,#text do
    displayText = displayText .. text[i]
  end

  displayText = displayText:sub(utils.textBox.showedText,#displayText)

  while font:getWidth(displayText) > textArea.w -10 do
    displayText = displayText:sub(1, #displayText -1)
  end

  return displayText
end

utils.textBox.display = function(title, currentText, x, y, w, h)
  x = x -cameraTranslation
  local font = love.graphics.getFont()
  local textArea = {x = x +5, y = y + h -font:getHeight(title) -15, w = w -10, h = font:getHeight(title) +10}
  local cursorDelay = 50

  if utils.textBox.focusedChar -1 <= utils.textBox.showedText and #utils.textBox.currText > 0 then
    utils.textBox.showedText = utils.textBox.focusedChar -1

  elseif utils.textBox.focusedChar > utils.textBox.showedText +#createDisplayText(currentText, textArea) then
    utils.textBox.showedText = utils.textBox.showedText +1
  end

  local displayText = createDisplayText(currentText, textArea)

  love.graphics.setColor(150, 150, 150)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(title, x +5, y +5)
  love.graphics.setColor(220, 220, 220)
  love.graphics.rectangle("fill", textArea.x, textArea.y, textArea.w, textArea.h)
  love.graphics.setColor(100, 100, 100)
  love.graphics.print(displayText, textArea.x +5, textArea.y +5)

  timer = (timer + 1) %cursorDelay

  if timer < cursorDelay /2 then
    love.graphics.rectangle("fill", textArea.x +5 +font:getWidth(displayText:sub(1,utils.textBox.focusedChar -utils.textBox.showedText)), textArea.y +5, 2, font:getHeight(title))
  end

  love.graphics.setColor(255, 255, 255)
end

utils.textBox.getInput = function()
  if utils.textBox.currChar ~= lastChar then
    utils.textBox.currCharDelay = 40
  end

  if utils.textBox.currChar then
    if utils.textBox.currChar ~= lastChar or utils.textBox.currCharDelay <= 0 then
      if utils.textBox.currCharDelay <= 0 then
        utils.textBox.currCharDelay = 2
      end

      if utils.textBox.currChar:find(utils.textBox.type[utils.textBox.selected].acceptedKeys) then
        local char = utils.textBox.currChar

        local upperCaseXOR = 0

        if utils.keys.rshift or utils.keys.lshift then
          upperCaseXOR = 1
        end

        if utils.keys.capslock then
          upperCaseXOR = upperCaseXOR + 1
        end

        if upperCaseXOR %2 == 1 then
          char = char:upper()
        end

        table.insert(utils.textBox.currText, utils.textBox.focusedChar, char)
        utils.textBox.focusedChar = utils.textBox.focusedChar + 1

      elseif utils.textBox.currChar == "backspace" and #utils.textBox.currText > 0 or utils.textBox.currChar == "delete" and utils.textBox.focusedChar <= #utils.textBox.currText then
        local offset = 0

        if utils.textBox.currChar == "backspace" then
          offset = 1
        end

        table.remove(utils.textBox.currText, utils.textBox.focusedChar - offset)
        utils.textBox.focusedChar = utils.textBox.focusedChar - offset

      elseif utils.textBox.currChar == "left" and utils.textBox.focusedChar -1 > 0 then
        utils.textBox.focusedChar = utils.textBox.focusedChar -1

      elseif utils.textBox.currChar == "right" and utils.textBox.focusedChar -1 < #utils.textBox.currText then
        utils.textBox.focusedChar = utils.textBox.focusedChar +1

      elseif utils.textBox.currChar == "return" then
        local textInput = ""

        for i=1, #utils.textBox.currText do
          textInput = textInput .. utils.textBox.currText[i]
        end

        utils.textBox.type[utils.textBox.selected].func(textInput)
        resetTextBox()
      end
    end
  end

  if utils.textBox.currChar then
    utils.textBox.currCharDelay = utils.textBox.currCharDelay -1
  end

  lastChar = utils.textBox.currChar
end

return utils
