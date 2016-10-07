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

controls.applyChanges = function()
  controlsStr = ""

  for i=1, #controls do
    if i > 1 then
      controlsStr = controlsStr .. "\r\n"
    end

    controlsStr = controlsStr .. controls[i].name .. ': "' .. controls[i].key .. '"'
  end

  love.filesystem.write("controls.cfg", controlsStr)
end

local function getCompareTblVal(tbl, name)
  for i=1, #tbl do
    if tbl[i].name == name then
      return i
    end
  end
end

local function updateControlTbl(compareTbl)
  for i=1, #controls do
    local index = getCompareTblVal(compareTbl, controls[i].name)

    if index and compareTbl[index].name == controls[i].name then
      controls[i].key = compareTbl[index].key
    end
  end
end

controls.loadControls = function()
  if not love.filesystem.exists("controls.cfg") then
    controls.applyChanges()
    return
  end

  local compareTbl = {}

  for line in love.filesystem.lines("controls.cfg") do
    local name = line:sub(line:find("^[%.%w]*:"))
    name = name:sub(1, #name -1)

    local key = line:sub(line:find('".*"$'))
    key = key:sub(2, #key -1)

    table.insert(compareTbl, {key = key, name = name})
  end

  updateControlTbl(compareTbl)
end

return controls
