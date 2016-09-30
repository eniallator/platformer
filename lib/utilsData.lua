local mapFileName = nil
local utilsData = {
  textBox = {selected = nil},
  alert = {selected = nil},
  dropMenu = {selected = nil, mapName = nil, coords = nil}
}

local function saveMap(mapName)
  map.writeTable(map.transform(mapGrid), "maps/" .. mapName .. mapExtension)
end

utilsData.textBox.saveMap = {
  title ="Map Name:", acceptedKeys = "^%w$",
  dimensions = function () local font = love.graphics.getFont() return {x = screenDim.x /2 -screenDim.x /(5 +1 /3), y = screenDim.y /2 - screenDim.y / (25 +5 /7), w = screenDim.x /(2 +2 /3), h = 25 +font:getHeight("Lp") *2} end,

  func = function (mapName)
    if love.filesystem.exists("maps/" .. mapName .. mapExtension) then
      utilsData.alert.selected = "fileExists"
      mapFileName = mapName
      return true

    else
      saveMap(mapName)
    end
  end
}

utilsData.alert.fileExists = {
  message = "File exists! overwrite file?",
  dimensions = function() local font = love.graphics.getFont() return {x = screenDim.x /2 -screenDim.x /(5 +1 /3), y = screenDim.y /2 - screenDim.y / (25 +5 /7) - (35 +font:getHeight("Lp") *2), w = screenDim.x /(2 +2 /3), h = 25 +font:getHeight("Lp") *2} end,
  buttons = {
    {
      name = "Yes",
      func = function()
        if mapFileName then

          saveMap(mapFileName)
          textBox.reset()
          utilsData.alert.selected = nil
        end
      end
    },
    {
      name = "No",
      func = function()

        textBox.stopped = false
        utilsData.alert.selected = nil
      end
    }
  }
}

utilsData.dropMenu.playMap = {
  {
    name = "Delete",
    func = function(mapName)
      love.filesystem.remove("maps/" .. mapName .. mapExtension)
    end
  }
}

return utilsData
