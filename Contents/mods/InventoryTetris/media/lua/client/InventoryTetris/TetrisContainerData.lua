require("InventoryTetris/TetrisItemCategory")

---@class ContainerGridDefinition
---@field gridDefinitions GridDefinition[]
---@field validCategories table<TetrisItemCategory, boolean>
---@field invalidCategories TetrisItemCategory[] -- Deprecated
---@field isOrganized boolean
---@field isFragile boolean

---@class GridDefinition
---@field size Size2D
---@field position Vector2Lua

local MAX_ITEM_HEIGHT = 30
local MAX_ITEM_WIDTH = 10

TetrisContainerData = {}

TetrisContainerData._containerDefinitions = {}
TetrisContainerData._vehicleStorageNames = {}
TetrisContainerData._pocketDefinitions = {}


function TetrisContainerData.setContainerDefinition(container, containerDef)
    local containerKey = TetrisContainerData._getContainerKey(container)
    TetrisContainerData._containerDefinitions[containerKey] = containerDef
end

function TetrisContainerData.getContainerDefinition(container)
    local containerKey = TetrisContainerData._getContainerKey(container)
    return TetrisContainerData._getContainerDefinitionByKey(container, containerKey)
end

function TetrisContainerData.getPocketDefinition(item)
    if not instanceof(item, "InventoryItem") then
        return nil
    end

    local key = item:getFullType()
    if isDebugEnabled() and TetrisDevTool.getPocketOverride(key) then
        return TetrisDevTool.getPocketOverride(key)
    end

    if not TetrisContainerData._pocketDefinitions[key] then
        TetrisContainerData._pocketDefinitions[key] = TetrisContainerData._calculatePocketDefinition(item)
    end

    return TetrisContainerData._pocketDefinitions[key]
end

function TetrisContainerData.calculateInnerSize(container)
    local definition = TetrisContainerData.getContainerDefinition(container)
    
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
    local type = container:getType()
    if TetrisContainerData._vehicleStorageNames[type] then
        return TetrisContainerData._calculateVehicleTrunkContainerDefinition(container)
    end

    local item = container:getContainingItem()
    if item then
        return TetrisContainerData._calculateItemContainerDefinition(container, item)
    end
    return TetrisContainerData._calculateWorldContainerDefinition(container)
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
    if item:IsInventoryContainer() and TetrisContainerData.isTardis(container) then
        return false
    end

    local itemCategory = TetrisItemCategory.getCategory(item)
    local validCategories = TetrisContainerData._getValidCategories(containerDef)
    return not validCategories or validCategories[itemCategory]
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

-- Valid categories are used now because they are easier to reason.
-- This remains to support existing datapacks.
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
function TetrisContainerData.isTardis(container)
    local type = container:getType()
    if type == "none" then
        return false
    end

    if not container:getContainingItem() then
        return false
    end

    local size = TetrisItemData.getItemSizeUnsquished(container:getContainingItem(), false)
    local capacity = TetrisContainerData.calculateInnerSize(container)
    return size < capacity
end

local bodySlotsToPocketDefinitions = {
    ["FullSuit"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=2, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            }
        }
    },
    ["FullSuitHead"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=2, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            }
        }
    },
    ["FullTop"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            },
        }
    },
    ["JacketHat"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
        }
    },
    ["JacketHat_Bulky"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
        }
    },
    ["Sweater"] = {
        gridDefinitions = {
            {
                size = {width=4, height=1},
                position = {x=0, y=0},
            },
        }
    },
    ["SweaterHat"] = {
        gridDefinitions = {
            {
                size = {width=4, height=1},
                position = {x=0, y=0},
            },
        }
    },
    ["Dress"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            },
        }
    },
    ["BathRobe"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
        }
    },
    ["Torso1Legs1"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=2, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            }
        }
    },
    ["Jacket"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=4, y=0},
            }
        }
    },
    ["JacketSuit"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=4, y=0},
            }
        }
    },
    ["Jacket_Bulky"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=4, y=0},
            }
        }
    },
    ["Jacket_Down"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=4, y=0},
            }
        }
    },
    ["TorsoExtra"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=4, y=0},
            }
        }
    },
    ["TorsoExtraPlus1"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=4, y=0},
            }
        }
    },
    ["TorsoExtraVest"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=4, y=0},
            }
        }
    },
    ["Boilersuit"] = {
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
            },
            {
                size = {width=1, height=1},
                position = {x=0, y=1},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=1},
            },
            {
                size = {width=1, height=1},
                position = {x=2, y=1},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=1},
            }
        }
    },
    ["AmmoStrap"] = {
        gridDefinitions = {
            {
                size = {width=2, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=2, height=1},
                position = {x=2, y=0},
            },
        },
        -- Ammo only
        validCategories = {
            [TetrisItemCategory.AMMO] = true
        }
    },
    ["LowerBody"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=2, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            }
        }
    },
    ["Legs1"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=2, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            }
        }
    },
    ["Pants"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=2, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=3, y=0},
            }
        }
    },
    ["Skirt"] = {
        gridDefinitions = {
            {
                size = {width=1, height=1},
                position = {x=0, y=0},
            },
            {
                size = {width=1, height=1},
                position = {x=1, y=0},
            }
        }
    }
}

function TetrisContainerData._calculatePocketDefinition(item)
    local bodySlot = item:getBodyLocation()
    
    if bodySlotsToPocketDefinitions[bodySlot] then
        return bodySlotsToPocketDefinitions[bodySlot]
    end
    
    return nil
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
        TetrisContainerData._processContainerPack(containerPack) -- You're late.
    end
end

function TetrisContainerData._initializeContainerPacks()
    for _, containerPack in ipairs(TetrisContainerData._containerDataPacks) do
        TetrisContainerData._processContainerPack(containerPack)
    end
    TetrisContainerData._packsLoaded = true
end

function TetrisContainerData._processContainerPack(containerPack)
    for key, containerDef in pairs(containerPack) do
        TetrisContainerData._containerDefinitions[key] = containerDef
    end
end


-- Register pocket definitions
TetrisContainerData._pocketDataPacks = {}

function TetrisContainerData.registerPocketDefinitions(pocketPack)
    table.insert(TetrisContainerData._pocketDataPacks, pocketPack)
    if TetrisContainerData._packsLoaded then
        TetrisContainerData._processPocketPack(pocketPack) -- You're late.
    end
end

function TetrisContainerData._initializePocketPacks()
    for _, pocketPack in ipairs(TetrisContainerData._pocketDataPacks) do
        TetrisContainerData._processPocketPack(pocketPack)
    end
    TetrisContainerData._packsLoaded = true
end

function TetrisContainerData._processPocketPack(pocketPack)
    for key, pocketDef in pairs(pocketPack) do
        TetrisContainerData._pocketDefinitions[key] = pocketDef
    end
end

function TetrisContainerData._onInitWorld()
    TetrisContainerData._initializeContainerPacks()
end
Events.OnInitWorld.Add(TetrisContainerData._onInitWorld)
