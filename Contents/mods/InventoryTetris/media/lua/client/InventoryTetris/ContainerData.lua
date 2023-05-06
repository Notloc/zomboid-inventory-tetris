local MAX_ITEM_HEIGHT = 9
local MAX_ITEM_WIDTH = 9

ContainerData = {
    -- Player Inv
    ["none"] = {
        gridDefinitions = {
            {
                size = {width=1, height=2},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=2},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=2},
                position = {x=2, y=0},
            },
            {
                size = {width=1, height=2},
                position = {x=3, y=0},
            }
        },
        isOrganized = true,
    },

    ["floor"] = {
        gridDefinitions = {
            {
                size = {width=8, height=8},
                position = {x=0, y=0},
            }
        },
        isOrganized = false,
    },
}

function ContainerData.getContainerDefinition(container)
    local containerKey = ContainerData._getContainerKey(container)
    return ContainerData._getContainerDefinitionByKey(container, containerKey)
end

function ContainerData._getContainerKey(container)
    if container:getType() == "none" then
        return "none"
    end
    return container:getType() .. "_" .. container:getCapacity()
end

function ContainerData._getContainerDefinitionByKey(container, containerKey)
    print("containerKey: " .. containerKey)
    if not ContainerData[containerKey] then
        ContainerData[containerKey] = ContainerData._calculateContainerDefinition(container)
    end
    return ContainerData[containerKey]
end

function ContainerData._calculateContainerDefinition(container)
    local item = container:getContainingItem()
    if item then
        return ContainerData._calculateItemContainerDefinition(container, item)
    end
    return ContainerData._calculateWorldContainerDefinition(container)
end

function ContainerData._calculateItemContainerDefinition(container, item)
    local capacity = container:getCapacity()
    local weightReduction = item:getWeightReduction()

    local bonus = weightReduction - 50
    if bonus < 0 then
        bonus = 0
    end

    local slotCount = 4 + capacity + bonus

    -- Determine two numbers that multiply close to the slot count
    local x, y = ContainerData._calculateDimensions(slotCount)
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

function ContainerData._calculateWorldContainerDefinition(container)
    local capacity = container:getCapacity()

    local size = math.ceil(math.sqrt(capacity) * 1.2)
    return {
        gridDefinitions = {{
            size = {width=size, height=size},
            position = {x=0, y=0},
        }}
    }
end

function ContainerData._calculateDimensions(target)
    local best = 99999999
    local bestX = 1
    local bestY = 1

    for x = 1, MAX_ITEM_WIDTH do
        for y = 1, MAX_ITEM_HEIGHT do
            local result = x * y
            local diff = math.abs(result - target) + math.pow(x, 0.25) + math.pow(y, 0.25) -- Punish large dimensions, encourage square 
            if diff < best then
                best = diff 
                bestX = x
                bestY = y
            end
        end
    end

    return bestX, bestY
end