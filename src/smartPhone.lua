local smartPhone = {}

smartPhone.arrowData = function()
  local drawSize = screenDim.y / 6
  horizontalDirArrows = {
    x = -cameraTranslation + screenDim.x - 10 - drawSize,
    y = screenDim.y - 10 - drawSize
  }

  return {
    radius = drawSize / 2,
    right = {
      x = horizontalDirArrows.x,
      y = horizontalDirArrows.y,
      r = 0,
      wOffset = 1,
      midPoint = {
        x = horizontalDirArrows.x + drawSize / 2,
        y = horizontalDirArrows.y + drawSize / 2
      }
    },
    left = {
      x = horizontalDirArrows.x - 10,
      y = horizontalDirArrows.y,
      r = 0,
      wOffset = -1,
      midPoint = {
        x = horizontalDirArrows.x - drawSize / 2 - 10,
        y = horizontalDirArrows.y + drawSize / 2
      }
    },
    up = {
      x = -cameraTranslation + 10,
      y = screenDim.y - 10,
      r = math.pi * 1.5,
      wOffset = 1,
      midPoint = {
        x = -cameraTranslation + 10 + drawSize / 2,
        y = horizontalDirArrows.y + drawSize / 2
      }
    }
  }
end

smartPhone.drawHorzontalButtons = function()
  if isSmartPhone then
    local arrow = texture.other.arrowIcon
    local drawSize = screenDim.y / 6

    for currArrow, data in pairs(smartPhone.arrowData()) do
      if currArrow == 'right' or currArrow == 'left' then
        love.graphics.draw(arrow, data.x, data.y, data.r, drawSize / arrow:getWidth() * data.wOffset, drawSize / arrow:getHeight())
      end
    end
  end
end

smartPhone.drawArrowButtons = function()
  if isSmartPhone then
    local arrow = texture.other.arrowIcon
    local drawSize = screenDim.y / 6

    for currArrow, data in pairs(smartPhone.arrowData()) do
      if currArrow ~= 'radius' then
        love.graphics.draw(arrow, data.x, data.y, data.r, drawSize / arrow:getWidth() * data.wOffset, drawSize / arrow:getHeight())
      end
    end
  end
end

smartPhone.checkButtonPress = function(arrowType)
  if isSmartPhone then
    local touches = love.touch.getTouches()
    local arrowData = smartPhone.arrowData()
    local currArrow = arrowData[arrowType].midPoint

    local circleTbl = {
      x = currArrow.x,
      y = currArrow.y,
      r = arrowData.radius
    }

    for _, id in pairs(touches) do
      local currTouch = {}
      currTouch.x, currTouch.y = love.touch.getPosition(id)
      currTouch.x = currTouch.x - cameraTranslation - borders.x / 2
      currTouch.y = currTouch.y - borders.y / 2

      -- if math.sqrt((abs(currTouch.x) - abs(currArrow.x)) ^ 2 + (abs(currTouch.y) - abs(currArrow.y)) ^ 2) < radius then
      if collision.circle(circleTbl, currTouch) then
        return true
      end
    end

    return false
  end
end

return smartPhone
