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
  dimensions = {x = screenDim.x /2 -150, y = screenDim.y /2 - 35, w = 300, h = 70},

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
  dimensions = {x = screenDim.x /2 -150, y = screenDim.y /2 -120, w = 300, h = 70},
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
  },
  {
    name = "Rename",
    func = function(mapName)
      -- Rename code
    end
  }
}

return utilsData
