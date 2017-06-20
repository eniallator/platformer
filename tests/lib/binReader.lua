local function createBinMapReader(binMap)
  local binReader = {}
  binReader.__binMap = binMap
  binReader.__currIndex = 1

  function binReader:hasNext()
    return self.__binMap[self.__currIndex + 1] and true or false
  end

  function binReader:nextBit()
    local bit = self.__binMap[self.__currIndex]
    self.__currIndex = self.__currIndex + 1
    return bit
  end

  function binReader:getCurrIndex()
    return self.__currIndex
  end

  return binReader
end

return createBinMapReader
