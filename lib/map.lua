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

  return tonumber(str:sub(xNum +1, yNum -1)), tonumber(str:sub(yNum +1, #str))
end

map.makeGrid = function()
  mapGrid = createGrid(screenDim.x/blockSize, screenDim.y/blockSize)

  for coords, data in pairs(formattedMap) do

    blockX, blockY = getCoords(coords)

    for i=1,data.h do
      for j=1,data.w do
        mapGrid[blockY+i-1][blockX+j-1] = {block = data.block}
      end
    end
  end
end

map.writeTable = function(tbl, fileToWrite)
  local writeStr = ""

  for coords, data in pairs(tbl) do

    blockX, blockY = getCoords(coords)
    writeStr = writeStr .. "x" .. string.char(blockX -1) .. "y" .. string.char(blockY -1) .. "b" .. string.char(collision.getBlock(data.block) -1)

    if data.w > 1 then
      writeStr = writeStr .. "w" .. string.char(data.w -2)
    end

    if data.h > 1 then
      writeStr = writeStr .. "h" .. string.char(data.h -2)
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

    if outKey then
      if not outTbl[outKey].w then
        outTbl[outKey].w = 1
      end

      if not outTbl[outKey].h then
        outTbl[outKey].h = 1
      end
    end

    if rawTbl[index] == "x" then
      index = index +1
      outKey = "x" .. string.byte(rawTbl[index]) +1
      index = index +1
    end

    if rawTbl[index] == "y" then
      index = index +1
      outKey = outKey .. "y" .. string.byte(rawTbl[index]) +1
      index = index +1
    end

    outTbl[outKey] = {}

    if rawTbl[index] == "b" then
      index = index +1
      outTbl[outKey].block = blocks[string.byte(rawTbl[index]) +1].name
      index = index +1
    end

    if rawTbl[index] == "w" then
      index = index +1
      outTbl[outKey].w = string.byte(rawTbl[index]) +2
      index = index +1
    end

    if rawTbl[index] == "h" then
      index = index +1
      outTbl[outKey].h = string.byte(rawTbl[index]) +2
      index = index +1
    end
  end

  return outTbl
end

map.destroyBlock = function(coords)
  mapGrid[math.ceil(coords[2]/blockSize)][math.ceil(coords[1]/blockSize)] = "n"
end

map.placeBlock = function(coords)
  mapGrid[math.ceil(coords[2]/blockSize)][math.ceil(coords[1]/blockSize)] = {block = blocks[selectedBlockIndex].name}
end

return map
