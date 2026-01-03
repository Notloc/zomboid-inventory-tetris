---@class Timer
---@field public prefix string
---@field public decimals integer
---@field public startTime_ns number
---@field private lastStep_ns number|nil
---@field private smoothedTimeTable table<string, number>
local Timer = {}

---@param prefix string?
---@return Timer
function Timer:new(prefix)
    local o = {}
    setmetatable(o, self);
    self.__index = self;

    if isDebugEnabled() then
        GameTime.setServerTimeShift(0)
    end

    o.prefix = prefix
    o.silent = false
    o.decimals = 2
    o.startTime_ns = GameTime.getServerTime()

    o.smoothedTimeTable = {}

    ---@cast o Timer
    return o
end

function Timer:start()
    self.lastStep_ns = nil
    self.startTime_ns = GameTime.getServerTime()
end

---@param message string|nil
---@return number
function Timer:stop(message)
    local compareTime_ns = self.lastStep_ns and self.lastStep_ns or self.startTime_ns
    local now_ns = GameTime.getServerTime()
    local elapsed_ns = now_ns - compareTime_ns

    local elapsed_ms = elapsed_ns / 1000000
    
    -- If a key is provided, smooth the time over multiple calls
    if message then
        local prev = self.smoothedTimeTable[message] or elapsed_ms
        local smoothFactor = 0.05
        local smoothed = (prev * (1 - smoothFactor)) + (elapsed_ms * smoothFactor)
        self.smoothedTimeTable[message] = smoothed
        elapsed_ms = smoothed
    end

    local decimalsF = "%." .. tostring(self.decimals) .. "f"
    local elapsed = string.format(decimalsF, elapsed_ms)
    local prefix = self.prefix and self.prefix or ""
    if message then
        print(prefix .. message .. ": " .. tostring(elapsed) .. "ms")
    else
        print(prefix .. ": " .. tostring(elapsed) .. "ms")
    end

    -- Grab time again to avoid counting print time in next step
    self.lastStep_ns = GameTime.getServerTime()

    return elapsed_ms
end

return Timer
