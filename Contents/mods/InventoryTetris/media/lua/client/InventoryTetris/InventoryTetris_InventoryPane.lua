require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISMouseDrag"
require "TimedActions/ISTimedActionQueue"
require "TimedActions/ISEatFoodAction"
require "ISUI/ISInventoryPane"

local X_POS = "invt_x"
local Y_POS = "invt_y"
local IS_ROTATED = "invt_rotated"

-- Consider a nil inventory as a ground container as well
-- This way the base game can code gets to deal with that and our code gets to assume inventroy is never nil
-- (Which might already be the case, but I'm not certain)
local function isGroundContainer(inventoryPane)
    return not inventoryPane.inventory or inventoryPane.inventory:getType() == 'floor'
end

-- Returns RGB values for a color based on the item's type
local function getItemBackgroundColor(item)
    local itemType = item:getDisplayCategory()
    if itemType == "Ammo" then
        return 0.5, 0.5, 0.5
    elseif itemType == "Weapon" then
        return 0.8, 0.2, 0.2
    elseif itemType == "Clothing" then
        return 0.8, 0.8, 0.1
    elseif itemType == "Food" then
        return 0.1, 0.7, 0.9
    elseif itemType == "Medical" then
        return 0.1, 0.7, 0.9
    else
        return 0.5, 0.5, 0.5
    end
end

local og_prerender = ISInventoryPane.prerender
function ISInventoryPane:prerender()
    self.mode = isGroundContainer(self) and "details" or "grid"
    if self.mode == "gridz" then
        self:renderBackGrid();
    end
    og_prerender(self);
end

local og_render = ISInventoryPane.render
function ISInventoryPane:render()
    if self.mode == "gridz" then
        self:renderGridItems()
        return
    end
    og_render(self)
end

local og_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
    og_refreshContainer(self)
    if self.mode == "gridz" then
        self:updateGridPositions()
    end
end


local cellSize = 48
local width = 8
local height = 8

function ISInventoryPane:renderBackGrid()
    local g = 1
    local b = 1
    
    if self.gridIsOverflowing then
        g = 0
        b = 0
    end
    
    self:drawRect(0, 0, cellSize * width, cellSize * height, 0.9, 0, 0, 0)

    for y = 0,height-1 do
        for x = 0,width-1 do
            self:drawRectBorder(cellSize * x, cellSize * y, cellSize, cellSize, 0.25, 1, g, b)
        end
    end

    --self:drawText("YO", 20, 20, 1, 1, 1, 0.5, UIFont.Small);
end

function ISInventoryPane:renderGridItems()
    local items = self.inventory:getItems();

    self:redoGridPositions(items) -- Temp code to fix the grid positions until we get things updating properly when items are added/removed

    local iconWidth = 40;
    local iconHeight = 40;

    local xPad = 4;
    local yPad = 4;

    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y = ItemGridUtil.getItemPosition(item)
        local w, h = ItemGridUtil.getItemSize(item)

        if x and y then

            local minDimension = math.min(w, h)

            self:drawRect(x * cellSize, y * cellSize, w * cellSize, h * cellSize, 0.8, getItemBackgroundColor(item))
            self:drawRectBorder(x * cellSize, y * cellSize, w * cellSize, h * cellSize, 1, 0, 1, 1)
            


            local x2 = x * cellSize + xPad * w + (w - minDimension) * cellSize / 2
            local y2 = y * cellSize + yPad * h + (h - minDimension) * cellSize / 2
            
            self:drawTextureScaled(item:getTex(), x2, y2, iconWidth * minDimension, iconHeight * minDimension, 1, 1, 1, 1);
        end
    end
end

function ISInventoryPane:redoGridPositions(items)
    for i = 0, items:size()-1 do
        local item = items:get(i);
        ItemGridUtil.clearItemPosition(item)
    end
    self:updateGridPositions()
end

function ISInventoryPane:updateGridPositions()
    self.gridIsOverflowing = false

    local isEquippedMap = self:getEquippedItemsMap()

    -- Clear the positions of all equipped items
    for item,_ in pairs(isEquippedMap) do
        ItemGridUtil.clearItemPosition(item)
    end
    
    local itemGrid, unpositionedItems = self:createItemGrid()
    
    -- Sort the unpositioned items by size, so we can place the biggest ones first
    table.sort(unpositionedItems, function(a, b) return a.size > b.size end)

    -- Place the unpositioned items
    for i = 1,#unpositionedItems do
        local item = unpositionedItems[i].item
        if not self:attemptToInsertItemIntoGrid(item, itemGrid) then
            self.gridIsOverflowing = true
            self:insertItemIntoGrid(item, itemGrid, 0,0)
        end
    end

    -- In the event that we can't fit an item, we put the inventory in a "overflow" mode
    -- where items are placed in the top left corner, the grid turns red, and new items can't be placed
end

function ISInventoryPane:getEquippedItemsMap()
    local playerObj = getSpecificPlayer(self.player)
    local isEquipped = {}
    if self.parent.onCharacter then
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

-- Insert the item into the grid, no checks
function ISInventoryPane:insertItemIntoGrid(item, itemGrid, xPos, yPos)
    if not itemGrid then
        itemGrid = self:createItemGrid()
    end
    
    ItemGridUtil.setItemPosition(item, xPos, yPos)
    local w, h = ItemGridUtil.getItemSize(item)
    for y = yPos, yPos+h-1 do
        for x = xPos, xPos+w-1 do
            itemGrid[y][x] = item
        end
    end
end

function ISInventoryPane:attemptToInsertItemIntoGrid(item, itemGrid, isRotationAttempt)
    local height = 8;
    local width = 8;

    if not itemGrid then
        itemGrid = self:createItemGrid()
    end

    local w, h = ItemGridUtil.getItemSize(item)
    for y = 0,height-h do
        for x = 0,width-w do
            local canPlace = true
            for y2 = y,y+h-1 do
                for x2 = x,x+w-1 do
                    if itemGrid[y2][x2] then
                        canPlace = false
                        break
                    end
                end
            end
            if canPlace then
                ItemGridUtil.setItemPosition(item, x, y)
                for y2 = y,y+h-1 do
                    for x2 = x,x+w-1 do
                        itemGrid[y2][x2] = true
                    end
                end
                return true
            end
        end
    end

    if not isRotationAttempt and w ~= h then
        -- Try rotating the item
        ItemGridUtil.rotateItem(item)
        return self:insertItemIntoGrid(item, itemGrid, true)
    end
    
    if w ~= h then
        -- Unrotate the item to its original state
        ItemGridUtil.rotateItem(item)
    end
    
    return false
end

-- Returns a 2D array of booleans, where true means the cell is occupied
-- Also returns a list of items that don't have a position in the grid
function ISInventoryPane:createItemGrid()
    local height = 8;
    local width = 8;
    
    local itemGrid = {}

    -- Fill the grid with false
    for y = 0,height-1 do
        itemGrid[y] = {}
        for x = 0,width-1 do
            itemGrid[y][x] = false
        end
    end

    local unpositionedItemData = {}

    -- Mark the cells occupied by items
    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y = ItemGridUtil.getItemPosition(item)
        if x and y then
            local w, h = ItemGridUtil.getItemSize(item)
            for y2 = y,y+h-1 do
                for x2 = x,x+w-1 do
                    itemGrid[y2][x2] = true
                end
            end
        else
            local w, h = ItemGridUtil.getItemSize(item)
            local size = w * h
            table.insert(unpositionedItemData, {item = item, size = size})
        end
    end

    return itemGrid, unpositionedItemData
end

















ItemGridUtil = {}

ItemGridUtil.itemSizes = {}
ItemGridUtil.isStackable = {}

ItemGridUtil.getItemPosition = function(item)
    local x = item:getModData()[X_POS]
    local y = item:getModData()[Y_POS]
    return x, y
end

ItemGridUtil.setItemPosition = function(item, x, y)
    item:getModData()[X_POS] = x
    item:getModData()[Y_POS] = y
end

ItemGridUtil.clearItemPosition = function(item)
    item:getModData()[X_POS] = nil
    item:getModData()[Y_POS] = nil
end

ItemGridUtil.rotateItem = function(item)
    local isRotated = item:getModData()[IS_ROTATED]
    if isRotated then
        item:getModData()[IS_ROTATED] = nil
    else
        item:getModData()[IS_ROTATED] = true
    end
end

ItemGridUtil.getItemSize = function(item)
    if not ItemGridUtil.itemSizes[item:getFullType()] then
        ItemGridUtil.calculateAndCacheItemInfo(item)
    end
    
    local sizeData = ItemGridUtil.itemSizes[item:getFullType()]
    if item:getModData()[IS_ROTATED] then
        return sizeData.y, sizeData.x
    else
        return sizeData.x, sizeData.y
    end
end

ItemGridUtil.calculateAndCacheItemInfo = function(item)
    ItemGridUtil.calculateItemSize(item)
    ItemGridUtil.calculateItemStackability(item)
end

-- Programatically determine the size of an item
-- I'll manually override the sizes of some items later via a config file or something
ItemGridUtil.calculateItemSize = function(item)
    local category = item:getDisplayCategory()
    if category == "Ammo" then
        -- determine if its ammo or a magazine by stackability
        if item:CanStack(item) then
            ItemGridUtil.calculateItemSizeMagazine(item)
        else
            ItemGridUtil.calculateItemSizeAmmo(item)
        end
    elseif category == "Weapon" then
        ItemGridUtil.calculateItemSizeWeapon(item)
    elseif category == "Clothing" then
        ItemGridUtil.calculateItemSizeClothing(item)
    elseif category == "Food" then
        ItemGridUtil.calculateItemSizeWeightBased(item)
    elseif category == "FirstAid" then
        ItemGridUtil.calculateItemSizeWeightBased(item)
    elseif category == "Container" then
        ItemGridUtil.calculateItemSizeContainer(item)
    elseif category == "Book" then
        ItemGridUtil.calculateItemSizeWeightBased(item)
    elseif category == "Key" then
        ItemGridUtil.calculateItemSizeKey(item)
    elseif category == "Junk" then
        ItemGridUtil.calculateItemSizeWeightBased(item)
    else
        ItemGridUtil.calculateItemSizeWeightBased(item)
    end
end

ItemGridUtil.calculateItemSizeMagazine = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 0.25 then
        height = 2
    end

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.calculateItemSizeAmmo = function(item)
    ItemGridUtil.itemSizes[item:getFullType()] = {x = 1, y = 1}
end

ItemGridUtil.calculateItemSizeWeapon = function(item)
    local width = 2
    local height = 1

    local weight = item:getActualWeight()

    if weight >= 3 then
        width = 4
        height = 2
    elseif weight >= 2.5 then
        width = 3
        height = 2
    elseif weight >= 2 then
        width = 3
        height = 1
    elseif weight <= 0.4 then
        width = 1
        height = 1
    end

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.calculateItemSizeClothing = function(item)
    local width = 2
    local height = 2

    -- This shouldn't happen, but just in case a mod does something weird
    if item:IsClothing() == false then
        ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
        return
    end

    local bulletDef = item:getBulletDefense()
    if bulletDef >= 50 then
        width = 3
        height = 3
    else
        local weight = item:getActualWeight()
        if weight >= 3.0 then
            width = 3
            height = 3
        elseif weight < 0.5 then
            width = 1
            height = 1
        elseif weight <= 1.0 then
            width = 2
            height = 1
        end
    end

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.calculateItemSizeWeightBased = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 10 then
        width = 4
        height = 4
    elseif weight >= 5 then
        width = 3
        height = 3
    elseif weight >= 2 then
        width = 2
        height = 2
    elseif weight >= 1 then
        width = 2
        height = 1
    end

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.calculateItemSizeKey = function(item)
    ItemGridUtil.itemSizes[item:getFullType()] = {x = 1, y = 1}
end

ItemGridUtil.calculateItemStackability = function(item)
    local stackable = item:CanStack(item)
    ItemGridUtil.isStackable[item:getFullType()] = stackable
end

ItemGridUtil.calculateItemSizeContainer = function(item)
    local width = 1
    local height = 1

    -- TODO: Should match the internal size of said container

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

local og_createMenu = ISInventoryPaneContextMenu.createMenu
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)

    local item = items[1].items[1]
    -- Pull a bunch of fields into local variables so we can view them in the debugger

    local itemCategory = item:getDisplayCategory()
    local itemDisplayName = item:getDisplayName()
    local itemFullType = item:getFullType()
    local itemWeight = item:getActualWeight()
    local itemType = item:getType()
    local itemKlass = item:getCat()
    
    og_createMenu(player, isInPlayerInventory, items, x, y, origin)
end