local ErrorCollector = require("Notloc/ErrorCollector")
local EasyOptionDefinition = require("Notloc/EasyOptions/EasyOptionDefinition")
local EasyOptionInstance = require("Notloc/EasyOptions/EasyOptionInstance")
local EasyOptionType = require("Notloc/EasyOptions/EasyOptionType")
local EasyOptions = require("Notloc/EasyOptions/EasyOptions")

local EasyOptionsBuilder = {}

---@param default any
---@param options any[]
---@param uiName string
---@return EasyOptionDefinition
function EasyOptionsBuilder.defineDropdown(default, options, uiName)
    return EasyOptionDefinition.dropdown({
        default = default,
        options = options,
        uiName = uiName,
    })
end

---@param default any
---@param uiName string
---@return EasyOptionDefinition
function EasyOptionsBuilder.defineCheckbox(default, uiName)
    return EasyOptionDefinition.checkbox({
        default = default,
        uiName = uiName,
    })
end

---@param default any
---@return EasyOptionDefinition
function EasyOptionsBuilder.defineHidden(default)
    return EasyOptionDefinition.hidden({
        default = default,
    })
end

---@param optionDefinitions table<string, EasyOptionDefinition>
---@param modId string
---@param modUiName string
---@return EasyOptions
function EasyOptionsBuilder.build(optionDefinitions, modId, modUiName)
    local errors = ErrorCollector:new()

    local optionsObj = EasyOptions:new()
    local keys = {}
    for key, definition in pairs(optionDefinitions) do
        if definition:validate(errors) then
            keys[#keys+1] = key
            local optionInstance = EasyOptionInstance:new(optionsObj, key, definition)
            optionsObj._optionInstances[key] = optionInstance
            optionsObj.OnValueChanged[key] = optionInstance.OnValueChanged
            optionsObj[key] = definition.default
        end
    end

    if false and ModOptions and ModOptions.getInstance then
        EasyOptionsBuilder._buildModOptions(optionsObj, keys, modId, modUiName)
    end

    EasyOptionsBuilder._buildVanillaOptions(optionsObj, keys, modId, modUiName)
    EasyOptionsBuilder._reportErrorsAfterDelay(errors, 1000)

    return optionsObj
end

function EasyOptionsBuilder._buildVanillaOptions(optionsObj, keys, modId, modUiName)
    local vanillaOptions = PZAPI.ModOptions:create(modId, modUiName)
    optionsObj._vanillaOptions = vanillaOptions

    for _, key in ipairs(keys) do
        local optionInstance = optionsObj._optionInstances[key]
        local definition = optionInstance.definition

        if definition.type == EasyOptionType.DROPDOWN then
            EasyOptionsBuilder._buildVanillaDropdown(vanillaOptions, optionInstance)
        end
    end

    vanillaOptions.apply = function (self)
        for _, key in ipairs(keys) do
            local optionInstance = optionsObj._optionInstances[key]
            local definition = optionInstance.definition

            if definition.type == EasyOptionType.DROPDOWN then
                local vOption = self:getOption(key)
                local valueIdx = vOption.selected
                local value = definition.options[valueIdx].value
                optionInstance.parent[key] = value
                optionInstance.OnValueChanged:trigger(value)
            end
        end
    end

    local og_load = PZAPI.ModOptions.load
    PZAPI.ModOptions.load = function(self)
        og_load(self)
        pcall(function ()
            vanillaOptions:apply()
        end)
    end
end

function EasyOptionsBuilder._buildVanillaDropdown(vanillaOptions, optionInstance)
    local key = optionInstance.key
    local uiName = getText(optionInstance.definition.uiName)
    --local tooltip = getText(optionInstance.definition.tooltip)

    -- Create the dropdown and add the options to it
    local comboBox = vanillaOptions:addComboBox(key, uiName, "tooltip")
    for i, option in ipairs(optionInstance.definition.options) do
        local optionName = getText(option.name)
        comboBox:addItem(optionName, i == optionInstance.defaultIndex)
    end
end

-- Only throw errors after a delay, so we don't prevent the game from loading properly
EasyOptionsBuilder._registeredErrorReporters = {}
function EasyOptionsBuilder._reportErrorsAfterDelay(errorCollector, delay)
    if not errorCollector:hasErrors() then
        return
    end

    local errorReporter = function()
        local startTime = EasyOptionsBuilder._registeredErrorReporters[errorCollector].startTime
        if not startTime then
            EasyOptionsBuilder._registeredErrorReporters[errorCollector].startTime = getTimestampMs()
            return
        end

        local currentTime = getTimestampMs()
        if currentTime - startTime < delay then
            return
        end

        local reporter = EasyOptionsBuilder._registeredErrorReporters[errorCollector].errorReporter
        EasyOptionsBuilder._registeredErrorReporters[errorCollector] = nil
        Events.OnFETick.Remove(reporter)

        errorCollector:goBoom()
    end

    EasyOptionsBuilder._registeredErrorReporters[errorCollector] = { startTime = nil, errorReporter = errorReporter }
    Events.OnFETick.Add(errorReporter)
end


return EasyOptionsBuilder
