ItemGrid = {}

function ItemGrid:new(gridDefinition, gridIndex, inventory, playerNum)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.gridDefinition = gridDefinition
    o.gridIndex = gridIndex
    o.inventory = inventory
    o.playerNum = playerNum

    o.isPlayerInventory = inventory == getSpecificPlayer(playerNum):getInventory()

    o.width = gridDefinition.size.width
    o.height = gridDefinition.size.height
    o:createDataGrid(o.width, o.height)
    
    if inventory:getType() == "floor" then
        o:redoGridPositions()
    else
        o:refresh()
    end

    return o
end

function ItemGrid:createDataGridOld(width, height)
    self.dataGrid = {}
    self.stacks = {}
    local dataGrid = self.dataGrid

    -- Fill the grid with nil
    for y = 0,height-1 do
        dataGrid[y] = {}
        for x = 0,width-1 do
            dataGrid[y][x] = nil
        end
    end

    -- Create item stacks in the grid
    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y, index = ItemGridUtil.getItemPosition(item)
        if x and y and index == self.gridIndex then
            self:insertItem(item, x, y)
        end
    end
end

function ItemGrid:createDataGrid(width, height)
    self.gridData = {}
    self.gridData.grid = {}
    self.gridData.idMap = {} -- maps item id to stack

    -- Fill the grid with nil
    local grid = self.gridData.grid
    for y = 0,height-1 do
        grid[y] = {}
        for x = 0,width-1 do
            grid[y][x] = nil
        end
    end
end

function ItemGrid:populateDataGrid()
    local modData = self:getModData()
    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local itemData = modData.stacks[item:getID()]
        if itemData and itemData.gridIndex == self.gridIndex then
            self:insertItem(item, itemData.x, itemData.y)
        end
    end
end

function ItemGrid:getGridData()
    if self.gridData then
        return self.gridData
    end

    self:createDataGrid(self.width, self.height)
    self:populateDataGrid()
    return self.gridData
end

function ItemGrid:isInBounds(x, y)
    return x >= 0 and x < self.width and y >= 0 and y < self.height
end

function ItemGrid:removeItem(item)
    local x, y, index = ItemGridUtil.getItemPosition(item)
    if x and y and index == self.gridIndex then
        local stack = self.dataGrid[y][x]
        stack:removeItem(item)
        if stack.count <= 0 then
            self:removeStackFromGrid(stack)
        end
        ItemGridUtil.clearItemPosition(item)
    end
end

function ItemGrid:removeStackFromGrid(stack) -- Stack must still contain at least one item
    local x, y = stack.position.x, stack.position.y
    local w, h = ItemGridUtil.getItemSize(stack.items[1])
    for y = y, y+h-1 do
        for x = x, x+w-1 do
            if self:isInBounds(x, y) then
                self.dataGrid[y][x] = nil
            end
        end
    end

    for _, item in ipairs(stack.items) do
        ItemGridUtil.clearItemPosition(item)
    end
end

function ItemGrid:attemptToInsertItem(item)
    local x, y = self:findPositionForItem(item)
    if x >= 0 and y >= 0 then
        self:insertItem(item, x, y)
        return true
    end
    return false
end

-- Insert the item into the grid, no checks other than stacking/overflow
function ItemGrid:insertItem(item, xPos, yPos)
    if item:isHidden() or item:isEquipped() then
        return
    end

    local stack = self.dataGrid[yPos][xPos]
    if stack and stack:canAddToStack(item) then
        stack:addItem(item)
        return
    end

    stack = ItemStack:new(item, xPos, yPos, self.gridIndex)
    table.insert(self.stacks, stack)
    
    local w, h = ItemGridUtil.getItemSize(item)
    for y = yPos, yPos+h-1 do
        for x = xPos, xPos+w-1 do
            if self:isInBounds(x, y) then
                self.dataGrid[y][x] = stack
            end
        end
    end
end

function ItemGrid:canAddItem(item)
    local x, y = self:findPositionForItem(item)
    return x >= 0 and y >= 0
end

