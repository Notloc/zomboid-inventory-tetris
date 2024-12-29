require("InventoryTetris/Data/TetrisItemCategory")

---@class ContainerGridDefinition
---@field gridDefinitions GridDefinition[]
---@field validCategories table<TetrisItemCategory, boolean>
---@field invalidCategories TetrisItemCategory[] -- Deprecated
---@field isFragile boolean

---@class GridDefinition
---@field size Size2D
---@field position Vector2Lua

local MAX_ITEM_HEIGHT = 30
local MAX_ITEM_WIDTH = 10

TetrisContainerData = {}

TetrisContainerData._containerDefinitions = {}
TetrisContainerData._vehicleStorageNames = {}

function TetrisContainerData.setContainerDefinition(container, containerDef)
    local containerKey = TetrisContainerData._getContainerKey(container)
    TetrisContainerData._containerDefinitions[containerKey] = containerDef
end

function TetrisContainerData.getContainerDefinition(container)
    local containerKey = TetrisContainerData._getContainerKey(container)
    return TetrisContainerData._getContainerDefinitionByKey(container, containerKey)
end

function TetrisContainerData.calculateInnerSize(container)
    local definition = TetrisContainerData.getContainerDefinition(container)
    return TetrisContainerData._calculateInnerSizeByDefinition(definition)
end

function TetrisContainerData._calculateInnerSizeByDefinition(definition)
    local innerSize = 0
    for _, gridDefinition in ipairs(definition.gridDefinitions) do
        local x = gridDefinition.size.width + SandboxVars.InventoryTetris.BonusGridSize
        local y = gridDefinition.size.height + SandboxVars.InventoryTetris.BonusGridSize
        innerSize = innerSize + x * y
    end
    return innerSize
end

function TetrisContainerData._getContainerKey(container)
    if container:getType() == "none" then
        return "none"
    end
    return container:getType() .. "_" .. container:getCapacity()
end

function TetrisContainerData._getContainerDefinitionByKey(container, containerKey)
    local devToolOverride = TetrisDevTool.getContainerOverride(containerKey)
    if devToolOverride then
        return devToolOverride
    end

    if not TetrisContainerData._containerDefinitions[containerKey] then
        TetrisContainerData._containerDefinitions[containerKey] = TetrisContainerData._calculateContainerDefinition(container)
    end
    return TetrisContainerData._containerDefinitions[containerKey]
end

function TetrisContainerData._calculateContainerDefinition(container)
    local definition = nil
    local type = container:getType()

    if TetrisContainerData._vehicleStorageNames[type] then
        definition = TetrisContainerData._calculateVehicleTrunkContainerDefinition(container)
    else
        local item = container:getContainingItem()
        if item then
            definition = TetrisContainerData._calculateItemContainerDefinition(container, item)
        else
            definition = TetrisContainerData._calculateWorldContainerDefinition(container)
        end
    end

    definition._autoCalculated = true
    return definition
end

function TetrisContainerData._calculateItemContainerDefinition(container, item)
    local capacity = container:getCapacity()
    local weightReduction = item:getWeightReduction()

    local bonus = weightReduction - 45
    if bonus < 0 then
        bonus = 0
    end

    local slotCount = 6 + capacity + bonus

    -- Determine two numbers that multiply close to the slot count
    local x, y = TetrisContainerData._calculateDimensions(slotCount)
    if x < 2 then
        x = 2
    end
    if y < 2 then
        y = 2
    end

    return {
        gridDefinitions = {{
            size = {width=x, height=y},
            position = {x=0, y=0},
        }}
    }
end

function TetrisContainerData._calculateWorldContainerDefinition(container)
    local capacity = container:getCapacity()

    local size = 1 + math.ceil(capacity^0.55)
    return {
        gridDefinitions = {{
            size = {width=size, height=size},
            position = {x=0, y=0},
        }}
    }
end

function TetrisContainerData._calculateVehicleTrunkContainerDefinition(container)
    local capacity = container:getCapacity()

    local size = 50 + capacity
    local x, y = TetrisContainerData._calculateDimensions(size)
    return {
        gridDefinitions = {{
            size = {width=x, height=y},
            position = {x=0, y=0},
        }}
    }
end

function TetrisContainerData._calculateDimensions(target)
    local best = 99999999
    local bestX = 1
    local bestY = 1

    for x = 1, MAX_ITEM_WIDTH do
        for y = 1, MAX_ITEM_HEIGHT do
            local result = x * y
            local diff = math.abs(result - target) + math.abs(x - y) -- Encourage square shapes 
            if diff < best then
                best = diff
                bestX = x
                bestY = y
            end
        end
    end

    return bestX, bestY
end

function TetrisContainerData.recalculateContainerData()
    TetrisContainerData._containerDefinitions = {}
    TetrisContainerData._onInitWorld()
end

