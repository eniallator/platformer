local debug = {}

local timeTable = {}

debug.initTimes = function()
  if debugMode then
    timeTbl = {start = os.clock()}
  end
end

debug.addTime = function(tbl, label)
  if debugMode then
    if not timeTbl[tbl] then
      timeTbl[tbl] = {}
    end

    table.insert(timeTbl[tbl], {label, os.clock()})
  end
end

debug.printTimes = function()
  if debugMode then
    love.graphics.setColor(255, 255, 255)
    local font = love.graphics.newFont('assets/Psilly.otf', screenDim.x / 55)
    love.graphics.setFont(font)
    local height = font:getHeight('Lg')
    local currHeight = 0
    local lastValue = timeTbl.start

    for name, tbl in pairs(timeTbl) do
      if name ~= 'start' then
        currHeight = currHeight ~= 0 and currHeight + 2 * height or currHeight
        love.graphics.print(name .. ':', screenDim.x / 2 - cameraTranslation, currHeight)

        for i = 1, #tbl do
          currHeight = currHeight + height
          love.graphics.print(tbl[i][1] .. ': ' .. tbl[i][2] - lastValue, screenDim.x / 2 - cameraTranslation, currHeight)
          lastValue = tbl[i][2]
        end
      end
    end

    love.graphics.setFont(love.graphics.newFont('assets/Psilly.otf', screenDim.x / 40))
    timeTable = {}
  end
end

return debug
