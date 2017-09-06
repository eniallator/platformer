optionGenerator = require "src.optionGenerator"
local optionData = {}

optionData.main = {
  display = function()
    local default = {w = screenDim.x /4, h = screenDim.y /8}
    default.x = screenDim.x /2 - default.w /2
    local boxGap = screenDim.y/30

    local returnTbl = {
      play = {name = "Play", x = default.x, y = screenDim.y /2 - default.h - boxGap / 2, w = default.w, h = default.h},
      createMap = {name = "Map Creator", x = default.x, y = screenDim.y /2 + boxGap / 2, w = default.w, h = default.h}
    }

    if not isSmartPhone then
      returnTbl.play = {name = "Play", x = default.x, y = screenDim.y /2 - default.h *1.5 - boxGap, w = default.w, h = default.h}
      returnTbl.createMap = {name = "Map Creator", x = default.x, y = screenDim.y /2 - default.h /2, w = default.w, h = default.h}
      returnTbl.controls = {name = "Controls", x = default.x, y = screenDim.y /2 + default.h /2 + boxGap, w = default.w, h = default.h}
    end

    return returnTbl
  end,

  funcs = {
    play = function() currMenu = "play" optionGenerator.currOptionPage = 1 end,
    controls = function() currMenu = "controls" end,

    createMap = function()
      selected = "createMap"
      formattedMap = {}
      formattedMap.foreground = {}
      formattedMap.background = {}
      map.makeGrid(256, screenDim.y/blockSize)
      firstLoad = true
      resetPlayer = true
      showBlockMenuHelpText = true
      currSelectedGrid = "foreground"
    end
  }
}

optionData.controls = {
  display = function()
    return optionGenerator.loadOptions(optionGenerator.tblToStr(controls), "controls",
      function(box)
        controls.waitForPress = box.controlIndex
      end
    )
  end
}

optionData.escMenu = {
  display = function()
    local default = {w = screenDim.x /4, h = screenDim.y /8}
    default.x = screenDim.x /2 - default.w /2
    local boxGap = screenDim.y /30

    local returnTbl = {
      close = {name = "Close", x = screenDim.x - screenDim.x /4, y = screenDim.y /18, w = screenDim.x /5, h = screenDim.y /9},
      modeSwitch = {name = "Mode: " .. selected, x = default.x, y = screenDim.y /2 -boxGap /2 -default.h, w = default.w, h = default.h},
      backToMenu = {name = "Back To Menu", x = default.x, y = screenDim.y /2 +boxGap /2, w = default.w, h = default.h}
    }

    if selected == "createMap" then
      returnTbl.save = {name = "Save Map", x = default.x, y = screenDim.y /2 -boxGap -default.h *1.5, w = default.w, h = default.h}
      returnTbl.modeSwitch.y = screenDim.y /2 -default.h * 0.5
      returnTbl.backToMenu.y = screenDim.y /2 +boxGap +default.h /2
    end

    return returnTbl
  end,

  funcs = {
    close = function() end,
    save = function()
      utilsData.textBox.selected = "saveMap"

      if isSmartPhone then
        love.keyboard.setTextInput(true)
      end
    end,

    backToMenu = function()
      selected = "menu"
      currMenu = "main"
      cameraTranslation = 0
    end,

    modeSwitch = function()
      if selected == "game" then
        selected = "createMap"
        currSelectedGrid = "foreground"

      else
        local playerDim = entity.player.dim()

        if entity.player.pos.x +playerDim.w /2 > screenDim.x /2  then
          if entity.player.pos.x +playerDim.w /2 > 255 *blockSize -screenDim.x /2 then
            cameraTranslation = -(255*blockSize - screenDim.x)

          else
            cameraTranslation = -(entity.player.pos.x -screenDim.x/2)
          end

        else
          cameraTranslation = 0
        end

        if resetPlayer then
          entity.player.reset()
          resetPlayer = false

        else
          entity.player.pos = {x = entity.player.spawnPos.x, y = entity.player.spawnPos.y}
          entity.player.vel = {x = 0, y = 0}
        end

        selected = "game"
        timeCounter = 0
      end
    end
  }
}

optionData.play = {
  display = function()
    return optionGenerator.loadOptions(optionGenerator.filterFiles(love.filesystem.getDirectoryItems("maps")), "play",
      function(box)
        formattedMap = {}

        if defaultMaps[box.name] then
          formattedMap = defaultMaps[box.name]

        else
          formattedMap = map.readTable("maps/" .. box.name .. ".map")
        end

        map.makeGrid(256, screenDim.y/blockSize)
        selected = "game"
        currMenu = "main"
        entity.player.reset()
        timeCounter = 0
      end
    )
  end
}

optionData.blockMenu = {
  display = function()

    return optionGenerator.loadBlockOptions()
  end,

  funcs = {
    nextPage = function() optionGenerator.currBlockPage = optionGenerator.currBlockPage + 1 end,
    prevPage = function() optionGenerator.currBlockPage = optionGenerator.currBlockPage - 1 end,
    toggleMapGrid = function() currSelectedGrid = currSelectedGrid == "foreground" and "background" or "foreground" end,
    togglePlaceMode = function() destroyMode = not destroyMode end
  }
}

optionData.winMenu = {
  display = function()
    local default = {w = screenDim.x /4, h = screenDim.y /8}
    default.x = screenDim.x /2 - default.w /2
    local boxGap = screenDim.y/30

    return {
      backToMenu = {name = "Back To Menu", x = default.x, y = screenDim.y /2 -default.h /2, w = default.w, h = default.h}
    }
  end,

  funcs = {
    backToMenu = function()
      selected = "menu"
      currMenu = "main"
      cameraTranslation = 0
      reachedGoal = false
    end
  }
}

optionData.smartPhoneEscMenu = {
  display = function()
    local box = {
      name = "esc",
      y = 0,
      w = screenDim.x / 5,
      h = screenDim.y / 15
    }
    box.x = screenDim.x - box.w

    return box
  end
}

optionData.smartPhoneMapCreator = {
  toggleBlockMenu = {
    x = screenDim.x / 2 - screenDim.x / 10,
    y = screenDim.y / 2 - screenDim.y / 24
  },

  displayIcon = function()
    local currCoords = optionData.smartPhoneMapCreator.toggleBlockMenu
    return {
      x = currCoords.x,
      y = currCoords.y,
      r = screenDim.y / 30,
    }
  end,

  display = function()
    return {
      toggleBlockMenu = {
        name = (mapCreatorMenu and "hide" or "show") .. " block menu",
        x = optionData.smartPhoneMapCreator.toggleBlockMenu.x,
        y = optionData.smartPhoneMapCreator.toggleBlockMenu.y,
        w = screenDim.x / 5,
        h = screenDim.y / 12
      }
    }
  end,

  funcs = {
    toggleBlockMenu = function() mapCreatorMenu = not mapCreatorMenu end
  }
}

return optionData
