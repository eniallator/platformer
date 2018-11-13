local function decompress(rawTbl)
  local outTbl = {}
  local index = 1
  local outKey
  local indexCount

  while rawTbl[index] do
    indexCount = indexCount and indexCount + 1 or 1
    outTbl[indexCount] = {}

    while rawTbl[index] and rawTbl[index] ~= 't' do
      if rawTbl[index] == 'x' then
        index = index + 1
        outKey = 'x' .. string.byte(rawTbl[index]) + 1
        index = index + 1
      end

      if rawTbl[index] == 'y' then
        index = index + 1
        outKey = outKey .. 'y' .. string.byte(rawTbl[index]) + 1
        index = index + 1
      end

      outTbl[indexCount][outKey] = {}

      if rawTbl[index] == 'b' then
        index = index + 1
        outTbl[indexCount][outKey].block = blocks[string.byte(rawTbl[index]) + 1].name
        index = index + 1
      end

      if rawTbl[index] == 'w' then
        index = index + 1
        outTbl[indexCount][outKey].w = string.byte(rawTbl[index]) + 2
        index = index + 1
      end

      if rawTbl[index] == 'h' then
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

return decompress
