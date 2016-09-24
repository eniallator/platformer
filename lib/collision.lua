local collision = {}

collision.getBlock = function(block)
  for i=1, #blocks do
    if block == blocks[i].name then
      return i
    end
  end

  return false
end

collision.detectPlayer = function(x,y)
  for i=1,#mapGrid do
    for j=1,#mapGrid[i] do
      if type(mapGrid[i][j]) == "table" then

        local currBlock = blocks[collision.getBlock(mapGrid[i][j].block)]

        if currBlock.solid and (j -1) *blockSize < x + player.w and x <= j *blockSize and (i -1) *blockSize < y + player.h and y <= i *blockSize then

          return true
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
  love.mouse.setCursor()

  if detectCollision(displayedTbl) then
    love.mouse.setCursor(handCursor)
  end
end

return collision
