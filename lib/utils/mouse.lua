local mouse = {
    left = {id = 1},
    right = {id = 2}
}

local function updateMouseState(mouseButton)
  mouseButton.clicked = false

  if love.mouse.isDown(mouseButton.id) then
    mouseButton.held = true

    if not mouseButton.stillDown then
      mouseButton.clicked = true
    end

    mouseButton.stillDown = true
  else
    mouseButton.held = false
    mouseButton.stillDown = false
  end
end

mouse.updateState = function()
  updateMouseState(mouse.left)
  updateMouseState(mouse.right)
end

return mouse
