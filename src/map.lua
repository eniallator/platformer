local oldDecompress = require 'src.compression.oldDecompress'
local compress = require 'src.compression.compress'
local decompress = require 'src.compression.decompress'
local binaryUtils = require 'src.utils.binary'

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

  if formattedMap["foreground"] then
    applyFormattedMap("foreground")
  end

  if formattedMap["background"] then
    applyFormattedMap("background")
  end
end

local function binToString(bin)
  local outStr = ''

  for i=0, math.ceil(#bin / 8) - 1 do
    local charId = 0

    for j=0, 7 do
      if bin[i * 8 + j + 1] == 1 then
        charId = charId + 2^j
      end
    end

    outStr = outStr .. string.char(charId)
  end

  return outStr
end

local function stringToBin(str)
  local binTbl = {}

  for i=1, #str do
    local numVal = string.byte(str:sub(i, i))
    local byteBin = binaryUtils.numToBin(numVal)

    for i=1, 8 do
      table.insert(binTbl, byteBin[i] or 0)
    end
  end

  return binTbl
end

map.writeTable = function(tbl, fileToWrite)
  local binMap = compress(tbl)
  local outStr = binToString(binMap)

  love.filesystem.write(fileToWrite, outStr)
end

local function splitString(str)
  local tbl = {}

  for i=1, #str do
    table.insert(tbl, str:sub(i,i))
  end

  return tbl
end

map.readTable = function(fileToRead)
  local binTbl = {}
  local fileContents = love.filesystem.read(fileToRead)
  local formattedArray

  if fileContents:sub(1, 1) == 'x' or fileContents:sub(1, 1) == 't' then
    local chars = splitString(fileContents)

    formattedArray = oldDecompress(chars)

  else
    local binMap = stringToBin(fileContents)

    formattedArray = decompress(binMap)
  end

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

return map
