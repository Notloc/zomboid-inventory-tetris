local EasyOptionType = require("Notloc/EasyOptions/EasyOptionType")

---@class EasyOptionInstance
---@field key string
---@field parent EasyOptions
---@field definition EasyOptionDefinition
---@field OnValueChanged EasyOptionEvent

local EasyOptionInstance = {}

---@param parent EasyOptions
---@param key string
---@param definition EasyOptionDefinition
---@return EasyOptionInstance
function EasyOptionInstance:new(parent, key, definition)
    local optionInstance = {
        key = key,
        parent = parent,
        definition = definition
    }
    optionInstance.OnValueChanged = EasyOptionInstance._createEvent(optionInstance)
    EasyOptionInstance._init(optionInstance)
    return optionInstance
end

function EasyOptionInstance._init(optionInstance)
    local definition = optionInstance.definition
    if definition.type == EasyOptionType.DROPDOWN then
        optionInstance.defaultIndex = 1
        for i, option in ipairs(definition.options) do
            if option.value == definition.default then
                optionInstance.defaultIndex = i
                break
            end
        end
    end
end

---@class EasyOptionEvent : SimpleEvent
---@field addAndApply fun(self:EasyOptionEvent, callback: function)

---@param optionInstance EasyOptionInstance
---@return EasyOptionEvent
function EasyOptionInstance._createEvent(optionInstance)
    ---@class EasyOptionEvent
    local event = NotUtil.createSimpleEvent()
    event.addAndApply = function(self, callback)
        self:add(callback)
        callback(optionInstance.parent[optionInstance.key])
    end
    return event
end

return EasyOptionInstance
