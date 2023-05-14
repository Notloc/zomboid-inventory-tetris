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
