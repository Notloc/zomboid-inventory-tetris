ItemGrid = {}

function ItemGrid:new(containerDefinition, gridIndex, inventory, playerNum)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.containerDefinition = containerDefinition
    o.gridDefinition = containerDefinition.gridDefinitions[gridIndex]
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
        if not ItemStack.canAddItem(stack, item, self.inventory) then 
            return false 
        end
        ItemStack.addItem(stack, item)
        return true
    else
        local w, h = GridItemManager.getItemSize(item, isRotated)
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
                self:_removeStack(stack, item)
            end
            return true
        end
    end
    return false
end

function ItemGrid:moveStack(stack, x, y, isRotated)
    local item = ItemStack.getFrontItem(stack)
    
    local w, h = GridItemManager.getItemSize(item, isRotated)
    if not self:_isAreaFree(x, y, w, h, stack) then
        return false
    end
    
    self:_removeStack(stack, item)
    self:_insertStack_premade(stack, x, y, isRotated)
    
    return true
end

function ItemGrid:gatherSameItems(stack)
    -- Pull all the items from other stacks into this one
    local targetItem = ItemStack.getFrontItem(stack)

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
                self:_removeStack(s, item)
            end
        end
    end
end

function ItemGrid:_insertStack(xPos, yPos, item, isRotated)
    local stack = ItemStack.create(xPos, yPos, isRotated, self.inventory)
    ItemStack.addItem(stack, item)
    table.insert(self.persistentData.stacks, stack)
    local w, h = GridItemManager.getItemSize(item, isRotated)
    self:_updateStackMap(xPos, yPos, w, h, stack)
end

function ItemGrid:_insertStack_premade(stack, x, y, isRotated)
    stack.x = x
    stack.y = y
    stack.isRotated = isRotated
    stack.inventory = self.inventory

    local item = ItemStack.getFrontItem(stack)
    local w, h = GridItemManager.getItemSize(item, isRotated)

    table.insert(self.persistentData.stacks, stack)
    self:_updateStackMap(x, y, w, h, stack)
end

function ItemGrid:_removeStack(stack, item)
    for i, s in ipairs(self.persistentData.stacks) do
        if s == stack then
            table.remove(self.persistentData.stacks, i)
            local w, h = GridItemManager.getItemSize(item, stack.isRotated)
            self:_updateStackMap(stack.x, stack.y, w, h, nil)
            return
        end
    end
end

function ItemGrid:_updateStackMap(xIn, yIn, w, h, val)
    for x=xIn,xIn+w-1 do
        for y=yIn,yIn+h-1 do
            self.stackMap[x][y] = val
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
    return true; -- TODO: uncomment this
    --local w, h = GridItemManager.getItemSize(item, stack.isRotated)
    --return self:_isInBounds(stack.x, stack.y) and self:_isInBounds(stack.x+w-1, stack.y+h-1)
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
        if ItemStack.canAddItem(stack, item, self.inventory) then
            return true
        end
    end

    local w, h = GridItemManager.getItemSize(item, isRotated)
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

    local w, h = GridItemManager.getItemSize(item, isRotated)
    return self:_isAreaFree(xPos, yPos, w, h, stack)
end

function ItemGrid:canItemBeStacked(item, xPos, yPos)
    local stack = self:getStack(xPos, yPos)
    if stack then
        return ItemStack.canAddItem(stack, item, self.inventory)
    end
    return false
end

function ItemGrid:willStackOverlapSelf(stack, newX, newY, isRotated)
    local w, h = GridItemManager.getItemSize(ItemStack.getFrontItem(stack, self.inventory), isRotated)
    for x=newX, newX+w-1 do
        for y=newY, newY+h-1 do
            if self.stackMap[x][y] == stack then
                return true
            end
        end
    end
    return false
end


function ItemGrid:_attemptToStackItem(item)
    for _, stack in ipairs(self.persistentData.stacks) do
        if ItemStack.canAddItem(stack, item, self.inventory) then
            ItemStack.addItem(stack, item)
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

    local w, h = GridItemManager.getItemSize(item, preferRotated)
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
    if stack and ItemStack.canAddItem(stack, item, self.inventory) then
        ItemStack.addItem(stack, item)
        return true
    end

    if self:_isAreaFree(xPos, yPos, w, h) then
        self:_insertStack(xPos, yPos, item, isRotated)
        return true
    end
end

