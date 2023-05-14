ItemGrid = {}

function ItemGrid:new(containerGrid, gridIndex, inventory, playerNum)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.containerGrid = containerGrid
    o.containerDefinition = containerGrid.containerDefinition
    o.gridDefinition = o.containerDefinition.gridDefinitions[gridIndex]
    o.gridIndex = gridIndex
    o.inventory = inventory
    o.playerNum = playerNum

    o.isPlayerInventory = inventory == getSpecificPlayer(playerNum):getInventory()

    o.width = o.gridDefinition.size.width
    o.height = o.gridDefinition.size.height
    o.firstRefresh = true

    o:_loadData()
    return o
end

function ItemGrid:getItem(x, y)
    if not self.stackMap[x] then return nil end
    local stack = self.stackMap[x][y]
    return stack and ItemStack.getFrontItem(stack, self.inventory) or nil
end

function ItemGrid:getStack(x, y)
    if not self.stackMap[x] then return nil end
    return self.stackMap[x][y]
end

function ItemGrid:getStacks()
    return self.persistentData.stacks
end

function ItemGrid:findStackByItem(item)
    for _, stack in ipairs(self.persistentData.stacks) do
        if ItemStack.containsItem(stack, item) then
            return stack
        end
    end
    return nil
end

function ItemGrid:insertItem(item, xPos, yPos, isRotated)
    local stack = self.stackMap[xPos][yPos]
    if stack then
        if not ItemStack.canAddItem(stack, item) then 
            return false 
        end
        ItemStack.addItem(stack, item)
        self:_sendModData()
        return true
    else
        local w, h = TetrisItemData.getItemSize(item, isRotated)
        if not self:_isAreaFree(xPos, yPos, w, h) then
            return false
        end
        self:_insertStack(xPos, yPos, item, isRotated)
        return true
    end
end

function ItemGrid:removeItem(item)
    for _, stack in ipairs(self.persistentData.stacks) do
        if ItemStack.containsItem(stack, item) then
            ItemStack.removeItem(stack, item, self.inventory)
            if stack.count == 0 then
                self:_removeStack(stack)
            end

            self:_sendModData()
            return true
        end
    end
    return false
end

function ItemGrid:moveStack(stack, x, y, isRotated)
    local item = ItemStack.getFrontItem(stack, self.inventory)
    
    local w, h = TetrisItemData.getItemSize(item, isRotated)
    if not self:_isAreaFree(x, y, w, h, stack) then
        return false
    end
    
    self:_removeStack(stack)
    self:_insertStack_premade(stack, x, y, isRotated)
    
    self:_sendModData()
    return true
end

function ItemGrid:gatherSameItems(stack)
    -- Pull all the items from other stacks into this one
    local targetItem = ItemStack.getFrontItem(stack, self.inventory)

    -- Compile a list of all stacks of the same item
    local stacksToGather = {}
    for _, s in ipairs(self.persistentData.stacks) do
        if s ~= stack and ItemStack.isSameType(s, targetItem) then
            table.insert(stacksToGather, s)
        end
    end

    -- Sort by count, ascending
    table.sort(stacksToGather, function(a, b) return a.count < b.count end)

    -- Gather the items, taking from the smallest stacks first
    for _, s in ipairs(stacksToGather) do
        for itemId, _ in pairs(s.itemIDs) do
            local item = self.inventory:getItemById(itemId)

            if not ItemStack.canAddItem(stack, item) then
                break
            end

            ItemStack.removeItem(s, item)
            ItemStack.addItem(stack, item)

            if s.count == 0 then
                self:_removeStack(s)
            end
        end
    end

    self:_sendModData()
end

function ItemGrid:_insertStack(xPos, yPos, item, isRotated)
    local stack = ItemStack.create(xPos, yPos, isRotated, item:getFullType())
    ItemStack.addItem(stack, item)
    table.insert(self.persistentData.stacks, stack)
    self:_rebuildStackMap()
    self:_sendModData()
end

