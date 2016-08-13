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

map.makeGrid = function()
  mapGrid = createGrid(screenDim.x/blockSize, screenDim.y/blockSize)

  for coords, data in pairs(formattedMap) do
    local xNum = coords:find("x")
    local yNum = coords:find("y")

    local blockX = tonumber(coords:sub(xNum +1, yNum -1))
    local blockY = tonumber(coords:sub(yNum +1, #coords))

    for i=1,data.h do
      for j=1,data.w do
        mapGrid[blockY+i-1][blockX+j-1] = {block = data.block}
      end
    end
  end
end

return map
