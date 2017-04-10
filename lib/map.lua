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

local function numToBin(num)
  local exponent = -1

  while 2 ^ (exponent + 1) <= num do
    exponent = exponent + 1
  end

  local binary = {}

  for i=exponent, 0, -1 do
    local val = 0

    if 2^i <= num then
      val = 1
      num = num - 2^i
    end

    binary[i+1] = val
  end

  return binary
end

local function binToNum(binTbl)
  local num = 0

  for i=1, #binTbl do
    if binTbl[i] == 1 then
      num = num + 2 ^ (i-1)
    end
  end

  return num
end

local function dataToBinary(coords, data)
  local pos = {}
  pos.x, pos.y = getCoords(coords)

  local binEntry = {{type = 'dimPrefix', dat = {0, 0}}}

  table.insert(binEntry, {type = 'x', dat = numToBin(pos.x)})
  table.insert(binEntry, {type = 'y', dat = numToBin(pos.y)})
  table.insert(binEntry, {type = 'block', dat = numToBin(collision.getBlock(data.block) - 1)})

  if data.w > 1 then
    table.insert(binEntry, {type = 'w', dat = numToBin(data.w - 2)})
    binEntry[1].dat[1] = 1
  end

  if data.h > 1 then
    table.insert(binEntry, {type = 'h', dat = numToBin(data.h - 2)})
    binEntry[1].dat[2] = 1
  end

  return binEntry
end

local mapDataLength = {
  dimPrefix = 2,
  x = 8,
  y = 5,
  block = 6,
  w = 8,
  h = 5
}

local function createPrefix(binMap)
  local binMapLength = numToBin(#binMap)

  for i=1, math.ceil(#binMapLength / 7) do
    table.insert(binMap, i * 8 - 7, 1)

    for j=1, 7 do
      local index = i * 8 - 7 + j
      table.insert(binMap, i * 8 - 7 + j, binMapLength[(i - 1) * 7 + j] or 0)
    end
  end

  return binMap
end

local function createBinaryMap(tbl)
  local binMap = {0}

  for coords, data in pairs(tbl) do
    local binEntry = dataToBinary(coords, data)

    for i=1, #binEntry do
      local binDat = binEntry[i].dat

      for j=1, mapDataLength[binEntry[i].type] do
        table.insert(binMap, binDat[j] or 0)
      end
    end
  end

  return createPrefix(binMap)
end

function serialise(a,b)local c={}local d=true;local e=""if not b then b=0 end;for f=1,b do e=e.." "end;local f=1;for g,h in pairs(a)do local i=""if g~=f then i="["..g.."] = "end;if type(h)=="table"then table.insert(c,i..serialise(a[g],b+2))d=false elseif type(h)=="string"then table.insert(c,i..'"'..a[g]..'"')else table.insert(c,i..tostring(a[g]))end;f=f+1 end;local j="{"if not d then j=j.."\n"end;for f=1,#c do if f~=1 then j=j..","if not d then j=j.."\n"end end;if not d then j=j..e.."  "end;j=j..c[f]end;if not d then j=j.."\n"..e end;return j.."}"end

local binMapData = {}

local function formattedTblToStr(tbl)
  local binMap = createBinaryMap(tbl)
  local strMap = ''
  table.insert(binMapData, binMap)

  for i=0, (#binMap - 1) / 8 do
    local byteNum = 0

    for j=1, 8 do
      if binMap[i * 8 + j] == 1 then
        byteNum = byteNum + 2 ^ (j - 1)
      end
    end

    strMap = strMap .. string.char(byteNum)
  end

  return strMap
end

map.writeTable = function(tbl, fileToWrite)
  local outStr = ""
  outStr = outStr .. formattedTblToStr(tbl.foreground)

  if tbl.background then
    outStr = outStr .. formattedTblToStr(tbl.background)
  end

  love.filesystem.write(fileToWrite, outStr)
end

local function decompressOldAlgorithm(rawTbl)
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

local dataOrder = {
  {name = 'x'},
  {name = 'y'},
  {name = 'block'},
  {name = 'w', condition = function(dimController) return dimController.w end},
  {name = 'h', condition = function(dimController) return dimController.h end}
}

local function decompressNewAlgorithm(binTbl)
  local currIndex = 1
  local currLayer = 1
  local transformedTbl = {}

  while currIndex < #binTbl do
    transformedTbl[currLayer] = {}
    local binMapLength = 0
    local exponent = 0

    while binTbl[currIndex] == 1 do
      currIndex = currIndex + 1

      for i=1, 7 do
        if binTbl[currIndex] == 1 then
          binMapLength = binMapLength + 2 ^ exponent
        end

        currIndex = currIndex + 1
        exponent = exponent + 1
      end
    end

    local maxLength = currIndex + binMapLength
    currIndex = currIndex + 1

    while currIndex < maxLength do
      local dimController = {
        w = binTbl[currIndex] == 1 and true,
        h = binTbl[currIndex + 1] == 1 and true
      }
      currIndex = currIndex + 2

      local key = ''
      local dataTbl = {w = 1, h = 1}

      for i=1, #dataOrder do
        local currData = dataOrder[i]

        if currData.condition and currData.condition(dimController) or not currData.condition then
          local currTbl = {}

          for i=1, mapDataLength[currData.name] do
            table.insert(currTbl, binTbl[currIndex])
            currIndex = currIndex + 1
          end

          if currData.name == 'x' or currData.name == 'y' then
            key = key .. currData.name .. binToNum(currTbl)

          elseif currData.name == 'block' then
            dataTbl[currData.name] = blocks[binToNum(currTbl) + 1].name

          else
            dataTbl[currData.name] = binToNum(currTbl) + 2
          end
        end
      end

      transformedTbl[currLayer][key] = dataTbl
    end

    currLayer = currLayer + 1
    currIndex = 8 * math.ceil(currIndex / 8) + 1
  end

  return transformedTbl
end

map.readTable = function(fileToRead)
  local binTbl = {}
  local fileBytes = love.filesystem.read(fileToRead)
  local formattedArray

  if fileBytes:sub(1, 1) == 'x' or fileBytes:sub(1, 1) == 't' then
    local charTbl = {}

    for i=1, #fileBytes do
      table.insert(charTbl, fileBytes:sub(i,i))
    end

    formattedArray = decompressOldAlgorithm(charTbl)

  else
    for i=1, #fileBytes do
      local numVal = string.byte(fileBytes:sub(i, i))
      local byteBin = numToBin(numVal)

      for i=1, 8 do
        table.insert(binTbl, byteBin[i] or 0)
      end
    end

    formattedArray = decompressNewAlgorithm(binTbl)
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
