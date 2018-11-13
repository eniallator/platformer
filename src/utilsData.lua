local mapFileName = nil
local utilsData = {
  textBox = {selected = nil},
  alert = {selected = nil},
  dropMenu = {selected = nil, mapName = nil, coords = nil}
}

local function saveMap(mapName)
  map.writeTable(map.transform(mapGrid), 'maps/' .. mapName .. mapExtension)
end

local function yOffset()
  if isSmartPhone then
    return screenDim.y * (2 / 7)
  end

  return 0
end

utilsData.textBox.saveMap = {
  title = 'Map Name:',
  acceptedKeys = '^[%w%s]$',
  dimensions = function()
    local font = love.graphics.getFont()
    return {
      x = screenDim.x / 2 - screenDim.x / (5 + 1 / 3),
      y = screenDim.y / 2 - screenDim.y / (25 + 5 / 7) - yOffset(),
      w = screenDim.x / (2 + 2 / 3),
      h = 25 + font:getHeight('Lp') * 2
    }
  end,
  func = function(mapName)
    if defaultMaps[mapName] then
      utilsData.alert.selected = 'defaultMapFileExists'
      return 'continue'
    elseif love.filesystem.exists('maps/' .. mapName .. mapExtension) then
      utilsData.alert.selected = 'fileExists'
      mapFileName = mapName
      return 'stop'
    else
      saveMap(mapName)
      textBox.reset()
    end
  end
}

utilsData.alert.fileExists = {
  message = 'File exists! overwrite file?',
  dimensions = function()
    local font = love.graphics.getFont()
    return {
      x = screenDim.x / 2 - screenDim.x / (5 + 1 / 3),
      y = screenDim.y / 2 - screenDim.y / (25 + 5 / 7) - (35 + font:getHeight('Lp') * 2) - yOffset(),
      w = screenDim.x / (2 + 2 / 3),
      h = 25 + font:getHeight('Lp') * 2
    }
  end,
  buttons = {
    {
      name = 'Yes',
      func = function()
        if mapFileName then
          saveMap(mapFileName)
          textBox.reset()
          utilsData.alert.selected = nil
        end
      end
    },
    {
      name = 'No',
      func = function()
        textBox.stopped = false
        utilsData.alert.selected = nil
      end
    }
  }
}

utilsData.alert.defaultMapFileExists = {
  message = "Can't overwrite default maps!",
  dimensions = function()
    local font = love.graphics.getFont()
    return {
      x = screenDim.x / 2 - screenDim.x / (5 + 1 / 3),
      y = screenDim.y / 2 - screenDim.y / (25 + 5 / 7) - (20 + font:getHeight('Lp')) - yOffset(),
      w = screenDim.x / (2 + 2 / 3),
      h = 10 + font:getHeight('Lp')
    }
  end,
  duration = 120
}

utilsData.alert.deleteMapConfirm = {
  message = 'Are you sure you want to Delete?',
  dimensions = function()
    local font = love.graphics.getFont()
    return {
      x = screenDim.x / 2 - screenDim.x / (5 + 1 / 3),
      y = screenDim.y / 2 - screenDim.y / (25 + 5 / 7) - (35 + font:getHeight('Lp') * 2),
      w = screenDim.x / (2 + 2 / 3),
      h = 25 + font:getHeight('Lp') * 2
    }
  end,
  buttons = {
    {
      name = 'Yes',
      func = function()
        love.filesystem.remove('maps/' .. utilsData.alert.deleteMapConfirm.selectedMap .. mapExtension)
        utilsData.alert.selected = nil
      end
    },
    {
      name = 'No',
      func = function()
        utilsData.alert.selected = nil
      end
    }
  }
}

return utilsData
