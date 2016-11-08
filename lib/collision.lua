local collision = {}

collision.getBlock = function(block)
  for i=1, #blocks do
    if block == blocks[i].name then
      return i
    end
  end

  return false
end

local function collideAxis(box1, box2, axis, dim)
  if box1[axis] < box2[axis] + box2[dim] and box2[axis] <= box1[axis] + box1[dim] then
    return true
  end

  return false
end

collision.rectangles = function(box1,box2)
  if collideAxis(box1, box2, "x", "w") and collideAxis(box1, box2, "y", "h") then
    return true
  end

  return false
end

collision.detectEntity = function(pos, currEntity, attribute)
  local currEntityDim = currEntity.dim()
  local gridCoordinates = {
    yMax = math.ceil((pos.y + currEntityDim.h + 1) / blockSize),
    xMax = math.ceil((pos.x + currEntityDim.w + 1) / blockSize),
    yMin = math.floor((pos.y - 1) / blockSize),
    xMin = math.floor((pos.x - 1) / blockSize)
  }
  local entityBounds = {
    x = pos.x,
    y = pos.y,
    w = currEntityDim.w,
    h = currEntityDim.h
  }

  for i = gridCoordinates.yMax, gridCoordinates.yMin, -1 do
    for j = gridCoordinates.xMax, gridCoordinates.xMin, -1 do
      if mapGrid.foreground[i] and type(mapGrid.foreground[i][j]) == "table" then

        local currBlock = blocks[collision.getBlock(mapGrid.foreground[i][j].block)]
        local pixelSize = (blockSize/10)
        local tilePos = {
          x = (j - 1) * blockSize,
          y = (i - 1) * blockSize
        }

        local tileBounds = {
          x = currBlock.offSet and tilePos.x + currBlock.offSet.x * pixelSize or tilePos.x,
          y = currBlock.offSet and tilePos.y + currBlock.offSet.y * pixelSize or tilePos.y,
          w = currBlock.dim and currBlock.dim.w * pixelSize or blockSize,
          h = currBlock.dim and currBlock.dim.h * pixelSize or blockSize
        }

        if currBlock[attribute] and collision.rectangles(tileBounds, entityBounds) then
          return j, i
        end
      end
    end
  end

  return false
end

collision.hoverOverBox = function(box)
  local mouseCoords = {love.mouse.getPosition()}
  local mouseBounds = {
    x = mouseCoords[1],
    y = mouseCoords[2],
    w = 0,
    h = 0
  }

  local boxBounds = {
    x = box.x +borders.x /2,
    y = box.y +borders.y /2,
    w = box.w,
    h = box.h
  }

  if collision.rectangles(boxBounds, mouseBounds) then
    return true
  end

  return false
end

collision.hoverOverBoxes = function(tbl)
  for name,box in pairs(tbl) do
    if collision.hoverOverBox(box) then
      return name
    end
  end

  return false
end

collision.clickBox = function(displayedTbl)
  if mouse.left.clicked then
    return collision.hoverOverBoxes(displayedTbl)
  end
end

collision.rightClickBox = function(displayedTbl)
  if mouse.right.clicked then
    return collision.hoverOverBoxes(displayedTbl)
  end
end

local handCursor = love.mouse.getSystemCursor("hand")

collision.updateMouseCursor = function(displayedTbl)
  if collision.hoverOverBoxes(displayedTbl) then
    love.mouse.setCursor(handCursor)
  end
end

return collision
