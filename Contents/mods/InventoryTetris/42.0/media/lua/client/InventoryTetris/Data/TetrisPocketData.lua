TetrisPocketData = {}

TetrisPocketData._pocketDefinitions = {}

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
local one_large_pocket = {
    gridDefinitions = {
        {
            size = {width=4, height=1},
            position = {x=0, y=0},
        }
    }
}
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
    ["BathRobe"] = two_big_pockets,
    ["Boilersuit"] = boiler_suit,
    ["Dress"] = two_pockets,
    ["FullSuit"] = four_pockets,
    ["FullSuitHead"] = four_pockets,
    ["FullTop"] = two_pockets,
    ["Jacket"] = two_big_two_small_pockets,
    ["JacketHat"] = two_big_pockets,
    ["JacketHat_Bulky"] = two_big_pockets,
    ["JacketSuit"] = two_big_two_small_pockets,
    ["Jacket_Bulky"] = two_big_two_small_pockets,
    ["Jacket_Down"] = two_big_two_small_pockets,
    ["Legs"] = four_pockets,
    ["LowerBody"] = four_pockets,
    ["Pants"] = four_pockets,
    ["ShortPants"] = four_pockets,
    ["ShortsShort"] = four_pockets,
    ["Skirt"] = two_pockets,
    ["Sweater"] = two_big_pockets,
    ["SweaterHat"] = two_big_pockets,
    ["TorsoExtra"] = two_big_two_small_pockets,
    ["TorsoExtraPlus1"] = two_big_two_small_pockets,
    ["TorsoExtraVest"] = four_big_four_small_pockets,
}

function TetrisPocketData.getPocketDefinition(item)
    if not instanceof(item, "InventoryItem") then
        return nil
    end

    local key = item:getFullType()
    if isDebugEnabled() and TetrisDevTool.getPocketOverride(key) then
        return TetrisDevTool.getPocketOverride(key)
    end

    -- Try to inject a default pocket definition if one doesn't exist
    if not TetrisPocketData._pocketDefinitions[key] then
        TetrisPocketData._pocketDefinitions[key] = TetrisPocketData.getDefaultPocketDefinition(item)
    end

    return TetrisPocketData._pocketDefinitions[key]
end

function TetrisPocketData.getDefaultPocketDefinition(item)
    local bodySlot = item:getBodyLocation()
    return TetrisPocketData.defaultPocketDefinitionsBySlot[bodySlot]
end


-- Register pocket definitions
TetrisPocketData._pocketDataPacks = {}

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

function TetrisPocketData._processPocketPack(pocketPack)
    for key, pocketDef in pairs(pocketPack) do
        TetrisPocketData._pocketDefinitions[key] = pocketDef
    end
end

function TetrisPocketData._onInitWorld()
    TetrisPocketData._initializePocketPacks()
end
Events.OnInitWorld.Add(TetrisPocketData._onInitWorld)