require("ISUI/ISInventoryPaneContextMenu")
local ItemContainerGrid = require("InventoryTetris/Model/ItemContainerGrid")

-- Fixes some quirks with the right click grab options
---@diagnostic disable: duplicate-set-field

Events.OnGameBoot.Add(function()
    local function quickMoveItems(items, playerNum)
        local invPage = getPlayerInventory(playerNum)
        local targetContainers = ItemGridUI.getOrderedBackpacks(invPage)

        local movedItem = nil
        local playerObj = getSpecificPlayer(playerNum)
        for _, item in ipairs(items) do
            local targetContainer = nil
            for _, testContainer in ipairs(targetContainers) do
                local gridContainer = ItemContainerGrid.GetOrCreate(testContainer, playerNum)
                if gridContainer:canAddItem(item) then
                    targetContainer = testContainer
                    break
                end
            end

            if not targetContainer then return end

            local transfer = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), targetContainer)
            transfer.enforceTetrisRules = true
            ISTimedActionQueue.add(transfer)

            if movedItem == nil then
                movedItem = transfer:isValid()
            end
        end

        return movedItem
    end

    local ogOnGrabItems = ISInventoryPaneContextMenu.onGrabItems
    function ISInventoryPaneContextMenu.onGrabItems(stacks, playerNum)
        if quickMoveItems(ISInventoryPane.getActualItems(stacks), playerNum) then
            ogOnGrabItems(stacks, playerNum)
        end
    end


    local ogOnGrabHalfItems = ISInventoryPaneContextMenu.onGrabHalfItems
    function ISInventoryPaneContextMenu.onGrabHalfItems(stacks, playerNum)
        local halfItems = ISInventoryPane.getActualItems(stacks)
        local count = math.ceil(#halfItems/2)
        halfItems[count] = nil -- remove this index so ipairs stops here

        if quickMoveItems(halfItems, playerNum) then
            ogOnGrabHalfItems(stacks, playerNum)
        end
    end

    local ogOnGrabOneItems = ISInventoryPaneContextMenu.onGrabOneItems
    function ISInventoryPaneContextMenu.onGrabOneItems(stacks, playerNum)
        local items = ISInventoryPane.getActualItems(stacks)
        if quickMoveItems({items[1]}, playerNum) then
            ogOnGrabOneItems(stacks, playerNum)
        end
    end
end)
