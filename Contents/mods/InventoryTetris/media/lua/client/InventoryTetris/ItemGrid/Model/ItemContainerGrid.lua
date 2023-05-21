local function searchInventoryPageForContainerGrid(invPage, targetInventory)
    if not invPage then
        return nil
    end
    
    if invPage.inventoryPane.gridContainerUis then
        for _, containerGridUi in pairs(invPage.inventoryPane.gridContainerUis) do
            if containerGridUi.inventory == targetInventory then
                return containerGridUi.containerGrid
            end
        end
    end
    for _, childWindow in ipairs(invPage.inventoryPane:getChildWindows()) do
        if childWindow.gridContainerUi and targetInventory == childWindow.gridContainerUi.inventory then
            return childWindow.gridContainerUi.containerGrid
        end
    end
    return nil
end


ItemContainerGrid = {}

function ItemContainerGrid:new(inventory, playerNum)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.inventory = inventory
    o.playerNum = playerNum
    o.containerDefinition = TetrisContainerData.getContainerDefinition(inventory)
    o.isPlayerInventory = inventory == getSpecificPlayer(playerNum):getInventory()
    o.grids = o:createGrids(inventory, playerNum)
    return o
end

ItemContainerGrid.Create = function(inventory, playerNum)
    local containerGrid = ItemContainerGrid.FindInstance(inventory, playerNum)
    if containerGrid then
        return containerGrid
    end
    return ItemContainerGrid:new(inventory, playerNum)
end

ItemContainerGrid.FindInstance = function(inventory, playerNum)
    local playerObj = getSpecificPlayer(playerNum)
    if inventory == playerObj:getInventory() then
        return ItemContainerGrid._getPlayerMainGrid(playerNum)
    end

    local invPage = getPlayerInventory(playerNum)
    local containerGrid = searchInventoryPageForContainerGrid(invPage, inventory)
    if containerGrid then
        return containerGrid
    end

    invPage = getPlayerLoot(playerNum)
    containerGrid = searchInventoryPageForContainerGrid(invPage, inventory)
    if containerGrid then
        return containerGrid
    end
    return nil
end

ItemContainerGrid._playerMainGrids = {}
function ItemContainerGrid._getPlayerMainGrid(playerNum)
    if not ItemContainerGrid._playerMainGrids[playerNum] then
        local playerObj = getSpecificPlayer(playerNum)
        local inventory = playerObj:getInventory()
        ItemContainerGrid._playerMainGrids[playerNum] = ItemContainerGrid:new(inventory, playerNum)
    end
    return ItemContainerGrid._playerMainGrids[playerNum]
end

function ItemContainerGrid:createGrids(inventory, playerNum)
    local grids = {}
    for index, gridDef in ipairs(self.containerDefinition.gridDefinitions) do
        local grid = ItemGrid:new(self, index, inventory, playerNum)
        grids[index] = grid
    end
    return grids
end

function ItemContainerGrid:isOrganized()
    return self.containerDefinition.isOrganized
end

function ItemContainerGrid:doesItemFit(item, gridX, gridY, gridIndex, rotate)
    local grid = self.grids[gridIndex]
    if not grid then
        return false
    end
    return grid:doesItemFit(item, gridX, gridY, rotate)
end

function ItemContainerGrid:_getCapacity()
    local player = getSpecificPlayer(self.playerNum)
    local hasOrganizedTrait = player:HasTrait("Organized")
    local hasDisorganizedTrait = player:HasTrait("Disorganized")

    local capacity = self.inventory:getCapacity()
    if hasOrganizedTrait then
        capacity = math.floor(capacity * 1.3)
    elseif hasDisorganizedTrait then
        capacity = math.floor(capacity * 0.7)
    end

    return capacity
end

function ItemContainerGrid:canAddItem(item)
    if not self:_validateOnlyAcceptCategory(item) then
        return false
    end

    local capacity = self:_getCapacity()
    if capacity < item:getActualWeight() + self.inventory:getCapacityWeight() then
        return false
    end

    for _, grid in ipairs(self.grids) do
        if grid:canAddItem(item, false) or grid:canAddItem(item, true) then
            return true
        end
    end
    return false
end

function ItemContainerGrid:_validateOnlyAcceptCategory(item)
    if self.inventory:getOnlyAcceptCategory() then
        if item:getCategory() ~= self.inventory:getOnlyAcceptCategory() then
            return false
        end
    end
    
    if not self.containerDefinition.acceptedCategories then
        return true
    end
    
    return self.containerDefinition.acceptedCategories[item:getCategory()]
end

function ItemContainerGrid:refresh()
    for _, grid in ipairs(self.grids) do
        grid:refresh()
    end
    self:_updateGridPositions()
    self.lastRefresh = getTimestampMs()
end

function ItemContainerGrid:shouldRefresh()
    if not self.lastRefresh then
        return true
    end
    return getTimestampMs() - self.lastRefresh > 1000
