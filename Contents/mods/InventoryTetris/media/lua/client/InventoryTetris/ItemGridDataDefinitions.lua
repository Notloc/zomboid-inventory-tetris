ItemGridDataDefinitions = {}

ItemGridDataDefinitions.itemSizes = {
    ["Base.VHS_Retail"] = {x=2, y=1},
    ["Base.Pot"] = {x=2, y=2},
    ["Base.KitchenTongs"] = {x=1, y=2},
    ["Base.GrillBrush"] = {x=1, y=2},
    ["Base.KitchenKnife"] = {x=1, y=2},
    ["Base.BakingTray"] = {x=2, y=2},
    ["Base.Icecream"] = {x=1, y=2},

    -- veggies, peas, corn, 2x1
    ["Base.MixedVegetables"] = {x=2, y=1},
    ["Base.Peas"] = {x=2, y=1},
    ["Base.CornFrozen"] = {x=2, y=1},

    -- bottles, 1x2
    ["Base.BeerBottle"] = {x=1,y=2},
    ["Base.WaterBottleFull"] = {x=1,y=2},
    ["Base.WaterBottleEmpty"] = {x=1, y=2},

    --end

    ["Base.Pillow"] = {x=2,y=2},


    ["Base.Crowbar"] = {x=1,y=4},


}

ItemGridDataDefinitions.isStackable = {}

ItemGridDataDefinitions.calculateAndCacheItemInfo = function(item)
    ItemGridDataDefinitions.calculateItemSize(item)
    ItemGridDataDefinitions.calculateItemStackability(item)
end

-- Programatically determine the size of items that are not manually defined
ItemGridDataDefinitions.calculateItemSize = function(item)
    local category = item:getDisplayCategory()
    local size = {x=1, y=1}

    if category == "Ammo" then
        -- determine if its ammo or a magazine by stackability
        if item:CanStack(item) then
            size = ItemGridDataDefinitions.calculateItemSizeMagazine(item)
        else
            size = {x=1, y=1}
        end
    elseif category == "Weapon" then
        size = ItemGridDataDefinitions.calculateItemSizeWeapon(item)
    elseif category == "Clothing" then
        size = ItemGridDataDefinitions.calculateItemSizeClothing(item)
    elseif category == "Food" then
        size = ItemGridDataDefinitions.calculateItemSizeWeightBased(item)
    elseif category == "FirstAid" then
        size = ItemGridDataDefinitions.calculateItemSizeWeightBased(item)
    elseif category == "Container" then
        size = ItemGridDataDefinitions.calculateItemSizeContainer(item)
    elseif category == "Literature" or category == "SkillBook" then
        size = {x=1, y=2}
    elseif category == "Key" then
        size = {x=1, y=1}
    else
        size = ItemGridDataDefinitions.calculateItemSizeWeightBased(item)
    end

    ItemGridDataDefinitions.itemSizes[item:getFullType()] = size
end

ItemGridDataDefinitions.calculateItemSizeMagazine = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 0.25 then
        height = 2
    end

    return {x = width, y = height}
end

ItemGridDataDefinitions.calculateItemSizeWeapon = function(item)
    local width = 2
    local height = 1

    local weight = item:getActualWeight()

    if weight >= 3 then
        width = 4
        height = 2
    elseif weight >= 2.5 then
        width = 3
        height = 2
    elseif weight >= 2 then
        width = 3
        height = 1
    elseif weight <= 0.4 then
        width = 1
        height = 1
    end

    return {x = width, y = height}
end

ItemGridDataDefinitions.calculateItemSizeClothing = function(item)
    local width = 2
    local height = 2

    -- This shouldn't happen, but just in case a mod does something weird
    if item:IsClothing() == false then
        ItemGridDataDefinitions.itemSizes[item:getFullType()] = {x = width, y = height}
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

    return {x = width, y = height}
end

ItemGridDataDefinitions.calculateItemSizeContainer = function(item)
    local width = 1
    local height = 1

    -- TODO: Should match the internal size of said container unless its a TARDIS
    return {x = width, y = height}
end

ItemGridDataDefinitions.calculateItemSizeWeightBased = function(item)
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

    return {x = width, y = height}
end

ItemGridDataDefinitions.calculateItemStackability = function(item)
    local stackable = item:CanStack(item)
    ItemGridDataDefinitions.isStackable[item:getFullType()] = stackable
end

