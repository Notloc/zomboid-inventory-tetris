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


GridItemManager = {}
GridItemManager._itemData = {}











Events.OnGameBoot.Add(GridItemManager.initializeGridItemManager)







GridItemManager.getItemSize = function(item, isRotated)
    local data = GridItemManager._getItemData(item)
    if isRotated then
        return data.height, data.width
    else
        return data.width, data.height
    end
end

GridItemManager.getMaxStackSize = function(item)
    local data = GridItemManager._getItemData(item)
    return data.maxStackSize
end



GridItemManager._getItemData = function(item)
    local fType = item:getFullType()
    if not GridItemManager._itemData[fType] then
        GridItemManager._calculateAndCacheItemInfo(item)
    end
    return GridItemManager._itemData[fType]
end

GridItemManager._calculateAndCacheItemInfo = function(item)
    local data = {}

    local itemClass = GridItemManager._calculateItemClass(item)

    data.width, data.height = GridItemManager._calculateItemSize(item, itemClass)
    data.maxStackSize = GridItemManager._calculateItemStackability(item, itemClass)

    GridItemManager._itemData[item:getFullType()] = data
end

GridItemManager._calculateItemClass = function(item)
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












GridItemManager._calculateItemSize = function(item, itemClass)
    local calculation = GridItemManager._itemClassToSizeCalculation[itemClass]    
    if type(calculation) == "function" then
        return calculation(item)
    else
        return calculation.x, calculation.y
    end
end

GridItemManager._calculateItemSizeMagazine = function(item)
    local width = 1
    local height = 1

    local maxAmmo = item:getMaxAmmo()
    if maxAmmo >= 15 then
        height = 2
    end

    return width, height
end

GridItemManager._calculateRangedWeaponSize = function(item)
    local width = 2
    local height = 1

    local weight = item:getActualWeight()

    if weight >= 4 then
        width = 4
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

GridItemManager._calculateMeleeWeaponSize = function(item)
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

GridItemManager._calculateItemSizeClothing = function(item)
    local width = 2
    local height = 2

    -- This shouldn't happen, but just in case a mod does something weird
    if item:IsClothing() == false then
        GridItemManager.itemSizes[item:getFullType()] = {x = width, y = height}
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

GridItemManager._calculateItemSizeContainer = function(item)
    local containerDefinition = ContainerData.getContainerDefinition(item:getItemContainer())
    if #containerDefinition.gridDefinitions == 1 then
        local gridDef = containerDefinition.gridDefinitions[1]
        return gridDef.size.width, gridDef.size.height
    end

    return containerDefinition.size.width, containerDefinition.size.height
end

GridItemManager._calculateItemSizeWeightBased = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 10 then
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

GridItemManager._calculateItemSizeWeightBasedTall = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 10 then
        width = 4
        height = 4
    elseif weight >= 5 then
        width = 3
        height = 3
    elseif weight >= 2 then
        width = 2
        height = 2
    elseif weight >= 1 then
        width = 1
        height = 2
    end

    return width, height
end

GridItemManager._itemClassToSizeCalculation = {
    [ItemClass.CONTAINER] = GridItemManager._calculateItemSizeContainer,
    
    [ItemClass.MELEE] = GridItemManager._calculateMeleeWeaponSize,
    [ItemClass.RANGED] = GridItemManager._calculateRangedWeaponSize,
    [ItemClass.MAGAZINE] = GridItemManager._calculateItemSizeMagazine,
    [ItemClass.AMMO] = {x = 1, y = 1},
    
    [ItemClass.FOOD] = GridItemManager._calculateItemSizeWeightBasedTall,
    [ItemClass.DRINK] = GridItemManager._calculateItemSizeWeightBasedTall,
    
    [ItemClass.CLOTHING] = GridItemManager._calculateItemSizeClothing,
    [ItemClass.HEALING] = GridItemManager._calculateItemSizeWeightBased,
    
    [ItemClass.BOOK] = {x = 1, y = 2},
    [ItemClass.ENTERTAINMENT] = {x = 2, y = 1},
    
    [ItemClass.KEY] = {x = 1, y = 1},
    [ItemClass.MISC] = GridItemManager._calculateItemSizeWeightBased
}



GridItemManager._calculateItemStackability = function(item, itemClass)
    local maxStack = 1

    local calculation = GridItemManager._itemClassToStackabilityCalculation[itemClass]
    if type(calculation) == "function" then
        maxStack = calculation(item)
    elseif calculation then
        maxStack = calculation
    end

    return maxStack
end

GridItemManager._calculateAmmoStackability = function(item)
    local maxStack = 30

    local weight = item:getActualWeight()
    if weight >= 0.0375 then
        maxStack = 12
    elseif weight >= 0.025 then
        maxStack = 30
    end

    return maxStack
end

GridItemManager._itemClassToStackabilityCalculation = {
    [ItemClass.CONTAINER] = 1,
    
    [ItemClass.MELEE] = 1,
    [ItemClass.RANGED] = 1,
    [ItemClass.MAGAZINE] = 1,
    [ItemClass.AMMO] = GridItemManager._calculateAmmoStackability,
    
    [ItemClass.FOOD] = 1,
    [ItemClass.DRINK] = 1,
    
    [ItemClass.CLOTHING] = 1,
    [ItemClass.HEALING] = 1,
    
    [ItemClass.BOOK] = 2,
    [ItemClass.ENTERTAINMENT] = 1,
    
    [ItemClass.KEY] = 1,
    [ItemClass.MISC] = GridItemManager._calculateMiscStackability
}
