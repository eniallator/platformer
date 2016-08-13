local display = {}

display.map = function()
  for i=1,#mapGrid do
    for j=1,#mapGrid[i] do
      if type(mapGrid[i][j]) == "table" then

        local blockData = blocks[mapGrid[i][j].block].col
        love.graphics.setColor(blockData.r, blockData.g, blockData.b)
        love.graphics.rectangle("fill", (j -1) *blockSize, (i -1) *blockSize, blockSize, blockSize)
      end
    end
  end
end

return display
