TetrisItemData = TetrisItemData or {} -- Partial class

local SQUISH_FACTOR = 3
local FLOAT_CORRECTION = 0.001

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
        width = 1
    end
    if maxAmmo > 30 then
        height = 3
        width = 1
    end
    if maxAmmo > 45 then
        height = 2
        width = 2
    end

    return width, height
end

function TetrisItemData._calculateRangedWeaponSize(item)
    local width = 2
    local height = 1

    -- Read weight from the script item to easily ignore attachment weight
    local weight = item:getScriptItem():getActualWeight()

    if weight >= 2 then
        width = 3
        height = 1
    end
    if weight >= 3 then
        width = 3
        height = 2
    end
    if weight >= 4 then
        width = 5
        height = 2
    end
    if weight >= 5 then
        width = 6
        height = 2
    end
    if weight >= 6 then
        width = 7
        height = 2
    end

    return width, height
end

function TetrisItemData._calculateMeleeWeaponSize(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()

    if weight >= 0.5 then
        width = 1
        height = 2
    end
    if weight >= 1.6 then
        width = 1
        height = 3
    end
    if weight >= 2.5 then
        width = 1
        height = 4
    end
    if weight >= 3.5 then
        width = 2
        height = 4
    end
    if weight >= 4 then
        width = 2
        height = 5
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
        -- Read weight from the script item to ignore wetness weight and the like
        local weight = item:getScriptItem():getActualWeight()
        if weight >= 3.0 then
            width = 3
            height = 3
        elseif weight <= 0.5 then
            width = 1
            height = 1
        elseif weight <= 1.0 then
            width = 1
            height = 2
        end
    end

    return width, height
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
    local x, y = TetrisItemData._calculateContainerItemSizeFromInner(innerSize)
    return x, y
end

-- Returns dimensions for a container item based on the number of items it can hold
-- Always returns a dimension that is >= innerSize
function TetrisItemData._calculateContainerItemSizeFromInner(innerSize)
    local MAX_ITEM_DIM = 12
    if innerSize > MAX_ITEM_DIM * MAX_ITEM_DIM then
        return MAX_ITEM_DIM, MAX_ITEM_DIM
    end

    local best = 99999999
    local bestX = 1
    local bestY = 1

    for x = 1, MAX_ITEM_DIM do
        for y = 1, MAX_ITEM_DIM do
            local result = x * y
            local diff = math.abs(result - innerSize) + math.abs(x - y) -- Encourage square shapes 
            if diff < best and result >= innerSize then
                best = diff
                bestX = x
                bestY = y
            end
        end
    end

    return bestX, bestY
end

function TetrisItemData._calculateMiscSize(item)
    if item:getFluidContainer() then
        return TetrisItemData._calculateFluidContainerSize(item)
    end
    return TetrisItemData._calculateItemSizeWeightBased(item)
end

function TetrisItemData._calculateItemSizeWeightBased(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()

    if weight < 1 then
        width = 1
        height = 1
    elseif weight < 2 then
        width = 1
        height = 2
    elseif weight < 3 then
        width = 2
        height = 2
    elseif weight < 4 then
        width = 2
        height = 3
    elseif weight < 5 then
        width = 3
        height = 3
    else
        return TetrisContainerData._calculateDimensions(weight * 2, 2)
    end

    return width, height
end

function TetrisItemData._calculateFoodSize(item)
    if item:getFluidContainer() then
        return TetrisItemData._calculateFluidContainerSize(item)
    end
    return TetrisItemData._calculateItemSizeWeightBasedTall(item)
end

function TetrisItemData._calculateFluidContainerSize(item)
    local fluidContainer = item:getFluidContainer()

    -- Small containers are 1x1
    local fluidCapacity = fluidContainer:getCapacity()
    if fluidCapacity <= 0.5 then
        return 1, 1
    end

    -- Everything else is 1 slot per liter with a minimum size of 1x2
    local slots = math.max(math.pow(fluidCapacity, 0.85), 2)
    local x, y = TetrisContainerData._calculateDimensions(slots, 2)

    if x > y then
        return y, x
    end
    return x, y
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
    return TetrisContainerData._calculateDimensions(weight * 2, 2)
end

TetrisItemData._itemClassToSizeCalculation = {
    [TetrisItemCategory.AMMO] = {x = 1, y = 1},
    [TetrisItemCategory.BOOK] = {x = 1, y = 2},
    [TetrisItemCategory.CLOTHING] = TetrisItemData._calculateItemSizeClothing,
    [TetrisItemCategory.CONTAINER] = TetrisItemData._calculateItemSizeContainer,
    [TetrisItemCategory.ENTERTAINMENT] = TetrisItemData._calculateEntertainmentSize,
    [TetrisItemCategory.FOOD] = TetrisItemData._calculateFoodSize,
    [TetrisItemCategory.HEALING] = TetrisItemData._calculateItemSizeWeightBased,
    [TetrisItemCategory.KEY] = {x = 1, y = 1},
    [TetrisItemCategory.MAGAZINE] = TetrisItemData._calculateItemSizeMagazine,
    [TetrisItemCategory.ATTACHMENT] = TetrisItemData._calculateItemSizeWeightBased,
    [TetrisItemCategory.MELEE] = TetrisItemData._calculateMeleeWeaponSize,
    [TetrisItemCategory.MISC] = TetrisItemData._calculateMiscSize,
    [TetrisItemCategory.MOVEABLE] = TetrisItemData._calculateMoveableSize,
    [TetrisItemCategory.RANGED] = TetrisItemData._calculateRangedWeaponSize,
    [TetrisItemCategory.SEED] = {x = 1, y = 1},
}


function TetrisItemData._simpleWeightStackability(item)
    local weight = item:getActualWeight()
    return math.ceil(0.75 / weight)
end

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
    elseif weight >= 0.0125 then
        maxStack = 60
    elseif weight >= 0.00625 then
        maxStack = 120
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
    if item:getFluidContainer() then
        return 1
    end

    local weight = item:getActualWeight()
    return math.max(1, math.floor(1 / weight))
end

function TetrisItemData._weaponStackability(item)
    local weight = item:getActualWeight() * 2
    return math.max(1, math.floor((1 / weight)+FLOAT_CORRECTION))
end

TetrisItemData._itemClassToStackabilityCalculation = {
    [TetrisItemCategory.AMMO] = TetrisItemData._calculateAmmoStackability,
    [TetrisItemCategory.BOOK] = TetrisItemData._simpleWeightStackability,
    [TetrisItemCategory.CLOTHING] = TetrisItemData._simpleWeightStackability,
    [TetrisItemCategory.CONTAINER] = 1,
    [TetrisItemCategory.ENTERTAINMENT] = TetrisItemData._calculateEntertainmentStackability,
    [TetrisItemCategory.HEALING] = TetrisItemData._simpleWeightStackability,
    [TetrisItemCategory.FOOD] = TetrisItemData._calculateFoodStackability,
    [TetrisItemCategory.KEY] = 1,
    [TetrisItemCategory.MAGAZINE] = 1,
    [TetrisItemCategory.MELEE] = TetrisItemData._weaponStackability,
    [TetrisItemCategory.MISC] = TetrisItemData._simpleWeightStackability,
    [TetrisItemCategory.MOVEABLE] = TetrisItemData._calculateMoveableStackability,
    [TetrisItemCategory.RANGED] = 1,
    [TetrisItemCategory.SEED] = TetrisItemData._calculateSeedStackability,
}