---@param container ItemContainer
---@param containerDef any
---@param item InventoryItem
---@return boolean
function TetrisContainerData.validateInsert(container, containerDef, item)
    if item:IsInventoryContainer() and SandboxVars.InventoryTetris.PreventTardisStacking then
        ---@cast item InventoryContainer

        -- Prevent the player from putting a bag of holding inside a bag of holding and blowing up the universe
        local isInsideTardis = TetrisContainerData.isTardisRecursive(container)
        if isInsideTardis then
            local leafTardis = {}
            TetrisContainerData._findLeafTardis(item:getItemContainer(), leafTardis)
            if #leafTardis > 0 then
                return false
            end
        end

        -- Prevent a rigid container from being put inside a rigid container unless its smaller
        -- i.e. You can't fit a 3x3 lunchbox inside a 3x3 lunchbox
        local containerItem = container:getContainingItem()
        if containerItem then
            local itemContainerDef = TetrisContainerData.getContainerDefinition(item:getItemContainer())
            if containerDef.isRigid and itemContainerDef.isRigid then
                local x,y = TetrisItemData.getItemSizeUnsquished(containerItem, false)
                local x2,y2 = TetrisItemData.getItemSizeUnsquished(item, false)
                if x*y <= x2*y2 then
                    return false
                end
            end
        end
    end

    local itemCategory = TetrisItemCategory.getCategory(item)
    return TetrisContainerData.canAcceptCategory(containerDef, itemCategory)
end


function TetrisContainerData.getSingleValidCategory(containerDef)
    local validCategories = TetrisContainerData._getValidCategories(containerDef)
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

function TetrisContainerData.canAcceptCategory(containerDef, category)
    local validCategories = TetrisContainerData._getValidCategories(containerDef)
    return not validCategories or validCategories[category]
end

-- Valid categories are used now because they are easier to reason.
-- Invalid parsing remains to support existing datapacks.
function TetrisContainerData._getValidCategories(containerDef)
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

---@param container ItemContainer
function TetrisContainerData.isTardisRecursive(container)
    local isTardis = TetrisContainerData.isTardis(container)
    if isTardis then
        return true
    end

    local item = container:getContainingItem()
    if not item then
        return false
    end

    container = item:getContainer()
    if not container then
        return false
    end

    return TetrisContainerData.isTardisRecursive(container)
end


---@param container ItemContainer
function TetrisContainerData.isTardis(container)
    local type = container:getType()
    if type == "none" or type == "KeyRing" then
        return false
    end

    if not container:getContainingItem() then
        return false
    end

    local containerDef = TetrisContainerData.getContainerDefinition(container)
    if not TetrisContainerData.canAcceptCategory(containerDef, TetrisItemCategory.CONTAINER) then
        return false
    end

    local w, h = TetrisItemData.getItemSizeUnsquished(container:getContainingItem(), false)
    local size = w * h
    local capacity = TetrisContainerData.calculateInnerSize(container)
    return size < capacity
end

---@param container ItemContainer
function TetrisContainerData._findLeafTardis(container, tardisList)
    local isTardis = TetrisContainerData.isTardis(container)
    if isTardis then
        table.insert(tardisList, container)
    end

    local items = container:getItems()
    for i = 1, items:size() do
        local item = items:get(i - 1)
        if item:IsInventoryContainer() then
            ---@cast item InventoryContainer
            TetrisContainerData._findLeafTardis(item:getItemContainer(), tardisList)
        end
    end
end


local itemScriptToContainerKey = {}

function TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    if not itemScriptToContainerKey[itemScript] then
        local item = instanceItem(itemScript)
        if not item:IsInventoryContainer() then
            return nil
        end
        ---@cast item InventoryContainer
        local container = item:getItemContainer()
        local containerKey = TetrisContainerData._getContainerKey(container)
        itemScriptToContainerKey[itemScript] = containerKey

        return TetrisContainerData._getContainerDefinitionByKey(container, containerKey)
    end

    return TetrisContainerData._getContainerDefinitionByKey(nil, itemScriptToContainerKey[itemScript])
end



-- Vehicle Storage Registration

function TetrisContainerData.registerLargeVehicleStorageContainers(containerTypes)
    for _, type in ipairs(containerTypes) do
        TetrisContainerData._vehicleStorageNames[type] = true
    end
end

-- Container Pack Registration
TetrisContainerData._containerDataPacks = {}

function TetrisContainerData.registerContainerDefinitions(containerPack)
    table.insert(TetrisContainerData._containerDataPacks, containerPack)
    if TetrisContainerData._packsLoaded then
        TetrisContainerData._processContainerPack(containerPack)
    end
end

function TetrisContainerData._initializeContainerPacks()
    for _, containerPack in ipairs(TetrisContainerData._containerDataPacks) do
        TetrisContainerData._processContainerPack(containerPack)
    end
    TetrisContainerData._packsLoaded = true
end

function TetrisContainerData._processContainerPack(containerPack)
    for defKey, containerDef in pairs(containerPack) do
        -- Write data into existing definition if it exists.
        -- Allows container packs containing only partial data to be merged. i.e. Old packs before the rigid and squishable flags were added.
        local existing = TetrisContainerData._containerDefinitions[defKey]
        if existing then
            for key, val in pairs(containerDef) do
                existing[key] = val
            end
        else
            TetrisContainerData._containerDefinitions[defKey] = containerDef
        end
    end
end

function TetrisContainerData._onInitWorld()
    TetrisContainerData._initializeContainerPacks()
end
Events.OnInitWorld.Add(TetrisContainerData._onInitWorld)
