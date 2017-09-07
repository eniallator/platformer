local timer = {}

function timer:init(tps)
    self.tps = tps
    self.last = os.clock()
    self.dt = 0.0
    self.ds = 0.0
    self.ticks = 0
    self.missingTicks = 0
end

function timer:clock()
    local now = os.clock()
    local deltaS = now - self.last
    self.last = now
    self.ds = self.ds + deltaS

    self.dt = self.dt + deltaS * self.tps

    if self.dt > 1 then
        self.missingTicks = math.floor(self.dt)
        self.dt = self.dt - self.missingTicks
        self.ticks = self.ticks + self.missingTicks
    else
        self.missingTicks = 0
    end

    if self.ds > 1 then
        self.ds = self.ds - 1
        self.ticks = 0
    end
end

return timer