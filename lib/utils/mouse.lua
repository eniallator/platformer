local mouse = {
    left = {id = 1},
    right = {id = 2}
}

local function updateMouseState(mouseButton)
  mouseButton.clicked = false

  if love.mouse.isDown(mouseButton.id) then
    if not mouseButton.held then
      mouseButton.clicked = true
    end

    mouseButton.held = true
  else
    mouseButton.held = false
  end
end

mouse.updateState = function()
  updateMouseState(mouse.left)
  updateMouseState(mouse.right)
end

return mouse