function ItemGrid:_insertStack_premade(stack, x, y, isRotated)
    stack.x = x
    stack.y = y
    stack.isRotated = isRotated
    stack.inventory = self.inventory

    table.insert(self.persistentData.stacks, stack)
    self:_rebuildStackMap()
    self:_sendModData()
end

function ItemGrid:_removeStack(stack)
    for i, s in ipairs(self.persistentData.stacks) do
        if s == stack then
            table.remove(self.persistentData.stacks, i)
            self:_rebuildStackMap()
            self:_sendModData()
            return
        end
    end
end

function ItemGrid:_isAreaFree(xPos, yPos, w, h, ignoreStack)
    if not self:_isInBounds(xPos, yPos) or not self:_isInBounds(xPos+w-1, yPos+h-1) then
        return false
    end
    
    for x=xPos,xPos+w-1 do
        for y=yPos,yPos+h-1 do
            local stack = self.stackMap[x][y]
            if stack and stack ~= ignoreStack then
                return false
            end
        end
    end
    return true
end

function ItemGrid:_isInBounds(x, y)
    return x >= 0 and x < self.width and y >= 0 and y < self.height
end

function ItemGrid:_isItemInBounds(item, stack)
    local w, h = TetrisItemData.getItemSize(item, stack.isRotated)
    return self:_isInBounds(stack.x, stack.y) and self:_isInBounds(stack.x+w-1, stack.y+h-1)
end

function ItemGrid:_isItemValid(item)
    return not item:isHidden() and not item:isEquipped() and not self:_isItemInHotbar(item)
end

function ItemGrid:_isItemInHotbar(item)
    if not self.isPlayerInventory then
        return false
    end

    local hotbar = getPlayerHotbar(self.playerNum);
    if not hotbar then return false end

    return hotbar:isInHotbar(item)
end

function ItemGrid:canAddItem(item, isRotated)
    if self.inventory:getType() == "floor" then
        return true;
    end

    for _, stack in ipairs(self.persistentData.stacks) do
        if ItemStack.canAddItem(stack, item) then
            return true
        end
    end

    local w, h = TetrisItemData.getItemSize(item, isRotated)
    for x=0,self.width-w do
        for y=0,self.height-h do
            if self:_isAreaFree(x, y, w, h) then
                return true
            end
        end
    end

    return false
end

function ItemGrid:doesItemFit(item, xPos, yPos, isRotated)
    local stack = self:findStackByItem(item)

    local w, h = TetrisItemData.getItemSize(item, isRotated)
    return self:_isAreaFree(xPos, yPos, w, h, stack)
end

function ItemGrid:canItemBeStacked(item, xPos, yPos)
    local stack = self:getStack(xPos, yPos)
    if stack then
        return ItemStack.canAddItem(stack, item)
    end
    return false
end

function ItemGrid:willStackOverlapSelf(stack, newX, newY, isRotated)
    local w, h = TetrisItemData.getItemSize(ItemStack.getFrontItem(stack, self.inventory), isRotated)
    for x=newX, newX+w-1 do
        for y=newY, newY+h-1 do
            if self.stackMap[x][y] == stack then
                return true
            end
        end
    end
    return false
end

function ItemGrid:hasFreeSlot()
    for x=0,self.width-1 do
        for y=0,self.height-1 do
            if not self.stackMap[x][y] then
                return true
            end
        end
    end
    return false
end

function ItemGrid:_attemptToStackItem(item)
    for _, stack in ipairs(self.persistentData.stacks) do
        if ItemStack.canAddItem(stack, item) then
            ItemStack.addItem(stack, item)
            self:_sendModData()
            return true
        end
    end
    return false
end

-- Slightly hacky, but shuffleMode can be nil as well, in which case it will be set to not containerDefinition.isOrganized
function ItemGrid:_attemptToInsertItem(item, preferRotated, shuffleMode)
    preferRotated = preferRotated or false
    
    if shuffleMode == nil then
        shuffleMode = not self.containerDefinition.isOrganized
    end

    if not shuffleMode then
        if self:_attemptToStackItem(item) then
            return true
        end
    end

    local w, h = TetrisItemData.getItemSize(item, preferRotated)
    if self:_attemptToInsertItem_outerLoop(item, w, h, preferRotated, shuffleMode) then
        return true
    end
    if self:_attemptToInsertItem_outerLoop(item, h, w, not preferRotated, shuffleMode) then
        return true
    end
    return false
