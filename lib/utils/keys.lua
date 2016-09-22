local keys = {
  state = {},
  currKey = nil
}

keys.updateState = function(key, newMode)
  if key == "capslock" then
    if newMode then
      keys.state.capslock = not keys.state.capslock
    end

  else
    if newMode then
      if key == "escape" and selected ~= "menu" then
        escPressed = true
      end

      keys.currKey = key

    else
      if keys.currKey == key then
        keys.currKey = nil
      end
    end

    keys.state[key] = newMode
  end
end

return keys
