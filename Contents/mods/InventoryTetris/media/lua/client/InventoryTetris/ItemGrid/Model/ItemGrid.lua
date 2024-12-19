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
    o.isOnPlayer = o.isPlayerInventory or (inventory:getContainingItem() and inventory:getContainingItem():isInPlayerInventory())
    o.isFloor = inventory:getType() == "floor"

    o.width = o.gridDefinition.size.width + SandboxVars.InventoryTetris.BonusGridSize
    o.height = o.gridDefinition.size.height + SandboxVars.InventoryTetris.BonusGridSize

    o:refresh()
    return o
end

function ItemGrid:getItem(x, y)
    local stack = self:getStack(x, y)
    return stack and ItemStack.getFrontItem(stack, self.inventory) or nil
end

function ItemGrid:getStack(x, y)
    local stack = nil
    if self.stackMap[x] then 
        stack = self.stackMap[x][y] 
    end

    if stack then
        if not self:_validateStackIsSearched(stack, self.playerNum) then
            return nil
        end
    end

    -- if do physics
    if SandboxVars.InventoryTetris.EnableGravity and stack and self:isStackBuried(stack) then
        return nil
    end

    return stack
end

function ItemGrid:getStackInternal(x, y)
    if self.stackMap[x] then 
        return self.stackMap[x][y] 
    end
    return nil
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
    if not self:_isInBounds(xPos, yPos) then
        return false
    end

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
    if not self:_isAreaFree(x, y, w, h, {[stack] = true}) then
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
    local stack = ItemStack.create(xPos, yPos, isRotated, item:getFullType(), TetrisItemCategory.getCategory(item))
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

    for i, s in ipairs(self.overflow) do
        if s == stack then
            table.remove(self.overflow, i)
            return
        end
    end
end

function ItemGrid:_isAreaFree(xPos, yPos, w, h, ignoreStacks)
    if not self:_isInBounds(xPos, yPos) or not self:_isInBounds(xPos+w-1, yPos+h-1) then
        return false
    end
    
    for x=xPos,xPos+w-1 do
        for y=yPos,yPos+h-1 do
            local stack = self.stackMap[x][y]
            if stack and (not ignoreStacks or not ignoreStacks[stack]) then
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

function ItemGrid:canAddItemAt(item, x, y, isRotated)
    local stack = self:getStack(x,y)
    if stack and ItemStack.canAddItem(stack, item) then
        return true
    end

    local w, h = TetrisItemData.getItemSize(item, isRotated)
    return self:_isAreaFree(x, y, w, h)
end

function ItemGrid:doesItemFit(item, xPos, yPos, isRotated)
    local ignoreStack = {[self:findStackByItem(item)] = true}

    local w, h = TetrisItemData.getItemSize(item, isRotated)
    return self:_isAreaFree(xPos, yPos, w, h, ignoreStack)
end

function ItemGrid:doesItemFitAnywhere(item, w, h, ignoreStacks)
    for x=0,self.width-w do
        for y=0,self.height-h do
            if self:_isAreaFree(x, y, w, h, ignoreStacks) then
                return true
            end
        end
    end
    return false
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

function ItemGrid:_attemptToInsertItem(item, preferRotated, isOrganized, isDisorganized)
    preferRotated = preferRotated or false
    
    if not isOrganized then
        isOrganized = self.containerDefinition.isOrganized
    end

    if not isDisorganized or TetrisItemData.isAlwaysStacks(item) then
        if self:_attemptToStackItem(item) then
            return true
        end
    end

    if not self:hasFreeSlot() then
        return false
    end

    if not isOrganized then
        preferRotated = ZombRand(0, 2) == 0
    end

    local w, h = TetrisItemData.getItemSize(item, preferRotated)
    if w == h then
        preferRotated = false
    end

    local useShuffle = not isOrganized
    if self:_attemptToInsertItem_outerLoop(item, w, h, preferRotated, useShuffle) then
        return true
    end
    if self:_attemptToInsertItem_outerLoop(item, h, w, not preferRotated, useShuffle) then
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

function ItemGrid:refresh(doPhysics)
    self.persistentData = self:_getSavedGridData() -- Reload incase the modData has changed from a mp sync
    self:_validateAndCleanStacks(self.persistentData)
    self:_rebuildStackMap(doPhysics)
end

function ItemGrid:_validateAndCleanStacks(persistentGridData)
    if not persistentGridData.stacks then
        persistentGridData.stacks = {}
    end

    persistentGridData.stacks = self:_validateStackList(persistentGridData.stacks)
end

