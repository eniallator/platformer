local binaryUtils = {}

binaryUtils.numToBin = function(num)
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

binaryUtils.binToNum = function(binTbl)
  local num = 0

  for i=1, #binTbl do
    if binTbl[i] == 1 then
      num = num + 2 ^ (i-1)
    end
  end

  return num
end

return binaryUtils
