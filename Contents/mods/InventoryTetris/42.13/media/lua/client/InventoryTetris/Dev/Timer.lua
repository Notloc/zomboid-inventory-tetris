---@class Timer
---@field public prefix string
---@field public startTime_ns number
---@field private lastStep_ns number|nil
local Timer = {}

---@param prefix string
---@return Timer
function Timer:new(prefix)
    local o = {}
    setmetatable(o, self);
    self.__index = self;

    if isDebugEnabled() then
        GameTime.setServerTimeShift(0)
    end

    o.prefix = prefix
    o.startTime_ns = GameTime.getServerTime()

    ---@cast o Timer
    return o
end

function Timer:start()
    self.lastStep_ns = nil
    self.startTime_ns = GameTime.getServerTime()
end

---@param message string|nil
function Timer:stop(message)
    local compareTime_ns = self.lastStep_ns and self.lastStep_ns or self.startTime_ns
    local now_ns = GameTime.getServerTime()
    local elapsed_ns = now_ns - compareTime_ns

    local elapsed_ms = elapsed_ns / 1000000
    
    -- Format to 2 decimal
    local elapsed = string.format("%.2f", elapsed_ms)

    local prefix = self.prefix and self.prefix or ""
    if message then
        print(prefix .. message .. ": " .. tostring(elapsed) .. "ms")
    else
        print(prefix .. ": " .. tostring(elapsed) .. "ms")
    end

    self.lastStep_ns = GameTime.getServerTime()
end

return Timer
