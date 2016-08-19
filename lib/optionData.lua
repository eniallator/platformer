local loadedMaps
local currPlayPage = 1
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

local function loadMapOptions()
  local mapIcon = {w = screenDim.x /2, h = screenDim.y /16}
  local boxGap = screenDim.y/40
  loadedMaps = filterFiles(love.filesystem.getDirectoryItems("maps"))

  mapPages = {}

  for i=1, #loadedMaps do
    if i % 8 == 1 then
      mapPages[math.floor(i/8 +1)] = {}
      currY = screenDim.y /2 - (mapIcon.h + boxGap) *3 - boxGap - screenDim.y /20
    end

    table.insert(mapPages[math.floor((i -1) /8 +1)], {name = loadedMaps[i], x = screenDim.x /2 - mapIcon.w /2, y = currY, w = mapIcon.w, h = mapIcon.h})
    currY = currY + mapIcon.h + boxGap
  end

  local returnTbl = {back = {name = "Back", x = screenDim.x /2 - mapIcon.w /2, y = screenDim.y /2 + mapIcon.h *1.5 + (mapIcon.h + boxGap) *3, w = mapIcon.w, h = mapIcon.h}}
  local pageGap = screenDim.x /40

  if mapPages[currPlayPage +1] then
    returnTbl.nextPage = {name = "Next Page", x = screenDim.x - screenDim.x /5, y = screenDim.y /2 - (mapIcon.h + boxGap) *3 - boxGap - screenDim.y /20, w = screenDim.x /7, h = currY + boxGap *2 + mapIcon.h *3}
    -- yOffset = screenDim.y /20
  end

  if mapPages[currPlayPage -1] then
    returnTbl.prevPage = {name = "Prev Page", x = screenDim.x /5 - screenDim.x /7, y = screenDim.y /2 - (mapIcon.h + boxGap) *3 - boxGap - screenDim.y /20, w = screenDim.x /7, h = currY + boxGap *2 + mapIcon.h *3}
  end

  for k,v in pairs(mapPages[currPlayPage]) do
    returnTbl[k] = v
  end

  loadPlayFuncs(mapPages[currPlayPage])

  return returnTbl
end

function loadPlayFuncs(page)
  optionData.play.funcs = {
    nextPage = function() currPlayPage = currPlayPage + 1 end,
    prevPage = function() currPlayPage = currPlayPage - 1 end,
    back = function() currMenu = "main" currPlayPage = 1 end
  }

  for k,v in pairs(page) do
    optionData.play.funcs[k] = function(box)

      formattedMap = map.readTable("maps/" .. box.name .. ".map")
      map.makeGrid()
      selected = "game"
      currMenu = "main"
    end
  end
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
    play = function() currMenu = "play" end,
    settings = function() currMenu = "options" end,

    createMap = function()
      selected = "createMap"
      formattedMap = {}
      map.makeGrid()
      firstLoad = true
    end
  }
}

optionData.options = {
  display = function()
    local default = {w = screenDim.x /4, h = screenDim.y /8}
    default.x = screenDim.x /2 - default.w /2
    local boxGap = screenDim.y/30

    return {
      back = {name = "Back", x = default.x, y = screenDim.y/2 - default.h/2, w = default.w, h = default.h}
    }
  end,

  funcs = {
    back = function() currMenu = "main" end
  }
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
    save = function() map.writeTable(map.transform(mapGrid), "maps/testMap.map") end,
    backToMenu = function() selected = "menu" currMenu = "main" update.resetPlayer() end,
    modeSwitch = function()
      if selected == "game" then
        selected = "createMap"

      else
        if player.pos.x +player.w /2 > screenDim.x /2  then
          if player.pos.x +player.w /2 > 255 *blockSize -screenDim.x /2 then
            cameraTranslation = -(255*blockSize - screenDim.x)

          else
            cameraTranslation = -(player.pos.x -screenDim.x/2)
          end

        else
          cameraTranslation = 0
        end

        selected = "game"
      end
    end
  }
}

optionData.play = {
  display = function()

    return loadMapOptions()
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

return optionData
