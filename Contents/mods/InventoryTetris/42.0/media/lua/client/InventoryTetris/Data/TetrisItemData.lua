require("InventoryTetris/Data/TetrisItemCategory")

local SQUISHED_SUFFIX = "__squished"
local SQUISH_FACTOR = 3

TetrisItemData = {}
TetrisItemData._itemData = {}

function TetrisItemData.getItemSize(item, isRotated)
    local data = TetrisItemData._getItemData(item)
    if isRotated then
        return data.height, data.width
    else
        return data.width, data.height
    end
end

function TetrisItemData.getItemSizeUnsquished(item, isRotated)
    local data = TetrisItemData._getItemData(item, true)
    if isRotated then
        return data.height, data.width
    else
        return data.width, data.height
    end
end

function TetrisItemData.getItemData_squishState(item, isSquished)
    local fType = isSquished and TetrisItemData.getSquishedFullType(item) or item:getFullType()
    return TetrisItemData._getItemDataByFullType(item, fType, isSquished)
end

function TetrisItemData.getMaxStackSize(item)
    local data = TetrisItemData._getItemData(item)
    return data.maxStackSize or 1
end

function TetrisItemData.getSquishedFullType(item)
    return item:getFullType() .. SQUISHED_SUFFIX
end

function TetrisItemData.getItemDefinitonByItemScript(itemScript)
    local fType = itemScript:getFullName()
    local item = nil
    if not TetrisItemData._itemData[fType] then
        item = instanceItem(fType)
    end
    return TetrisItemData._getItemDataByFullType(item, fType, false)
end

function TetrisItemData._getItemData(item, noSquish)
    local fType = item:getFullType()
    local isSquished = not noSquish and TetrisItemData.isSquished(item)

    if isSquished then
        fType = fType .. SQUISHED_SUFFIX
    end

    return TetrisItemData._getItemDataByFullType(item, fType, isSquished)
end


function TetrisItemData._getItemDataByFullType(item, fType, isSquished)
    local devToolOverride = TetrisDevTool.getItemOverride(fType)
    if devToolOverride then
        return devToolOverride
    end

    if not TetrisItemData._itemData[fType] then
        local data = TetrisItemData._autoCalculateItemInfo(item, isSquished)
        TetrisItemData._itemData[fType] = data
    end
    return TetrisItemData._itemData[fType]
end

function TetrisItemData._autoCalculateItemInfo(item, isSquished)
    local data = {}

    if isSquished then
        local regData = TetrisItemData._getItemData(item, true)
        data.width = regData.width
        data.height = regData.height
        data.maxStackSize = regData.maxStackSize
    else
        local category = TetrisItemCategory.getCategory(item)
        data.maxStackSize = TetrisItemData._calculateItemStackability(item, category)
        data.width, data.height = TetrisItemData._calculateItemSize(item, category)
        if data.width > 10 then data.width = 10 end
        if data.height > 12 then data.height = 12 end
    end

    if isSquished then
        data.width = math.ceil(data.width / SQUISH_FACTOR)
        data.height = math.ceil(data.height / SQUISH_FACTOR)
    end

    data._autoCalculated = true
    return data
end

function TetrisItemData._calculateItemSize(item, category)
    local calculation = TetrisItemData._itemClassToSizeCalculation[category]
    if type(calculation) == "function" then
        return calculation(item)
    else
        return calculation.x, calculation.y
    end
end

function TetrisItemData._calculateItemSizeMagazine(item)
    local width = 1
    local height = 1

    local maxAmmo = item:getMaxAmmo()
    if maxAmmo > 15 then
        height = 2
    end

    return width, height
end

function TetrisItemData._calculateRangedWeaponSize(item)
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

function TetrisItemData._calculateMeleeWeaponSize(item)
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

function TetrisItemData._calculateItemSizeClothing(item)
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
            width = 1
            height = 2
        end
    end

    return width, height
end

function TetrisItemData.isSquished(item)
    return TetrisItemData.isSquishable(item) and item:getItemContainer():isEmpty()
end

function TetrisItemData._calculateItemSizeContainer(item)
    local containerDefinition = TetrisContainerData.getContainerDefinition(item:getItemContainer())
    if #containerDefinition.gridDefinitions == 1 then
        local gridDef = containerDefinition.gridDefinitions[1]
        local x,y = gridDef.size.width, gridDef.size.height
        x = x + SandboxVars.InventoryTetris.BonusGridSize
        y = y + SandboxVars.InventoryTetris.BonusGridSize
        return x, y
    end

    local innerSize = TetrisContainerData.calculateInnerSize(item)
    local x, y = TetrisContainerData._calculateDimensions(innerSize)
    return x, y
end

