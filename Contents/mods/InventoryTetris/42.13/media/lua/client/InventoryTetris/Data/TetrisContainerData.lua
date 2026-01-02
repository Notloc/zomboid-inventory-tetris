local TetrisItemCategory = require("InventoryTetris/Data/TetrisItemCategory")
local TetrisContainerCalculator = require("InventoryTetris/Data/TetrisContainerCalculator")
local TetrisModCompatibility = require("InventoryTetris/TetrisModCompatibility")

---@class ContainerGridDefinition
---@field gridDefinitions GridDefinition[]
---@field validCategories table<TetrisItemCategory, boolean>|nil
---@field invalidCategories TetrisItemCategory[]|nil -- Deprecated
---@field isFragile boolean|nil
---@field isRigid boolean|nil
---@field trueType string|nil
---@field _autoCalculated boolean|nil
---@field corrected boolean|nil

---@class GridDefinition
---@field size WidthHeight
---@field position XY

---@class TetrisContainerService
---@field _containerDefinitions table<string, ContainerGridDefinition>
---@field _devContainerDefinitions table<string, ContainerGridDefinition>
local TetrisContainerService = {}

TetrisContainerService._containerDefinitions = {}
TetrisContainerService._devContainerDefinitions = {}

-- Containers that must never be marked as non-fragile due to java side hardcoding
-- Without this the disable carry weight feature causes the containers to misbehave
local MUST_BE_FRAGILE = {
    ["clothingwasher"] = true,
    ["clothingdryer"] = true,
}

---@param container ItemContainer
---@param containerDef ContainerGridDefinition?
function TetrisContainerService.setContainerDefinition(container, containerDef)
    local containerKey = TetrisContainerService._getContainerKey(container)
    TetrisContainerService._containerDefinitions[containerKey] = containerDef
end

---@param container ItemContainer
---@return ContainerGridDefinition
function TetrisContainerService.getContainerDefinition(container)
    local containerKey = TetrisContainerService._getContainerKey(container)
    return TetrisContainerService._getContainerDefinitionByKey(container, containerKey)
end

---@param container ItemContainer
---@return integer
function TetrisContainerService.calculateInnerSize(container)
    local definition = TetrisContainerService.getContainerDefinition(container)
    return TetrisContainerService._calculateInnerSizeByDefinition(definition)
end

---@param definition ContainerGridDefinition
---@return integer
function TetrisContainerService._calculateInnerSizeByDefinition(definition)
    local innerSize = 0
    for _, gridDefinition in ipairs(definition.gridDefinitions) do
        local x = gridDefinition.size.width + SandboxVars.InventoryTetris.BonusGridSize
        local y = gridDefinition.size.height + SandboxVars.InventoryTetris.BonusGridSize
        innerSize = innerSize + x * y
    end
    return innerSize
end

---@param container ItemContainer
---@return string
function TetrisContainerService._getContainerKey(container)
    local modKey = TetrisModCompatibility.getModContainerKey(container)
    if modKey then
        return modKey
    end

    local type = container:getType()
    if type == "none" then
        return "none"
    end
    return type .. "_" .. container:getCapacity()
end

---@param container ItemContainer
---@param containerKey string
---@return ContainerGridDefinition
function TetrisContainerService._getContainerDefinitionByKey(container, containerKey)
    local def = TetrisContainerService._devContainerDefinitions[containerKey] or TetrisContainerService._containerDefinitions[containerKey]
    if not def then
        def = TetrisContainerCalculator.calculateContainerDefinition(container)
        TetrisContainerService._containerDefinitions[containerKey] = def
    end

    if not def.corrected then
        TetrisContainerService._enforceCorrections(container, def)
    end

    return def
end

-- Inject new required fields and enforce certain rules
---@param container ItemContainer
---@param containerDef ContainerGridDefinition
function TetrisContainerService._enforceCorrections(container, containerDef)
    if containerDef.corrected then
        return
    end

    local containerType = container:getType()
    if MUST_BE_FRAGILE[containerType] then
        containerDef.isFragile = true
    end

    containerDef.trueType = containerType

    containerDef.corrected = true
end

function TetrisContainerService.recalculateContainerData()
    TetrisContainerService._containerDefinitions = {}
    TetrisContainerService._onInitWorld()
