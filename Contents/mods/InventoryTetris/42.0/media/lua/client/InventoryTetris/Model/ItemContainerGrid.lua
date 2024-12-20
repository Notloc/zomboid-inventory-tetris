-- Represents a collection of many grids that all belong to the same container object
-- Also statically caches grids for performance reasons (Grids get rebuilt entirely every few frames because we have no trusted events to know when the inventory changes)

local GRID_REFRESH_DELAY = 600
local PHYSICS_DELAY = 600

---@class ItemContainerGrid
---@field inventory ItemContainer
---@field playerNum number
---@field containerDefinition ContainerGridDefinition
---@field isPlayerInventory boolean
---@field isOnPlayer boolean
---@field grids ItemGrid[]
---@field overflow ItemStack[]
---@field secondaryGrids table
---@field _onSecondaryGridsAdded table
---@field _onSecondaryGridsRemoved table
---@field disableSecondaryGrids boolean
ItemContainerGrid = {}

ItemContainerGrid._tempGrid = {} -- For hovering over container items, so we don't create a new grid every frame to evaluate if an item can be placed into a hovered backpack
ItemContainerGrid._gridCache = {} -- Just created grids, so we don't end up creating a new grid multiple times in a single tick when looping or something

function ItemContainerGrid:new(inventory, playerNum, definitionOverride)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.inventory = inventory
    o.playerNum = playerNum
    o.containerDefinition = definitionOverride or TetrisContainerData.getContainerDefinition(inventory)
    o.isPlayerInventory = inventory == getSpecificPlayer(playerNum):getInventory()
    o.isOnPlayer = o.isPlayerInventory or (inventory:getContainingItem() and inventory:getContainingItem():isInPlayerInventory())
    o.grids = o:createGrids(inventory)
    o.overflow = {}
    
    o.secondaryGrids = {}
    o._onSecondaryGridsAdded = {}
    o._onSecondaryGridsRemoved = {}

    o.disableSecondaryGrids = definitionOverride or not o.isPlayerInventory

    if not o.disableSecondaryGrids then
        o.player = getSpecificPlayer(playerNum)

        local _self = o
        _self._onClothingUpdated = function(player)
            if _self.player ~= player then
                return
            end
            if _self.player:isDead() then
                Events.OnClothingUpdated.Remove(_self._onClothingUpdated)
                return
            end
            _self:refreshSecondaryGrids()
        end
        Events.OnClothingUpdated.Add(o._onClothingUpdated)
    else
        o:refresh() -- Don't refresh the player's main inventory before we register our secondary grids or the main pocket might claim items that are supposed to go into the secondary grids
    end

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


-- TODO: Rename this to GetOrCreate, as it's not guaranteed to create a new container grid
---@return ItemContainerGrid
function ItemContainerGrid.GetOrCreate(inventory, playerNum, containerDefOverride)
    if not containerDefOverride then

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
    end

    local containerGrid = ItemContainerGrid:new(inventory, playerNum, containerDefOverride)

    if not containerDefOverride then
        ItemContainerGrid._gridCache[playerNum] = ItemContainerGrid._gridCache[playerNum] or {}
        table.insert(ItemContainerGrid._gridCache[playerNum], containerGrid)
    end
    return containerGrid
end

---@return ItemContainerGrid
function ItemContainerGrid.CreateTemp(inventory, playerNum)
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

---@return ItemContainerGrid?
function ItemContainerGrid.FindInstance(inventory, playerNum)
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

function ItemContainerGrid:createGrids(container)
    local grids = {}
    for index, gridDef in ipairs(self.containerDefinition.gridDefinitions) do
        local grid = ItemGrid:new(self, index, container, self.containerDefinition, gridDef, self.isPlayerInventory)
        grids[index] = grid
    end
    return grids
end

function ItemContainerGrid:createSecondaryGrids(target)
    local containerDef = TetrisContainerData.getPocketDefinition(target)
    local grids = {}
    if not containerDef then
        return grids
    end

    for index, gridDef in ipairs(containerDef.gridDefinitions) do
        local grid = ItemGrid:new(self, index, self.inventory, containerDef, gridDef, true, target)
        grids[index] = grid
    end
    return grids
