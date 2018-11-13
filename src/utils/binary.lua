local binaryUtils = {}

binaryUtils.numToBin = function(num)
  local binary = {}

  while num > 0 do
    table.insert(binary, num % 2)
    num = math.floor(num / 2)
  end

  return binary
end

binaryUtils.binToNum = function(binTbl)
  local num = 0

  for i = 1, #binTbl do
    if binTbl[i] == 1 then
      num = num + 2 ^ (i - 1)
    end
  end

  return num
end

return binaryUtils
