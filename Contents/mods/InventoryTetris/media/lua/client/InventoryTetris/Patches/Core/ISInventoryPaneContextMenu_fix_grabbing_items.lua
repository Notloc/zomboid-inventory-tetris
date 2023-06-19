require "ISUI/ISInventoryPaneContextMenu"

local function quickMoveItems(items, playerNum)
    local invPage = getPlayerInventory(playerNum)
    local targetContainers = ItemGridUiUtil.getOrderedBackpacks(invPage)
    
    local retVal = nil
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
        transfer.enforceTetrisRules = true
        ISTimedActionQueue.add(transfer)

        if retVal == nil then
            retVal = transfer:isValid()
        end
    end

    return retVal
end

local ogOnGrabItems = ISInventoryPaneContextMenu.onGrabItems
ISInventoryPaneContextMenu.onGrabItems = function(stacks, playerNum)
    if quickMoveItems(ISInventoryPane.getActualItems(stacks), playerNum) then
        ogOnGrabItems(stacks, playerNum)
    end
end


local ogOnGrabHalfItems = ISInventoryPaneContextMenu.onGrabHalfItems
ISInventoryPaneContextMenu.onGrabHalfItems = function(stacks, playerNum)
    local halfItems = ISInventoryPane.getActualItems(stacks)
    local count = math.ceil(#halfItems/2)
    halfItems[count] = nil -- remove this index so ipairs stops here

    if quickMoveItems(halfItems, playerNum) then
        ogOnGrabHalfItems(stacks, playerNum)
    end
end

local ogOnGrabOneItems = ISInventoryPaneContextMenu.onGrabOneItems
ISInventoryPaneContextMenu.onGrabOneItems = function(stacks, playerNum)
    local items = ISInventoryPane.getActualItems(stacks)
    if quickMoveItems({items[1]}, playerNum) then
        ogOnGrabOneItems(stacks, playerNum)
    end
end
