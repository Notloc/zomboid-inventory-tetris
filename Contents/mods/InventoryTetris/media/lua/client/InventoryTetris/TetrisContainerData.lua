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


function TetrisContainerData._addContainerDefinition(key, definition)
    if not definition.gridDefinitions then
        definition.gridDefinitions = TetrisContainerData._generateGridDefinitions(definition)
    end
    TetrisContainerData._containerDefinitions[key] = definition
end

function TetrisContainerData._generateGridDefinitions(definition)
    local rows = definition.rows or 1
    local columns = definition.columns or 1

    local gridDefinitions = {}
    for row = 1, rows do
        for column = 1, columns do
            local width = math.floor(definition.size.width / columns)
            local height = math.floor(definition.size.height / rows)
            local gridDefinition = {
                size = {width=width, height=height},
                position = {x=column-1, y=row-1},
            }
            table.insert(gridDefinitions, gridDefinition)
        end
    end
    return gridDefinitions
end

TetrisContainerData._definitionPacks = {}

function TetrisContainerData.RegisterContainerDefinitions(modData)
    table.insert(TetrisContainerData._definitionPacks, modData)
    if TetrisContainerData._isInitialized then
        for key, definition in pairs(modData) do
            TetrisContainerData._addContainerDefinition(key, definition)
        end
    end
end

function TetrisContainerData._onGameBoot()
    for _, definitionPack in ipairs(TetrisContainerData._definitionPacks) do
        for key, definition in pairs(definitionPack) do
            TetrisContainerData._addContainerDefinition(key, definition)
        end
    end
    TetrisContainerData._isInitialized = true
end

local builtIn = {
    -- Player Inv
    ["none"] = {
        size = {width=4, height=2},
        columns = 4,
        isOrganized = true,
    },

    ["floor_50"] = {
        size = {width=9, height=12},
        --gridDefinitions = {
        --    {
        --        size = {width=9, height=12},
        --        position = {x=1, y=1},
        --    }
        --},
        isOrganized = false,
    },
}

TetrisContainerData.RegisterContainerDefinitions(builtIn)

Events.OnGameBoot.Add(TetrisContainerData._onGameBoot)


TetrisContainerData.recalculateContainerData = function()
    TetrisContainerData._containerDefinitions = {}
    TetrisContainerData._onGameBoot()
end

