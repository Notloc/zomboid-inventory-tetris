local GRID_REFRESH_DELAY = 600
local PHYSICS_DELAY = 600

ItemContainerGrid = {}
ItemContainerGrid._tempGrid = {} -- For hovering over items, so we don't create a new grid every frame to evaluate if an item can be placed
ItemContainerGrid._gridCache = {} -- Just created grids, so we don't have to create a new grid multiple times in a single tick

-- TODO: Remove playerNum from this class, it's not actually used unless the grid is for the player's base inventory
-- Thankfully grids are pretty much entirely agnostic to the player interacting with them, so it should be easy to remove or ignore
function ItemContainerGrid:new(inventory, playerNum)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.inventory = inventory
    o.playerNum = playerNum
    o.containerDefinition = TetrisContainerData.getContainerDefinition(inventory)
    o.isPlayerInventory = inventory == getSpecificPlayer(playerNum):getInventory()
    o.isOnPlayer = o.isPlayerInventory or (inventory:getContainingItem() and inventory:getContainingItem():isInPlayerInventory())
    o.grids = o:createGrids(inventory, playerNum)
    o.overflow = {}

    o:refresh()
    return o
end

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

    if invPage.inventoryPane.tetrisWindowManager then
        local window = invPage.inventoryPane.tetrisWindowManager:findWindowByInventory(targetInventory)
        if window then
            return window.gridContainerUi.containerGrid
        end
    end

    return nil
end

ItemContainerGrid.Create = function(inventory, playerNum)
    local containerGrid = ItemContainerGrid.FindInstance(inventory, playerNum)
    if containerGrid then
        return containerGrid
    end

    -- Remove any temp grids that are for this inventory
    for playerN, grid in pairs(ItemContainerGrid._tempGrid) do
        if grid.inventory == inventory then
            ItemContainerGrid._tempGrid[playerN] = nil
        end
    end

    return ItemContainerGrid:new(inventory, playerNum)
end

ItemContainerGrid.CreateTemp = function(inventory, playerNum)
    local containerGrid = ItemContainerGrid.FindInstance(inventory, playerNum)
    if containerGrid then
        return containerGrid
    end

    local existingTempGrid = ItemContainerGrid._tempGrid[playerNum]

    if existingTempGrid and existingTempGrid.inventory == inventory then
        return existingTempGrid
    end

    local tempGrid = ItemContainerGrid:new(inventory, playerNum)
    ItemContainerGrid._tempGrid[playerNum] = tempGrid
    return tempGrid
end

ItemContainerGrid.FindInstance = function(inventory, playerNum)
    if ItemContainerGrid._gridCache[playerNum] then
        for _, grid in ipairs(ItemContainerGrid._gridCache[playerNum]) do
            if grid.inventory == inventory then
                return grid
            end
        end
    end

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

function ItemContainerGrid:doesItemFitAnywhere(item, w, h, ignoreItems)
    local ignoreMap = {}

    for _, grid in ipairs(self.grids) do
        for _, item in ipairs(ignoreItems) do
            local stack = grid:findStackByItem(item)
            if stack then
                ignoreMap[stack] = true
            end
        end
    end

    for _, grid in ipairs(self.grids) do
        if grid:doesItemFitAnywhere(item, w, h, ignoreMap) then
            return true
        end
        if w ~= h and grid:doesItemFitAnywhere(item, h, w, ignoreMap) then
            return true
        end
    end
    return false
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

function ItemContainerGrid:isItemAllowed(item)
    return self:_validateOnlyAcceptCategory(item)
end

function ItemContainerGrid:canAddItem(item)
    if not self:_validateOnlyAcceptCategory(item) then
        return false
    end

    local capacity = self:_getCapacity()
    if item:getContainer() ~= self.inventory and capacity < item:getActualWeight() + self.inventory:getCapacityWeight() then
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
    
    return TetrisContainerData.validateInsert(self.containerDefinition, item)
end

function ItemContainerGrid:refresh()
    local doPhysics = SandboxVars.InventoryTetris.EnableGravity and self:shouldDoPhysics()  
    for _, grid in ipairs(self.grids) do
        grid:refresh(doPhysics)
    end
    self:_updateGridPositions()

    self.lastRefresh = getTimestampMs()
    if doPhysics then
        self.lastPhysics = self.lastRefresh
    end
end

function ItemContainerGrid:shouldRefresh()
    if not self.lastRefresh then
        return true
    end
    local delay = self.isPlayerInventory and 100 or GRID_REFRESH_DELAY -- main inventory is more responsive
    return getTimestampMs() - self.lastRefresh >= delay