function ItemGrid:_validateStackList(stacks, skipBounds)
    local seenItemIDs = {}
    local badItemIDs = {}
    local badStacks = {}
    for _,stack in ipairs(stacks) do
        for itemID, _ in pairs(stack.itemIDs) do
            if seenItemIDs[itemID] then
                badItemIDs[itemID] = true
                badStacks[stack] = true
            end
            
            local item = self.inventory:getItemById(itemID)
            if not item or not self.containerGrid:_isItemValid(item) then
                badStacks[stack] = true
            end

            seenItemIDs[itemID] = true
        end
    end

    local validatedStacks = {}
    for _,stack in ipairs(stacks) do
        if not badStacks[stack] and (skipBounds or self:_isInBounds(stack.x, stack.y)) then
            table.insert(validatedStacks, stack)
        else
            local newStack = ItemStack.copyWithoutItems(stack)

            for itemID, _ in pairs(stack.itemIDs) do
                local item = self.inventory:getItemById(itemID)
                if not badItemIDs[itemID] and item and self.containerGrid:_isItemValid(item) and self:_isItemInBounds(item, newStack) then
                    ItemStack.addItem(newStack, item)
                end
            end

            if newStack.count > 0 then
                table.insert(validatedStacks, newStack)
            end
            self:_sendModData()
        end
    end

    return validatedStacks
end


function ItemGrid:_rebuildStackMap(doPhysics)
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
    if doPhysics then
        self:physicsUpdate()
    end
end

function ItemGrid:physicsUpdate()
    local processedStacks = {}
    local ignoreMap = {}

    for y=self.height-2, 0, -1 do -- Skip the bottom row because it can't fall
        for x=0, self.width - 1 do
            local stack = self:getStackInternal(x, y)
            ignoreMap[stack] = true

            if stack and not processedStacks[stack] then
                local item = ItemStack.getFrontItem(stack, self.inventory)
                if item then
                    local w, h = TetrisItemData.getItemSize(item, stack.isRotated)                    
                    local canFall = self:_isAreaFree(stack.x, stack.y+1, w, h, ignoreMap)
                    if canFall then
                        self:_physicsFallPreValidated(stack, w, h)
                        self:_sendModData()
                    end
                    processedStacks[stack] = true
                end
            end

            ignoreMap[stack] = nil
        end
    end
end

function ItemGrid:_physicsFallPreValidated(stack, w, h)
    local item = ItemStack.getFrontItem(stack, self.inventory)
    for x=stack.x,stack.x+w-1 do
        for y=stack.y,stack.y+h-1 do
            self.stackMap[x][y] = nil
        end
    end

    stack.y = stack.y + 1
    for x=stack.x,stack.x+w-1 do
        for y=stack.y,stack.y+h-1 do
            self.stackMap[x][y] = stack
        end
    end
end

function ItemGrid:isStackBuried(stack)
    local dragItem = DragAndDrop.getDraggedItem()
    local mouseStack = dragItem and self:findStackByItem(dragItem) or nil

    local item = ItemStack.getFrontItem(stack, self.inventory)
    if item then
        local w, h = TetrisItemData.getItemSize(item, stack.isRotated)
        for x=stack.x,stack.x+w-1 do
            if self:_isInBounds(x, stack.y-1) then 
                local otherStack = self.stackMap[x][stack.y-1]
                if otherStack and mouseStack ~= otherStack then
                    return true
                end
            end
        end
    end
    return false
end

-- TODO: Either remove this method or make it batch several items at once with minimal checks
function ItemGrid:_acceptUnpositionedItem(item, isOrganized, isDisorganized)    
    return self:_attemptToInsertItem(item, false, isOrganized, isDisoraganized)
end

function ItemGrid:isEmpty()
    return #self.persistentData.stacks == 0
end



function ItemGrid:isUnsearched(playerNum)
    if not SandboxVars.InventoryTetris.EnableSearch then
        return false
    end

    if self.isPlayerInventory or self.isFloor then
        return false
    end

    local uuid = self._getPlayerUUID(playerNum)

    if not self.persistentData.searchLog then
        self.persistentData.searchLog = {}
    end

    return not self.persistentData.searchLog[uuid]
end





-- Searches are not saved, they are kept in memory only
-- Only completion of a search is saved
ItemGrid._searchSessions = {}

function ItemGrid._getSearchSession(playerNum, grid)
    if not ItemGrid._searchSessions[playerNum] then
        ItemGrid._searchSessions[playerNum] = {}
    end

    if not ItemGrid._searchSessions[playerNum][grid.inventory] then
        return nil
    end

    return ItemGrid._searchSessions[playerNum][grid.inventory][grid.gridIndex]
end

function ItemGrid._getOrCreateSearchSession(playerNum, grid)
    local existingSession = ItemGrid._getSearchSession(playerNum, grid)
    if existingSession then
        return existingSession
    end

    local sessions = ItemGrid._searchSessions[playerNum]
    if not sessions[grid.inventory] then
        sessions[grid.inventory] = {}
    end

    sessions[grid.inventory][grid.gridIndex] = ItemGrid._createSearchSession(grid)
    table.insert(sessions, sessions[grid.inventory][grid.gridIndex])

    if #sessions > 10 then
        local session = sessions[1]
        table.remove(sessions, 1)
        sessions[session.inventory] = nil
    end

    return sessions[grid.inventory][grid.gridIndex]
