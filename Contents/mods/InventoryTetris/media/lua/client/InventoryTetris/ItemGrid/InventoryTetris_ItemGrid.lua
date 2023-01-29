ItemGrid = {}

function ItemGrid.CreateGrids(inventory, playerNum)
    local gridType = getGridContainerTypeByInventory(inventory)
    local gridDefinition = getGridDefinitionByContainerType(gridType)
    
    local grids = {}
    for index, definition in ipairs(gridDefinition) do
        local grid = ItemGrid:new(definition, index, inventory, playerNum)
        grids[index] = grid
    end
    return grids, gridType
end

function ItemGrid:new(gridDefinition, gridIndex, inventory, playerNum)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.gridDefinition = gridDefinition
    o.gridIndex = gridIndex
    o.inventory = inventory
    o.playerNum = playerNum

    o.width = gridDefinition.size.width
    o.height = gridDefinition.size.height
    o.gridIsOverflowing = false
    o.dataGrid = o:createDataGrid(o.width, o.height)
    
    if inventory:getType() == "floor" then
        o:redoGridPositions()
    else
        o:refreshGrid()
    end

    return o
end

-- Returns a 2D array of booleans, where true means the cell is occupied
function ItemGrid:createDataGrid(width, height)
    local dataGrid = {}

    -- Fill the grid with false
    for y = 0,height-1 do
        dataGrid[y] = {}
        for x = 0,width-1 do
            dataGrid[y][x] = -1
        end
    end

    -- Mark the cells occupied by items
    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y, index = ItemGridUtil.getItemPosition(item)
        if index == self.gridIndex and x and y then
            local w, h = ItemGridUtil.getItemSize(item)
            for y2 = y,y+h-1 do
                for x2 = x,x+w-1 do
                    if self:isInBounds(x2, y2) then
                        dataGrid[y2][x2] = item:getID()
                    end
                end
            end
        end
    end

    return dataGrid
end

function ItemGrid:getUnpositionedItems()
    local unpositionedItemData = {}

    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y, i = ItemGridUtil.getItemPosition(item)
        if not x or not y or not i then
            local w, h = ItemGridUtil.getItemSize(item)
            local size = w * h
            table.insert(unpositionedItemData, {item = item, size = size})
        end
    end

    return unpositionedItemData
end

function ItemGrid:isInBounds(x, y)
    return x >= 0 and x < self.width and y >= 0 and y < self.height
end

function ItemGrid:removeItemFromGrid(item)
    local x, y = ItemGridUtil.getItemPosition(item)
    if x and y then
        local w, h = ItemGridUtil.getItemSize(item)
        for y2 = y,y+h-1 do
            for x2 = x,x+w-1 do
                if self:isInBounds(x2, y2) then
                    self.dataGrid[y2][x2] = -1
                end
            end
        end
    end
    ItemGridUtil.clearItemPosition(item)
end

function ItemGrid:attemptToInsertItemIntoGrid(item)
    local x, y = self:findPositionForItem(item)
    if x >= 0 and y >= 0 then
        self:insertItemIntoGrid(item, x, y)
        return true
    end
    return false
end

-- Insert the item into the grid, no checks
function ItemGrid:insertItemIntoGrid(item, xPos, yPos) 
    if item:isHidden() then
        return
    end

    ItemGridUtil.setItemPosition(item, xPos, yPos, self.gridIndex)
    local w, h = ItemGridUtil.getItemSize(item)
    for y = yPos, yPos+h-1 do
        for x = xPos, xPos+w-1 do
            if self:isInBounds(x, y) then
                self.dataGrid[y][x] = item:getID()
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
            if self.dataGrid[y][x] ~= -1 and self.dataGrid[y][x] ~= item:getID() then
                return false
            end
        end
    end
    return true
end

function ItemGrid:getEquippedItemsMap()
    local playerObj = getSpecificPlayer(self.playerNum)
    local isEquipped = {}
    if self.inventory == playerObj:getInventory() then
        local wornItems = playerObj:getWornItems()
        for i=1,wornItems:size() do
            local wornItem = wornItems:get(i-1):getItem()
            isEquipped[wornItem] = true
        end
        local item = playerObj:getPrimaryHandItem()
        if item then
            isEquipped[item] = true
        end
        item = playerObj:getSecondaryHandItem()
        if item then
            isEquipped[item] = true
        end
    end
    return isEquipped
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
    self:refreshGrid()
end

function ItemGrid:refreshGrid()
    self:clearGrid()
    self:updateGridPositions()
end

function ItemGrid:clearGrid()
    local items = self.inventory:getItems();
    for y = 0, self.height-1 do
        for x = 0, self.width-1 do
            self.dataGrid[y][x] = -1
        end
    end
end

function ItemGrid:updateGridPositions()
    self.gridIsOverflowing = false

    local isEquippedMap = self:getEquippedItemsMap()

    -- Clear the positions of all equipped items
    --for item,_ in pairs(isEquippedMap) do
    --    ItemGridUtil.clearItemPosition(item)
    --end
    
    for i = 0, self.inventory:getItems():size()-1 do
        local item = self.inventory:getItems():get(i);
        if item:isHidden() then
            ItemGridUtil.clearItemPosition(item)
        else
            local x, y, gridIndex = ItemGridUtil.getItemPosition(item)
            if gridIndex == self.gridIndex then
                if x and y then
                    self:insertItemIntoGrid(item, x, y)
                else
                    self:attemptToInsertItemIntoGrid(item)
                end
            end
        end
    end


    local unpositionedItems = self:getUnpositionedItems()
    
    -- Sort the unpositioned items by size, so we can place the biggest ones first
    table.sort(unpositionedItems, function(a, b) return a.size > b.size end)

    -- Place the unpositioned items
    for i = 1,#unpositionedItems do
        local item = unpositionedItems[i].item
        if not self:attemptToInsertItemIntoGrid(item) then
            self.gridIsOverflowing = true
            self:insertItemIntoGrid(item, 0,0)
        end
    end

    -- In the event that we can't fit an item, we put the inventory in to "overflow" mode
    -- where items are placed in the top left corner, the grid turns red, and new items can't be placed
end
