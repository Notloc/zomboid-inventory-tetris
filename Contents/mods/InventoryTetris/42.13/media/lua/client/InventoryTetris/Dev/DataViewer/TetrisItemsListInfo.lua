local TetrisItemData = require("InventoryTetris/Data/TetrisItemData")

local TetrisItemsListInfo = {}

function TetrisItemsListInfo.getItemDimensions(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    if not itemDef then return "-" end
    return itemDef.width .. "x" .. itemDef.height
end

function TetrisItemsListInfo.getItemSize(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    if not itemDef then return nil end
    return itemDef.width * itemDef.height
end

function TetrisItemsListInfo.getMaxStackSize(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    if not itemDef then return nil end
    return itemDef.maxStackSize
end

function TetrisItemsListInfo.getItemDensity(itemScript)
    local itemSize = TetrisItemsListInfo.getItemSize(itemScript)
    if not itemSize then return nil end
    local itemWeight = itemScript:getActualWeight()
    return itemWeight / itemSize
end

function TetrisItemsListInfo.getStackDensity(itemScript)
    local itemSize = TetrisItemsListInfo.getItemSize(itemScript)
    if not itemSize then return nil end

    local stackSize = TetrisItemsListInfo.getMaxStackSize(itemScript)
    if not stackSize then return nil end

    local itemWeight = itemScript:getActualWeight()
    return itemWeight * stackSize / itemSize
end

function TetrisItemsListInfo.isAutoCalculated(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    return itemDef and itemDef._autoCalculated or false
end

return TetrisItemsListInfo
