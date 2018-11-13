local optionGenerator = {
  currBlockPage = 1,
  currOptionPage = 1
}

optionGenerator.filterFiles = function(oldTbl)
  newTbl = {}

  for i = 1, #oldTbl do
    if oldTbl[i]:sub(#oldTbl[i] - #mapExtension + 1, #oldTbl[i]) == mapExtension then
      table.insert(newTbl, oldTbl[i]:sub(1, #oldTbl[i] - #mapExtension))
    end
  end

  return newTbl
end

optionGenerator.tblToStr = function(tbl)
  local outTbl = {}

  for i = 1, #controls do
    if controls.waitForPress ~= i then
      table.insert(outTbl, {controls[i].name .. ': ' .. controls[i].key, i})
    else
      table.insert(outTbl, {'Press new key to set', i})
    end
  end

  return outTbl
end

local function generatePages(tbl)
  local outTbl = {}
  local dim = {w = screenDim.x / 2, h = screenDim.y / 16}
  local boxGap = screenDim.y / 40
  local counter = 0

  if currMenu == 'play' then
    dim.w = screenDim.x * (3 / 8) - boxGap / 2
    outTbl.deleteNames = {}

    for name, _ in pairs(defaultMaps) do
      counter = counter + 1

      if counter % 8 == 1 then
        outTbl[math.floor(counter / 8 + 1)] = {mapNames = {}, deleteNames = {}}
        currY = screenDim.y / 2 - (dim.h + boxGap) * 3 - boxGap - screenDim.y / 20
      end

      local yIndex = math.floor((counter - 1) / 8 + 1)
      local mapNameTbl = {
        name = name,
        x = screenDim.x / 2 - screenDim.x / 4,
        y = currY,
        w = screenDim.x / 2,
        h = dim.h
      }

      table.insert(outTbl[yIndex].mapNames, mapNameTbl)
      currY = currY + dim.h + boxGap
    end
  end

  for i = 1, #tbl do
    i = i + counter

    if i % 8 == 1 then
      outTbl[math.floor(i / 8 + 1)] = {mapNames = {}}
      currY = screenDim.y / 2 - (dim.h + boxGap) * 3 - boxGap - screenDim.y / 20

      if currMenu == 'play' then
        outTbl[math.floor(i / 8 + 1)].deleteNames = {}
      end
    end

    local mapNameTbl = {
      x = screenDim.x / 2 - screenDim.x / 4,
      y = currY,
      w = dim.w,
      h = dim.h
    }

    if type(tbl[i]) == 'table' then
      mapNameTbl.name = tbl[i - counter][1]
      mapNameTbl.controlIndex = tbl[i - counter][2]
    else
      mapNameTbl.name = tbl[i - counter]
    end

    local yIndex = math.floor((i - 1) / 8 + 1)
    table.insert(outTbl[yIndex].mapNames, mapNameTbl)

    if currMenu == 'play' then
      local deleteMapTbl = {
        mapName = tbl[i - counter],
        name = 'Delete',
        x = mapNameTbl.x + mapNameTbl.w + boxGap,
        y = currY,
        w = screenDim.x * (1 / 8) - boxGap / 2,
        h = dim.h
      }

      table.insert(outTbl[yIndex].deleteNames, deleteMapTbl)
    end

    currY = currY + dim.h + boxGap
  end

  return outTbl
end

local function loadOptionFuncs(page, menuName, func)
  optionData[menuName].funcs = {
    nextPage = function(_, rmb)
      if not rmb then
        optionGenerator.currOptionPage = optionGenerator.currOptionPage + 1
      end
    end,
    prevPage = function(_, rmb)
      if not rmb then
        optionGenerator.currOptionPage = optionGenerator.currOptionPage - 1
      end
    end,
    back = function(_, rmb)
      if not rmb then
        currMenu = 'main'
        optionGenerator.currOptionPage = 1
      end
    end
  }

  if menuName == 'controls' then
    optionData[menuName].funcs.apply = controls.applyChanges
  end

  if page then
    for k, v in pairs(page.mapNames) do
      optionData[menuName].funcs[k] = func

      if menuName == 'play' then
        optionData[menuName].funcs['delete:' .. k] = function(box, rmb)
          utilsData.alert.selected = 'deleteMapConfirm'
          utilsData.alert.deleteMapConfirm.selectedMap = box.mapName
        end
      end
    end
  end
end

optionGenerator.loadOptions = function(list, menuName, func)
  local mapIcon = {w = screenDim.x / 2, h = screenDim.y / 16}
  local boxGap = screenDim.y / 40
  local listPages = generatePages(list)
  local pageGap = screenDim.x / 40
  local returnTbl = {
    back = {
      name = 'Back',
      x = screenDim.x / 2 - mapIcon.w / 2,
      y = screenDim.y / 2 + mapIcon.h * 1.5 + (mapIcon.h + boxGap) * 3,
      w = mapIcon.w,
      h = mapIcon.h
    }
  }

  if menuName == 'controls' then
    returnTbl.back.w = mapIcon.w / 2 - pageGap / 2
    returnTbl.apply = {
      name = 'Apply',
      x = screenDim.x / 2 + pageGap / 2,
      y = screenDim.y / 2 + mapIcon.h * 1.5 + (mapIcon.h + boxGap) * 3,
      w = mapIcon.w / 2 - pageGap / 2,
      h = mapIcon.h
    }
  end

  if listPages[optionGenerator.currOptionPage + 1] then
    returnTbl.nextPage = {
      name = 'Next Page',
      x = screenDim.x - screenDim.x / 5,
      y = screenDim.y / 2 - (mapIcon.h + boxGap) * 3 - boxGap - screenDim.y / 20,
      w = screenDim.x / 7,
      h = currY + boxGap * 2 + mapIcon.h * 3
    }
  end

  if listPages[optionGenerator.currOptionPage - 1] then
    returnTbl.prevPage = {
      name = 'Prev Page',
      x = screenDim.x / 5 - screenDim.x / 7,
      y = screenDim.y / 2 - (mapIcon.h + boxGap) * 3 - boxGap - screenDim.y / 20,
      w = screenDim.x / 7,
      h = currY + boxGap * 2 + mapIcon.h * 3
    }
  end

  if listPages[1] then
    for k, v in pairs(listPages[optionGenerator.currOptionPage].mapNames) do
      if menuName == 'controls' and v.name == controls.waitForPress then
        v.name = 'Press a key to change'
      end

      returnTbl[k] = v

      if menuName == 'play' then
        returnTbl['delete:' .. k] = listPages[optionGenerator.currOptionPage].deleteNames[k]
      end
    end
  end

  loadOptionFuncs(listPages[optionGenerator.currOptionPage], menuName, func)
  return returnTbl
end

optionGenerator.loadBlockOptions = function()
  local pageIndex = 0
  local returnTbl = {}
  local blockGap = screenDim.x / 40
  local currX

  for i = 1, #blocks do
    if i % 14 == 1 then
      pageIndex = pageIndex + 1
      returnTbl[pageIndex] = {}
      currX = screenDim.x / (40 / 3)
    end

    table.insert(
      returnTbl[pageIndex],
      {blockIndex = i, texture = texture.block[blocks[i].name], x = currX, y = screenDim.y - screenDim.y / 12, w = blockSize, h = blockSize}
    )
    currX = currX + blockSize + blockGap
  end

  if returnTbl[optionGenerator.currBlockPage + 1] then
    returnTbl[optionGenerator.currBlockPage].nextPage = {
      name = 'Next',
      x = screenDim.x - (screenDim.x / (40 / 1) + blockSize),
      y = screenDim.y - screenDim.y / 12,
      w = blockSize,
      h = blockSize
    }
  end

  if returnTbl[optionGenerator.currBlockPage - 1] then
    returnTbl[optionGenerator.currBlockPage].prevPage = {
      name = 'Prev',
      x = screenDim.x / (40 / 1),
      y = screenDim.y - screenDim.y / 12,
      w = blockSize,
      h = blockSize
    }
  end

  local buttonWidth = screenDim.x / 3 - 17.5

  if isSmartPhone then
    returnTbl[optionGenerator.currBlockPage].togglePlaceMode = {
      name = 'Mode: ' .. (destroyMode and 'Destroy' or 'Place'),
      x = 20 + buttonWidth,
      y = 10,
      w = buttonWidth,
      h = screenDim.y / 16
    }
  end

  returnTbl[optionGenerator.currBlockPage].toggleMapGrid = {
    name = 'Selected layer: ' .. currSelectedGrid,
    x = 10,
    y = 10,
    w = buttonWidth,
    h = screenDim.y / 16
  }

  returnTbl[optionGenerator.currBlockPage].blockMenuArea = {
    notButton = true,
    x = screenDim.x / 60 - cameraTranslation,
    y = screenDim.y - screenDim.y / 9,
    w = screenDim.x - screenDim.x / 60 * 2,
    h = blockSize * 2
  }

  return returnTbl[optionGenerator.currBlockPage]
end

return optionGenerator