end

function ItemGrid:_attemptToInsertItem_outerLoop(item, w, h, isRotated, shuffleMode)
    local startY = shuffleMode and ZombRand(0, self.height-h+1) or 0
    local startX = shuffleMode and ZombRand(0, self.width-w+1) or 0
    
    local loopForward = not shuffleMode or ZombRand(0, 2) == 0

    if loopForward then
        for y=0,self.height-h do
            for x=0,self.width-w do
                local xPos = (x + startX) % self.width
                local yPos = (y + startY) % self.height
                if self:_attemptToInsertItem_innerLoop(item, w, h, xPos, yPos, isRotated) then
                    return true
                end
            end
        end
    else
        for y=self.height-h,0,-1 do
            for x=self.width-w,0,-1 do
                local xPos = (x + startX) % self.width
                local yPos = (y + startY) % self.height
                if self:_attemptToInsertItem_innerLoop(item, w, h, xPos, yPos, isRotated) then
                    return true
                end
            end
        end
    end

    return false
end

function ItemGrid:_attemptToInsertItem_innerLoop(item, w, h, xPos, yPos, isRotated)
    local stack = self:getStack(xPos, yPos)
    if stack and ItemStack.canAddItem(stack, item) then
        ItemStack.addItem(stack, item)
        self:_sendModData()
        return true
    end

    if self:_isAreaFree(xPos, yPos, w, h) then
        self:_insertStack(xPos, yPos, item, isRotated)
        self:_sendModData()
        return true
    end
end

function ItemGrid:refresh()
    self:_loadData()
    self:_updateGridPositions(self.firstRefresh or not self.containerDefinition.isOrganized)
    self.firstRefresh = false
end

function ItemGrid:_loadData()
    self.persistentData, self.isoObject = self:_getSavedGridData()
    self:_validateAndCleanStacks(self.persistentData)
    self:_rebuildStackMap()
end

function ItemGrid:_validateAndCleanStacks(persistentGridData)
    if not persistentGridData.stacks then
        persistentGridData.stacks = {}
        return
    end

    local badStacks = {}
    for _,stack in ipairs(persistentGridData.stacks) do
        for itemID, _ in pairs(stack.itemIDs) do
            local item = self.inventory:getItemById(itemID)
            if not item or not self:_isItemValid(item) then
                badStacks[stack] = true
                break
            end
        end
    end

    local validatedStacks = {}
    for _,stack in ipairs(persistentGridData.stacks) do
        if not badStacks[stack] and self:_isInBounds(stack.x, stack.y) then
            table.insert(validatedStacks, stack)
        else
            local newStack = ItemStack.copyWithoutItems(stack)

            for itemID, _ in pairs(stack.itemIDs) do
                local item = self.inventory:getItemById(itemID)
                if item and self:_isItemValid(item) and self:_isItemInBounds(item, newStack) then
                    ItemStack.addItem(newStack, item)
                end
            end

            if newStack.count > 0 then
                table.insert(validatedStacks, newStack)
            end
            self:_sendModData()
        end
    end

    persistentGridData.stacks = validatedStacks
    self:_rebuildStackMap()
end

function ItemGrid:_rebuildStackMap()
    local stackMap = {}
    for x=0, self.width-1 do
        stackMap[x] = {}
    end

    for _,stack in ipairs(self.persistentData.stacks) do
        local item = ItemStack.getFrontItem(stack, self.inventory)
        if item then
            local w, h = TetrisItemData.getItemSize(item, stack.isRotated)
            for x=stack.x,stack.x+w-1 do
                for y=stack.y,stack.y+h-1 do
                    if self:_isInBounds(x, y) then
                        stackMap[x][y] = stack
                    else
                        print("ItemGrid:_rebuildStackMap() - Stack out of bounds: " .. tostring(x) .. ", " .. tostring(y) .. " - " .. tostring(item:getName()))
                    end
                end
            end
        else
            print("ItemGrid:_rebuildStackMap() - Stack has no items: " .. tostring(stack.x) .. ", " .. tostring(stack.y))
        end
    end

    self.stackMap = stackMap
