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
  local currEntityDim = currEntity.dim()

  for i = math.floor((y -1) /blockSize), math.ceil((y +currEntityDim.h +1) /blockSize) do
    for j = math.floor((x -1) /blockSize), math.ceil((x +currEntityDim.w +1) /blockSize) do
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

        if currBlock[attribute] and (j -1) *blockSize +xOff < x +currEntityDim.w and x <= (j -1) *blockSize +xDim +xOff and (i -1) *blockSize +yOff < y +currEntityDim.h and y <= (i -1) *blockSize +yDim +yOff then
          return j, i
        end
      end
    end
  end

  return false
end

local function detectCollision(tbl, addBorder)
  local mouseCoords = {love.mouse.getPosition()}

  for name,box in pairs(tbl) do
    local newY = box.y + borders.y /2
    local newX = box.x

    if addBorder then
      newX = box.x + borders.x /2
    end

    if mouseCoords[1] >= newX and mouseCoords[1] <= newX + box.w and mouseCoords[2] >= newY and mouseCoords[2] <= newY + box.h then
      return name
    end
  end

  return false
end

collision.clickBox = function(displayedTbl, addBorder)
  if mouse.left.clicked then
    return detectCollision(displayedTbl, addBorder)
  end
end

collision.rightClickBox = function(displayedTbl, addBorder)
  if mouse.right.clicked then
    return detectCollision(displayedTbl, addBorder)
  end
end

local handCursor = love.mouse.getSystemCursor("hand")

collision.updateMouseCursor = function(displayedTbl, addBorder)
  if detectCollision(displayedTbl, addBorder) then
    love.mouse.setCursor(handCursor)
  end
end

return collision
