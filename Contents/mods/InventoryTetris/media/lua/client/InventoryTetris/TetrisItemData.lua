require "InventoryTetris/TetrisItemCategory"

TetrisItemData = {}
TetrisItemData._itemData = {}
TetrisItemData._squishableItems = {}

TetrisItemData.getItemSize = function(item, isRotated)
    local data = TetrisItemData._getItemData(item)
    if isRotated then
        return data.height, data.width
    else
        return data.width, data.height
    end
end

TetrisItemData.getItemSizeUnsquished = function(item, isRotated)
    local data = TetrisItemData._getItemData(item, true)
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

TetrisItemData._getItemData = function(item, noSquish)
    local fType = item:getFullType()
    if not noSquish and TetrisItemData.isSquished(item) then
        return {width = 1, height = 1, maxStackSize = 1}
    end

    if TetrisDevTool.itemEdits[fType] then
        return TetrisDevTool.itemEdits[fType]
    end

    if not TetrisItemData._itemData[fType] then
        TetrisItemData._calculateAndCacheItemInfo(item, fType)
    end
    return TetrisItemData._itemData[fType]
end

TetrisItemData._calculateAndCacheItemInfo = function(item, fType)
    local data = {}

    local category = TetrisItemCategory.getCategory(item)

    data.width, data.height = TetrisItemData._calculateItemSize(item, category)
    if data.width > 10 then data.width = 10 end
    if data.height > 12 then data.height = 12 end

    data.maxStackSize = TetrisItemData._calculateItemStackability(item, category)

    TetrisItemData._itemData[fType] = data
end

TetrisItemData._calculateItemSize = function(item, category)
    local calculation = TetrisItemData._itemClassToSizeCalculation[category]    
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

    local weight = item:getWeight()

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

    local weight = item:getWeight()

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
        local weight = item:getWeight()
        if weight >= 3.0 then
            width = 3
            height = 3
        elseif weight < 0.5 then
            width = 1
            height = 1
        elseif weight <= 1.0 then
            width = 1
            height = 2
        end
    end

    return width, height
end

TetrisItemData.isSquished = function(item)
    return TetrisItemData.isSquishable(item) and item:getItemContainer():isEmpty()
end

TetrisItemData._calculateItemSizeContainer = function(item)
    local containerDefinition = TetrisContainerData.getContainerDefinition(item:getItemContainer())
    if #containerDefinition.gridDefinitions == 1 then
        local gridDef = containerDefinition.gridDefinitions[1]
        local x,y = gridDef.size.width, gridDef.size.height
        x = x + SandboxVars.InventoryTetris.BonusGridSize
        y = y + SandboxVars.InventoryTetris.BonusGridSize
        return math.ceil(x/2), math.ceil(y/2)
    end

    local innerSize = TetrisContainerData.calculateInnerSize(item)
    local x, y = TetrisContainerData._calculateDimensions(innerSize)
    return math.ceil(x/2), math.ceil(y/2)
end

TetrisItemData._calculateItemSizeWeightBased = function(item)
    local width = 1
    local height = 1

    local weight = item:getWeight()
    
    if weight >= 60 then
        width = 10
        height = 12
    elseif weight >= 45 then
        width = 9
        height = 10
    elseif weight >= 35 then
        width = 9
        height = 9
    elseif weight >= 25 then
        width = 8
        height = 8
    elseif weight >= 20 then
        width = 7
        height = 7
    elseif weight >= 15 then
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

TetrisItemData._calculateMoveableSize = function(item)
    local width = 1
    local height = 1

    local weight = item:getWeight()
    
    if weight >= 50 then
        width = 10
        height = 12
    elseif weight >= 40 then
        width = 9
        height = 10
    elseif weight >= 30 then
        width = 8
        height = 9
    elseif weight >= 20 then
        width = 7
        height = 9
    elseif weight >= 25 then
        width = 7
        height = 8
    elseif weight >= 20 then
        width = 6
        height = 8
    elseif weight >= 15 then
        width = 5
        height = 7
    elseif weight >= 12.5 then
        width = 5
        height = 6
    elseif weight >= 10 then
        width = 5
        height = 5
    elseif weight >= 7 then
        width = 5
        height = 4
    elseif weight >= 5 then
        width = 4
        height = 3
    elseif weight >= 4 then
        width = 3
        height = 3
    elseif weight >= 3 then
        width = 2
        height = 2
    elseif weight >= 1.5 then
        width = 1
        height = 2
    end

    return width, height
end

