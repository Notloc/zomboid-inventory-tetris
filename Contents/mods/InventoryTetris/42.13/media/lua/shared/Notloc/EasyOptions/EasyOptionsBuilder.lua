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
function EasyOptionsBuilder.defineDropdown(luaName, default, options, uiName)
    return EasyOptionDefinition.dropdown({
        luaName = luaName,
        default = default,
        options = options,
        uiName = uiName,
    })
end

---@param default any
---@param uiName string
---@return EasyOptionDefinition
function EasyOptionsBuilder.defineCheckbox(luaName, default, uiName, tooltip)
    return EasyOptionDefinition.checkbox({
        luaName = luaName,
        default = default,
        uiName = uiName,
        tooltip = tooltip,
    })
end

---@param default any
---@return EasyOptionDefinition
function EasyOptionsBuilder.defineHidden(luaName, default)
    return EasyOptionDefinition.hidden({
        luaName = luaName,
        default = default,
    })
end

---@param uiName string
function EasyOptionsBuilder.defineTitle(uiName)
    return EasyOptionDefinition.title({
        uiName = uiName,
    })
end

---@param uiName string
function EasyOptionsBuilder.defineDescription(uiName)
    return EasyOptionDefinition.description({
        uiName = uiName,
    })
end

function EasyOptionsBuilder.defineSeparator()
    return EasyOptionDefinition.separator({})
end

---@param optionDefinitions EasyOptionDefinition[]
---@param modId string
---@param modUiName string
---@return EasyOptions
function EasyOptionsBuilder.build(optionDefinitions, modId, modUiName)
    local errors = ErrorCollector:new()

    local optionsObj = EasyOptions:new()
    local keys = {}
    for i, definition in ipairs(optionDefinitions) do
        if definition:validate(errors) then
            local key = definition.luaName
            if key then
                keys[#keys+1] = key
                local optionInstance = EasyOptionInstance:new(optionsObj, key, definition)
                optionsObj._optionInstances[key] = optionInstance
                optionsObj.OnValueChanged[key] = optionInstance.OnValueChanged
                optionsObj[key] = definition.default
            end
        end
    end

    EasyOptionsBuilder._buildOptions(optionsObj, optionDefinitions, keys, modId, modUiName)
    EasyOptionsBuilder._reportErrorsAfterDelay(errors, 1000)

    return optionsObj
end

function EasyOptionsBuilder._buildOptions(optionsObj, optionDefinitions, keys, modId, modUiName)
    local vanillaOptions = PZAPI.ModOptions:create(modId, modUiName)
    optionsObj._vanillaOptions = vanillaOptions

    for i, definition in ipairs(optionDefinitions) do
        local key = definition.luaName
        local optionInstance = optionsObj._optionInstances[key]

        if definition.type == EasyOptionType.DROPDOWN then
            EasyOptionsBuilder._buildDropdown(vanillaOptions, optionInstance)
        elseif definition.type == EasyOptionType.CHECKBOX then
            EasyOptionsBuilder._buildCheckbox(vanillaOptions, optionInstance)

        -- Layout options
        elseif definition.type == EasyOptionType.TITLE then
            EasyOptionsBuilder._buildTitle(vanillaOptions, definition.uiName)
        elseif definition.type == EasyOptionType.DESCRIPTION then
            EasyOptionsBuilder._buildDescription(vanillaOptions, definition.uiName)
        elseif definition.type == EasyOptionType.SEPARATOR then
            vanillaOptions:addSeparator()
        end
    end

    function vanillaOptions:apply()
        for _, key in ipairs(keys) do
            local optionInstance = optionsObj._optionInstances[key]
            local definition = optionInstance.definition

            if definition.type == EasyOptionType.DROPDOWN then
                local vOption = self:getOption(key)
                if vOption then
                    ---@cast vOption umbrella.ModOptions.ComboBox
                    local valueIdx = vOption.selected
                    local value = definition.options[valueIdx].value
                    optionInstance.parent[key] = value
                    optionInstance.OnValueChanged:trigger(value)
                end
            end

            if definition.type == EasyOptionType.CHECKBOX then
                local vOption = self:getOption(key)
                if vOption then
                    ---@cast vOption umbrella.ModOptions.TickBox
                    local value = vOption:getValue()
                    optionInstance.parent[key] = value
                    optionInstance.OnValueChanged:trigger(value)
                end
            end

        end
    end

    local og_load = PZAPI.ModOptions.load
    function PZAPI.ModOptions:load()
        og_load(self)
        pcall(function ()
            vanillaOptions:apply()
        end)
    end
end

function EasyOptionsBuilder._buildDropdown(vanillaOptions, optionInstance)
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

function EasyOptionsBuilder._buildCheckbox(vanillaOptions, optionInstance)
    local key = optionInstance.key
    local uiName = getText(optionInstance.definition.uiName)
    local tooltip = getText(optionInstance.definition.tooltip) or ""

    -- Create the dropdown and add the options to it
    local tickbox = vanillaOptions:addTickBox(key, uiName, optionInstance.definition.default, tooltip)
end

function EasyOptionsBuilder._buildTitle(vanillaOptions, uiName)
    local title = getText(uiName)
    vanillaOptions:addTitle(title)
end

function EasyOptionsBuilder._buildDescription(vanillaOptions, uiName)
    local description = getText(uiName)
    vanillaOptions:addDescription(description)
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
