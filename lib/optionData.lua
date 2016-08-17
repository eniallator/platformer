local loadedMaps
local currPage = 1
local optionData = {}

local function loadMapOptions()
  local mapIcon = {w = screenDim.x /2, h = screenDim.y /16}
  local boxGap = screenDim.y/40
  loadedMaps = love.filesystem.getDirectoryItems("maps")
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

  if mapPages[currPage +1] then
    returnTbl.nextPage = {name = "Next Page", x = screenDim.x - screenDim.x /5, y = screenDim.y /2 - (mapIcon.h + boxGap) *3 - boxGap - screenDim.y /20, w = screenDim.x /7, h = currY + boxGap *2 + mapIcon.h *3}
    -- yOffset = screenDim.y /20
  end

  if mapPages[currPage -1] then
    returnTbl.prevPage = {name = "Prev Page", x = screenDim.x /5 - screenDim.x /7, y = screenDim.y /2 - (mapIcon.h + boxGap) *3 - boxGap - screenDim.y /20, w = screenDim.x /7, h = currY + boxGap *2 + mapIcon.h *3}
  end

  for k,v in pairs(mapPages[currPage]) do
    returnTbl[k] = v
  end

  loadPlayFuncs(mapPages[currPage])

  return returnTbl
end

function loadPlayFuncs(page)
  optionData.play.funcs = {
    nextPage = function() currPage = currPage + 1 end,
    prevPage = function() currPage = currPage - 1 end,
    back = function() currMenu = "main" currPage = 1 end
  }

  for k,v in pairs(page) do
    optionData.play.funcs[k] = function(box)

      formattedMap = map.readTable("maps/" .. box.name)
      selected = "game"
      currMenu = "main"
    end
  end
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
    createMap = function() selected = "createMap" end,
    settings = function() currMenu = "options" end
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

optionData.play = {
  display = function()

    return loadMapOptions()
  end
}

return optionData
