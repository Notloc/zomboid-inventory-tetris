-- Responsible for forcing items out of the player's inventory if it somehow slips into an invalid state
GridAutoDropSystem = {}
GridAutoDropSystem.itemsToDrop = {}
GridAutoDropSystem.dropProcessing = {}

function GridAutoDropSystem.queueItemForDrop(item, playerNum)
    if GridAutoDropSystem.dropProcessing[playerNum] then return end
    GridAutoDropSystem.itemsToDrop[item] = {item, playerNum}
end

-- PRIVATE FUNCTIONS --

function GridAutoDropSystem._handleItem(item, playerNum)
    GridAutoDropSystem.dropProcessing[playerNum] = true

    if GridAutoDropSystem._isItemUndroppable(item) then
        GridAutoDropSystem._forceItemIntoInventoryOrHands(item, playerNum)
    else
        ISInventoryPaneContextMenu.onDropItems({item, item}, playerNum)
    end

    GridAutoDropSystem.dropProcessing[playerNum] = false
end

-- Certain furniture items (like the fridge) can't be dropped on the floor as an item, they must be placed in the world.
-- We can't do that on the player's behalf, so we'll just force the item into their inventory or hands.
function GridAutoDropSystem._isItemUndroppable(item)
    return instanceof(item, "Moveable") and item:getSpriteGrid() == nil and not item:CanBeDroppedOnFloor()
end

function GridAutoDropSystem._forceItemIntoInventoryOrHands(item, playerNum)
    local playerObj = getSpecificPlayer(playerNum)
    if GridAutoDropSystem._attemptToForcePositionItem(item, playerObj, playerNum) then return end
    if GridAutoDropSystem._attemptToForceEquipItem(item, playerObj, playerNum) then return end
end

function GridAutoDropSystem._attemptToForcePositionItem(item, playerObj, playerNum)
    local inventory = playerObj:getInventory()
    local grid = ItemContainerGrid.Create(inventory, playerNum)
    if grid:canAddItem(item) then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), inventory))
        return true
    end

    local wornItems = playerObj:getWornItems()
    for i = 0, wornItems:size()-1 do
        local wornItem = wornItems:get(i):getItem()
        if wornItem:IsInventoryContainer() then
            local grid = ItemContainerGrid.Create(wornItem:getInventory(), playerNum)
            if grid:canAddItem(item) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), wornItem:getInventory()))
                return true
            end
        end
    end
end

function GridAutoDropSystem._attemptToForceEquipItem(item, playerObj, playerNum)
    local primHand = playerObj:getPrimaryHandItem()
    local secHand = playerObj:getSecondaryHandItem()
    local requiresBothHands = item:isRequiresEquippedBothHands()

    if not instanceof(primHand, "Moveable") then
        ISInventoryPaneContextMenu.equipWeapon(item, true, requiresBothHands, playerNum)
        return true
    end

    if not requiresBothHands and not instanceof(secHand, "Moveable") then
        ISInventoryPaneContextMenu.equipWeapon(item, false, false, playerNum)
        return true
    end

    return false
end


function GridAutoDropSystem._processItems()
    for _, data in pairs(GridAutoDropSystem.itemsToDrop) do
        local item, playerNum = data[1], data[2]
        GridAutoDropSystem._handleItem(item, playerNum)
    end

    GridAutoDropSystem.itemsToDrop = {}
end

Events.OnTick.Add(GridAutoDropSystem._processItems)
