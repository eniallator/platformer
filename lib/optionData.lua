local loadedMaps
local currOptionPage = 1
local currBlockPage = 1
local otherTranslation = 0
local optionData = {}

local function filterFiles(oldTbl)
  newTbl = {}

  for i=1, #oldTbl do
    if oldTbl[i]:sub(#oldTbl[i] -#mapExtension +1, #oldTbl[i]) == mapExtension then
      table.insert(newTbl, oldTbl[i]:sub(1, #oldTbl[i] -#mapExtension))
    end
  end

  return newTbl
end

local function tblToStr(tbl)
  local outTbl = {}

  for i=1, #controls do
    if controls.waitForPress ~= i then
      table.insert(outTbl, {controls[i].name .. ": " .. controls[i].key, i})
    else
      table.insert(outTbl, {"Press new key to set", i})
    end
  end

  return outTbl
end

local function generatePages(tbl)
  local outTbl = {}
  local dim = {w = screenDim.x /2, h = screenDim.y /16}
  local boxGap = screenDim.y/40

  for i=1, #tbl do
    if i % 8 == 1 then
      outTbl[math.floor(i/8 +1)] = {}
      currY = screenDim.y /2 - (dim.h + boxGap) *3 - boxGap - screenDim.y /20
    end

    local tblToInsert = {x = screenDim.x /2 - dim.w /2, y = currY, w = dim.w, h = dim.h}

    if type(tbl[i]) == "table" then
      tblToInsert.name = tbl[i][1]
      tblToInsert.controlIndex = tbl[i][2]

    else
      tblToInsert.name = tbl[i]
    end

    table.insert(outTbl[math.floor((i -1) /8 +1)], tblToInsert)
    currY = currY + dim.h + boxGap
  end

  return outTbl
end

local function loadOptionFuncs(page, menuName, func)
  optionData[menuName].funcs = {
    nextPage = function(_, rmb)
      if not rmb then
        currOptionPage = currOptionPage + 1
      end
    end,

    prevPage = function(_, rmb)
      if not rmb then
        currOptionPage = currOptionPage - 1
      end
    end,

    back = function(_, rmb)
      if not rmb then
        currMenu = "main" currOptionPage = 1
      end
    end
  }

  if menuName == "controls" then
    optionData[menuName].funcs.apply = controls.applyChanges
  end

  if page then
    for k,v in pairs(page) do
      optionData[menuName].funcs[k] = func
    end
  end
end

local function loadOptions(list, menuName, func)
  local mapIcon = {w = screenDim.x /2, h = screenDim.y /16}
  local boxGap = screenDim.y/40
  local listPages = generatePages(list)
  local pageGap = screenDim.x /40
  local returnTbl = {back = {name = "Back", x = screenDim.x /2 - mapIcon.w /2, y = screenDim.y /2 + mapIcon.h *1.5 + (mapIcon.h + boxGap) *3, w = mapIcon.w, h = mapIcon.h}}

  if menuName == "controls" then
    returnTbl.back.w = mapIcon.w /2 -pageGap /2
    returnTbl.apply = {name = "Apply", x = screenDim.x /2 +pageGap /2, y = screenDim.y /2 + mapIcon.h *1.5 + (mapIcon.h + boxGap) *3, w = mapIcon.w /2 -pageGap /2, h = mapIcon.h}
  end

  if listPages[currOptionPage +1] then
    returnTbl.nextPage = {name = "Next Page", x = screenDim.x - screenDim.x /5, y = screenDim.y /2 - (mapIcon.h + boxGap) *3 - boxGap - screenDim.y /20, w = screenDim.x /7, h = currY + boxGap *2 + mapIcon.h *3}
  end

  if listPages[currOptionPage -1] then
    returnTbl.prevPage = {name = "Prev Page", x = screenDim.x /5 - screenDim.x /7, y = screenDim.y /2 - (mapIcon.h + boxGap) *3 - boxGap - screenDim.y /20, w = screenDim.x /7, h = currY + boxGap *2 + mapIcon.h *3}
  end

  if listPages[1] then
    for k,v in pairs(listPages[currOptionPage]) do
      if menuName == "controls" and v.name == controls.waitForPress then
        v.name = "Press a key to change"
      end

      returnTbl[k] = v
    end
  end

  loadOptionFuncs(listPages[currOptionPage], menuName, func)
  return returnTbl
end

local function loadBlockOptions()
  local pageIndex = 0
  local returnTbl = {}
  local blockGap = screenDim.x /40
  local currX

  for i=1, #blocks do
    if i%14 == 1 then
      pageIndex = pageIndex +1
      returnTbl[pageIndex] = {}
      currX = screenDim.x /(40/3)
    end

    table.insert(returnTbl[pageIndex], {blockIndex = i, texture = texture.block[blocks[i].name], x = currX, y = screenDim.y -screenDim.y /12, w = blockSize, h = blockSize})
    currX = currX + blockSize + blockGap
  end

  if returnTbl[currBlockPage + 1] then
    returnTbl[currBlockPage].nextPage = {name = "Next", x = screenDim.x -(screenDim.x /(40/3) - blockSize), y = screenDim.y -screenDim.y /12, w = blockSize, h = blockSize}
  end

  if returnTbl[currBlockPage - 1] then
    returnTbl[currBlockPage].prevPage = {name = "Prev", x = screenDim.x /(40/3) - blockSize, y = screenDim.y -screenDim.y /12, w = blockSize, h = blockSize}
  end

  return returnTbl[currBlockPage]
end

optionData.main = {
  display = function()
    local default = {w = screenDim.x /4, h = screenDim.y /8}
    default.x = screenDim.x /2 - default.w /2
    local boxGap = screenDim.y/30

    return {
      play = {name = "Play", x = default.x, y = screenDim.y /2 - default.h *1.5 - boxGap, w = default.w, h = default.h},
      createMap = {name = "Map Creator", x = default.x, y = screenDim.y /2 - default.h /2, w = default.w, h = default.h},
      settings = {name = "Settings", x = default.x, y = screenDim.y /2 + default.h /2 + boxGap, w = default.w, h = default.h}
    }
  end,

  funcs = {
    play = function() currMenu = "play" currOptionPage = 1 end,
    settings = function() currMenu = "options" end,

    createMap = function()
      selected = "createMap"
      formattedMap = {}
      map.makeGrid(256, screenDim.y/blockSize)
      firstLoad = true
      resetPlayer = true
    end
  }
}

optionData.options = {
  display = function()
    local default = {w = screenDim.x /4, h = screenDim.y /8}
    default.x = screenDim.x /2 - default.w /2
    local boxGap = screenDim.y/30

    return {
      controls = {name = "Controls", x = default.x, y = screenDim.y/2 - boxGap/2 - default.h, w = default.w, h = default.h},
      back = {name = "Back", x = default.x, y = screenDim.y/2 + boxGap/2, w = default.w, h = default.h}
    }
  end,

  funcs = {
    back = function() currMenu = "main" end,
    controls = function() currMenu = "controls" currOptionPage = 1 end
  }
}

optionData.controls = {
  display = function()
    return loadOptions(tblToStr(controls), "controls",
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
    save = function() utilsData.textBox.selected = "saveMap" end,

    backToMenu = function()
      selected = "menu"
      currMenu = "main"
      cameraTranslation = 0
    end,

    modeSwitch = function()
      if selected == "game" then
        selected = "createMap"

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
      end
    end
  }
}

optionData.play = {
  display = function()
    return loadOptions(filterFiles(love.filesystem.getDirectoryItems("maps")), "play",
      function(box, rmb)
        if not rmb then
          formattedMap = map.readTable("maps/" .. box.name .. ".map")
          map.makeGrid(256, screenDim.y/blockSize)
          selected = "game"
          currMenu = "main"
          entity.player.reset()

        else
          utilsData.dropMenu.selected = "playMap"
          utilsData.dropMenu.mapName = box.name
        end
      end
    )
  end
}

optionData.blockMenu = {
  display = function()

    return loadBlockOptions()
  end,

  funcs = {
    nextPage = function() currBlockPage = currBlockPage + 1 end,
    prevPage = function() currBlockPage = currBlockPage - 1 end
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

return optionData
