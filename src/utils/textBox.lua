local timer = 0
local lastChar = nil
local defaultCharDelay = 50
local textBox = {}

local function createDisplayText(text, textArea)
  local font = love.graphics.getFont()
  local displayText = ''

  for i = 1, #text do
    displayText = displayText .. text[i]
  end

  displayText = displayText:sub(textBox.showedText, #displayText)

  while font:getWidth(displayText) > textArea.w - 10 do
    displayText = displayText:sub(1, #displayText - 1)
  end

  return displayText
end

local function renderTextBox(title, textArea, font, currentText, dim)
  local cursorBlinkDelay = 50
  local displayText = createDisplayText(currentText, textArea)

  love.graphics.setColor(150, 150, 150)
  love.graphics.rectangle('fill', dim.x, dim.y, dim.w, dim.h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(title, dim.x + 5, dim.y + 5)
  love.graphics.setColor(220, 220, 220)
  love.graphics.rectangle('fill', textArea.x, textArea.y, textArea.w, textArea.h)
  love.graphics.setColor(100, 100, 100)
  love.graphics.print(displayText, textArea.x + 5, textArea.y + 5)

  if not textBox.stopped then
    timer = (timer + 1) % cursorBlinkDelay
  end

  if timer < cursorBlinkDelay / 2 then
    love.graphics.rectangle(
      'fill',
      textArea.x + 5 + font:getWidth(displayText:sub(1, textBox.focusedChar - textBox.showedText)),
      textArea.y + 5,
      2,
      font:getHeight(title)
    )
  end

  love.graphics.setColor(255, 255, 255)
end

textBox.reset = function()
  utilsData.textBox.selected = nil
  textBox.currCharDelay = defaultCharDelay
  textBox.currText = {}
  textBox.focusedChar = 1
  textBox.showedText = 1
  textBox.stopped = false

  if isSmartPhone then
    love.keyboard.setTextInput(false)
  end
end

textBox.display = function(title, currentText, dim)
  dim.x = dim.x - cameraTranslation
  local font = love.graphics.getFont()
  local textArea = {x = dim.x + 5, y = dim.y + dim.h - font:getHeight(title) - 15, w = dim.w - 10, h = font:getHeight(title) + 10}

  if textBox.focusedChar - 1 <= textBox.showedText and #textBox.currText > 0 then
    textBox.showedText = textBox.focusedChar - 1
  elseif textBox.focusedChar > textBox.showedText + #createDisplayText(currentText, textArea) then
    textBox.showedText = textBox.showedText + 1
  end

  renderTextBox(title, textArea, font, currentText, dim)
end

local function checkText(selectedTextBox)
  local textInput = ''

  for i = 1, #textBox.currText do
    textInput = textInput .. textBox.currText[i]
  end

  local funcOutput = selectedTextBox.func(textInput)

  if funcOutput == 'stop' then
    textBox.stopped = true
  elseif funcOutput then
    return funcOutput
  else
    return true
  end
end

local function backSpace()
  if #textBox.currText > 0 then
    table.remove(textBox.currText, textBox.focusedChar - 1)
    textBox.focusedChar = textBox.focusedChar - 1
  end
end

textBox.getInput = function(selectedTextBox)
  if keys.currKey ~= lastChar then
    textBox.currCharDelay = defaultCharDelay
  end

  if textBox.stopped then
    checkText(selectedTextBox)
  else
    if keys.textInput and keys.textInput:find(selectedTextBox.acceptedKeys) then
      table.insert(textBox.currText, textBox.focusedChar, keys.textInput)
      textBox.focusedChar = textBox.focusedChar + 1
    elseif keys.textInput and keys.textInput == '\b' then
      backSpace()
    elseif keys.currKey and keys.currKey ~= lastChar or textBox.currCharDelay <= 0 then
      if textBox.currCharDelay <= 0 then
        textBox.currCharDelay = 4
      end

      if keys.currKey == 'backspace' then
        backSpace()
      elseif keys.currKey == 'delete' and textBox.focusedChar <= #textBox.currText then
        table.remove(textBox.currText, textBox.focusedChar)
      elseif keys.currKey == 'left' and textBox.focusedChar - 1 > 0 then
        textBox.focusedChar = textBox.focusedChar - 1
      elseif keys.currKey == 'right' and textBox.focusedChar - 1 < #textBox.currText then
        textBox.focusedChar = textBox.focusedChar + 1
      elseif keys.currKey == 'return' then
        if checkText(selectedTextBox) == 'stop' then
          textBox.reset()
        end
      elseif update.checkEscButton() then
        textBox.reset()
      end
    end
  end

  if keys.currKey then
    textBox.currCharDelay = textBox.currCharDelay - 1
  end

  lastChar = keys.currKey
end

return textBox
