local ItemClass = {
    MELEE = "MELEE_WEAPON",
    RANGED = "RANGED_WEAPON",
    AMMO = "AMMO",
    MAGAZINE = "MAGAZINE",
    FOOD = "FOOD",
    DRINK = "DRINK",
    CLOTHING = "CLOTHING",
    CONTAINER = "CONTAINER",
    HEALING = "HEALING",
    BOOK = "BOOK",
    ENTERTAINMENT = "ENTERTAINMENT",
    
    KEY = "KEY",
    MISC = "MISC",
}

TetrisItemData = {}
TetrisItemData._itemData = {}

TetrisItemData._itemDataPacks = {}

TetrisItemData.initializeTetrisItemData = function()
    for _, pack in ipairs(TetrisItemData._itemDataPacks) do
        for k, v in pairs(pack) do
            TetrisItemData._itemData[k] = v
        end
    end
end

TetrisItemData.registerItemDefinitions = function(pack)
    table.insert(TetrisItemData._itemDataPacks, pack)
end

local builtIn = {
--  item:getFullType()    x/y size          maxStackSize=1 if not specified
    ["Base.KeyRing"] = { width=1, height=1, maxStackSize=1 },
    ["Base.Pan"] = {height=2, width=2, maxStackSize=1},
    ["Base.BakingTray"] = {height=2, width=2, maxStackSize=1},
    ["Base.CuttingBoardPlastic"] = {height=2, width=2, maxStackSize=5},
    ["Base.TinOpener"] = {height=1, width=2, maxStackSize=1},
    ["Base.Nails"] = {height=1, width=1, maxStackSize=50},
    ["Base.HandTorch"] = {height=1, width=2, maxStackSize=1},
    ["Base.Peas"] = {height=2, width=1, maxStackSize=1},
    ["Base.Spatula"] = {height=1, width=2, maxStackSize=1},
    ["Base.TunaTin"] = {height=1, width=1, maxStackSize=3},
    ["Base.RedPen"] = {height=1, width=1, maxStackSize=5},
    ["Base.Pen"] = {height=1, width=1, maxStackSize=5},
    ["Base.SheetPaper2"] = {height=1, width=2, maxStackSize=10},
    ["Base.BluePen"] = {height=1, width=1, maxStackSize=5},
    ["Base.Plank"] = {height=1, width=4, maxStackSize=2},
    ["Base.EmptyPetrolCan"] = {height=2, width=2, maxStackSize=1},
    ["Base.Pencil"] = {height=1, width=1, maxStackSize=5},
    ["Base.WaterBottleFull"] = {height=1, width=2, maxStackSize=1},
    ["Base.WaterBottleEmpty"] = {height=1, width=2, maxStackSize=1},
    ["Base.Money"] = {height=1, width=1, maxStackSize=100},
    ["Moveables.location_shop_greenes_01_37"] = {height=3, width=3, maxStackSize=1},
    ["Base.Saucepan"] = {height=2, width=2, maxStackSize=2},
    ["Base.KitchenTongs"] = {height=1, width=2, maxStackSize=1},
    ["Base.BakingPan"] = {height=2, width=2, maxStackSize=4},
    ["Base.Kettle"] = {height=2, width=2, maxStackSize=1},
    ["Base.MuffinTray"] = {height=2, width=2, maxStackSize=4},
    ["Base.Bowl"] = {height=1, width=1, maxStackSize=3},
    ["Base.OvenMitt"] = {height=1, width=2, maxStackSize=2},
    ["Base.Shovel"] = {height=1, width=4, maxStackSize=1},
    ["Base.CordlessPhone"] = {height=1, width=2, maxStackSize=1},
    ["Base.ElectronicsScrap"] = {height=1, width=1, maxStackSize=2},
    ["Base.Cereal"] = {height=2, width=2, maxStackSize=1},
    ["Base.OilOlive"] = {height=1, width=2, maxStackSize=1},
    ["Base.Peppermint"] = {height=1, width=1, maxStackSize=5},
    ["Base.Flour"] = {height=2, width=2, maxStackSize=1},
    ["Base.PopBottle"] = {height=1, width=2, maxStackSize=1},
    ["Base.GuitarAcoustic"] = {height=2, width=5, maxStackSize=1},
    ["Base.GridlePan"] = {height=2, width=2, maxStackSize=1},
    ["Base.Plunger"] = {height=1, width=3, maxStackSize=1},
    ["Base.Sheet"] = {height=2, width=1, maxStackSize=2},
    ["Base.Drumstick"] = {height=1, width=2, maxStackSize=1},
    ["Base.Trumpet"] = {height=3, width=2, maxStackSize=1},
    ["Base.Headphones"] = {height=2, width=2, maxStackSize=4},
    ["Base.RoastingPan"] = {height=2, width=2, maxStackSize=3},
    ["Base.Disinfectant"] = {height=1, width=2, maxStackSize=1},
    ["Radio.ElectricWire"] = {height=2, width=2, maxStackSize=5},
    ["Base.GardenSaw"] = {height=2, width=1, maxStackSize=2},
    ["Base.HandAxe"] = {height=1, width=2, maxStackSize=1},
    ["Base.Rope"] = {height=2, width=2, maxStackSize=3},
    ["Base.Gravelbag"] = {height=2, width=3, maxStackSize=2},
    ["Base.FishingRod"] = {height=1, width=4, maxStackSize=1},
    ["Base.PropaneTank"] = {height=3, width=4, maxStackSize=2},
    ["Base.CarBattery3"] = {height=3, width=2, maxStackSize=2},
    ["Base.WineEmpty"] = {height=1, width=2, maxStackSize=3},
    ["Base.Broom"] = {height=1, width=4, maxStackSize=1},
    ["Base.Tarp"] = {height=2, width=2, maxStackSize=2},
    ["Base.Mop"] = {height=1, width=4, maxStackSize=4},
    ["Base.Bleach"] = {height=1, width=2, maxStackSize=2},
    ["Base.BeerEmpty"] = {height=1, width=2, maxStackSize=4},
    ["Base.GlassWine"] = {height=1, width=1, maxStackSize=1},
    ["Base.VHS_Retail"] = {height=2, width=1, maxStackSize=1},
    ["Base.Aluminum"] = {height=2, width=1, maxStackSize=2},
    ["Base.Pot"] = {height=2, width=2, maxStackSize=1},
    ["Base.KitchenKnife"] = {height=1, width=2, maxStackSize=1},
    ["Base.CannedSardines"] = {height=1, width=1, maxStackSize=3},
    ["Base.GuitarElectricBlue"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricRed"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricBlack"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricBassBlue"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricBassRed"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricBassBlack"] = {height=2, width=5, maxStackSize=1},
    ["Base.AmmoStraps"] = {height=2, width=1, maxStackSize=2},
    ["Base.Amplifier"] = {height=1, width=1, maxStackSize=1},
    ["Base.Saw"] = {height=2, width=1, maxStackSize=2},
    ["Base.Wire"] = {height=2, width=2, maxStackSize=4},
    ["Base.FirstAidKit"] = {height=2, width=2, maxStackSize=1}
}
TetrisItemData.registerItemDefinitions(builtIn)

Events.OnGameBoot.Add(TetrisItemData.initializeTetrisItemData)

TetrisItemData.getItemSize = function(item, isRotated)
    local data = TetrisItemData._getItemData(item)
    if isRotated then
        return data.height, data.width
    else
        return data.width, data.height
    end
end

TetrisItemData.getMaxStackSize = function(item)
    local data = TetrisItemData._getItemData(item)
    return data.maxStackSize or 1
end

TetrisItemData._getItemData = function(item)
    local fType = item:getFullType()

    if TetrisDevTool.itemEdits[fType] then
        return TetrisDevTool.itemEdits[fType]
    end

    if not TetrisItemData._itemData[fType] then
        TetrisItemData._calculateAndCacheItemInfo(item)
    end
    return TetrisItemData._itemData[fType]
end

TetrisItemData._calculateAndCacheItemInfo = function(item)
    local data = {}

    local itemClass = TetrisItemData._calculateItemClass(item)

    data.width, data.height = TetrisItemData._calculateItemSize(item, itemClass)
    data.maxStackSize = TetrisItemData._calculateItemStackability(item, itemClass)

    TetrisItemData._itemData[item:getFullType()] = data
end

TetrisItemData._calculateItemClass = function(item)
    local category = item:getDisplayCategory()

    if item:IsInventoryContainer() then
        return ItemClass.CONTAINER

    elseif item:IsWeapon() or category == "Weapon" then
        if item:getAmmoType() then
            return ItemClass.RANGED
        else
            return ItemClass.MELEE
        end

    elseif category == "Ammo" then
        local maxAmmoCount = item:getMaxAmmo()
        if maxAmmoCount > 0 then
            return ItemClass.MAGAZINE
        else
            return ItemClass.AMMO
        end

    elseif category == "Clothing" then
        return ItemClass.CLOTHING

    elseif category == "Food" then
        return ItemClass.FOOD

    elseif category == "FirstAid" then
        return ItemClass.HEALING

    elseif category == "Literature" or category == "SkillBook" then
        return ItemClass.BOOK

    elseif category == "Entertainment" then
        return ItemClass.ENTERTAINMENT
    
    elseif category == "Key" then
        return ItemClass.KEY
    end

    return ItemClass.MISC
end












TetrisItemData._calculateItemSize = function(item, itemClass)
    local calculation = TetrisItemData._itemClassToSizeCalculation[itemClass]    
    if type(calculation) == "function" then
        return calculation(item)
    else
        return calculation.x, calculation.y
    end
end

TetrisItemData._calculateItemSizeMagazine = function(item)
    local width = 1
    local height = 1

    local maxAmmo = item:getMaxAmmo()
    if maxAmmo >= 15 then
        height = 2
    end

    return width, height
end

TetrisItemData._calculateRangedWeaponSize = function(item)
    local width = 2
    local height = 1

    local weight = item:getActualWeight()

    if weight >= 4 then
        width = 5
        height = 2
    elseif weight >= 3 then
        width = 3
        height = 2
    elseif weight >= 2 then
        width = 3
        height = 1
    end

    return width, height
end

TetrisItemData._calculateMeleeWeaponSize = function(item)
    local width = 1
    local height = 2

    local weight = item:getActualWeight()

    if weight >= 4 then
        width = 2
        height = 5
    elseif weight >= 3 then
        width = 2
        height = 4
    elseif weight >= 2.5 then
        width = 1
        height = 4
    elseif weight >= 1.5 then
        width = 1
        height = 3
    elseif weight <= 0.4 then
        width = 1
        height = 1
    end

    return width, height
end

TetrisItemData._calculateItemSizeClothing = function(item)
    local width = 2
    local height = 2

    -- This shouldn't happen, but just in case a mod does something weird
    if item:IsClothing() == false then
        TetrisItemData.itemSizes[item:getFullType()] = {x = width, y = height}
        return
    end

    local bulletDef = item:getBulletDefense()
    if bulletDef >= 50 then
        width = 3
        height = 3
    else
        local weight = item:getActualWeight()
        if weight >= 3.0 then
            width = 3
            height = 3
        elseif weight < 0.5 then
            width = 1
            height = 1
        elseif weight <= 1.0 then
            width = 2
            height = 1
        end
    end

    return width, height
end

TetrisItemData._calculateItemSizeContainer = function(item)
    local containerDefinition = TetrisContainerData.getContainerDefinition(item:getItemContainer())
    if #containerDefinition.gridDefinitions == 1 then
        local gridDef = containerDefinition.gridDefinitions[1]
        return gridDef.size.width, gridDef.size.height
    end

    return containerDefinition.size.width, containerDefinition.size.height
end

TetrisItemData._calculateItemSizeWeightBased = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 20 then
        width = 8
        height = 8
    elseif weight >= 16 then
        width = 7
        height = 7
    elseif weight >= 12 then
        width = 6
        height = 6
    elseif weight >= 10 then
        width = 5
        height = 5
    elseif weight >= 7.5 then
        width = 4
        height = 4
    elseif weight >= 5 then
        width = 3
        height = 3
    elseif weight >= 2 then
        width = 2
        height = 2
    elseif weight >= 1 then
        width = 2
        height = 1
    end

    return width, height
end

TetrisItemData._calculateItemSizeWeightBasedTall = function(item)
    local width, height = TetrisItemData._calculateItemSizeWeightBased(item)
    return height, width
end

TetrisItemData._calculateEntertainmentSize = function(item)
    local width = 1
    local height = 1

    local mediaData = item:getMediaData()
    if mediaData then
        local category = mediaData:getCategory()
        if category == "CDs" then
            width = 1
            height = 1
        end
    end

    return width, height
end

TetrisItemData._itemClassToSizeCalculation = {
    [ItemClass.CONTAINER] = TetrisItemData._calculateItemSizeContainer,
    
    [ItemClass.MELEE] = TetrisItemData._calculateMeleeWeaponSize,
    [ItemClass.RANGED] = TetrisItemData._calculateRangedWeaponSize,
    [ItemClass.MAGAZINE] = TetrisItemData._calculateItemSizeMagazine,
    [ItemClass.AMMO] = {x = 1, y = 1},
    
    [ItemClass.FOOD] = TetrisItemData._calculateItemSizeWeightBasedTall,
    [ItemClass.DRINK] = TetrisItemData._calculateItemSizeWeightBasedTall,
    
    [ItemClass.CLOTHING] = TetrisItemData._calculateItemSizeClothing,
    [ItemClass.HEALING] = TetrisItemData._calculateItemSizeWeightBased,
    
    [ItemClass.BOOK] = {x = 1, y = 2},
    [ItemClass.ENTERTAINMENT] = TetrisItemData._calculateEntertainmentSize,
    
    [ItemClass.KEY] = {x = 1, y = 1},
    [ItemClass.MISC] = TetrisItemData._calculateItemSizeWeightBased
}

TetrisItemData._calculateItemStackability = function(item, itemClass)
    local maxStack = 1

    local calculation = TetrisItemData._itemClassToStackabilityCalculation[itemClass]
    if type(calculation) == "function" then
        maxStack = calculation(item)
    elseif calculation then
        maxStack = calculation
    end

    return maxStack
end

TetrisItemData._calculateAmmoStackability = function(item)
    local maxStack = 30

    local weight = item:getActualWeight()
    if weight >= 0.0375 then
        maxStack = 12
    elseif weight >= 0.025 then
        maxStack = 30
    end

    return maxStack
end

TetrisItemData._calculateEntertainmentStackability = function(item)
    local maxStack = 1

    local mediaData = item:getMediaData()
    if mediaData then
        local category = mediaData:getCategory()
        if category == "CDs" then
            maxStack = 10
        end
    end

    return maxStack
end

TetrisItemData._calculateMiscStackability = function(item)
    local maxStack = 1

    local weight = item:getActualWeight()
    if weight >= 0.5 then
        maxStack = 2
    elseif weight >= 0.25 then
        maxStack = 3
    elseif weight >= 0.1 then
        maxStack = 4
    elseif weight >= 0.05 then
        maxStack = 5
    end

    return maxStack
end

TetrisItemData._itemClassToStackabilityCalculation = {
    [ItemClass.CONTAINER] = 1,
    
    [ItemClass.MELEE] = 1,
    [ItemClass.RANGED] = 1,
    [ItemClass.MAGAZINE] = 1,
    [ItemClass.AMMO] = TetrisItemData._calculateAmmoStackability,
    
    [ItemClass.FOOD] = 1,
    [ItemClass.DRINK] = 1,
    
    [ItemClass.CLOTHING] = 1,
    [ItemClass.HEALING] = 1,
    
    [ItemClass.BOOK] = 2,
    [ItemClass.ENTERTAINMENT] = TetrisItemData._calculateEntertainmentStackability,
    
    [ItemClass.KEY] = 1,
    [ItemClass.MISC] = TetrisItemData._calculateMiscStackability
}
