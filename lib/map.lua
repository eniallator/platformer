selectedBlockIndex = 1
local map = {}
local createBinReader = require 'lib/utils/binReader'

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

local function updateMaxVal(tbl1, tbl2)
  for key, val in pairs(tbl2) do
    local binLength = #numToBin(val)
    print(key, binLength)
    tbl1[key] = (not tbl1[key] or binLength > tbl1[key]) and binLength or tbl1[key]
  end
end

local maxValues

local function dataToBinary(coords, data)
  local pos = {}
  pos.x, pos.y = getCoords(coords)
  local dataForBin = {
    block = collision.getBlock(data.block) - 1,
    w = data.w - 1,
    h = data.h - 1
  }
  updateMaxVal(maxValues, pos)
  updateMaxVal(maxValues, dataForBin)

  local binEntry = {
    numToBin(pos.x),
    numToBin(pos.y),
    numToBin(dataForBin.block)
  }

  if data.w > 1 then
    table.insert(binEntry, numToBin(dataForBin.w))
    table.insert(binEntry[#binEntry], 1, 1)

  else
    table.insert(binEntry, {})
  end

  if data.h > 1 then
    table.insert(binEntry, numToBin(dataForBin.h))
    table.insert(binEntry[#binEntry], 1, 1)

  else
    table.insert(binEntry, {})
  end

  return binEntry
end

local mapDataLength = {
  x = 8,
  y = 5,
  block = 6,
  w = 8,
  h = 5
}

local dataOrder = {
  {name = 'x'},
  {name = 'y'},
  {name = 'block'},
  {name = 'w'},
  {name = 'h'}
}


local function combineTbl(tbl)
  local combinedTbl = {}

  for i=1, #tbl do
    for j=1, #tbl[i] do
      table.insert(combinedTbl, tbl[i][j])
    end
    v = v + #tbl[i]
    print(#tbl[i] .. '/' .. v)
  end

  return combinedTbl
end

local function createPrefix(binMap)
  local binMapLength = numToBin(#binMap)
  local currPrefix = {}

  -- Excludes control bit
  local binLengthBytes = #binMapLength / 7

  for i=1, math.ceil(binLengthBytes > 0 and binLengthBytes or 1) do
    table.insert(currPrefix, 1)

    for j=1, 7 do
      table.insert(currPrefix, binMapLength[(i - 1) * 7 + j] or 0)
    end
  end

  table.insert(currPrefix, 0)

  return currPrefix
end

local function getTranslatedTbl(tbl)
  local transformedTbl = {}

  for coords, data in pairs(tbl) do
    local binEntry = dataToBinary(coords, data)
    table.insert(transformedTbl, binEntry)
  end

  return transformedTbl
end

local function tblToBinMapLayers(tbl)
  local binMap = {}

  for layer=1, #tbl do
    currLayer = {}

    for binEntryIndex=1, #tbl[layer] do
      local binEntry = tbl[layer][binEntryIndex]

      for i=1, #binEntry do
        local maxVal = maxValues[dataOrder[i].name]

        if i > 3 and #binEntry[i] > 1 then
          maxVal = maxVal + 1
        elseif i > 3 then
          maxVal = 1
        end

        for j=1, maxVal do
          table.insert(currLayer, binEntry[i][j] or 0)
        end
      end
    end

    binMap[layer] = combineTbl({createPrefix(currLayer), currLayer})
  end

  return binMap
end

function serialise(a,b)local c={}local d=true;local e=""if not b then b=0 end;for f=1,b do e=e.." "end;local f=1;for g,h in pairs(a)do local i=""if g~=f then i="["..g.."] = "end;if type(h)=="table"then table.insert(c,i..serialise(a[g],b+2))d=false elseif type(h)=="string"then table.insert(c,i..'"'..a[g]..'"')else table.insert(c,i..tostring(a[g]))end;f=f+1 end;local j="{"if not d then j=j.."\n"end;for f=1,#c do if f~=1 then j=j..","if not d then j=j.."\n"end end;if not d then j=j..e.."  "end;j=j..c[f]end;if not d then j=j.."\n"..e end;return j.."}"end

local binMapData = {}

local function getBinMetaData(maxValues)
  local metaData = {0}

  for i=1, #dataOrder do
    local maxLength = maxValues[dataOrder[i].name]
    local maxBinLength = numToBin(maxLength)

    for i=1, math.ceil((#maxBinLength > 0 and #maxBinLength or 1) / 3) do
      if i > 1 then
        table.insert(metaData, 1)
      end

      for j=1, 3 do
        table.insert(metaData, maxBinLength[(i-1) * 3 + j] or 0)
      end
    end

    table.insert(metaData, 0)
  end

  return metaData
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

map.writeTable = function(tbl, fileToWrite)
  local outStr = ''
  maxValues = {}
  v = 0

  local translatedTbl = {getTranslatedTbl(tbl.foreground) or {}, getTranslatedTbl(tbl.background) or {}}
  local binMapLayers = tblToBinMapLayers(translatedTbl)
  local binMetaData = getBinMetaData(maxValues)

  print(serialise(maxValues), serialise(translatedTbl))

  table.insert(binMapLayers, 1, binMetaData)
  local binMap = combineTbl(binMapLayers)
  outStr = outStr .. binToString(binMap)

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

local function decompressNewAlgorithm(binTbl)
  local binMapLength = #binTbl
  local reader = createBinReader(binTbl)
  local currLayer = 1
  local transformedTbl = {}
  local metaDataIndex = 1
  local maxVal = {}
  local metaDataCurrVal = 0
  local metaDataExponent = 0

  reader:nextBit()

  while metaDataIndex <= #dataOrder do --recursion???
    for i=0, 2 do
      if reader:nextBit() == 1 then
        metaDataCurrVal = metaDataCurrVal + 2^(metaDataExponent + i)
      end
    end

    if reader:nextBit() == 0 then
      maxVal[dataOrder[metaDataIndex].name] = metaDataCurrVal

      metaDataIndex = metaDataIndex + 1
      metaDataCurrVal = 0
      metaDataExponent = 0

    else
      metaDataExponent = metaDataExponent + 3
    end
  end

  print(serialise(maxVal), serialise(binTbl), reader:getCurrIndex(), #binTbl)

  while reader:hasNext() do
    transformedTbl[currLayer] = {}
    local layerLength = 0
    local currLayerExponent = 0

    if binMapLength - reader:getCurrIndex() < 8 then
      break
    end

    while reader:nextBit() == 1 do
      for i=1, 7 do
        if reader:nextBit() == 1 then
          layerLength = layerLength + 2 ^ currLayerExponent
        end

        currLayerExponent = currLayerExponent + 1
      end
    end

    local layerEndPoint = reader:getCurrIndex() + layerLength
    print(layerEndPoint, layerLength, reader:getCurrIndex())

    while reader:getCurrIndex() < layerEndPoint do
      local key = ''
      local dataTbl = {w = 1, h = 1}

      for i=1, #dataOrder do
        local currFieldName = dataOrder[i].name
        local currBinData = {}

        local dimVal = currFieldName == 'w' or currFieldName == 'h'
        local dimValWithTail = dimVal and maxVal[currFieldName] > 0 and reader:nextBit() == 1

        if dimValWithTail or not dimVal then
          for i=1, maxVal[currFieldName] do
            table.insert(currBinData, reader:nextBit())
          end
        end

        -- print(currFieldName, serialise(currBinData))

        if currFieldName == 'x' or currFieldName == 'y' then
          key = key .. currFieldName .. binToNum(currBinData)

        elseif currFieldName == 'block' then
          print(serialise(currBinData))
          dataTbl[currFieldName] = blocks[binToNum(currBinData) + 1].name

        elseif #currBinData > 0 then
          dataTbl[currFieldName] = binToNum(currBinData) + 1
        end
      end

      transformedTbl[currLayer][key] = dataTbl
    end

    currLayer = currLayer + 1
    print(reader:getCurrIndex() .. '/' .. #binTbl)
  end

  print(serialise(transformedTbl))

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