function TetrisItemData._calculateItemSizeWeightBased(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    
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

function TetrisItemData._calculateItemSizeWeightBasedTall(item)
    local width, height = TetrisItemData._calculateItemSizeWeightBased(item)
    return height, width
end

function TetrisItemData._calculateEntertainmentSize(item)
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

function TetrisItemData._calculateMoveableSize(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    
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
    [TetrisItemCategory.AMMO] = {x = 1, y = 1},
    [TetrisItemCategory.BOOK] = {x = 1, y = 2},
    [TetrisItemCategory.CLOTHING] = TetrisItemData._calculateItemSizeClothing,
    [TetrisItemCategory.CONTAINER] = TetrisItemData._calculateItemSizeContainer,
    [TetrisItemCategory.ENTERTAINMENT] = TetrisItemData._calculateEntertainmentSize,
    [TetrisItemCategory.DRINK] = TetrisItemData._calculateItemSizeWeightBasedTall,
    [TetrisItemCategory.FOOD] = TetrisItemData._calculateItemSizeWeightBasedTall,
    [TetrisItemCategory.HEALING] = TetrisItemData._calculateItemSizeWeightBased,
    [TetrisItemCategory.KEY] = {x = 1, y = 1},
    [TetrisItemCategory.MAGAZINE] = TetrisItemData._calculateItemSizeMagazine,
    [TetrisItemCategory.ATTACHMENT] = TetrisItemData._calculateItemSizeWeightBased,
    [TetrisItemCategory.MELEE] = TetrisItemData._calculateMeleeWeaponSize,
    [TetrisItemCategory.MISC] = TetrisItemData._calculateItemSizeWeightBased,
    [TetrisItemCategory.MOVEABLE] = TetrisItemData._calculateMoveableSize,
    [TetrisItemCategory.RANGED] = TetrisItemData._calculateRangedWeaponSize,
    [TetrisItemCategory.SEED] = {x = 1, y = 1},
}

function TetrisItemData._calculateItemStackability(item, itemClass)
    local maxStack = 1

    local calculation = TetrisItemData._itemClassToStackabilityCalculation[itemClass]
    if type(calculation) == "function" then
        maxStack = calculation(item)
    elseif calculation then
        maxStack = calculation
    end

    return maxStack
end

function TetrisItemData._calculateAmmoStackability(item)
    local maxStack = 30

    local weight = item:getActualWeight()
    if weight >= 0.0375 then
        maxStack = 12
    elseif weight >= 0.025 then
        maxStack = 30
    end

    return maxStack
end

function TetrisItemData._calculateEntertainmentStackability(item)
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

function TetrisItemData._calculateMiscStackability(item)
    local maxStack = 1

    if instanceof(item, "Drainable") then
        return 1;
    end

    local weight = item:getActualWeight()
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

function TetrisItemData._calculateSeedStackability(item)
    local type = item:getFullType()

    if string.find(type, "BagSeed") then
        return 4
    else
        return 50
    end
end

function TetrisItemData._calculateMoveableStackability(item)
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

function TetrisItemData._calculateFoodStackability(item)
    local weight = item:getActualWeight()
    if weight >= 0.11 then
        return 1
    end
    return 5
end

TetrisItemData._itemClassToStackabilityCalculation = {
    [TetrisItemCategory.AMMO] = TetrisItemData._calculateAmmoStackability,
    [TetrisItemCategory.BOOK] = 2,
    [TetrisItemCategory.CLOTHING] = 1,
    [TetrisItemCategory.CONTAINER] = 1,
    [TetrisItemCategory.DRINK] = 1,
    [TetrisItemCategory.ENTERTAINMENT] = TetrisItemData._calculateEntertainmentStackability,
    [TetrisItemCategory.HEALING] = 1,
    [TetrisItemCategory.FOOD] = TetrisItemData._calculateFoodStackability,
    [TetrisItemCategory.KEY] = 1,
    [TetrisItemCategory.MAGAZINE] = 1,
    [TetrisItemCategory.MELEE] = 1,
    [TetrisItemCategory.MISC] = TetrisItemData._calculateMiscStackability,
    [TetrisItemCategory.MOVEABLE] = TetrisItemData._calculateMoveableStackability,
    [TetrisItemCategory.RANGED] = 1,
    [TetrisItemCategory.SEED] = TetrisItemData._calculateSeedStackability,
}

function TetrisItemData.isAlwaysStacks(item)
    local maxStack = TetrisItemData.getMaxStackSize(item)
    return TetrisItemData._alwaysStackOnSpawnItems[item:getFullType()] or maxStack >= 10 or false
end

function TetrisItemData.isInDataPack(ftype)
    for _, pack in ipairs(TetrisItemData._itemDataPacks) do
        if pack[ftype] then
            return true
        end
    end
    return false
end

-- Item Pack Registration
TetrisItemData._itemDataPacks = {}

function TetrisItemData.registerItemDefinitions(pack)
    table.insert(TetrisItemData._itemDataPacks, pack)
    if TetrisItemData._packsLoaded then
        TetrisItemData._processItemPack(pack) -- You're late.
    end
end

function TetrisItemData._initializeTetrisItemData()
    for _, pack in ipairs(TetrisItemData._itemDataPacks) do
        TetrisItemData._processItemPack(pack)
    end
    TetrisItemData._packsLoaded = true
end

function TetrisItemData._processItemPack(itemPack)
    for k, v in pairs(itemPack) do
        TetrisItemData._itemData[k] = v
    end
end

TetrisItemData._alwaysStackOnSpawnItems = {}

function TetrisItemData.registerAlwaysStackOnSpawnItems(itemNames)
    for _, itemName in ipairs(itemNames) do
        TetrisItemData._alwaysStackOnSpawnItems[itemName] = true
    end
end

function TetrisItemData._onInitWorld()
    TetrisItemData._initializeTetrisItemData()
end
Events.OnInitWorld.Add(TetrisItemData._onInitWorld)

function TetrisItemData.isSquishable(item)
    return item:IsInventoryContainer() and not TetrisContainerData.getContainerDefinition(item:getItemContainer()).isRigid
end
