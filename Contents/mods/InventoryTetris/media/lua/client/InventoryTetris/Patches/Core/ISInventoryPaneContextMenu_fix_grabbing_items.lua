local function quickMoveItems(items, playerNum)
    local invPage = getPlayerInventory(playerNum)
    local targetContainers = ItemGridUiUtil.getOrderedBackpacks(invPage)
    
    local playerObj = getSpecificPlayer(playerNum)
    for _, item in ipairs(items) do
        local targetContainer = nil
        for _, testContainer in ipairs(targetContainers) do
            local gridContainer = ItemContainerGrid.Create(testContainer, playerNum)
            if gridContainer:canAddItem(item) then
                targetContainer = testContainer
                break
            end
        end

        if not targetContainer then return end
        
        local transfer = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), targetContainer)
        ISTimedActionQueue.add(transfer)
    end
end

local ogOnGrabItems = ISInventoryPaneContextMenu.onGrabItems
ISInventoryPaneContextMenu.onGrabItems = function(stacks, playerNum)
    quickMoveItems(ISInventoryPane.getActualItems(stacks), playerNum)
    ogOnGrabItems(stacks, playerNum)
end


local ogOnGrabHalfItems = ISInventoryPaneContextMenu.onGrabHalfItems
ISInventoryPaneContextMenu.onGrabHalfItems = function(stacks, playerNum)
    local halfItems = ISInventoryPane.getActualItems(stacks)
    local count = math.ceil(#halfItems/2)
    halfItems[count] = nil -- remove this index so ipairs stops here

    quickMoveItems(halfItems, playerNum)
    ogOnGrabHalfItems(stacks, playerNum)
end

local ogOnGrabOneItems = ISInventoryPaneContextMenu.onGrabOneItems
ISInventoryPaneContextMenu.onGrabOneItems = function(stacks, player)
    local items = ISInventoryPane.getActualItems(stacks)
    quickMoveItems({items[1]}, playerNum)
    ogOnGrabOneItems(stacks, playerNum)
end
