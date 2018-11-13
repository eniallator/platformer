local keys = {
  state = {}
}

local function updateKeyState(key, newMode)
  if key == controls[controls.findName('mapCreator.blockMenu')].key then
    update.mapCreatorBlockMenu()
  end

  escPressed = newMode and key == 'escape' and selected ~= 'menu' or escPressed
  keys.currKey = newMode and key or keys.currKey ~= key and keys.currKey
  keys.state[key] = newMode
end

function love.keypressed(key)
  updateKeyState(key, true)
end

function love.keyreleased(key)
  updateKeyState(key, false)
end

function love.textinput(text)
  keys.textInput = text
end

return keys
