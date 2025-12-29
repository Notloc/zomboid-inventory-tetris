local TetrisItemData = require("InventoryTetris/Data/TetrisItemData")
local TetrisContainerData = require("InventoryTetris/Data/TetrisContainerData")

---@class TetrisContainersListInfo
local TetrisContainersListInfo = {}

---@param itemScript Item
---@return boolean
function TetrisContainersListInfo.isAutoCalculated(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    return containerDef and containerDef._autoCalculated or false
end

---@param itemScript Item
---@return integer
function TetrisContainersListInfo.getSlotCount(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    if not containerDef then return 1 end
    return TetrisContainerData._calculateInnerSizeByDefinition(containerDef)
end

---@param itemScript Item
---@return boolean
function TetrisContainersListInfo.isFragile(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    return containerDef and containerDef.isFragile or false
end

local capacityByFullItemType = {}

---@param itemScript Item
---@return integer
function TetrisContainersListInfo.getCapacity(itemScript)
    local fType = itemScript:getFullName()
    if not capacityByFullItemType[fType] then
        local item = instanceItem(fType)
        if not item:IsInventoryContainer() then return 1 end
        ---@cast item InventoryContainer
        local container = item:getItemContainer()
        capacityByFullItemType[fType] = container:getCapacity()
    end

    return capacityByFullItemType[fType]
end

---@param itemScript Item
---@return number
function TetrisContainersListInfo.getSlotDensity(itemScript)
    local capacity = TetrisContainersListInfo.getCapacity(itemScript)
    local slotCount = TetrisContainersListInfo.getSlotCount(itemScript)
    return capacity / slotCount
end

---@param itemScript Item
---@return boolean
function TetrisContainersListInfo.isSquishable(itemScript)
    local containerDef = TetrisContainerData.getContainerDefinitionByItemScript(itemScript)
    local isRigid = containerDef and containerDef.isRigid
    return not isRigid
end

---@param itemScript Item
---@return integer
function TetrisContainersListInfo.getSquishedSize(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript, true)
    if not itemDef then return 1 end
    return itemDef.width * itemDef.height
end

---@param itemScript Item
---@return boolean
function TetrisContainersListInfo.isTardis(itemScript)
    local slotCount = TetrisContainersListInfo.getSlotCount(itemScript)
    local itemDef = TetrisItemData.getItemDefinitonByItemScript(itemScript)
    return slotCount > itemDef.width * itemDef.height
end

return TetrisContainersListInfo
