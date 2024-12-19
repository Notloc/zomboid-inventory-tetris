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

    if ModOptions and ModOptions.getInstance then
        EasyOptionsBuilder._buildModOptions(optionsObj, keys, modId, modUiName)
    end

    EasyOptionsBuilder._reportErrorsAfterDelay(errors, 1000)

    return optionsObj
end

function EasyOptionsBuilder._buildModOptions(OPTIONS, keys, modId, modUiName)
    -- I'm not clear on what the difference between these two is
    local modOptionsData = EasyOptionsBuilder._prebuildModOptions(OPTIONS, keys, modId, modUiName)
    local modOptionsInstance = ModOptions:getInstance(modOptionsData)

    ModOptions:loadFile()
    EasyOptionsBuilder._buildModOptionsInstance(OPTIONS, keys, modId, modOptionsData, modOptionsInstance)

    OPTIONS._modOptionsInstance = modOptionsInstance
end

function EasyOptionsBuilder._prebuildModOptions(OPTIONS, keys, modId, modUiName)
    local modOptionsData = {
        options = {},
        names = {},
        mod_id = modId,
        mod_shortname = getText(modUiName),
    }

    for _, key in ipairs(keys) do
        local optionInstance = OPTIONS._optionInstances[key]
        local definition = optionInstance.definition

        if EasyOptionType.isModOptionsSupported(definition.type) then
            modOptionsData.names[key] = optionInstance.definition.uiName
            modOptionsData.options[key] = optionInstance.default
            if definition.type == EasyOptionType.DROPDOWN then
                modOptionsData.options[key] = optionInstance.defaultIndex
            end
        end
    end

    return modOptionsData
end

function EasyOptionsBuilder._buildModOptionsInstance(OPTIONS, keys, modId, modOptionsData, modOptionsInstance)
    for _, key in ipairs(keys) do
        local optionInstance = OPTIONS._optionInstances[key]
        local definition = optionInstance.definition

        if definition.type ~= EasyOptionType.HIDDEN then
            local modOptionEntry = modOptionsInstance:getData(key)
            if definition.type == EasyOptionType.DROPDOWN then
                EasyOptionsBuilder._buildModOptionDropdown(modOptionsData, modOptionEntry, optionInstance)
            end

            -- Load the value from the mod options
            modOptionEntry:OnApply(modOptionsData.options[key])
        end
    end
end

function EasyOptionsBuilder._buildModOptionDropdown(modOptionsData, modOptionEntry, optionInstance)
    for i, option in ipairs(optionInstance.definition.options) do
        modOptionEntry[i] = getText(option.name)
    end

    local key = optionInstance.key
    function modOptionEntry:OnApply(index)
        modOptionsData.options[key] = index
        local value = optionInstance.definition.options[index].value
        optionInstance.parent[key] = value
        optionInstance.OnValueChanged:trigger(value)
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