function ItemGrid:refresh()
    local time = getTimestampMs()
    print("REFRESH START")
    self:_loadData()
    self:_updateGridPositions(self.firstRefresh or not self.containerDefinition.isOrganized)
    self.firstRefresh = false
    print("REFRESH END")
    print("REFRESH TIME: "..(getTimestampMs() - time .. "ms"))
end

function ItemGrid:_loadData()
    print("LOAD START")
    local time = getTimestampMs()
    self.persistentData = self:_getSavedData()
    self:_validateAndCleanStacks(self.persistentData)
    self:_rebuildStackMap()
    print("LOAD END")
    print("LOAD TIME: "..(getTimestampMs() - time))
end

function ItemGrid:_validateAndCleanStacks(persistentGridData)
    if not persistentGridData.stacks then
        persistentGridData.stacks = {}
        return
    end

    local itemMap = self:_buildItemMap()
    local validatedStacks = {}
    
    for _,stack in ipairs(persistentGridData.stacks) do
        local newStack = ItemStack.copyWithoutItems(stack, self.inventory)

        for itemID, _ in pairs(stack.itemIDs) do
            local item = itemMap[itemID]
            if item and self:_isItemValid(item) and self:_isItemInBounds(item, newStack) then
                ItemStack.addItem(newStack, item)
            end
        end

        if newStack.count > 0 then
            table.insert(validatedStacks, newStack)
        end
    end

    persistentGridData.stacks = validatedStacks
end

function ItemGrid:_rebuildStackMap()
    local stackMap = {}
    for x=0, self.width-1 do
        stackMap[x] = {}
    end

    for _,stack in ipairs(self.persistentData.stacks) do
        local item = ItemStack.getFrontItem(stack, self.inventory)
        local w, h = GridItemManager.getItemSize(item, stack.isRotated)
        
        for x=stack.x,stack.x+w-1 do
            for y=stack.y,stack.y+h-1 do
                if self:_isInBounds(x, y) then
                    stackMap[x][y] = stack
                else
                    print("ItemGrid:_rebuildStackMap() - Stack out of bounds: " .. tostring(x) .. ", " .. tostring(y) .. " - " .. tostring(item:getName()))
                end
            end
        end
    end

    self.stackMap = stackMap
end

function ItemGrid:_buildItemMap()
    local itemMap = {}
    for i=0,self.inventory:getItems():size()-1 do
        local item = self.inventory:getItems():get(i)
        itemMap[item:getID()] = item
    end
    return itemMap
end

function ItemGrid:_updateGridPositions(useShuffle)
    local unpositionedItems = self:_getUnpositionedItems()
    self:_processUnpositionedItems(unpositionedItems, useShuffle)
end

function ItemGrid:_getUnpositionedItems()
    local positionedItems = self:_getPositionedItems()
    local unpositionedItemData = {}

    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        if not positionedItems[item:getID()] and self:_isItemValid(item) then
            local w, h = GridItemManager.getItemSize(item)
            local size = w * h
            table.insert(unpositionedItemData, {item = item, size = size})
        end
    end
    return unpositionedItemData
end

function ItemGrid:_getPositionedItems()
    local modData = self:_getParentModData()
    if not modData.gridContainers then return {} end

    local grid = modData.gridContainers[self.inventory:getType()]

    local positionedItems = {}
    for _, subGrid in pairs(grid) do
        for _, stack in pairs(subGrid.stacks) do
            for itemID, _ in pairs(stack.itemIDs) do
                positionedItems[itemID] = true
            end
        end
    end
    return positionedItems
end

function ItemGrid:_processUnpositionedItems(unpositionedItems, useShuffle)
    -- Try to stack items first, loop backwards so reduce array shuffling
    for i = #unpositionedItems,1,-1 do
        local item = unpositionedItems[i].item
        if self:_attemptToStackItem(item) then
            table.remove(unpositionedItems, i)
        end
    end

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



function ItemGrid:_getSavedData()
    local modData = self:_getParentModData()
    if not modData.gridContainers then
        modData.gridContainers = {}
    end

    local invType = self.inventory:getType()
    if not modData.gridContainers[invType] then
        modData.gridContainers[invType] = {}
    end

    if not modData.gridContainers[invType][self.gridIndex] then
        modData.gridContainers[invType][self.gridIndex] = {}
    end

    return modData.gridContainers[invType][self.gridIndex]
end

ItemGrid._floorModData = {} -- No need to save floor grids, but lets allow users to reposition items on the floor

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
        return isoObject:getModData()
    end

    print("Error: ItemGrid:_getParentModData() An invalid container setup was found. Contact Notloc and tell him what you were doing when this happened.")
    return {} -- Return an empty table so we don't error out
end