end

---@param containerDef ContainerGridDefinition
---@return string|nil
function TetrisContainerService.getSingleValidCategory(containerDef)
    local validCategories = TetrisContainerService._getValidCategories(containerDef)
    if not validCategories then
        return nil
    end

    local category = nil
    for key, _ in pairs(validCategories) do
        if category then
            return nil
        else
            category = key
        end
    end
    return category
end

---@param containerDef ContainerGridDefinition
---@param category TetrisItemCategory
---@return boolean
function TetrisContainerService.canAcceptCategory(containerDef, category)
    local validCategories = TetrisContainerService._getValidCategories(containerDef)
    return not validCategories or validCategories[category]
end

-- Valid categories are used now because they are easier to reason.
-- Invalid parsing remains to support existing datapacks.
---@param containerDef ContainerGridDefinition
---@return table<TetrisItemCategory, boolean>|nil
function TetrisContainerService._getValidCategories(containerDef)
    if containerDef.validCategories then
        return containerDef.validCategories
    end
    if not containerDef.invalidCategories then
        return nil -- By default, all categories are valid, represented by nil
    end

    local validCategories = {}
    for _, category in ipairs(TetrisItemCategory.list) do
        local valid = true
        for _, invalidCategory in ipairs(containerDef.invalidCategories) do
            if category == invalidCategory then
                valid = false
                break
            end
        end
        if valid then
            validCategories[category] = true
        end
    end
    containerDef.validCategories = validCategories
    return validCategories
end

--- Cache for the debug tool container viewer so we don't instantiate items per frame
---@type table<Item, ItemContainer>
local itemScriptToContainerCache = {}

---@param itemScript Item
---@return ContainerGridDefinition|nil
function TetrisContainerService.getContainerDefinitionByItemScript(itemScript)
    if not itemScriptToContainerCache[itemScript] then
        local item = instanceItem(itemScript)
        if not item:IsInventoryContainer() then
            return nil
        end
        ---@cast item InventoryContainer
        local container = item:getItemContainer()
        itemScriptToContainerCache[itemScript] = container
    end

    local container = itemScriptToContainerCache[itemScript]
    local containerKey = TetrisContainerService._getContainerKey(container)
    return TetrisContainerService._getContainerDefinitionByKey(container, containerKey)
end


-- Vehicle Storage Registration

--- The container types that are considered large vehicle storage and get much more grid space.
---@param containerTypes string[]
function TetrisContainerService.registerLargeVehicleStorageContainers(containerTypes)
    for _, type in ipairs(containerTypes) do
        TetrisContainerCalculator._vehicleStorageNames[type] = true
    end
end

-- Container Pack Registration

TetrisContainerService._containerDataPacks = {}

---@param containerPack table<string, ContainerGridDefinition>
function TetrisContainerService.registerContainerDefinitions(containerPack)
    table.insert(TetrisContainerService._containerDataPacks, containerPack)
    if TetrisContainerService._packsLoaded then
        TetrisContainerService._processContainerPack(containerPack)
    end
end

function TetrisContainerService._initializeContainerPacks()
    for _, containerPack in ipairs(TetrisContainerService._containerDataPacks) do
        TetrisContainerService._processContainerPack(containerPack)
    end
    TetrisContainerService._packsLoaded = true
end

---@param containerPack table<string, ContainerGridDefinition>
function TetrisContainerService._processContainerPack(containerPack)
    for defKey, containerDef in pairs(containerPack) do
        -- Write data into existing definition if it exists.
        -- Allows container packs containing only partial data to be merged. i.e. Old packs before the rigid and squishable flags were added.
        local existing = TetrisContainerService._containerDefinitions[defKey]
        if existing then
            for key, val in pairs(containerDef) do
                existing[key] = val
            end
        else
            TetrisContainerService._containerDefinitions[defKey] = containerDef
        end
    end
end

function TetrisContainerService._onInitWorld()
    TetrisContainerService._initializeContainerPacks()
end

Events.OnInitWorld.Add(TetrisContainerService._onInitWorld)

-- For backwards compatibility with existing datapacks
_G.TetrisContainerData = TetrisContainerService

return TetrisContainerService