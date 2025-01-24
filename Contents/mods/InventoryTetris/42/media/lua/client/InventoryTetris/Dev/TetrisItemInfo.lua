TetrisItemInfo = TetrisItemInfo or {}

function TetrisItemInfo.getItemDimensions(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    if not itemDef then return "-" end
    return itemDef.width .. "x" .. itemDef.height
end

function TetrisItemInfo.getItemSize(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    if not itemDef then return nil end
    return itemDef.width * itemDef.height
end

function TetrisItemInfo.getMaxStackSize(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    if not itemDef then return nil end
    return itemDef.maxStackSize
end

function TetrisItemInfo.getItemDensity(itemScript)
    local itemSize = TetrisItemInfo.getItemSize(itemScript)
    if not itemSize then return nil end
    local itemWeight = itemScript:getActualWeight()
    return itemWeight / itemSize
end

function TetrisItemInfo.getStackDensity(itemScript)
    local itemSize = TetrisItemInfo.getItemSize(itemScript)
    if not itemSize then return nil end

    local stackSize = TetrisItemInfo.getMaxStackSize(itemScript)
    if not stackSize then return nil end

    local itemWeight = itemScript:getActualWeight()
    return itemWeight * stackSize / itemSize
end

function TetrisItemInfo.isAutoCalculated(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    return itemDef and itemDef._autoCalculated or false
end