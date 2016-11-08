selectedBlockIndex = 1
local map = {}

local function createGrid(xMax,yMax)
  local tbl = {}

  for y=1,yMax do
    tbl[y] = {}

    for x=1,xMax do
      tbl[y][x] = "n"
    end
  end

  return tbl
end

local function getCoords(str)
  local xNum = str:find("x")
  local yNum = str:find("y")

  return tonumber(str:sub(xNum + 1, yNum - 1)), tonumber(str:sub(yNum + 1, #str))
end

local function applyFormattedMap(level)
  for coords, data in pairs(formattedMap[level]) do
    local blockX, blockY = getCoords(coords)

    for i=1,data.h do
      for j=1,data.w do
        mapGrid[level][blockY + i - 1][blockX + j - 1] = {block = data.block}
      end
    end
  end
end

map.makeGrid = function(x, y)
  mapGrid = {}
  mapGrid.foreground = createGrid(x, y)
  mapGrid.background = createGrid(x, y)
  applyFormattedMap("foreground")
  applyFormattedMap("background")
end

local function formattedTblToStr(tbl)
  local writeStr = ""

  for coords, data in pairs(tbl) do

    blockX, blockY = getCoords(coords)
    writeStr = writeStr .. "x" .. string.char(blockX - 1) .. "y" .. string.char(blockY - 1) .. "b" .. string.char(collision.getBlock(data.block) - 1)

    if data.w > 1 then
      writeStr = writeStr .. "w" .. string.char(data.w - 2)
    end

    if data.h > 1 then
      writeStr = writeStr .. "h" .. string.char(data.h - 2)
    end
  end

  return writeStr
end

map.writeTable = function(tbl, fileToWrite)
  local outStr = ""
  outStr = outStr .. formattedTblToStr(tbl.foreground)

  if tbl.background then
    outStr = outStr .. "t" .. formattedTblToStr(tbl.background)
  end

  love.filesystem.write(fileToWrite, outStr)
end

local function fileToFormattedTbl(rawTbl)
  local outTbl = {}
  local index = 1
  local outKey
  local indexCount

  while rawTbl[index] do
    indexCount = indexCount and indexCount + 1 or 1
    outTbl[indexCount] = {}

    while rawTbl[index] and rawTbl[index] ~= "t" do
      if rawTbl[index] == "x" then
        index = index + 1
        outKey = "x" .. string.byte(rawTbl[index]) + 1
        index = index + 1
      end

      if rawTbl[index] == "y" then
        index = index + 1
        outKey = outKey .. "y" .. string.byte(rawTbl[index]) + 1
        index = index + 1
      end

      outTbl[indexCount][outKey] = {}

      if rawTbl[index] == "b" then
        index = index + 1
        outTbl[indexCount][outKey].block = blocks[string.byte(rawTbl[index]) + 1].name
        index = index + 1
      end

      if rawTbl[index] == "w" then
        index = index + 1
        outTbl[indexCount][outKey].w = string.byte(rawTbl[index]) + 2
        index = index + 1
      end

      if rawTbl[index] == "h" then
        index = index + 1
        outTbl[indexCount][outKey].h = string.byte(rawTbl[index]) + 2
        index = index + 1
      end

      if not outTbl[indexCount][outKey].w then
        outTbl[indexCount][outKey].w = 1
      end

      if not outTbl[indexCount][outKey].h then
        outTbl[indexCount][outKey].h = 1
      end
    end

    index = index + 1
  end

  return outTbl
end

map.readTable = function(fileToRead)
  local rawTbl = {}
  local rawStr = love.filesystem.read(fileToRead)

  for i=1, #rawStr do
    table.insert(rawTbl, rawStr:sub(i, i))
  end

  local formattedArray = fileToFormattedTbl(rawTbl)
  local outTbl = {}
  outTbl.foreground = formattedArray[1] or {}
  outTbl.background = formattedArray[2] or {}
  return outTbl
end

local function checkEmpty(tbl)
  for i=1, #tbl do
    for j=1, #tbl[i] do
      if type(tbl[i][j]) == "table" then
        return i, j
      end
    end
  end

  return false
end

local function checkBlockRow(tbl, block, width, x, y)
  local allSame = true

  for i=0,width - 1 do
    if tbl[y] and type(tbl[y][x + i]) == "table" then
      if tbl[y][x + i].block ~= block then
        allSame = false
      end

    else
      allSame = false
    end
  end

  return allSame
end

local function copyTable(tbl)
  local newTbl = {}

  for k,v in pairs(tbl) do
    if type(v) == "table" then
      newTbl[k] = copyTable(v)

    else
      newTbl[k] = v
    end
  end

  return newTbl
end

local function createFormattedMapTbl(oldMap)
  local outMap = {}

  repeat
    local blockY, blockX = checkEmpty(oldMap)

    if blockY then
      local blocksWidth = 1
      local blocksHeight = 1
      local compareBlock = oldMap[blockY][blockX].block
      local currKey = "x" .. blockX .. "y" .. blockY

      outMap[currKey] = {block = compareBlock}

      while oldMap[blockY][blockX + blocksWidth] and oldMap[blockY][blockX + blocksWidth].block == compareBlock do
        blocksWidth = blocksWidth + 1
      end

      while checkBlockRow(oldMap, compareBlock, blocksWidth, blockX, blockY + blocksHeight) do
        blocksHeight = blocksHeight + 1
      end

      outMap[currKey].w = blocksWidth
      outMap[currKey].h = blocksHeight

      for i=1, blocksHeight do
        for j=1, blocksWidth do
          oldMap[blockY + i - 1][blockX + j - 1] = "n"
        end
      end
    end

  until not blockY

  return outMap
end

map.transform = function(mapTbl)
  local outMap = {}
  outMap.foreground = createFormattedMapTbl(copyTable(mapTbl.foreground))
  outMap.background = createFormattedMapTbl(copyTable(mapTbl.background))
  return outMap
end

map.destroyBlock = function(coords)
  mapGrid[currSelectedGrid][math.ceil(coords.y / blockSize)][math.ceil(coords.x / blockSize)] = "n"
end

map.placeBlock = function(coords)
  mapGrid[currSelectedGrid][math.ceil(coords.y / blockSize)][math.ceil(coords.x / blockSize)] = {block = blocks[selectedBlockIndex].name}
end

map.syncDefaultMaps = function()
  if not love.filesystem.isDirectory("maps") then
    love.filesystem.createDirectory("maps")
  end

  for name,mapData in pairs(defaultMaps) do
    if not love.filesystem.exists("maps/" .. name .. mapExtension) then
      map.writeTable(mapData, "maps/" .. name .. mapExtension)
    end
  end
end

map.checkDefaultMapName = function(compareName)
  for name,_ in pairs(defaultMaps) do
    if name == compareName then
      return true
    end
  end

  return false
end

return map
