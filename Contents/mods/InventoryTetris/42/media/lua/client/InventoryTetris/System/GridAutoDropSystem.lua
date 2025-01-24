-- Responsible for forcing items out of the player's inventory when it slips into an invalid state
local ItemUtil = require("Notloc/ItemUtil")

GridAutoDropSystem = {}
GridAutoDropSystem._dropQueues = {}
GridAutoDropSystem._dropProcessing = {}

function GridAutoDropSystem.queueItemForDrop(item, playerObj)
    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queueIsEmpty = #queueObj.queue == 0
    if queueIsEmpty then
        local playerNum = playerObj:getPlayerNum()
        if GridAutoDropSystem._dropProcessing[playerNum] then return end
        if not GridAutoDropSystem._dropQueues[playerNum] then GridAutoDropSystem._dropQueues[playerNum] = {} end
        GridAutoDropSystem._dropQueues[playerNum][item] = true
    end
end

function GridAutoDropSystem._processItems(playerNum, items)
    GridAutoDropSystem._dropProcessing[playerNum] = true

    local playerObj = getSpecificPlayer(playerNum)
    local isDisorganized = playerObj:HasTrait("Disorganized")
    local containers = ItemUtil.getAllEquippedContainers(playerObj)
    local mainInv = playerObj:getInventory()

    for _, item in ipairs(items) do
        local addedToContainer = false

        local currentContainer = item:getContainer()
        if currentContainer then
            local containerGrid = ItemContainerGrid.GetOrCreate(currentContainer, playerNum)
            if containerGrid:canAddItem(item) and containerGrid:autoPositionItem(item, isDisorganized) then
                addedToContainer = true
            else
                for _, container in ipairs(containers) do
                    local containerGrid = ItemContainerGrid.GetOrCreate(container, playerNum)
                    if currentContainer ~= container and containerGrid:canAddItem(item) then
                        local transfer = ISInventoryTransferAction:new(playerObj, item, currentContainer, container, 1)
                        transfer.enforceTetrisRules = true
                        ISTimedActionQueue.add(transfer)
                        addedToContainer = true
                        break
                    end
                end

                if TetrisItemCategory.getCategory(item) == TetrisItemCategory.KEY then
                    local keyRings = mainInv:getAllTag("KeyRing", ArrayList.new())
                    for i = 0, keyRings:size()-1 do
                        local keyRing = keyRings:get(i)
                        local container = keyRing:getItemContainer()
                        local containerGrid = ItemContainerGrid.GetOrCreate(container, playerNum)
                        if containerGrid:canAddItem(item) then
                            local transfer = ISInventoryTransferAction:new(playerObj, item, currentContainer, container, 1)
                            transfer.enforceTetrisRules = true
                            ISTimedActionQueue.add(transfer)
                            addedToContainer = true
                            break
                        end
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
        local playerObj = getSpecificPlayer(playerNum)
        local transfer = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), ISInventoryPage.GetFloorContainer(playerNum), 1)
        ISTimedActionQueue.add(transfer)
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
    local grid = ItemContainerGrid.GetOrCreate(inventory, playerNum)
    if grid:canAddItem(item) then
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), inventory, 1))
        return true
    end

    local wornItems = playerObj:getWornItems()
    for i = 0, wornItems:size()-1 do
        local wornItem = wornItems:get(i):getItem()
        if wornItem:IsInventoryContainer() then
            local grid = ItemContainerGrid.GetOrCreate(wornItem:getInventory(), playerNum)
            if grid:canAddItem(item) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), wornItem:getInventory(), 1))
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
