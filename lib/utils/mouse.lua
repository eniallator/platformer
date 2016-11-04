local mouse = {
    left = {id = 1},
    right = {id = 2}
}

mouse.updateState = function(isDown, x, y, id)
  local button = id == 1 and "left" or "right"
  mouse[button].pos = {x = x, y = y}
  mouse[button].clicked = not mouse[button].held and isDown
  mouse[button].held = isDown
end

return mouse
