local TetrisItemData = require("InventoryTetris/Data/TetrisItemData")
local TetrisContainerData = require("InventoryTetris/Data/TetrisContainerData")

local TetrisContainersListInfo = {}

function TetrisContainersListInfo.isAutoCalculated(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    return containerDef and containerDef._autoCalculated or false
end

function TetrisContainersListInfo.getSlotCount(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    if not containerDef then return nil end
    return TetrisContainerData._calculateInnerSizeByDefinition(containerDef)
end

function TetrisContainersListInfo.isFragile(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    return containerDef and containerDef.isFragile or false
end

local capacityByFType = {}
function TetrisContainersListInfo.getCapacity(itemScript)
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

function TetrisContainersListInfo.getSlotDensity(itemScript)
    local capacity = TetrisContainersListInfo.getCapacity(itemScript)
    local slotCount = TetrisContainersListInfo.getSlotCount(itemScript)
    return capacity / slotCount
end

function TetrisContainersListInfo.isSquishable(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    local isRigid = containerDef and containerDef.isRigid
    return not isRigid
end

function TetrisContainersListInfo.getSquishedSize(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript, true)
    if not itemDef then return nil end
    return itemDef.width * itemDef.height
end

function TetrisContainersListInfo.isTardis(itemScript)
    local slotCount = TetrisContainersListInfo.getSlotCount(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    return slotCount > itemDef.width * itemDef.height
end

return TetrisContainersListInfo
