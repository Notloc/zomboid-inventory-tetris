ItemGrid = {}

function ItemGridNew:new(gridDefinition, gridIndex, inventory, playerNum)
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
    o:_prepareData(o.width, o.height)
    
    if inventory:getType() == "floor" then
        o:redoGridPositions()
    else
        o:refresh()
    end

    return o
end

function ItemGridNew:_prepareData(width, height)
    local persistentData = self:_getSavedData()
    self:_validateAndCleanStacks(persistentData)
    self:_rebuildStackMap()
    self.persistentData = persistentData
end

function ItemGridNew:_validateAndCleanStacks(persistentGridData)
    if not persistentGridData.stacks then
        persistentGridData.stacks = {}
        return
    end

    local itemMap = self:_buildItemMap()
    local validatedStacks = {}
    
    for _,stack in ipairs(persistentGridData.stacks) do
        local newStack = ItemStackNew.copyWithoutItems(stack)

        for itemID, _ in pairs(stack.items) do
            local item = itemMap[itemID]
            if item then
                ItemStackNew.addItem(newStack, item)
            end
        end

        if stack.count > 0 then
            table.insert(validatedStacks, newStack)
        end
    end

    persistentGridData.stacks = validatedStacks
end

function ItemGridNew:_rebuildStackMap()
    local stackMap = {}
    for 0, width-1 do
        stackMap[x] = {}
        -- No need to initialize y thanks to lua tables
    end

    for _,stack in ipairs(gridData.stacks) do
        local item = ItemStackNew.getFrontItem(stack)
        local w, h = ItemGridUtil.getItemSize(item, stack.isRotated)
        
        for x=stack.x,stack.x+w-1 do
            for y=stack.y,stack.y+h-1 do
                stackMap[x][y] = stack
            end
        end
    end

    self.stackMap = stackMap
end

function ItemGridNew:_buildItemMap()
    local itemMap = {}
    for i=0,self.inventory:getItems():size()-1 do
        local item = self.inventory:getItems():get(i)
        itemMap[item:getID()] = item
    end
    return itemMap
end



function ItemGridNew:getItem(x, y)
    local stack = self.stackMap[x][y]
    if stack then
        return ItemStackNew.getFrontItem(stack)
    end
    return nil
end

function ItemGridNew:getStack(x, y)
    return self.stackMap[x][y]
end

function ItemGridNew:insertItem(item, xPos, yPos, rotate)
    local stack = self.stackMap[xPos][yPos]
    if stack then
        if not ItemStackNew.canAddItem(stack, item) then 
            return false 
        end
        ItemStackNew.addItem(stack, item)
        return true
    else
        local w, h = ItemGridUtil.getItemSize(item, rotate)
        if not self:_isAreaFree(xPos, yPos, w, h) then
            return false
        end
        self:_insertStack(xPos, yPos, item, rotate)
end

function ItemGridNew:removeItem(item)
    for _, stack in ipairs(self.persistentData.stacks) do
        if ItemStackNew.containsItem(stack, item) then
            ItemStackNew.removeItem(stack, item)
            if stack.count == 0 then
                self:removeStackFromGrid(stack)
            end
            return true
        end
    end
    return false
end

function ItemGridNew:_insertStack(xPos, yPos, item, rotate)
    local stack = ItemStackNew.create(xPos, yPos, rotate)
    ItemStackNew.addItem(stack, item)
    table.insert(self.persistentData.stacks, stack)
    self:_rebuildStackMap()
end

function ItemGridNew:_removeStack(stack)
    for i, s in ipairs(self.persistentData.stacks) do
        if s == stack then
            table.remove(self.persistentData.stacks, i)
            self:_rebuildStackMap()
            return
        end
    end
end

function ItemGridNew:_isAreaFree(xPos, yPos, w, h)
    for x=xPos,xPos+w-1 do
        for y=yPos,yPos+h-1 do
            if not self:_isInBounds(x, y) or self.stackMap[x][y] then
                return false
            end
        end
    end
    return true
end

function ItemGridNew:_isInBounds(x, y)
    return x >= 0 and x < self.width and y >= 0 and y < self.height
end


function ItemGridNew:canAddItem(item)
    error("Not implemented")
end

function ItemGridNew:findPositionForItem(item, isRotationAttempt)
    error("Not implemented")
end

function ItemGridNew:doesItemFit(item, xPos, yPos, rotate)
    error("Not implemented")
end

function ItemGridNew:doesItemFit_WH(item, xPos, yPos, w, h)
    error("Not implemented")
end

function ItemGridNew:canItemBeStacked(item, xPos, yPos)
    error("Not implemented")
end

function ItemGridNew:attemptToStackItem(item)
    error("Not implemented")
end

function ItemGridNew:willItemOverlapSelf(item, newX, newY)
    error("Not implemented")
end

function ItemGridNew:redoGridPositions()
    error("Not implemented")
end

function ItemGridNew:refresh()
    error("Not implemented")
end

function ItemGridNew:clearGrid()
    error("Not implemented")
end

function ItemGridNew:updateGridPositions()
    error("Not implemented")
end

function ItemGridNew:getHotbarItemsMap()
    error("Not implemented")
end

function ItemGridNew:claimUnpositionedItems()
    error("Not implemented")
end

function ItemGridNew:dropUnpositionedItem(item)
    error("Not implemented")
end

function ItemGridNew:getUnpositionedItems()
    error("Not implemented")
end



















function ItemGridNew:_getSavedData()
    local modData = self:_getActualModData()
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

-- Returns the mod data for the owning object
function ItemGridNew:_getActualModData()
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

        print("Error: this code should never be reached. ItemGridNew:_getActualModData().")
        print("Whatever this is, it's not a valid container.")
        return {} -- Return an empty table so we don't error out
    end
end
