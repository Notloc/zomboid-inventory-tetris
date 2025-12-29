local TetrisItemCalculator = require("InventoryTetris/Data/TetrisItemCalculator")
local TetrisContainerData = require("InventoryTetris/Data/TetrisContainerData")

local SQUISHED_SUFFIX = "__squished"

---@class TetrisItemPack : table<string, TetrisItemDefinition>[]

---@class TetrisItemDefinition
---@field public width integer
---@field public height integer
---@field public maxStackSize integer

---@class TetrisItemData
---@field _itemData table<string, TetrisItemDefinition>
---@field _devItemData table<string, TetrisItemDefinition>
---@field _itemDataPacks TetrisItemPack[]
---@field _alwaysStackOnSpawnItems table<string, boolean>
---@field _squishedIdCache table<string, string>
local TetrisItemService = {
    _itemData = {},
    _devItemData = {},
    _itemDataPacks = {},
    _alwaysStackOnSpawnItems = {},
    _squishedIdCache = {},
}

-- TODO: Move into dev tool and datapacks
-- Intentionally overriding TetrisItemCalculator._dynamicSizeItems
TetrisItemCalculator._dynamicSizeItems = {
    ["Moveables.Moveable"] = true,
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

    -- Meat Cuts
    ["FishFillet"] = true,
}

---@param item InventoryItem
---@param isRotated boolean
---@return integer, integer
function TetrisItemService.getItemSize(item, isRotated)
    local data = TetrisItemService._getItemData(item)
    if isRotated then
        return data.height, data.width
    else
        return data.width, data.height
    end
end

---@param item InventoryItem
---@param isRotated boolean
---@return integer, integer
function TetrisItemService.getItemSizeUnsquished(item, isRotated)
    local data = TetrisItemService._getItemData(item, true)
    if isRotated then
        return data.height, data.width
    else
        return data.width, data.height
    end
end

---@param item InventoryItem
---@param isSquished boolean
---@return TetrisItemDefinition
function TetrisItemService.getItemData_squishState(item, isSquished)
    local fType = isSquished and TetrisItemService.getSquishedFullType(item) or item:getFullType()
    return TetrisItemService._getItemDataByFullType(item, fType, isSquished)
end

---@param item InventoryItem
---@return integer
function TetrisItemService.getMaxStackSize(item)
    local data = TetrisItemService._getItemData(item)
    return data.maxStackSize or 1
end

---@param item InventoryItem
---@return string
function TetrisItemService.getSquishedFullType(item)
    return item:getFullType() .. SQUISHED_SUFFIX
end

-- Only used in debug mode item viewer
local itemScriptCache = {}

---@param itemScript Item
---@param squished boolean?
---@return TetrisItemDefinition
function TetrisItemService.getItemDefinitonByItemScript(itemScript, squished)
    if squished == nil then
        squished = false
    end

    local fullType = itemScript:getFullName()
    local item = itemScriptCache[fullType]
    if not item then
        item = instanceItem(fullType)
        itemScriptCache[fullType] = item
    end
    return TetrisItemService._getItemDataByFullType(item, fullType .. (squished and SQUISHED_SUFFIX or ""), squished)
end

---@param item InventoryItem
---@param noSquish boolean|nil
---@return TetrisItemDefinition
function TetrisItemService._getItemData(item, noSquish)
    local fType = item:getFullType()
    local isSquished = not noSquish and TetrisItemService.isSquished(item)

    if isSquished then
        fType = TetrisItemService._getSquishedId(fType)
    end

    return TetrisItemService._getItemDataByFullType(item, fType, isSquished)
end

---@param fullType string
---@return string
function TetrisItemService._getSquishedId(fullType)
    local squishedId = fullType .. SQUISHED_SUFFIX
    TetrisItemService._squishedIdCache[fullType] = squishedId
    return squishedId
end

---@param item InventoryItem
---@param fullType string
---@param isSquished boolean
---@return TetrisItemDefinition
function TetrisItemService._getItemDataByFullType(item, fullType, isSquished)
    if TetrisItemCalculator._dynamicSizeItems[fullType] then
        fullType = fullType .. tostring(item:getActualWeight())
    end

    local data = TetrisItemService._devItemData[fullType] or TetrisItemService._itemData[fullType]
    if not data then
        if isSquished then
            local unsquishedData = TetrisItemService._getItemDataByFullType(item, item:getFullType(), false)
            data = TetrisItemCalculator.calculateItemInfoSquished(unsquishedData)
        else
            data = TetrisItemCalculator.calculateItemInfo(item)
        end
        TetrisItemService._itemData[fullType] = data
    end
    return data
end

---@param item InventoryItem
---@return boolean
function TetrisItemService.isSquishable(item)
    if not item:IsInventoryContainer() then
        return false
    end
    ---@cast item InventoryContainer
    return not TetrisContainerData.getContainerDefinition(item:getItemContainer()).isRigid
end

---@param containerItem InventoryContainer
---@return boolean
function TetrisItemService.isSquished(containerItem)
    return TetrisItemService.isSquishable(containerItem) and containerItem:getItemContainer():isEmpty()
end

---@param item InventoryItem
---@return boolean
function TetrisItemService.isAlwaysStacks(item)
    local maxStack = TetrisItemService.getMaxStackSize(item)
    return TetrisItemService._alwaysStackOnSpawnItems[item:getFullType()] or maxStack >= 10 or false
end

---@param fullType string
---@return boolean
function TetrisItemService.isInDataPack(fullType)
    for _, pack in ipairs(TetrisItemService._itemDataPacks) do
        if pack[fullType] then
            return true
        end
    end
    return false
end

function TetrisItemService.registerItemDefinitions(pack)
    table.insert(TetrisItemService._itemDataPacks, pack)
    if TetrisItemService._packsLoaded then
        TetrisItemService._processItemPack(pack) -- You're late.
    end
end

function TetrisItemService._initializeTetrisItemData()
    for _, pack in ipairs(TetrisItemService._itemDataPacks) do
        TetrisItemService._processItemPack(pack)
    end
    TetrisItemService._packsLoaded = true
end

function TetrisItemService._processItemPack(itemPack)
    for k, v in pairs(itemPack) do
        TetrisItemService._itemData[k] = v
    end
end

function TetrisItemService.registerAlwaysStackOnSpawnItems(itemNames)
    for _, itemName in ipairs(itemNames) do
        TetrisItemService._alwaysStackOnSpawnItems[itemName] = true
    end
end

function TetrisItemService._onInitWorld()
    TetrisItemService._initializeTetrisItemData()
end

Events.OnInitWorld.Add(TetrisItemService._onInitWorld)

-- Export as global for modpack backwards compatibility
_G.TetrisItemData2 = TetrisItemService

return TetrisItemService
