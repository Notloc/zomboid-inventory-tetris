InventoryTetrisGridDefinitions = {
    ["default"] = {
        {
            size = {width=5, height=5},
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

function getGridContainerTypeByInventory(inventory)
    local containerType = inventory:getType()
    local containerOverloads = InventoryTetrisContainerOverloads[containerType]
    if containerOverloads then
        local capacity = inventory:getCapacity()
        if containerOverloads[capacity] then
            return containerOverloads[capacity]
        end

        local biggest = 0
        for overloadCapacity, overloadType in pairs(containerOverloads) do
            if overloadCapacity > biggest and overloadCapacity <= capacity then
                biggest = overloadCapacity
                containerType = overloadType
            end
        end
    end
    return containerType
end

function getGridDefinitionByContainerType(containerType)
    print("containerType: " .. containerType)

    local gridDefinition = InventoryTetrisGridDefinitions[containerType]
    if not gridDefinition then
        gridDefinition = InventoryTetrisGridDefinitions["default"]
    end
    return gridDefinition
end


