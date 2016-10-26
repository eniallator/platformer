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

map.makeGrid = function(x, y)
  mapGrid = createGrid(x, y)

  for coords, data in pairs(formattedMap) do

    blockX, blockY = getCoords(coords)

    for i=1,data.h do
      for j=1,data.w do
        mapGrid[blockY + i - 1][blockX + j - 1] = {block = data.block}
      end
    end
  end
end

map.writeTable = function(tbl, fileToWrite)
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

  love.filesystem.write(fileToWrite, writeStr)
end

map.readTable = function(fileToRead)
  local rawTbl = {}
  local rawStr = love.filesystem.read(fileToRead)

  for i=1, #rawStr do
    table.insert(rawTbl,rawStr:sub(i,i))
  end

  local outTbl = {}
  local index = 1
  local outKey

  while rawTbl[index] do
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

    outTbl[outKey] = {}

    if rawTbl[index] == "b" then
      index = index + 1
      outTbl[outKey].block = blocks[string.byte(rawTbl[index]) + 1].name
      index = index + 1
    end

    if rawTbl[index] == "w" then
      index = index + 1
      outTbl[outKey].w = string.byte(rawTbl[index]) + 2
      index = index + 1
    end

    if rawTbl[index] == "h" then
      index = index + 1
      outTbl[outKey].h = string.byte(rawTbl[index]) + 2
      index = index + 1
    end

    if not outTbl[outKey].w then
      outTbl[outKey].w = 1
    end

    if not outTbl[outKey].h then
      outTbl[outKey].h = 1
    end
  end

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

map.transform = function(mapTbl)
  local outMap = {}
  local oldMap = copyTable(mapTbl)

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

map.destroyBlock = function(coords)
  mapGrid[math.ceil(coords[2] / blockSize)][math.ceil(coords[1] / blockSize)] = "n"
end

map.placeBlock = function(coords)
  mapGrid[math.ceil(coords[2] / blockSize)][math.ceil(coords[1] / blockSize)] = {block = blocks[selectedBlockIndex].name}
end

return map