end

function ItemContainerGrid:shouldDoPhysics()
    if not self.lastPhysics then
        return true
    end
    return getTimestampMs() - self.lastPhysics >= PHYSICS_DELAY
end

-- isDisoraganized is determined by the player's traits
-- If it is nil, they have no relevant traits and the container itself determines if it is disorganized
function ItemContainerGrid:attemptToInsertItem(item, preferRotated, isOrganized, isDisoraganized)
    for _, grid in ipairs(self.grids) do
        if grid:_attemptToInsertItem(item, preferRotated, isOrganized, isDisoraganized) then
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

function ItemContainerGrid:removeItem(item)
    for _, grid in pairs(self.grids) do
        if grid:removeItem(item) then
            return true
        end
    end
    return false
end

function ItemContainerGrid:autoPositionItem(item, isOrganized, isDisorganized)
    for _, grid in ipairs(self.grids) do
        if grid:removeItem(item) then
            print("ohno")
        end
    end

    for _, grid in ipairs(self.grids) do
        if grid:_attemptToInsertItem(item, false, isOrganized, isDisoraganized) then
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
    if not vanillaStack then return nil end
    return self:findStackByItem(vanillaStack.items[1])
end

function ItemContainerGrid:findStackByItem(item)
    if not item then return nil end
    
    for _, grid in ipairs(self.grids) do
        local gridStack = grid:findStackByItem(item)
        if gridStack then
            return gridStack, grid
        end
    end
    return nil, nil
end


function ItemContainerGrid:_updateGridPositions()
    self.overflow = {}
    local unpositionedItems = self:_getUnpositionedItems()

    local isOrganized = false
    local isDisorganized = false
    if self.isOnPlayer then
        local player = getSpecificPlayer(self.playerNum)
        isOrganized = player:HasTrait("Organized")
        isDisorganized = player:HasTrait("Disorganized")
    end

    -- Sort the unpositioned items by size, so we can place the biggest ones first
    table.sort(unpositionedItems, function(a, b) return a.size < b.size end)
    
    local remainingItems = {}
    local gridCount = #self.grids

    local gridIndex = 1
    for _, item in ipairs(unpositionedItems) do
        gridIndex = self.isOnPlayer and 1 or gridIndex
        local startIndex = gridIndex
        local placedItem = false
        repeat
            local grid = self.grids[gridIndex]
            gridIndex = gridIndex + 1
            if gridIndex > #self.grids then
                gridIndex = 1
            end

            if grid:_acceptUnpositionedItem(item.item, isOrganized, isDisorganized) then
                placedItem = true
                break
            end
        until gridIndex == startIndex

        if not placedItem then
            remainingItems[#remainingItems+1] = item
        end

        gridIndex = (gridIndex + ZombRand(0, gridCount+1)) % (gridCount + 1)
        if gridIndex == 0 then
            gridIndex = 1
        end
    end

    if #remainingItems == 0 then
        return
    end

    for _, unpositionedItemData in ipairs(remainingItems) do
        local item = unpositionedItemData.item
        if not self:_stackIntoOverflow(item) then
            local stack = ItemStack.create(0, 0, false, item:getFullType(), TetrisItemCategory.getCategory(item))
            ItemStack.addItem(stack, item)
            table.insert(self.overflow, stack)
        end
    end

    if self.isOnPlayer then
        local playerObj = getSpecificPlayer(self.playerNum)
        if getPlayerHotbar(self.playerNum) then -- Wait for the hotbar to be initialized
            for _, unpositionedItemData in ipairs(remainingItems) do
                GridAutoDropSystem.queueItemForDrop(unpositionedItemData.item, playerObj)
            end
        end
    end
end

function ItemContainerGrid:_stackIntoOverflow(item)
    for _, stack in ipairs(self.overflow) do
        if ItemStack.canAddItem(stack, item) then
            ItemStack.addItem(stack, item)
            return true
        end
    end
    return false
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
    for playerNum, grid in pairs(ItemContainerGrid._playerMainGrids) do
        local player = getSpecificPlayer(playerNum)
        if not player or player:isDead() then
            ItemContainerGrid._playerMainGrids[playerNum] = nil
        else
            if grid:shouldRefresh() then
                grid:refresh()
            end
        end
    end

    for playerNum, grids in pairs(ItemContainerGrid._gridCache) do
        grids[1] = nil
    end
end)
