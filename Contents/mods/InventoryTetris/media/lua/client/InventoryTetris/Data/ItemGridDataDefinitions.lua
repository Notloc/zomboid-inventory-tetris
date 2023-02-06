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

    ["Base.Pillow"] = {x=2, y=2},
    ["Base.Kettle"] = {x=2, y=2},
    ["Base.BakingPan"] = {x=2, y=2},
    ["Base.Pan"] = {x=2, y=2},

    ["Base.Crowbar"] = {x=1, y=4},
    ["Base.LeadPipe"] = {x=1, y=3},
    ["Base.BaseballBat"] = {x=1, y=4},

    ["Base.GuitarElectricBassBlue"] = {x=2,y=4},
    ["Base.GuitarElectricBassRed"] = {x=2,y=4},
    ["Base.GuitarElectricBassBlack"] = {x=2,y=4},

    ["Base.GuitarElectricBlack"] = {x=2,y=4},
    ["Base.GuitarElectricBlue"] = {x=2,y=4},
    ["Base.GuitarElectricRed"] = {x=2,y=4},

    ["Base.GuitarAcoustic"] = {x=2,y=4},
    ["Base.Guitarcase"] = {x=2,y=5},

    ["Base.Garbagebag"] = {x=4, y=4},
    ["Base.Corn"] = {x=1, y=2},
    ["Base.ButterKnife"] = {x=1, y=2},
    ["Base.CarvingFork"] = {x=1, y=2},

    ["Base.CuttingBoardPlastic"] = {x=2, y=2},
    ["Base.Spatula"] = {x=1, y=2},
    ["Base.Cereal"] = {x=2, y=2},
    ["Base.SewingKit"] = {x=2, y=1},
    ["Base.Headphones"] = {x=2, y=2},
    ["Base.PipeWrench"] = {x=1, y=3},
    ["Base.Sheet"] = {x=2, y=1},
    ["Base.HockeyStick"] = {x=1, y=5},
    ["Base.Saw"] = {x=2, y=1},
    ["Base.Shovel2"] = {x=1, y=5},
    ["Base.ClubHammer"] = {x=1, y=2},
    ["Base.WoodenMallet"] = {x=1, y=2},
    ["Base.Wrench"] = {x=1, y=2},
    ["Base.BucketEmpty"] = {x=2, y=2},
    ["Base.NailsBox"] = {x=2, y=1},
}

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
        size = ItemGridDataDefinitions.calculateItemSizeWeightBasedTall(item)
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

ItemGridDataDefinitions.calculateItemSizeWeightBasedTall = function(item)
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

    return {x = width, y = height}
end

ItemGridDataDefinitions.calculateItemStackability = function(item)
    ItemGridDataDefinitions.itemSizes[item:getFullType()].maxStackSize = 10
end

