local display = {}

display.map = function()
  for coords, data in pairs(map) do
    local xNum = coords:find("x")
    local yNum = coords:find("y")

    local blockX = tonumber(coords:sub(xNum +1, yNum -1))
    local blockY = tonumber(coords:sub(yNum +1, #coords))

    local blockData = blocks[data.block]
    love.graphics.setColor(blockData.r, blockData.g, blockData.b)
    love.graphics.rectangle("fill", (blockX-1)*blockSize, (blockY-1)*blockSize, data.w*blockSize, data.h*blockSize)
  end
end

return display