end

function ItemContainerGrid:isOrganized()
    return self.containerDefinition.isOrganized
end

--- Check if any grids are unsearched
function ItemContainerGrid:areAnyUnsearched()
    for _, grid in ipairs(self.grids) do
        if grid:isUnsearched(self.playerNum) then 
            return true 
        end
    end
    return false
end

--- Perform search on all unsearched
function ItemContainerGrid:searchAll()
    local player = getSpecificPlayer(self.playerNum)
    for _, grid in ipairs(self.grids) do
        if grid:isUnsearched(self.playerNum) then 
            ISTimedActionQueue.add(SearchGridAction:new(player, grid))
        end
    end

    -- Intentionally ignore secondary grids, as they only exist for worn items which are not searched
end

function ItemContainerGrid:getSpecificGrid(index, secondaryTarget)
    local grids = secondaryTarget and self.secondaryGrids[secondaryTarget] or self.grids
    return grids[index]
end

function ItemContainerGrid:doesItemFit(item, gridX, gridY, gridIndex, rotate, secondaryTarget)
    local grid = self:getSpecificGrid(gridIndex, secondaryTarget)
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

    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            for _, item in ipairs(ignoreItems) do
                local stack = grid:findStackByItem(item)
                if stack then
                    ignoreMap[stack] = true
                end
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

    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            if grid:doesItemFitAnywhere(item, w, h, ignoreMap) then
                return true
            end
            if w ~= h and grid:doesItemFitAnywhere(item, h, w, ignoreMap) then
                return true
            end
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

---@return boolean
function ItemContainerGrid:isItemAllowed(item)
    return self:_validateOnlyAcceptCategory(item)
end

---@return boolean
function ItemContainerGrid:canAddItem(item)
    if not self:_validateOnlyAcceptCategory(item) then
        return false
    end

    local capacity = self:_getCapacity()
    if self.containerDefinition.isFragile and item:getContainer() ~= self.inventory and capacity < item:getActualWeight() + self.inventory:getCapacityWeight() then
        return false
    end

    for _, grid in ipairs(self.grids) do
        if grid:canAddItem(item, false) or grid:canAddItem(item, true) then
            return true
        end
    end

    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            if grid:canAddItem(item, false) or grid:canAddItem(item, true) then
                return true
            end
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

    return TetrisContainerData.validateInsert(self.inventory, self.containerDefinition, item)
end

function ItemContainerGrid:refresh()
    local doPhysics = SandboxVars.InventoryTetris.EnableGravity and self:shouldDoPhysics()  
    for _, grid in ipairs(self.grids) do
        grid:refresh(doPhysics)
    end
    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            grid:refresh(doPhysics)
        end
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

function ItemContainerGrid:attemptToInsertItem(item, preferRotated, isOrganized, isDisoraganized)
    for _, grid in ipairs(self.grids) do
        if grid:_attemptToInsertItem(item, preferRotated, isOrganized, isDisoraganized) then
            return true
        end
    end
    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            if grid:_attemptToInsertItem(item, preferRotated, isOrganized, isDisoraganized) then
                return true
            end
        end
    end
    return false
end

function ItemContainerGrid:insertItem(item, gridX, gridY, gridIndex, isRotated, secondaryTarget)
    local grid = self:getSpecificGrid(gridIndex, secondaryTarget)
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
    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            if grid:removeItem(item) then
                return true
            end
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
    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            if grid:removeItem(item) then
                print("ohno")
            end
        end
    end

    for _, grid in ipairs(self.grids) do
        if grid:_attemptToInsertItem(item, false, isOrganized, isDisorganized) then
            return true
        end
    end
    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            if grid:_attemptToInsertItem(item, false, isOrganized, isDisorganized) then
                return true
            end
        end
    end
    return false
end

