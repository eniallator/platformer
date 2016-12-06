local credits = {
  {
    prefix = "Credits",
    name = ""
  },
  {
    prefix = "Coder",
    name = "eniallator",
    youtube = "https://www.youtube.com/c/en1allat0r",
    twitter = "https://twitter.com/mceniallator"
  },
  {
    prefix = "Artist",
    name = "Sairtoume",
    soundcloud = "https://soundcloud.com/user-380605931"
  },
  {
    prefix = "Artist",
    name = "SacredRedstone",
    youtube = "https://www.youtube.com/user/SacredRedstone",
    twitter = "https://twitter.com/SacredRedstone"
  }
}

credits.websiteIcons = {
  twitter = love.graphics.newImage("assets/textures/icons/twitter.png"),
  youtube = love.graphics.newImage("assets/textures/icons/youtube.png"),
  soundcloud = love.graphics.newImage("assets/textures/icons/soundcloud.png")
}

local function getMaxTextSize(font, textType)
  local size = 0

  for i=1,#credits do
    local currWidth = font:getWidth(credits[i][textType])

    if currWidth > size then
      size = currWidth
    end
  end

  return size
end

local function generateIcons(font, maxPrefixSize, iconSize)
  local iconTbl = {}
  local maxNameSize = getMaxTextSize(font, "name")

  for i=1,#credits do
    local rowY = screenDim.y - (iconSize + 5) * (#credits - i + 1) - 10
    local iconNum = 0

    for websiteName, url in pairs(credits[i]) do
      if websiteName ~= "prefix" and websiteName ~= "name" then
        local currIcon = {type = websiteName, url = url}

        currIcon.x = 50 + maxNameSize + maxPrefixSize + iconNum * (iconSize + 5)
        currIcon.y = rowY
        currIcon.w = iconSize
        currIcon.h = iconSize

        table.insert(iconTbl, currIcon)
        iconNum = iconNum + 1
      end
    end
  end

  return iconTbl
end

local function displayIcons(font, maxPrefixSize, iconSize)
  local iconList = generateIcons(font, maxPrefixSize, iconSize)

  for name,box in pairs(iconList) do
    local currIcon = credits.websiteIcons[box.type]
    love.graphics.draw(currIcon, box.x, box.y, 0, box.w / currIcon:getWidth(), box.h / currIcon:getHeight())
  end
end

credits.display = function()
  if currMenu == "main" then
    local font = love.graphics.newFont("assets/Psilly.otf", screenDim.x / (isSmartPhone and 30 or 40))
    love.graphics.setFont(font)

    local maxPrefixSize = getMaxTextSize(font, "prefix")
    local iconSize = screenDim.y / (isSmartPhone and 16 or 27)
    displayIcons(font, maxPrefixSize, iconSize)

    for i=1,#credits do
      love.graphics.print(credits[i], 15, screenDim.y -(font:getHeight(credits[i]) + 2) * (#credits - i + 1) - 10)
      local rowY = screenDim.y -(iconSize + 5) * (#credits - i + 1) - 10
      local iconsDrawn = 0

      love.graphics.print(credits[i].prefix, 15, rowY)
      love.graphics.print(":  " .. credits[i].name, 25 + maxPrefixSize, rowY)
    end

    love.graphics.setFont(love.graphics.newFont("assets/Psilly.otf", screenDim.x / 40))
  end
end

credits.update = function()
  if currMenu == "main" then
    local font = love.graphics.getFont()
    local iconSize = screenDim.y / (isSmartPhone and 16 or 27)
    local iconList = generateIcons(font, getMaxTextSize(font, "prefix"), iconSize)

    collision.updateMouseCursor(iconList)
    local clickedIcon = collision.clickBox(iconList)

    if clickedIcon then
      love.system.openURL(iconList[clickedIcon].url)
    end
  end
end

return credits
