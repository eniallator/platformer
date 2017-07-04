local binaryUtils = require 'lib/utils/binary'
local createBinReader = require 'lib/compression/binReader'

local dataOrder = {
  {name = 'x'},
  {name = 'y'},
  {name = 'block'},
  {name = 'w'},
  {name = 'h'}
}

local function decompress(binTbl)
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
    for i=1, 3 do
      if reader:nextBit() == 1 then
        metaDataCurrVal = metaDataCurrVal + 2 ^ metaDataExponent
        metaDataExponent = metaDataExponent + 1
      end
    end

    if reader:nextBit() == 0 then
      maxVal[dataOrder[metaDataIndex].name] = metaDataCurrVal

      metaDataIndex = metaDataIndex + 1
      metaDataCurrVal = 0
      metaDataExponent = 0
    end
  end

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

        if currFieldName == 'x' or currFieldName == 'y' then
          key = key .. currFieldName .. binaryUtils.binToNum(currBinData)

        elseif currFieldName == 'block' then
          dataTbl[currFieldName] = blocks[binaryUtils.binToNum(currBinData) + 1].name

        elseif #currBinData > 0 then
          dataTbl[currFieldName] = binaryUtils.binToNum(currBinData) + 1
        end
      end

      transformedTbl[currLayer][key] = dataTbl
    end

    currLayer = currLayer + 1
  end

  return transformedTbl
end

return decompress
