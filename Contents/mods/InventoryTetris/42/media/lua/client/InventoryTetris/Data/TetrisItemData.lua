local TetrisItemCalculator = require("InventoryTetris/Data/TetrisItemCalculator")
local TetrisContainerData = require("InventoryTetris/Data/TetrisContainerData")

-- Intentional global
TetrisItemData = {}

TetrisItemData._itemData = {}
TetrisItemData._devItemData = {}
TetrisItemData._itemDataPacks = {}
TetrisItemData._alwaysStackOnSpawnItems = {}

local SQUISHED_SUFFIX = "__squished"
TetrisItemData._squishedIdCache = {}

-- TODO: Move into dev tool and datapacks
-- Intentionally overriding TetrisItemCalculator._dynamicSizeItems
TetrisItemCalculator._dynamicSizeItems = {
    ["Base.CorpseAnimal"] = true,

    -- Fish
    ["Base.AligatorGar"] = true,
    ["Base.BlackCrappie"] = true,
    ["Base.BlueCatfish"] = true,
    ["Base.ChannelCatfish"] = true,
    ["Base.FishFillet"] = true,
    ["Base.FlatheadCatfish"] = true,
    ["Base.FreshwaterDrum"] = true,
    ["Base.LargemouthBass"] = true,
    ["Base.Muskellunge"] = true,
    ["Base.Paddlefish"] = true,
    ["Base.SmallmouthBass"] = true,
    ["Base.SpottedBass"] = true,
    ["Base.Walleye"] = true,
    ["Base.WhiteBass"] = true,
    ["Base.WhiteCrappie"] = true,
}

---@param item InventoryItem
---@param isRotated boolean
---@return integer
---@return integer
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

function TetrisItemData.getItemDefinitonByItemScript(itemScript, squished)
    if squished == nil then
        squished = false
    end

    local fType = itemScript:getFullName()
    local item = nil
    if not TetrisItemData._itemData[fType] or (squished and not TetrisItemData._itemData[fType .. SQUISHED_SUFFIX]) then
        item = instanceItem(fType)
    end
    return TetrisItemData._getItemDataByFullType(item, fType .. (squished and SQUISHED_SUFFIX or ""), squished)
end

function TetrisItemData._getItemData(item, noSquish)
    local fType = item:getFullType()
    local isSquished = not noSquish and TetrisItemData.isSquished(item)

    if isSquished then
        fType = TetrisItemData._getSquishedId(fType)
    end

    return TetrisItemData._getItemDataByFullType(item, fType, isSquished)
end

function TetrisItemData._getSquishedId(fType)
    local squishedId = fType .. SQUISHED_SUFFIX
    TetrisItemData._squishedIdCache[fType] = squishedId
    return squishedId
end

function TetrisItemData._getItemDataByFullType(item, fType, isSquished)
    if TetrisItemCalculator._dynamicSizeItems[fType] then
        fType = fType .. tostring(item:getActualWeight())
    end

    local data = TetrisItemData._devItemData[fType] or TetrisItemData._itemData[fType]
    if not data then
        if isSquished then
            local unsquishedData = TetrisItemData._getItemDataByFullType(item, item:getFullType(), false)
            data = TetrisItemCalculator.calculateItemInfoSquished(unsquishedData)
        else
            data = TetrisItemCalculator.calculateItemInfo(item)
        end
        TetrisItemData._itemData[fType] = data
    end
    return data
end

function TetrisItemData.isSquishable(item)
    return item:IsInventoryContainer() and not TetrisContainerData.getContainerDefinition(item:getItemContainer()).isRigid
end

function TetrisItemData.isSquished(item)
    return TetrisItemData.isSquishable(item) and item:getItemContainer():isEmpty()
end

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

function TetrisItemData.registerAlwaysStackOnSpawnItems(itemNames)
    for _, itemName in ipairs(itemNames) do
        TetrisItemData._alwaysStackOnSpawnItems[itemName] = true
    end
end

function TetrisItemData._onInitWorld()
    TetrisItemData._initializeTetrisItemData()
end

Events.OnInitWorld.Add(TetrisItemData._onInitWorld)

return TetrisItemData
