local controls = {
  waitForPress = nil,
  {name = "game.jump", key = "up"},
  {name = "game.right", key = "right"},
  {name = "game.left", key = "left"},
  {name = "mapCreator.blockMenu", key = "m"},
  {name = "mapCreator.scrollRight", key = "right"},
  {name = "mapCreator.scrollLeft", key = "left"}
}

controls.findName = function(name)
  for i=1, #controls do
    if controls[i].name == name then
      return i
    end
  end
end

controls.getKeyInput = function()
  if controls.waitForPress and keys.currKey then
    controls[controls.waitForPress].key = keys.currKey
    controls.waitForPress = nil
  end
end

return controls
