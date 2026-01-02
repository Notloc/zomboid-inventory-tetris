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

---@class SimpleEvent
---@field add fun(self:SimpleEvent, listener: function)
---@field remove fun(self:SimpleEvent, listener: function)
---@field trigger function
---@field private _listeners function[]

---@return SimpleEvent
local function createSimpleEvent()
    local event = {}
    event._listeners = {}

    function event:add(func)
        table.insert(self._listeners, func)
    end

    function event:remove(func)
        table.remove(self._listeners, func)
    end

    function event:trigger(...)
        for _, func in ipairs(self._listeners) do
            func(...)
        end
    end

    return event
end

---@class EasyOptionEvent : SimpleEvent
---@field addAndApply fun(self:EasyOptionEvent, callback: function)

---@param optionInstance EasyOptionInstance
---@return EasyOptionEvent
function EasyOptionInstance._createEvent(optionInstance)
    ---@type EasyOptionEvent
    local event = createSimpleEvent()
    event.addAndApply = function(self, callback)
        self:add(callback)
        callback(optionInstance.parent[optionInstance.key])
    end
    return event
end

return EasyOptionInstance