end

function ItemGrid:_updateGridPositions(useShuffle)
    local unpositionedItems = self:_getUnpositionedItems()
    self:_processUnpositionedItems(unpositionedItems, useShuffle)
end

function ItemGrid:_getUnpositionedItems()
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
            if count >= 50 then -- Don't process too many items at once
                break
            end
        end
    end
    return unpositionedItemData
end

function ItemGrid:_getPositionedItems()
    local containerData = self:_getSavedContainerData()

    local positionedItems = {}
    for index, grid in pairs(containerData) do
        if self.containerGrid.grids[index] then
        
            for _, stack in pairs(grid.stacks) do
                for itemID, _ in pairs(stack.itemIDs) do
                    positionedItems[itemID] = true
                end
            end
        end
    end
    return positionedItems
end

function ItemGrid:_processUnpositionedItems(unpositionedItems, useShuffle)    
    local hasStackType = {}
    for _,stack in ipairs(self.persistentData.stacks) do
        local item = ItemStack.getFrontItem(stack, self.inventory)
        hasStackType[item:getFullType()] = true
    end

    -- Try to stack items first, loop backwards so reduce array shuffling
    for i = #unpositionedItems,1,-1 do
        local item = unpositionedItems[i].item
        if hasStackType[item:getFullType()] and self:_attemptToStackItem(item) then
            table.remove(unpositionedItems, i)
        end
    end

    if self:hasFreeSlot() then
        -- Sort the remaining unpositioned items by size, so we can place the biggest ones first
        table.sort(unpositionedItems, function(a, b) return a.size > b.size end)
        for i = 1,#unpositionedItems do
            local item = unpositionedItems[i].item
            if not self:_attemptToInsertItem(item, false, useShuffle) then
                if self.isPlayerInventory then
                    self:_dropUnpositionedItem(item)
                end
            end
        end
    end
end

function ItemGrid:_dropUnpositionedItem(item)
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



function ItemGrid:_getSavedGridData()
    local containerData, parent = self:_getSavedContainerData()

    if not containerData[self.gridIndex] then
        containerData[self.gridIndex] = {}
    end

    return containerData[self.gridIndex], parent
end

function ItemGrid:_getSavedContainerData()
    local modData, parent = self:_getParentModData()
    if not modData.gridContainers then
        modData.gridContainers = {}
    end

    local invType = self.inventory:getType()
    if not modData.gridContainers[invType] then
        modData.gridContainers[invType] = {}
    end

    return modData.gridContainers[invType], parent
end

ItemGrid._floorModData = {} -- No need to save floor grids, but we do allow users to reposition items on the floor temporarily

function ItemGrid:_getParentModData()
    if self.isPlayerInventory then
        return getSpecificPlayer(self.playerNum):getModData()
    end

    if self.inventory:getType() == "floor" then
        return ItemGrid._floorModData
    end

    local item = self.inventory:getContainingItem()
    if item then
        return item:getModData()
    end

    local isoObject = self.inventory:getParent()
    if isoObject then
        return isoObject:getModData(), isoObject
    end

    print("Error: ItemGrid:_getParentModData() An invalid container setup was found. Contact Notloc and tell him what you were doing when this happened.")
    return {} -- Return an empty table so we don't error out
end


ItemGrid._modDataSyncQueue = {}

function ItemGrid:_sendModData()
    if isClient() and self.isoObject then
        ItemGrid._modDataSyncQueue[self.isoObject] = true
    end
end

if isClient() then
    Events.OnTick.Add(function()
        for isoObject,_ in pairs(ItemGrid._modDataSyncQueue) do
            isoObject:transmitModData()
        end
        ItemGrid._modDataSyncQueue = {}
    end)
end