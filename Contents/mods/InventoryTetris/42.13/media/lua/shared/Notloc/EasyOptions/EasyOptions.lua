---@class EasyOptions
---@field OnValueChanged table<string, EasyOptionEvent>
---@field _optionInstances table<string, EasyOptionInstance>
local EasyOptions = {}
EasyOptions.__index = EasyOptions

---@return EasyOptions
function EasyOptions:new()
    local o = setmetatable({}, self)
    o.OnValueChanged = {}
    o._optionInstances = {}
    return o
end

function EasyOptions:setValue(key, value)
    self[key] = value
    self.OnValueChanged[key]:trigger(value)
end

return EasyOptions
