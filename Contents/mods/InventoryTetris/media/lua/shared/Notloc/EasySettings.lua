local EasySettingDefinition = require("Notloc/EasySettingDefinition")
local EasySettingType = require("Notloc/EasySettingType")

local EasySettings = {}

---@param default any
---@param options any[]
---@param uiName string
---@return EasySettingDefinition
function EasySettings.defineDropdown(default, options, uiName)
    return EasySettingDefinition.dropdown({
        default = default,
        options = options,
        uiName = uiName,
    })
end

---@param default any
---@param uiName string
---@return EasySettingDefinition
function EasySettings.defineCheckbox(default, uiName)
    return EasySettingDefinition.checkbox({
        default = default,
        uiName = uiName,
    })
end

---@param default any
---@return EasySettingDefinition
function EasySettings.defineHidden(default)
    return EasySettingDefinition.hidden({
        default = default,
    })
end


function EasySettings._createSettingInstance(parent, key, definition)
    local settingInstance = {
        key = key,
        parent = parent,
        definition = definition,
        OnValueChanged = NotUtil.createSimpleEvent(),
    }

    if definition.type == EasySettingType.DROPDOWN then
        for i, option in ipairs(definition.options) do
            if option.value == definition.default then
                settingInstance.defaultIndex = i
                break
            end
        end

        if not settingInstance.defaultIndex then
            error("Invalid default value for dropdown setting: "..key)
        end
    end

    return settingInstance
end


---@param settingDefinitions EasySettingDefinition[]
---@return table
function EasySettings.build(settingDefinitions, modId, modUiName)
    local SETTINGS = {
        OnValueChanged = {},
        _settingInstances = {},
    }

    local keys = {}

    for key, definition in pairs(settingDefinitions) do
        keys[#keys+1] = key
        SETTINGS[key] = definition.default
        local settingInstance = EasySettings._createSettingInstance(SETTINGS, key, definition)
        SETTINGS._settingInstances[key] = settingInstance
        SETTINGS.OnValueChanged[key] = settingInstance.OnValueChanged
    end

    if ModOptions and ModOptions.getInstance then
        EasySettings._buildModOptions(SETTINGS, keys, modId, modUiName)
    end

    return SETTINGS
end

function EasySettings._buildModOptions(SETTINGS, keys, modId, modUiName)
    -- I'm not clear on what the difference between these two is
    local modOptionsData = EasySettings._prebuildModOptions(SETTINGS, keys, modId, modUiName)
    local modOptionsInstance = ModOptions:getInstance(modOptionsData)

    ModOptions:loadFile()
    EasySettings._buildModOptionsInstance(SETTINGS, keys, modOptionsData, modOptionsInstance)

    SETTINGS._modOptionsInstance = modOptionsInstance
end

function EasySettings._prebuildModOptions(SETTINGS, keys, modId, modUiName)
    local modOptionsData = {
        options = {},
        names = {},
        mod_id = modId,
        mod_shortname = modUiName,
    }

    for _, key in ipairs(keys) do
        local settingInstance = SETTINGS._settingInstances[key]
        local definition = settingInstance.definition

        if definition.type ~= EasySettingType.HIDDEN then 
            modOptionsData.names[key] = settingInstance.definition.uiName
            modOptionsData.options[key] = settingInstance.default
            if definition.type == EasySettingType.DROPDOWN then
                modOptionsData.options[key] = settingInstance.defaultIndex
            end
        end
    end

    return modOptionsData
end

function EasySettings._buildModOptionsInstance(SETTINGS, keys, modOptionsData, modOptionsInstance)
    for _, key in ipairs(keys) do
        local settingInstance = SETTINGS._settingInstances[key]
        local definition = settingInstance.definition

        if definition.type ~= EasySettingType.HIDDEN then
            local modOptionEntry = modOptionsInstance:getData(key)
            if definition.type == EasySettingType.DROPDOWN then
                EasySettings._buildModOptionDropdown(modOptionsData, modOptionEntry, settingInstance)
            else
                function modOptionEntry:OnApplyInGame(val)
                    settingInstance.parent[key] = val
                    settingInstance.OnValueChanged:trigger(val)
                end
            end
        end
    end
end

function EasySettings._buildModOptionDropdown(modOptionsData, modOptionEntry, settingInstance)
    for i, option in ipairs(settingInstance.definition.options) do
        modOptionEntry[i] = option.name
    end

    function modOptionEntry:OnApplyInGame(index)
        modOptionsData.options[settingInstance.key] = index
        local value = settingInstance.definition.options[index].value
        settingInstance.parent[settingInstance.key] = value
        settingInstance.OnValueChanged:trigger(value)
    end
end

return EasySettings