end

function ItemGrid._createSearchSession(grid)
    local session = {}
    session.inventory = grid.inventory
    session.gridIndex = grid.gridIndex
    session.isGridRevealed = false
    session.searchedStackIDs = {}
    session.progressTicks = 0
    return session
end

function ItemGrid:getSearchSession(playerNum)
    return ItemGrid._getSearchSession(playerNum, self)
end

function ItemGrid:updateSearch(player, playerNum)
    local session = ItemGrid._getOrCreateSearchSession(playerNum, self)

    if self:isEmpty() then
        session.isGridRevealed = true
        return true
    end

    local searchTime = SandboxVars.InventoryTetris.SearchTime
    if player:HasTrait("AllThumbs") then
        searchTime = searchTime * 1.5
    elseif player:HasTrait("Dextrous") then
        searchTime = searchTime * 0.66
    end

    
    local progressTicks = session.progressTicks + 1

    if not session.isGridRevealed and progressTicks >= (searchTime * 2) then
        progressTicks = progressTicks - (searchTime * 2)
        session.isGridRevealed = true
    end

    if not session.isGridRevealed then
        session.progressTicks = progressTicks
        return false
    end

    local stacks = self:getStacks()
    local i = 1
    while progressTicks >= searchTime do
        if i > #stacks then
            break
        end

        while i <= #stacks do
            local stack = stacks[i]
            i = i + 1
            
            local frontItem = ItemStack.getFrontItem(stack, self.inventory)
            local frontItemID = frontItem and frontItem:getID() or nil
            if frontItemID and not session.searchedStackIDs[frontItemID] then
                session.searchedStackIDs[frontItemID] = true
                progressTicks = progressTicks - searchTime
                break
            end
        end
    end

    local allSearched = true

    for j=i, #stacks do
        local stack = stacks[j]
        local frontItem = ItemStack.getFrontItem(stack, self.inventory)
        local frontItemID = frontItem and frontItem:getID() or nil
        if frontItemID and not session.searchedStackIDs[frontItemID] then
            allSearched = false
            break
        end
    end

    session.progressTicks = progressTicks
    return allSearched
end

function ItemGrid:completeSearch(playerNum)
    if not self:isUnsearched(playerNum) then
        return
    end

    local uuid = self._getPlayerUUID(playerNum)
    if not self.persistentData.searchLog then
        self.persistentData.searchLog = {}
    end

    self.persistentData.searchLog[uuid] = true
    self:_sendModData()
end


function ItemGrid:_validateStackIsSearched(stack, playerNum)
    if not self:isUnsearched(playerNum) then
        return true
    end

    local frontItem = ItemStack.getFrontItem(stack, self.inventory)
    local frontItemID = frontItem and frontItem:getID() or nil
    if not frontItemID then
        return false
    end

    local session = ItemGrid._getSearchSession(playerNum, self)
    return session and session.searchedStackIDs[frontItemID]
end

function ItemGrid:resetGridData()
    self:_getSavedContainerData()[self.gridIndex] = {}
    self:refresh()
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
ItemGrid._proxData = {} -- Proximity inventory mod support, acts the same as floor grids

function ItemGrid:_getParentModData()
    if self.isPlayerInventory then
        local player = getSpecificPlayer(self.playerNum)
        return player:getModData(), player
    end

    if self.inventory:getType() == "floor" then
        return ItemGrid._floorModData, nil
    end

    if self.inventory:getType() == "local" then
        return ItemGrid._proxData, nil
    end

    local itemContainer = self.inventory:getContainingItem()
    if itemContainer then
        return TetrisClient.getInventoryContainerModData(itemContainer)
    end

    local isoObject = self.inventory:getParent()
    if isoObject then
        if instanceof(isoObject, "BaseVehicle") then
            return TetrisClient.getVehicleModData(isoObject)
        end

        return isoObject:getModData(), isoObject
    end

    print("Error: ItemGrid:_getParentModData() An invalid container setup was found. Data will not be saved.")
    return {} -- Return an empty table so we don't error out
end

local TETRIS_UUID = "TetrisUUID"
function ItemGrid._getPlayerUUID(playerNum)
    local player = getSpecificPlayer(playerNum)
    
    local uuid = player:getModData()[TETRIS_UUID]
    if not uuid then
        uuid = getRandomUUID()
        player:getModData()[TETRIS_UUID] = uuid
        TetrisClient.queueModDataSync(player)
    end

    return uuid
end

function ItemGrid:_sendModData()
    if isClient() then
        local _, parent = self:_getParentModData()
        if parent then
            TetrisClient.queueModDataSync(parent)
        end
    end
end
