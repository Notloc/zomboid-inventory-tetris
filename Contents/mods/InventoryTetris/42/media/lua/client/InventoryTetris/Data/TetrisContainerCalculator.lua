local TetrisContainerCalculator = {}

TetrisContainerCalculator._vehicleStorageNames = {}

local MAX_CONTAINER_WIDTH = 12
local MAX_CONTAINER_HEIGHT = 50

function TetrisContainerCalculator.calculateContainerDefinition(container)
    local definition = nil
    local type = container:getType()

    if TetrisContainerCalculator._vehicleStorageNames[type] then
        definition = TetrisContainerCalculator._calculateVehicleTrunkContainerDefinition(container)
    else
        local item = container:getContainingItem()
        if item then
            definition = TetrisContainerCalculator._calculateItemContainerDefinition(container, item)
        else
            definition = TetrisContainerCalculator._calculateWorldContainerDefinition(container)
        end
    end

    definition._autoCalculated = true
    return definition
end

---@param container InventoryContainer
---@param item InventoryContainer
function TetrisContainerCalculator._calculateItemContainerDefinition(container, item)
    local capacity = container:getCapacity()
    local weightReduction = item:getWeightReduction()
    local bonus = math.ceil(weightReduction / 10)
    if bonus < 0 then
        bonus = 0
    end
    if bonus > 4 then
        bonus = 4
    end
    if bonus > math.floor(capacity) then
        bonus = math.floor(capacity)
    end

    local slotCount = math.ceil(capacity) * 2 + bonus

    -- Special case for slotted containers to build a pocketed grid
    if item:IsInventoryContainer() and item:getMaxItemSize() > 1 and item:getBodyLocation() ~= "" then
        return TetrisContainerCalculator._buildGridDefinitionForSlottedContainer(slotCount, item:getMaxItemSize())
    end

    local x, y = TetrisContainerCalculator._calculateContainerDimensions(slotCount, 2)
    if x<2 then x=2 end
    if y<2 then y=2 end
    return {
        gridDefinitions = {{
            size = {width=x, height=y},
            position = {x=0, y=0},
        }}
    }
end

function TetrisContainerCalculator._calculateWorldContainerDefinition(container)
    local capacity = container:getCapacity()
    local size = 2 * math.ceil(capacity)
    local x, y = TetrisContainerCalculator._calculateContainerDimensions(size, 1)
    return {
        gridDefinitions = {{
            size = {width=x, height=y},
            position = {x=0, y=0},
        }}
    }
end

function TetrisContainerCalculator._calculateVehicleTrunkContainerDefinition(container)
    local capacity = container:getCapacity()

    local size = 50 + capacity * 2.5 -- TODO: nerf base size once spec slots are added
    local x, y = TetrisContainerCalculator._calculateContainerDimensions(size, 1)
    return {
        gridDefinitions = {{
            size = {width=x, height=y},
            position = {x=0, y=0},
        }}
    }
end

--- Determine two numbers that multiply *close* to the target slot count
---@param target number -- The target slot count
---@param accuracy number -- Reduces the importance of squaring the shape
function TetrisContainerCalculator._calculateContainerDimensions(target, accuracy)
    local best = 99999999
    local bestX = 1
    local bestY = 1

    if not accuracy then
        accuracy = 1
    end

    for x = 1, MAX_CONTAINER_WIDTH do
        for y = 1, MAX_CONTAINER_HEIGHT do
            local result = x * y
            local diff = math.abs(result - target) + math.abs(x - y)/accuracy -- Encourage square shapes 
            if diff < best then
                best = diff
                bestX = x
                bestY = y
            end
        end
    end

    -- Swap thin containers to be wide as it uses screen space better
    if bestX <= 4 and bestY > bestX then
        local temp = bestX
        bestX = bestY
        bestY = temp
    end

    return bestX, bestY
end

function TetrisContainerCalculator._buildGridDefinitionForSlottedContainer(slotCount, maxItemSize)
    local def = { gridDefinitions = {} }

    local maxPocketSize = math.max(math.floor(maxItemSize * 2), 2)
    local evenSplit = slotCount % maxPocketSize == 0

    local pocketCount = math.max(math.floor(slotCount / maxPocketSize), 1)

    for i = 1, pocketCount do
        local x, y = TetrisContainerCalculator._calculateContainerDimensions(maxPocketSize, 10)
        if pocketCount > 3 and x > y then
            -- Prefer tall pockets
            local temp = x
            x = y
            y = temp
        end

        local pY = pocketCount > 6 and math.floor((i-1) / 4) or 0

        local pocket = {
            size = { width = x, height = y },
            position = { x = i-1, y = pY }
        }

        table.insert(def.gridDefinitions, pocket)
    end

    return def
end

return TetrisContainerCalculator