-- TODO: Fix secondary grid insertion
function ItemContainerGrid:canItemBeStacked(item, xPos, yPos, gridIndex, secondaryTarget)
    local grid = self:getSpecificGrid(gridIndex, secondaryTarget)
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
    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            local gridStack = grid:findStackByItem(item)
            if gridStack then
                return gridStack, grid
            end
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

    local allGrids = {}
    for _, grid in ipairs(self.grids) do
        allGrids[#allGrids+1] = grid
    end
    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            allGrids[#allGrids+1] = grid
        end
    end

    local gridCount = #allGrids

    local remainingItems = {}
    local gridIndex = 1
    for _, item in ipairs(unpositionedItems) do
        gridIndex = self.isOnPlayer and 1 or gridIndex
        local startIndex = gridIndex
        local placedItem = false
        repeat
            local grid = allGrids[gridIndex]
            gridIndex = gridIndex + 1
            if gridIndex > #allGrids then
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

    for _, grids in pairs(self.secondaryGrids) do
        for _, grid in ipairs(grids) do
            local gridData = grid:_getSavedGridData()
            for _, stack in pairs(gridData.stacks) do
                for itemID, _ in pairs(stack.itemIDs) do
                    positionedItems[itemID] = true
                end
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


function ItemContainerGrid:refreshSecondaryGrids(forceFull)
    if self.disableSecondaryGrids then
        return
    end

    local items = self:getWornItemsWithPockets()

    for target, _ in pairs(self.secondaryGrids) do
        if not items[target] or forceFull then
            self:removeSecondaryGrid(target)
        end
    end

    for item, _ in pairs(items) do
        if not self.secondaryGrids[item] then
            self:addSecondaryGrid(item)
        end
    end
end

function ItemContainerGrid:getWornItemsWithPockets()
    local player = getSpecificPlayer(self.playerNum)
    local wornItems = player:getWornItems()

    local items = {}
    for i=0, wornItems:size()-1 do
        local item = wornItems:get(i):getItem()
        if self:_hasPockets(item) then
            items[item] = true
        end
    end
    return items
end

function ItemContainerGrid:_hasPockets(item)
    return not item:isHidden() and TetrisContainerData.getPocketDefinition(item) ~= nil
end

function ItemContainerGrid:addOnSecondaryGridsAdded(obj, callback)
    self._onSecondaryGridsAdded[obj] = callback
end

function ItemContainerGrid:removeOnSecondaryGridsAdded(obj)
    self._onSecondaryGridsAdded[obj] = nil
end

function ItemContainerGrid:addOnSecondaryGridsRemoved(obj, callback)
    self._onSecondaryGridsRemoved[obj] = callback
end

function ItemContainerGrid:removeOnSecondaryGridsRemoved(obj)
    self._onSecondaryGridsRemoved[obj] = nil
end

function ItemContainerGrid:addSecondaryGrid(secondaryTarget)
    local grids = self:createSecondaryGrids(secondaryTarget)
    self.secondaryGrids[secondaryTarget] = grids
    for obj, callback in pairs(self._onSecondaryGridsAdded) do
        callback(obj, secondaryTarget, grids)
    end
end

function ItemContainerGrid:removeSecondaryGrid(secondaryTarget)
    local grids = self.secondaryGrids[secondaryTarget]
    for _, grid in ipairs(grids) do
        grid:deleteGridData()
    end

    self.secondaryGrids[secondaryTarget] = nil
    for obj, callback in pairs(self._onSecondaryGridsRemoved) do
        callback(obj, secondaryTarget)
    end
end

-- Keep the player's main inventory grid refreshed, so it drops unpositioned items even if the ui isn't open
Events.OnTick.Add(function()
    for playerNum, grid in pairs(ItemContainerGrid._playerMainGrids) do
        local player = getSpecificPlayer(playerNum)
        if not player or player:isDead() or player:isNPC() then
            ItemContainerGrid._playerMainGrids[playerNum] = nil
        else
            if grid:shouldRefresh() then
                grid:refresh()
            end
        end
    end

    for playerNum, grids in pairs(ItemContainerGrid._gridCache) do
        table.wipe(grids)
    end
end)
