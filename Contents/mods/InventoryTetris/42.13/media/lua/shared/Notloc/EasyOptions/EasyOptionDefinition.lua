local EasyOptionType = require("Notloc/EasyOptions/EasyOptionType")

---@class EasyOptionDefinition
---@field type EasyOptionType
---@field default any
---@field luaName string
---@field uiName string
---@field options any[]?
---@field nameMap any[]?
local EasyOptionDefinition = {}

function EasyOptionDefinition.dropdown(o)
    o.type = EasyOptionType.DROPDOWN
    setmetatable(o, EasyOptionDefinition)
    return o
end

function EasyOptionDefinition.checkbox(o)
    o.type = EasyOptionType.CHECKBOX
    setmetatable(o, EasyOptionDefinition)
    return o
end

function EasyOptionDefinition.hidden(o)
    o.type = EasyOptionType.HIDDEN
    setmetatable(o, EasyOptionDefinition)
    return o
end

function EasyOptionDefinition.title(o)
    o.type = EasyOptionType.TITLE
    setmetatable(o, EasyOptionDefinition)
    return o
end

function EasyOptionDefinition.description(o)
    o.type = EasyOptionType.DESCRIPTION
    setmetatable(o, EasyOptionDefinition)
    return o
end

function EasyOptionDefinition.separator(o)
    o.type = EasyOptionType.SEPARATOR
    setmetatable(o, EasyOptionDefinition)
    return o
end

---@param errorCollector ErrorCollector
function EasyOptionDefinition:validate(errorCollector)
    if self.type == EasyOptionType.DROPDOWN then
        if not self.options or #self.options == 0 then
            errorCollector:add("EasyOptions: Dropdown " .. getText(self.uiName) .. " has no options.")
            return false
        end

        for _, option in ipairs(self.options) do
            if option.value == self.default then
                return true
            end
        end

        errorCollector:add("EasyOptions: Default value for " .. getText(self.uiName) .. " is not in the dropdown list.")
        return true -- Still allow the option to be created.
    end
    return true
end

return EasyOptionDefinition
