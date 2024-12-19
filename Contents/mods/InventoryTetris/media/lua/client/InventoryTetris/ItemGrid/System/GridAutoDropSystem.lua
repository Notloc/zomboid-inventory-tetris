-- Responsible for forcing items out of the player's inventory when it slips into an invalid state
GridAutoDropSystem = {}
GridAutoDropSystem._dropQueues = {}
GridAutoDropSystem._dropProcessing = {}

function GridAutoDropSystem.queueItemForDrop(item, playerObj)
    local queueIsEmpty = #ISTimedActionQueue.getTimedActionQueue(playerObj).queue == 0
    if queueIsEmpty then
        local playerNum = playerObj:getPlayerNum()
        if GridAutoDropSystem._dropProcessing[playerNum] then return end
        if not GridAutoDropSystem._dropQueues[playerNum] then GridAutoDropSystem._dropQueues[playerNum] = {} end
        GridAutoDropSystem._dropQueues[playerNum][item] = true
    end
end

-- PRIVATE FUNCTIONS --

function GridAutoDropSystem._processItems(playerNum, items)
    GridAutoDropSystem._dropProcessing[playerNum] = true

    local playerObj = getSpecificPlayer(playerNum)
    local isOrganized = playerObj:HasTrait("Organized")
    local isDisorganized = playerObj:HasTrait("Disorganized")
    local containers = NotUtil.getAllEquippedContainers(playerObj)

    for _, item in ipairs(items) do
        local addedToContainer = false

        local currentContainer = item:getContainer()
        if currentContainer then
            local containerGrid = ItemContainerGrid.Create(currentContainer, playerNum)
            if containerGrid:canAddItem(item) then
                containerGrid:autoPositionItem(item, isOrganized, isDisoraganized)
                addedToContainer = true
            else
                for _, container in ipairs(containers) do
                    local containerGrid = ItemContainerGrid.Create(container, playerNum)
                    if currentContainer ~= container and containerGrid:canAddItem(item) then
                        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, currentContainer, container))
                        addedToContainer = true
                        break
                    end
                end
            end
        end

        if not addedToContainer then
            GridAutoDropSystem._handleDropItem(item, playerNum)
        end
    end

    GridAutoDropSystem._dropProcessing[playerNum] = false
end

function GridAutoDropSystem._handleDropItem(item, playerNum)
    GridAutoDropSystem._dropProcessing[playerNum] = true

    if GridAutoDropSystem._isItemUndroppable(item) then
        GridAutoDropSystem._forceItemIntoInventoryOrHands(item, playerNum)
    else
        item:setFavorite(false) -- We don't play favorites here
        ISInventoryPaneContextMenu.onDropItems({item, item}, playerNum)
    end

    GridAutoDropSystem._dropProcessing[playerNum] = false
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
        ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, item, 0, true, requiresBothHands));
        return true
    end

    if not requiresBothHands and not instanceof(secHand, "Moveable") then
        ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, item, 0, false, requiresBothHands));
        return true
    end

    return false
end


function GridAutoDropSystem._processQueues()
    for playerNum, itemMap in pairs(GridAutoDropSystem._dropQueues) do
        local itemsToDrop = {}
        for item, _ in pairs(itemMap) do
            table.insert(itemsToDrop, item)
        end
        --print("Processing drop queue, " .. #itemsToDrop .. " items to drop")
        GridAutoDropSystem._processItems(playerNum, itemsToDrop)
        GridAutoDropSystem._dropQueues[playerNum] = nil
    end
end

Events.OnTick.Add(GridAutoDropSystem._processQueues)







-- There is a sizable amount of vanilla actions that do not properly unequip items from the player's hands before destroying them.
-- Lets just do this and forget about it.

TetrisHandMonitor = {}
TetrisHandMonitor.ticksByPlayer = {}

TetrisHandMonitor.validateEquippedItems = function(playerObj)
    local playerNum = playerObj:getPlayerNum()
    if not playerNum or playerNum >= 4 then return end -- Some NPC mod or something

    local tick = TetrisHandMonitor.ticksByPlayer[playerNum] or 0
    if tick < 30 then
        TetrisHandMonitor.ticksByPlayer[playerObj:getPlayerNum()] = tick + 1
        return
    end

    local primHand = playerObj:getPrimaryHandItem()
    if primHand and not primHand:getContainer() then
        playerObj:setPrimaryHandItem(nil)
    end

    local secHand = playerObj:getSecondaryHandItem()
    if secHand and not secHand:getContainer() then
        playerObj:setSecondaryHandItem(nil)
    end
end
Events.OnPlayerUpdate.Add(TetrisHandMonitor.validateEquippedItems)