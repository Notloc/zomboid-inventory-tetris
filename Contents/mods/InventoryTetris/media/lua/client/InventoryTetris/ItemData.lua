ItemData = {}

ItemData.itemSizes = {
    ["Base.VHS_Retail"] = {x=2, y=1},
    ["Base.Pot"] = {x=2, y=2},
    ["Base.KitchenTongs"] = {x=1, y=2},
    ["Base.GrillBrush"] = {x=1, y=2},
    ["Base.KitchenKnife"] = {x=1, y=2},
    ["Base.BakingTray"] = {x=2, y=2},
    ["Base.Icecream"] = {x=1, y=2},

    ["Base.MixedVegetables"] = {x=2, y=1},
    ["Base.Peas"] = {x=2, y=1},
    ["Base.CornFrozen"] = {x=2, y=1},

    ["Base.BeerBottle"] = {x=1,y=2},
    ["Base.WaterBottleFull"] = {x=1,y=2},
    ["Base.WaterBottleEmpty"] = {x=1, y=2},

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

ItemData.calculateAndCacheItemInfo = function(item)
    ItemData.calculateItemSize(item)
    ItemData.calculateItemStackability(item)
end

-- Programatically determine the size of items that are not manually defined
ItemData.calculateItemSize = function(item)
    local category = item:getDisplayCategory()
    local size = {x=1, y=1}

    if item:IsInventoryContainer() then
        size = ItemData.calculateItemSizeContainer(item)
    elseif category == "Ammo" then
        -- determine if its ammo or a magazine by stackability
        if item:CanStack(item) then
            size = ItemData.calculateItemSizeMagazine(item)
        else
            size = {x=1, y=1}
        end
    elseif category == "Weapon" then
        size = ItemData.calculateItemSizeWeapon(item)
    elseif category == "Clothing" then
        size = ItemData.calculateItemSizeClothing(item)
    elseif category == "Food" then
        size = ItemData.calculateItemSizeWeightBasedTall(item)
    elseif category == "FirstAid" then
        size = ItemData.calculateItemSizeWeightBased(item)
    elseif category == "Literature" or category == "SkillBook" then
        size = {x=1, y=2}
    elseif category == "Key" then
        size = {x=1, y=1}
    else
        size = ItemData.calculateItemSizeWeightBased(item)
    end

    ItemData.itemSizes[item:getFullType()] = size
end

ItemData.calculateItemSizeMagazine = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 0.25 then
        height = 2
    end

    return {x = width, y = height}
end

ItemData.calculateItemSizeWeapon = function(item)
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

ItemData.calculateItemSizeClothing = function(item)
    local width = 2
    local height = 2

    -- This shouldn't happen, but just in case a mod does something weird
    if item:IsClothing() == false then
        ItemData.itemSizes[item:getFullType()] = {x = width, y = height}
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

ItemData.calculateItemSizeContainer = function(item)
    local gridDefinition = ContainerData.getGridDefinitionByContainer(item:getItemContainer())[1]
    return {x = gridDefinition.size.width, y = gridDefinition.size.height}
end

ItemData.calculateItemSizeWeightBased = function(item)
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

ItemData.calculateItemSizeWeightBasedTall = function(item)
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

ItemData.calculateItemStackability = function(item)
    ItemData.itemSizes[item:getFullType()].maxStackSize = 10
end

