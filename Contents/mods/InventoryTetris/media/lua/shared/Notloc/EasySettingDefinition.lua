local EasySettingType = require("Notloc/EasySettingType")

---@class EasySettingDefinition
---@field type EasySettingType
---@field default any
---@field uiName string?
---@field options any[]?
---@field nameMap any[]?
local EasySettingDefinition = {}

function EasySettingDefinition.dropdown(o)
    o.type = EasySettingType.DROPDOWN
    setmetatable(o, EasySettingDefinition)
    return o
end

function EasySettingDefinition.checkbox(o)
    o.type = EasySettingType.CHECKBOX
    setmetatable(o, EasySettingDefinition)
    return o
end

function EasySettingDefinition.hidden(o)
    o.type = EasySettingType.HIDDEN
    setmetatable(o, EasySettingDefinition)
    return o
end

return EasySettingDefinition
