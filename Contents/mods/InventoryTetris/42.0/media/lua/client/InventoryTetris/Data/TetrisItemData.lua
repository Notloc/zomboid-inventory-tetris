require("InventoryTetris/Data/TetrisItemCategory")

local SQUISHED_SUFFIX = "__squished"

TetrisItemData = TetrisItemData or {}  -- Partial class

TetrisItemData._itemData = {}
TetrisItemData._itemDataPacks = {}
TetrisItemData._alwaysStackOnSpawnItems = {}

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
