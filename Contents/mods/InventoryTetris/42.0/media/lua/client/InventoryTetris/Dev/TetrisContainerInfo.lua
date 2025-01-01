TetrisContainerInfo = TetrisContainerInfo or {}

function TetrisContainerInfo.isAutoCalculated(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    return containerDef and containerDef._autoCalculated or false
end

function TetrisContainerInfo.getSlotCount(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    if not containerDef then return nil end
    return TetrisContainerData._calculateInnerSizeByDefinition(containerDef)
end

function TetrisContainerInfo.isFragile(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    return containerDef and containerDef.isFragile or false
end

local capacityByFType = {}
function TetrisContainerInfo.getCapacity(itemScript)
    local fType = itemScript:getFullName()
    if not capacityByFType[fType] then
        local item = instanceItem(fType)
        if not item:IsInventoryContainer() then return nil end
        ---@cast item InventoryContainer
        local container = item:getItemContainer()
        capacityByFType[fType] = container:getCapacity()
    end

    return capacityByFType[fType]
end

function TetrisContainerInfo.getSlotDensity(itemScript)
    local capacity = TetrisContainerInfo.getCapacity(itemScript)
    local slotCount = TetrisContainerInfo.getSlotCount(itemScript)
    return capacity / slotCount
end

function TetrisContainerInfo.isSquishable(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    local isRigid = containerDef and containerDef.isRigid
    return not isRigid
end

function TetrisContainerInfo.getSquishedSize(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript, true)
    if not itemDef then return nil end
    return itemDef.width * itemDef.height
end

function TetrisContainerInfo.isTardis(itemScript)
    local slotCount = TetrisContainerInfo.getSlotCount(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    return slotCount > itemDef.width * itemDef.height
end