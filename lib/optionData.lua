local optionData = {}

optionData.main = {
  display = function()
    local default = {w = screenDim.x /4, h = screenDim.y /8}
    default.x = screenDim.x /2 - default.w /2
    local boxGap = 20

    return {
      play = {name = "Play", x = default.x, y = screenDim.y /2 - default.h *1.5 - boxGap, w = default.w, h = default.h},
      createMap = {name = "Map Creator", x = default.x, y = screenDim.y /2 - default.h /2, w = default.w, h = default.h},
      settings = {name = "Settings", x = default.x, y = screenDim.y /2 + default.h /2 + boxGap, w = default.w, h = default.h}
    }
  end,

  funcs = {
    play = function() selected = "game" end,
    createMap = function() selected = "createMap" end,
    settings = function() currMenu = "options" end
  }
}

optionData.options = {
  display = function()
    local default = {w = screenDim.x /4, h = screenDim.y /8}
    default.x = screenDim.x /2 - default.w /2
    local boxGap = 20

    return {
      back = {name = "Back", x = default.x, y = screenDim.y/2 - default.h/2, w = default.w, h = default.h}
    }
  end,

  funcs = {
    back = function() currMenu = "main" end
  }
}

return optionData
