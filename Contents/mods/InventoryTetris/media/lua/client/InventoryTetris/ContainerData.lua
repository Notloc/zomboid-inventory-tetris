ContainerData = {
    -- Player Inv
    ["none"] = {
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

    ["floor"] = {
        {
            size = {width=8, height=8},
            position = {x=0, y=0},
        }
    },

    ["overhead"] = {
        {
            size = {width=5, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=1},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=2},
        }
    },

    ["counter"] = {
        {
            size = {width=4, height=3},
            position = {x=0, y=0},
        },
        {
            size = {width=4, height=3},
            position = {x=1, y=0},
        },
        {
            size = {width=4, height=3},
            position = {x=0, y=1},
        },
        {
            size = {width=4, height=3},
            position = {x=1, y=1},
        }
    },

    ["shelves_small"] = {
        {
            size = {width=5, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=1},
        },
    },

    ["shelves_medium"] = {
        {
            size = {width=5, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=1},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=2},
        },
    },

    -- 3 small drawers, vertical
    ["sidetable"] = {
        {
            size = {width=3, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=3, height=2},
            position = {x=0, y=1},
        },
        {
            size = {width=3, height=2},
            position = {x=0, y=2},
        },
    },

    -- 3 small drawers, vertical        
    ["dresser"] = {
        {
            size = {width=3, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=3, height=2},
            position = {x=0, y=1},
        },
        {
            size = {width=3, height=2},
            position = {x=0, y=2},
        },
    },

    ["Guitarcase"] = {
        {
            size = {width=2, height=5},
            position = {x=0, y=0},
        }
    },
}

InventoryTetrisContainerOverloads = {
    ["crate"] = {
        [40] = "crate_medium"
    },
    ["shelves"] = {
        [15] = "shelves_small",
        [30] = "shelves_medium",
    },
}


ContainerData.calculateContainerItemDefinition = function(container)
    local containerType = container:getType()

    return itemGrid
end

function ContainerData.getGridKey(container)
    if container:getType() == "none" then
        return "none"
    end
    return container:getType() .. "_" .. container:getCapacity()
end

function ContainerData.getGridDefinitionByContainer(container)
    local gridKey = ContainerData.getGridKey(container)
    return ContainerData.getGridDefinitionByKey(container, gridKey)
end

function ContainerData.getGridDefinitionByKey(container, gridKey)
    print("gridKey: " .. gridKey)
    if not ContainerData[gridKey] then
        ContainerData[gridKey] = ContainerData.calculateContainerDefinition(container)
    end
    return ContainerData[gridKey]
end

function ContainerData.calculateContainerDefinition(container)
    local item = container:getContainingItem()
    if item then
        return ContainerData.calculateItemContainerDefinition(container, item)
    end
    return ContainerData.calculateWorldContainerDefinition(container)
end

function ContainerData.calculateItemContainerDefinition(container, item)
    local capacity = container:getCapacity()
    local weightReduction = item:getWeightReduction()

    local bonus = weightReduction - 50
    if bonus < 0 then
        bonus = 0
    end

    local slotCount = 4 + capacity + bonus

    -- Determine two numbers that multiply close to the slot count
    local x, y = ContainerData.calculateDimensions(slotCount)
    if x < 2 then
        x = 2
    end
    if y < 2 then
        y = 2
    end

    return {
        {
            size = {width=x, height=y},
            position = {x=0, y=0},
        }
    }
end

function ContainerData.calculateWorldContainerDefinition(container)
    local capacity = container:getCapacity()

    local size = math.ceil(math.sqrt(capacity) * 1.2)
    return {
        {
            size = {width=size, height=size},
            position = {x=0, y=0},
        }
    }
end




function ContainerData.calculateDimensions(target)
    -- Find two numbers that multiply close to the target
    -- x and y are the two numbers
    -- x max is 6

    local best = 99999999
    local bestX = 1
    local bestY = 1

    for x = 1, 7 do
        for y = 1, 20 do
            local result = x * y
            local diff = math.abs(result - target) + y * 0.75 -- Penalize y a bit so we don't get 
            if diff < best then
                best = diff 
                bestX = x
                bestY = y
            end
        end
    end

    return bestX, bestY
end