TetrisItemData._itemClassToSizeCalculation = {
    [TetrisItemCategory.CONTAINER] = TetrisItemData._calculateItemSizeContainer,
    
    [TetrisItemCategory.MELEE] = TetrisItemData._calculateMeleeWeaponSize,
    [TetrisItemCategory.RANGED] = TetrisItemData._calculateRangedWeaponSize,
    [TetrisItemCategory.MAGAZINE] = TetrisItemData._calculateItemSizeMagazine,
    [TetrisItemCategory.AMMO] = {x = 1, y = 1},
    
    [TetrisItemCategory.FOOD] = TetrisItemData._calculateItemSizeWeightBasedTall,
    [TetrisItemCategory.DRINK] = TetrisItemData._calculateItemSizeWeightBasedTall,
    
    [TetrisItemCategory.CLOTHING] = TetrisItemData._calculateItemSizeClothing,
    [TetrisItemCategory.HEALING] = TetrisItemData._calculateItemSizeWeightBased,
    
    [TetrisItemCategory.BOOK] = {x = 1, y = 2},
    [TetrisItemCategory.ENTERTAINMENT] = TetrisItemData._calculateEntertainmentSize,
    
    [TetrisItemCategory.KEY] = {x = 1, y = 1},
    [TetrisItemCategory.MISC] = TetrisItemData._calculateItemSizeWeightBased,
    [TetrisItemCategory.SEED] = {x = 1, y = 1},
    [TetrisItemCategory.MOVEABLE] = TetrisItemData._calculateMoveableSize,
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

    local weight = item:getWeight()
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

    if instanceof(item, "Drainable") then
        return 1;
    end

    local weight = item:getWeight()
    if weight <= 0.025 then
        maxStack = 50
    elseif weight <= 0.05 then
        maxStack = 25
    elseif weight <= 0.1 then
        maxStack = 10
    elseif weight <= 0.25 then
        maxStack = 5
    elseif weight <= 0.5 then
        maxStack = 3
    end

    return maxStack
end

TetrisItemData._calculateSeedStackability = function(item)
    local type = item:getFullType()

    if string.find(type, "BagSeed") then
        return 4
    else
        return 50
    end
end

TetrisItemData._calculateMoveableStackability = function(item)
    local name = tostring(item:getDisplayName()) or ""

    local a = string.find(name, "%(")
    local b = string.find(name, "/")
    local c = string.find(name, "%)")

    local isPackaged = a and b and c and a < b and b < c
    if isPackaged then
        return 2
    end

    return 1
end

TetrisItemData._calculateFoodStackability = function(item)
    local weight = item:getWeight()
    if weight >= 0.11 then
        return 1
    end
    return 5
end

TetrisItemData._itemClassToStackabilityCalculation = {
    [TetrisItemCategory.CONTAINER] = 1,
    
    [TetrisItemCategory.MELEE] = 1,
    [TetrisItemCategory.RANGED] = 1,
    [TetrisItemCategory.MAGAZINE] = 1,
    [TetrisItemCategory.AMMO] = TetrisItemData._calculateAmmoStackability,
    
    [TetrisItemCategory.FOOD] = TetrisItemData._calculateFoodStackability,
    [TetrisItemCategory.DRINK] = 1,
    
    [TetrisItemCategory.CLOTHING] = 1,
    [TetrisItemCategory.HEALING] = 1,
    
    [TetrisItemCategory.BOOK] = 2,
    [TetrisItemCategory.ENTERTAINMENT] = TetrisItemData._calculateEntertainmentStackability,
    
    [TetrisItemCategory.KEY] = 1,
    [TetrisItemCategory.MISC] = TetrisItemData._calculateMiscStackability,
    [TetrisItemCategory.SEED] = TetrisItemData._calculateSeedStackability,
    [TetrisItemCategory.MOVEABLE] = TetrisItemData._calculateMoveableStackability,
}

function TetrisItemData.isAlwaysStacks(item)
    local maxStack = TetrisItemData.getMaxStackSize(item)
    return TetrisItemData._alwaysStackOnSpawnItems[item:getFullType()] or maxStack >= 10 or false
end


-- Item Pack Registration
TetrisItemData._itemDataPacks = {}

TetrisItemData.registerItemDefinitions = function(pack)
    table.insert(TetrisItemData._itemDataPacks, pack)
    if TetrisItemData._packsLoaded then
        TetrisItemData._processItemPack(pack) -- You're late.
    end
end

TetrisItemData._initializeTetrisItemData = function()
    for _, pack in ipairs(TetrisItemData._itemDataPacks) do
        TetrisItemData._processItemPack(pack)
    end
    TetrisItemData._packsLoaded = true
end

TetrisItemData._processItemPack = function(itemPack)
    for k, v in pairs(itemPack) do
        TetrisItemData._itemData[k] = v
    end
end

TetrisItemData._alwaysStackOnSpawnItems = {}

TetrisItemData.registerAlwaysStackOnSpawnItems = function(itemNames)
    for _, itemName in ipairs(itemNames) do
        TetrisItemData._alwaysStackOnSpawnItems[itemName] = true
    end
end

TetrisItemData._onInitWorld = function() 
    TetrisItemData._initializeTetrisItemData()
end
Events.OnInitWorld.Add(TetrisItemData._onInitWorld)



TetrisItemData.isSquishable = function(item)
    return TetrisItemData._squishableItems[item:getFullType()] or false
end

TetrisItemData.registerSquishableItems = function(itemNames)
    for _, itemName in ipairs(itemNames) do
        TetrisItemData._squishableItems[itemName] = true
    end
end


TetrisItemData.registerSquishableItems({
    "Base.Garbagebag",
    "Base.GroceryBag1",
    "Base.GroceryBag2",
    "Base.GroceryBag3",
    "Base.GroceryBag4",
    "Base.GroceryBag5",
    "Base.Plasticbag",
})