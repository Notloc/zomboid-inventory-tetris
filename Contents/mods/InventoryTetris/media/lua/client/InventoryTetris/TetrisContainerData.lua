require "InventoryTetris/TetrisItemCategory"

local MAX_ITEM_HEIGHT = 8
local MAX_ITEM_WIDTH = 8

TetrisContainerData = {}

TetrisContainerData._containerDefinitions = {}

function TetrisContainerData.getContainerDefinition(container)
    local containerKey = TetrisContainerData._getContainerKey(container)
    return TetrisContainerData._getContainerDefinitionByKey(container, containerKey)
end

function TetrisContainerData.isTardis(container)
    local item = container:getContainingItem()
    if not item then return false end

    local w, h = TetrisItemData.getItemSize(item)
    local size = w * h

    local containerKey = TetrisContainerData._getContainerKey(container)
    local definition = TetrisContainerData._getContainerDefinitionByKey(container, containerKey)

    local innerSize = 0
    for _, gridDefinition in ipairs(definition.gridDefinitions) do
        innerSize = innerSize + gridDefinition.size.width * gridDefinition.size.height
    end

    return size < innerSize
end

function TetrisContainerData._getContainerKey(container)
    if container:getType() == "none" then
        return "none"
    end
    return container:getType() .. "_" .. container:getCapacity()
end

function TetrisContainerData._getContainerDefinitionByKey(container, containerKey)
    print("containerKey: " .. containerKey)
    if not TetrisContainerData._containerDefinitions[containerKey] then
        TetrisContainerData._containerDefinitions[containerKey] = TetrisContainerData._calculateContainerDefinition(container)
    end
    return TetrisContainerData._containerDefinitions[containerKey]
end

function TetrisContainerData._calculateContainerDefinition(container)
    local item = container:getContainingItem()
    if item then
        return TetrisContainerData._calculateItemContainerDefinition(container, item)
    end
    return TetrisContainerData._calculateWorldContainerDefinition(container)
end

function TetrisContainerData._calculateItemContainerDefinition(container, item)
    local capacity = container:getCapacity()
    local weightReduction = item:getWeightReduction()

    local bonus = weightReduction - 50
    if bonus < 0 then
        bonus = 0
    end

    local slotCount = 4 + capacity + bonus

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

    local size = 1 + math.ceil(math.pow(capacity, 0.35))
    return {
        gridDefinitions = {{
            size = {width=size, height=size},
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

TetrisContainerData.recalculateContainerData = function()
    TetrisContainerData._containerDefinitions = {}
    TetrisContainerData._onGameBoot()
end

TetrisContainerData.validateInsert = function(containerDef, item)
    if not containerDef.validCategories and not containerDef.validItems then
        return true
    end

    if containerDef.validCategories then
        local itemCategory = TetrisItemCategory.getCategory(item)
        for _, category in ipairs(containerDef.validCategories) do
            if itemCategory == category then
                return true
            end
        end
    end

    if containerDef.validItems then
        local itemType = item:getFullType()
        for _, validItem in ipairs(containerDef.validItems) do
            if itemType == validItem then
                return true
            end
        end
    end

end



-- Container Pack Registration
TetrisContainerData._containerDataPacks = {}

TetrisContainerData.registerContainerDefinitions = function(containerPack)
    table.insert(TetrisContainerData._containerDataPacks, containerPack)
    if TetrisContainerData._packsLoaded then
        TetrisContainerData._processContainerPack(containerPack) -- You're late.
    end
end

TetrisContainerData._initializeContainerPacks = function()
    for _, containerPack in ipairs(TetrisContainerData._containerDataPacks) do
        TetrisContainerData._processContainerPack(containerPack)
    end
    TetrisContainerData._packsLoaded = true
end

TetrisContainerData._processContainerPack = function(containerPack)
    for key, containerDef in pairs(containerPack) do
        TetrisContainerData._containerDefinitions[key] = containerDef
    end
end

TetrisContainerData._onInitWorld = function()
    TetrisContainerData._initializeContainerPacks()
end
Events.OnInitWorld.Add(TetrisContainerData._onInitWorld)