function ItemGrid:findPositionForItem(item, isRotationAttempt)
    local w, h = ItemGridUtil.getItemSize(item)
    for y = 0,self.height-h do
        for x = 0,self.width-w do
            local stack = self.dataGrid[y][x]
            if stack and stack:canAddToStack(item) then
                return x, y
            end

            local canPlace = self:doesItemFit_WH(item, x, y, w, h)
            if canPlace then
                return x, y
            end
        end
    end

    if not isRotationAttempt and w ~= h then
        -- Try rotating the item
        ItemGridUtil.rotateItem(item)
        return self:findPositionForItem(item, true)
    end
    
    if w ~= h then
        -- Unrotate the item to its original state
        ItemGridUtil.rotateItem(item)
    end
    
    return -1, -1
end

function ItemGrid:doesItemFit(item, xPos, yPos, rotate)
    local w, h = ItemGridUtil.getItemSize(item)
    if rotate then
        w, h = h, w
    end
    return self:doesItemFit_WH(item, xPos, yPos, w, h)
end

function ItemGrid:doesItemFit_WH(item, xPos, yPos, w, h)
    if not self:isInBounds(xPos, yPos) or not self:isInBounds(xPos+w-1, yPos+h-1) then
        return false
    end

    for y = yPos, yPos+h-1 do
        for x = xPos, xPos+w-1 do
            local stack = self.dataGrid[y][x]
            if stack and not stack:containsItem(item) then
                return false
            end
        end
    end
    return true
end

function ItemGrid:canItemBeStacked(item, xPos, yPos)
    if not self:isInBounds(xPos, yPos) then
        return false
    end
    local stack = self.dataGrid[yPos][xPos]
    return stack and stack:canAddToStack(item)
end

function ItemGrid:attemptToStackItem(item)
    for y = 0,self.height-1 do
        for x = 0,self.width-1 do
            if self:canItemBeStacked(item, x, y) then
                self:insertItem(item, x, y)
                return true
            end
        end
    end
    return false
end

function ItemGrid:willItemOverlapSelf(item, newX, newY)
    local w, h = ItemGridUtil.getItemSize(item)
    for y = newY, newY+h-1 do
        for x = newX, newX+w-1 do
            if self:isInBounds(x, y) then
                local stack = self.dataGrid[y][x]
                if stack and stack:containsItem(item) then
                    return true
                end
            end
        end
    end
    return false
end

function ItemGrid:redoGridPositions()
    local items = self.inventory:getItems()
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local gridIndex = ItemGridUtil.getItemGridIndex(item)
        if gridIndex == self.gridIndex then
            ItemGridUtil.clearItemPosition(item)
        end
    end
    self:refresh()
end

function ItemGrid:refresh()
    if self.isPlayerInventory and not getPlayerHotbar(self.playerNum) then
        return false
    end

    self:clearGrid()
    self:updateGridPositions()
    return true
end

function ItemGrid:clearGrid()
    local items = self.inventory:getItems();
    for y = 0, self.height-1 do
        for x = 0, self.width-1 do
            self.dataGrid[y][x] = nil
        end
    end
    self.stacks = {}
end

function ItemGrid:updateGridPositions()
    local isInHotbarMap = self:getHotbarItemsMap()

    for i = 0, self.inventory:getItems():size()-1 do
        local item = self.inventory:getItems():get(i);
        if item:isHidden() or item:isEquipped() or isInHotbarMap[item] then
            ItemGridUtil.clearItemPosition(item)
        else
            local x, y, gridIndex = ItemGridUtil.getItemPosition(item)
            if x and y and gridIndex == self.gridIndex then
                if not self:doesItemFit(item, x, y, ItemGridUtil.isItemRotated(item)) then
                    ItemGridUtil.clearItemPosition(item)
                else
                    self:insertItem(item, x, y)
                end
            end
        end
    end
    
    self:claimUnpositionedItems()
end

function ItemGrid:getHotbarItemsMap()
    local hotbar = getPlayerHotbar(self.playerNum);

	local isInHotbar = {}
    if hotbar and hotbar.attachedItems then
        for _,item in pairs(hotbar.attachedItems) do
            isInHotbar[item] = true
        end
    end

    return isInHotbar
end

