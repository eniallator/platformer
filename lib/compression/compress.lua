local binaryUtils = require 'lib/utils/binary'
local maxValues

local function updateMaxVal(tbl1, tbl2)
  for key, val in pairs(tbl2) do
    local binLength = #binaryUtils.numToBin(val)
    tbl1[key] = (not tbl1[key] or binLength > tbl1[key]) and binLength or tbl1[key]
  end
end

local function getCoords(str)
  local xNum = str:find("x")
  local yNum = str:find("y")

  return tonumber(str:sub(xNum + 1, yNum - 1)), tonumber(str:sub(yNum + 1, #str))
end

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
    binaryUtils.numToBin(pos.x),
    binaryUtils.numToBin(pos.y),
    binaryUtils.numToBin(dataForBin.block)
  }

  if data.w > 1 then
    table.insert(binEntry, binaryUtils.numToBin(dataForBin.w))
    table.insert(binEntry[#binEntry], 1, 1)

  else
    table.insert(binEntry, {})
  end

  if data.h > 1 then
    table.insert(binEntry, binaryUtils.numToBin(dataForBin.h))
    table.insert(binEntry[#binEntry], 1, 1)

  else
    table.insert(binEntry, {})
  end

  return binEntry
end

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
  end

  return combinedTbl
end

local function createPrefix(binMap)
  local binMapLength = binaryUtils.numToBin(#binMap)
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
        elseif i > 3 and maxVal > 0 then
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

local binMapData = {}

local function getBinMetaData(maxValues)
  local metaData = {0}

  for i=1, #dataOrder do
    local maxLength = maxValues[dataOrder[i].name]
    local maxBinLength = binaryUtils.numToBin(maxLength or 0)

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

local function compress(tbl)
  maxValues = {}

  local translatedTbl = {getTranslatedTbl(tbl.foreground) or {}, getTranslatedTbl(tbl.background) or {}}
  local binMapLayers = tblToBinMapLayers(translatedTbl)
  local binMetaData = getBinMetaData(maxValues)

  table.insert(binMapLayers, 1, binMetaData)

  return combineTbl(binMapLayers)
end

return compress