end

-- isDisoraganized is determined by the player's traits
-- If it is nil, they have no relevant traits and the container itself determines if it is disorganized
function ItemContainerGrid:attemptToInsertItem(item, preferRotated, isDisoraganized)
    for _, grid in ipairs(self.grids) do
        if grid:_attemptToInsertItem(item, preferRotated, isDisoraganized) then
            return true
        end
    end
    return false
end

function ItemContainerGrid:insertItem(item, gridX, gridY, gridIndex, isRotated)
    local grid = self.grids[gridIndex]
    if not grid then
        return false
    end
    return grid:insertItem(item, gridX, gridY, isRotated)
end

function ItemContainerGrid:forceInsertItem(item)
    local grid = self.grids[1]
    if not grid then
        return false
    end
    return grid:insertItem(item, 1, 1)
end

function ItemContainerGrid:removeItem(item)
    for _, grid in pairs(self.grids) do
        if grid:removeItem(item) then
            return true
        end
    end
    return false
end

function ItemContainerGrid:autoPositionItem(item)
    for _, grid in ipairs(self.grids) do
        if grid:removeItem(item) then
            print("ohno")
        end
    end

    for _, grid in ipairs(self.grids) do
        if grid:_attemptToInsertItem(item) then
            return true
        end
    end
    return false
end

function ItemContainerGrid:canItemBeStacked(item, xPos, yPos, gridIndex)
    local grid = self.grids[gridIndex]
    if not grid then
        return false
    end
    return grid:canItemBeStacked(item, xPos, yPos)
end

function ItemContainerGrid:findGridStackByVanillaStack(vanillaStack)
    local item = vanillaStack.items[1]
    if not item then return nil end
    
    for _, grid in ipairs(self.grids) do
        local gridStack = grid:findStackByItem(item)
        if gridStack then
            return gridStack, grid
        end
    end
    return nil, nil
end


function ItemContainerGrid:_updateGridPositions(useShuffle)
    local unpositionedItems = self:_getUnpositionedItems()

    -- Sort the unpositioned items by size, so we can place the biggest ones first
    table.sort(unpositionedItems, function(a, b) return a.size > b.size end)
    
    for _, grid in ipairs(self.grids) do
        unpositionedItems = grid:_acceptUnpositionedItems(unpositionedItems, useShuffle)
    end

    for _, unpositionedItemData in ipairs(unpositionedItems) do
        self:_dropUnpositionedItem(unpositionedItemData.item)
    end
end

function ItemContainerGrid:_getUnpositionedItems()
    local positionedItems = self:_getPositionedItems()
    local unpositionedItemData = {}

    local count = 0
    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        if not positionedItems[item:getID()] and self:_isItemValid(item) then
            local w, h = TetrisItemData.getItemSize(item)
            local size = w * h
            table.insert(unpositionedItemData, {item = item, size = size})
            count = count + 1
            if count >= 100 then -- Don't process too many items at once
                break
            end
        end
    end
    return unpositionedItemData
end

function ItemContainerGrid:_getPositionedItems()
    local positionedItems = {}
    for index, grid in ipairs(self.grids) do
        local gridData = grid:_getSavedGridData()
        for _, stack in pairs(gridData.stacks) do
            for itemID, _ in pairs(stack.itemIDs) do
                positionedItems[itemID] = true
            end
        end
    end
    return positionedItems
end

function ItemContainerGrid:_dropUnpositionedItem(item)
    local playerNum = self.playerNum
    local playerObj = getSpecificPlayer(playerNum)
    local action = TimedActionSnooper.findUpcomingActionThatHandlesItem(playerObj, item)
    if action then
        if action.autoDropInjected then
            return -- Already injected
        end
        
        -- If the player is about to use the item, don't drop it
        -- Inject an auto drop if they cancel the action
        local og_stop = action.stop
        action.stop = function(self)
            og_stop(self)
            GridAutoDropSystem.queueItemForDrop(item, playerNum)
        end
        action.autoDropInjected = true
        return
    end

    GridAutoDropSystem.queueItemForDrop(item, playerNum)
end

function ItemContainerGrid:_isItemValid(item)
    return not item:isHidden() and not item:isEquipped() and not self:_isItemInHotbar(item)
end

function ItemContainerGrid:_isItemInHotbar(item)
    if not self.isPlayerInventory then
        return false
    end

    local hotbar = getPlayerHotbar(self.playerNum);
    if not hotbar then return false end

    return hotbar:isInHotbar(item)
end



-- Keep the player's main inventory grid refreshed, so it drops unpositioned items even if the ui isn't open
Events.OnTick.Add(function()
    for _, grid in pairs(ItemContainerGrid._playerMainGrids) do
        if grid:shouldRefresh() then
            grid:refresh()
        end
    end
end)

