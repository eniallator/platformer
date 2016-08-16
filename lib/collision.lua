local stillDown
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

      local currBlock = blocks[collision.getBlock(mapGrid[i][j].block)]

      if type(mapGrid[i][j]) == "table" and currBlock.solid and (j -1) *blockSize < x + player.w and x <= j *blockSize and (i -1) *blockSize < y + player.h and y <= i *blockSize then

        return true
      end
    end
  end

  return false
end

collision.clickBox = function(displayedTbl)
  local clicked = false

  if love.mouse.isDown(1) then
    if not stillDown then
      clicked = true
    end

    stillDown = true
  else
    stillDown = false
  end

  if clicked then
    local mouseCoords = {love.mouse.getPosition()}

    for name,box in pairs(displayedTbl) do
      if mouseCoords[1] >= box.x and mouseCoords[1] <= box.x + box.w and mouseCoords[2] >= box.y and mouseCoords[2] <= box.y + box.h then

        return name
      end
    end

    return false
  end

end

return collision
