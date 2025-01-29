---@class EasyOptions
---@field OnValueChanged table<string, EasyOptionEvent>
---@field _optionInstances table<string, EasyOptionInstance>
local EasyOptions = {}

---@return EasyOptions
function EasyOptions:new()
    local options = {
        OnValueChanged = {},
        _optionInstances = {},
    }

    setmetatable(options, self)
    self.__index = self

    return options
end

function EasyOptions:setValue(key, value)
    self[key] = value
    self.OnValueChanged[key]:trigger(value)
end

return EasyOptions
