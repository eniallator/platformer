local collision = {}

collision.getBlock = function(block)
  for i=1, #blocks do
    if block == blocks[i].name then
      return i
    end
  end

  return false
end

collision.detectEntity = function(x, y, currEntity, attribute)
  for i = math.floor((y -1) /blockSize), math.ceil((y +currEntity.dim.h +1) /blockSize) do
    for j = math.floor((x -1) /blockSize), math.ceil((x +currEntity.dim.w +1) /blockSize) do
      if mapGrid[i] and type(mapGrid[i][j]) == "table" then

        local currBlock = blocks[collision.getBlock(mapGrid[i][j].block)]
        local xDim, yDim = blockSize, blockSize
        local xOff, yOff = 0, 0

        if currBlock.dim then
          xDim = currBlock.dim.w *(screenDim.y/200)
          yDim = currBlock.dim.h *(screenDim.y/200)
        end

        if currBlock.offSet then
          xOff = currBlock.offSet.x *(screenDim.y/200)
          yOff = currBlock.offSet.y *(screenDim.y/200)
        end

        if currBlock[attribute] and (j -1) *blockSize +xOff < x +currEntity.dim.w and x <= (j -1) *blockSize +xDim +xOff and (i -1) *blockSize +yOff < y +currEntity.dim.h and y <= (i -1) *blockSize +yDim +yOff then
          return j, i
        end
      end
    end
  end

  return false
end

local function detectCollision(tbl)
  local mouseCoords = {love.mouse.getPosition()}

  for name,box in pairs(tbl) do
    if mouseCoords[1] >= box.x and mouseCoords[1] <= box.x + box.w and mouseCoords[2] >= box.y and mouseCoords[2] <= box.y + box.h then

      return name
    end
  end

  return false
end

collision.clickBox = function(displayedTbl)
  if mouse.left.clicked then
    return detectCollision(displayedTbl)
  end
end

collision.rightClickBox = function(displayedTbl)
  if mouse.right.clicked then
    return detectCollision(displayedTbl)
  end
end

local handCursor = love.mouse.getSystemCursor("hand")

collision.updateMouseCursor = function(displayedTbl)
  if detectCollision(displayedTbl) then
    love.mouse.setCursor(handCursor)
  end
end

return collision