function ItemGrid:claimUnpositionedItems()
    local unpositionedItems = self:getUnpositionedItems()
    
    -- Try to stack items first, loop backwards so we can remove items from the list
    for i = #unpositionedItems,1,-1 do
        local item = unpositionedItems[i].item
        if self:attemptToStackItem(item) then
            table.remove(unpositionedItems, i)
        end
    end

    -- Sort the remaining unpositioned items by size, so we can place the biggest ones first
    table.sort(unpositionedItems, function(a, b) return a.size > b.size end)
    for i = 1,#unpositionedItems do
        local item = unpositionedItems[i].item
        if not self:attemptToInsertItem(item) then
            if self.isPlayerInventory then
                self:dropUnpositionedItem(item)
            end
        end
    end
end

function ItemGrid:dropUnpositionedItem(item)
    if ItemGrid.dropProcessing then
        return
    end

    local playerNum = self.playerNum
    local playerObj = getSpecificPlayer(playerNum)
    local action = TimedActionSnooper.findUpcomingActionThatHandlesItem(playerObj, item)
    if action then
        -- If the player is about to use the item, don't drop it
        -- Register an auto drop if they cancel the action
        
        local og_stop = action.stop
        action.stop = function(self)
            og_stop(self)
            table.insert(ItemGrid.itemsToDrop, {item, playerNum})
        end

        return
    end

    ItemGrid.handleDroppingItem(item, playerNum)
end

function ItemGrid:getUnpositionedItems()
    local unpositionedItemData = {}
    local hotbarItems = self.isPlayerInventory and self:getHotbarItemsMap() or {}

    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        if not item:isHidden() and not item:isEquipped() and not hotbarItems[item] then
            local x, y, i = ItemGridUtil.getItemPosition(item)
            if not x or not y or not i then
                local w, h = ItemGridUtil.getItemSize(item)
                local size = w * h
                table.insert(unpositionedItemData, {item = item, size = size})
            end
        end
    end

    return unpositionedItemData
end

function ItemGrid:get(x, y)
    if not self:isInBounds(x, y) then
        return nil
    end
    return self.dataGrid[y][x]
end

function ItemGrid:getByItem(item)
    local x, y, index = ItemGridUtil.getItemPosition(item)
    if x and y and index == self.gridIndex then
        return self:get(x, y)
    end
    return nil
end





ItemGrid.itemsToDrop = {}

function ItemGrid.dropItems()
    if #ItemGrid.itemsToDrop == 0 then return end

    for _, data in ipairs(ItemGrid.itemsToDrop) do
        local item, playerNum = data[1], data[2]
        ItemGrid.handleDroppingItem(item, playerNum)
    end

    ItemGrid.itemsToDrop = {}
end

function ItemGrid.handleDroppingItem(item, playerNum)
    ItemGrid.dropProcessing = true

    if instanceof(item, "Moveable") and item:getSpriteGrid()==nil and not item:CanBeDroppedOnFloor() then
        -- We have to force this item back into the player's inventory or hand
        ItemGrid.forceItemIntoInventory(item, playerNum)
    else
        ISInventoryPaneContextMenu.onDropItems({item, item}, playerNum)
    end

    ItemGrid.dropProcessing = false
end

-- Special handling for moveables that can't be dropped on the floor
function ItemGrid.forceItemIntoInventory(item, playerNum)
    local playerObj = getSpecificPlayer(playerNum)
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

Events.OnTick.Add(ItemGrid.dropItems)





















-- The mod data format is a map of item id to position data
function ItemGrid:getModData()
    local modData = self:_getActualModData()
    if not modData.containers then
        modData.containers = {}
    end

    local invType = self.inventory:getType()
    if not modData.containers[invType] then
        modData.containers[invType] = {}
    end

    if not modData.containers[invType][self.gridIndex] then
        modData.containers[invType][self.gridIndex] = {}
    end

    return modData.containers[invType][self.gridIndex]
end

-- Returns the mod data for the owning object
function ItemGrid:_getActualModData()
    if self.isPlayerInventory then
        return getSpecificPlayer(self.playerNum):getModData()
    else
        local item = self.inventory:getContainingItem()
        if item then
            return item:getModData()
        end

        local isoObject = self.inventory:getParent()
        if isoObject then
            return isoObject:getModData()
        end

        print("Error: this code should never be reached. ItemGrid:_getActualModData().")
        print("Whatever this is, it's not a valid container.")
        return {} -- Return an empty table so we don't error out
    end
end


function ItemGrid:getItemPosition(item)
    if item:isEquipped() then
        return -1, -1, 0
    end

    local gridData = self:getGridData()

end




