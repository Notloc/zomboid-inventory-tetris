local TetrisItemCategory = require("InventoryTetris/Data/TetrisItemCategory")

---@class TetrisPocketDefinition
---@field gridDefinitions GridDefinition[] List of grid definitions that make up the pocket
---@field validCategories table<TetrisItemCategory, boolean>|nil Optional table of valid item categories for this pocket

---@class TetrisPocketPack : table<string, TetrisPocketDefinition> Pocket definitions keyed by item full type

---@class TetrisPocketData
---@field _pocketDefinitions table<string, TetrisPocketDefinition> 
---@field _devPocketDefinitions table<string, TetrisPocketDefinition> Development overrides
local TetrisPocketData = {
    _pocketDefinitions = {},
    _devPocketDefinitions = {},
}

---@type TetrisPocketDefinition
local two_pockets = {
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

---@type TetrisPocketDefinition
local four_pockets = {
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
}

---@type TetrisPocketDefinition
local six_pockets = {
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
        },
        {
            size = {width=1, height=1},
            position = {x=4, y=0},
        },
        {
            size = {width=1, height=1},
            position = {x=5, y=0},
        }
    }
}

---@type TetrisPocketDefinition
local two_big_pockets = {
    gridDefinitions = {
        {
            size = {width=2, height=1},
            position = {x=0, y=0},
        },
        {
            size = {width=2, height=1},
            position = {x=1, y=0},
        }
    }
}

---@type TetrisPocketDefinition
local one_large_pocket = {
    gridDefinitions = {
        {
            size = {width=4, height=1},
            position = {x=0, y=0},
        }
    }
}

---@type TetrisPocketDefinition
local two_big_two_small_pockets = {
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
            position = {x=2, y=0},
        },
        {
            size = {width=1, height=1},
            position = {x=3, y=0},
        }
    }
}

---@type TetrisPocketDefinition
local four_big_four_small_pockets = {
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
            position = {x=2, y=0},
        },
        {
            size = {width=1, height=1},
            position = {x=3, y=0},
        },
        {
            size = {width=2, height=1},
            position = {x=0, y=1},
        },
        {
            size = {width=2, height=1},
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
}

---@type TetrisPocketDefinition
local boiler_suit = {
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
}

---@type TetrisPocketDefinition
local ammo_strap = {
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
}

TetrisPocketData.defaultPocketDefinitionsBySlot = {
    [ItemBodyLocation.BATH_ROBE] = two_big_pockets,
    [ItemBodyLocation.BOILERSUIT] = boiler_suit,
    [ItemBodyLocation.DRESS] = two_pockets,
    [ItemBodyLocation.FULL_SUIT] = four_pockets,
    [ItemBodyLocation.FULL_SUIT_HEAD] = four_pockets,
    [ItemBodyLocation.FULL_TOP] = two_pockets,
    [ItemBodyLocation.JACKET] = two_big_two_small_pockets,
    [ItemBodyLocation.JACKET_HAT] = two_big_pockets,
    [ItemBodyLocation.JACKET_HAT_BULKY] = two_big_pockets,
    [ItemBodyLocation.JACKET_SUIT] = two_big_two_small_pockets,
    [ItemBodyLocation.JACKET_BULKY] = two_big_two_small_pockets,
    [ItemBodyLocation.JACKET_DOWN] = two_big_two_small_pockets,
    [ItemBodyLocation.PANTS] = four_pockets,
    [ItemBodyLocation.PANTS_SKINNY] = four_pockets,
    [ItemBodyLocation.PANTS_EXTRA] = six_pockets,
    [ItemBodyLocation.SHORT_PANTS] = four_pockets,
    [ItemBodyLocation.SHORTS_SHORT] = four_pockets,
    [ItemBodyLocation.SKIRT] = two_pockets,
    [ItemBodyLocation.SWEATER] = two_big_pockets,
    [ItemBodyLocation.SWEATER_HAT] = two_big_pockets,
    [ItemBodyLocation.TORSO_EXTRA] = two_big_two_small_pockets,
    [ItemBodyLocation.TORSO_EXTRA_VEST] = four_big_four_small_pockets
}

---@param item InventoryItem
---@return TetrisPocketDefinition|nil
function TetrisPocketData.getPocketDefinition(item)
    if not instanceof(item, "InventoryItem") then
        return nil
    end

    local key = item:getFullType()
    local def = TetrisPocketData._devPocketDefinitions[key] or TetrisPocketData._pocketDefinitions[key]
    if not def then
        local defaultDef = TetrisPocketData.getDefaultPocketDefinition(item)
        if defaultDef then
            TetrisPocketData._pocketDefinitions[key] = defaultDef
        end
    end

    return def
end

---@param item InventoryItem
---@return TetrisPocketDefinition|nil
function TetrisPocketData.getDefaultPocketDefinition(item)
    local bodySlot = item:getBodyLocation()
    return TetrisPocketData.defaultPocketDefinitionsBySlot[bodySlot]
end


-- Register pocket definitions
TetrisPocketData._pocketDataPacks = {}

---@param pocketPack TetrisPocketPack
function TetrisPocketData.registerPocketDefinitions(pocketPack)
    table.insert(TetrisPocketData._pocketDataPacks, pocketPack)
    if TetrisPocketData._packsLoaded then
        TetrisPocketData._processPocketPack(pocketPack)
    end
end

function TetrisPocketData._initializePocketPacks()
    for _, pocketPack in ipairs(TetrisPocketData._pocketDataPacks) do
        TetrisPocketData._processPocketPack(pocketPack)
    end
    TetrisPocketData._packsLoaded = true
end

---@param pocketPack TetrisPocketPack
function TetrisPocketData._processPocketPack(pocketPack)
    for key, pocketDef in pairs(pocketPack) do
        TetrisPocketData._pocketDefinitions[key] = pocketDef
    end
end

function TetrisPocketData._onInitWorld()
    TetrisPocketData._initializePocketPacks()
end

Events.OnInitWorld.Add(TetrisPocketData._onInitWorld)

_G.TetrisPocketData = TetrisPocketData

return TetrisPocketData