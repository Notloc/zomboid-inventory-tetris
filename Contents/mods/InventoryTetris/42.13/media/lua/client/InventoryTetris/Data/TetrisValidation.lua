local TetrisContainerData = require("InventoryTetris/Data/TetrisContainerData")
local TetrisItemData = require("InventoryTetris/Data/TetrisItemData")
local TetrisItemCategory = require("InventoryTetris/Data/TetrisItemCategory")

---@class TetrisValidationService
local TetrisValidation = {}

---@param container ItemContainer
---@param containerDef any
---@param item InventoryItem
---@return boolean
function TetrisValidation.validateInsert(container, containerDef, item)
    local itemInContainer = item:getContainer() == container
    if not itemInContainer and not container:isItemAllowed(item) then
        return false
    end

    if item:IsInventoryContainer() and SandboxVars.InventoryTetris.PreventTardisStacking then
        ---@cast item InventoryContainer

        -- If the receiving container is inside or is a tardis
        local isInsideTardis = TetrisValidation.isTardisRecursive(container)
        if isInsideTardis then
            -- Ensure the container item being inserted is not and does not contain any tardis
            local leafTardis = {}
            TetrisValidation._findLeafTardis(item:getItemContainer(), leafTardis)
            if #leafTardis > 0 then
                return false
            end
        end

        -- Prevent a rigid container from being put inside a rigid container unless its smaller
        -- i.e. You can't fit a 3x3 lunchbox inside a 3x3 lunchbox
        local containerItem = container:getContainingItem()
        if containerItem then
            local itemContainerDef = TetrisContainerData.getContainerDefinition(item:getItemContainer())
            if containerDef.isRigid and itemContainerDef.isRigid then
                local x,y = TetrisItemData.getItemSizeUnsquished(containerItem, false)
                local x2,y2 = TetrisItemData.getItemSizeUnsquished(item, false)
                if x*y <= x2*y2 then
                    return false
                end
            end
        end
    end

    if containerDef.maxSize then
        local w, h = TetrisItemData.getItemSizeUnsquished(item, false)
        local size = w * h
        if size > containerDef.maxSize then
            return false
        end
    end

    local itemCategory = TetrisItemCategory.getCategory(item)
    return TetrisContainerData.canAcceptCategory(containerDef, itemCategory)
end

--- TODO: Refactor to not use recursion.
--- Searches up the container hierarchy to see if any parent container is a tardis.
---@param container ItemContainer
---@return boolean
function TetrisValidation.isTardisRecursive(container)
    local isTardis = TetrisValidation.isTardis(container)
    if isTardis then
        return true
    end

    local item = container:getContainingItem()
    if not item then
        return false
    end

    container = item:getContainer()
    if not container then
        return false
    end

    return TetrisValidation.isTardisRecursive(container)
end

--- A "Tardis" is a container that has more internal slot capacity than the size of its containing item.
---@param container ItemContainer
---@return boolean
function TetrisValidation.isTardis(container)
    local containingItem = container:getContainingItem()
    local isKeyRing = containingItem and containingItem:hasTag(ItemTag.KEY_RING)

    if isKeyRing or container:getType() == "none" then
        return false
    end

    if not container:getContainingItem() then
        return false
    end

    local containerDef = TetrisContainerData.getContainerDefinition(container)
    if not TetrisContainerData.canAcceptCategory(containerDef, TetrisItemCategory.CONTAINER) then
        return false
    end

    local w, h = TetrisItemData.getItemSizeUnsquished(container:getContainingItem(), false)
    local size = w * h
    local capacity = TetrisContainerData.calculateInnerSize(container)
    return size < capacity
end

--- TODO: Refactor to not use recursion.
--- Searches down the container hierarchy to find any leaf tardis containers.
---@param container ItemContainer
---@param tardisList ItemContainer[]
function TetrisValidation._findLeafTardis(container, tardisList)
    local isTardis = TetrisValidation.isTardis(container)
    if isTardis then
        table.insert(tardisList, container)
    end

    local items = container:getItems()
    for i = 1, items:size() do
        local item = items:get(i - 1)
        if item:IsInventoryContainer() then
            ---@cast item InventoryContainer
            TetrisValidation._findLeafTardis(item:getItemContainer(), tardisList)
        end
    end
end

return TetrisValidation