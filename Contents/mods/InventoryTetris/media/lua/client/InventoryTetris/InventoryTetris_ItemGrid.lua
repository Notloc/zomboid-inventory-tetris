require "ISUI/ISPanel"

ItemGrid = ISPanel:derive("ItemGrid")

local X_POS = "invt_x"
local Y_POS = "invt_y"
local IS_ROTATED = "invt_rotated"

local CELL_SIZE = 48
local TEXTURE_SIZE = 40;
local TEXTURE_PAD = 4;


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

local function calculateWidth(gridWidth)
    return gridWidth * (CELL_SIZE + TEXTURE_PAD * 2)
end

local function calculateHeight(gridHeight)
    return gridHeight * (CELL_SIZE + TEXTURE_PAD * 2)
end

local function getDraggedItem()
    -- Only return the item being dragged if it's the only item being dragged
    -- We can't render a list being dragged from the ground
    local item = (ISMouseDrag.dragging and #ISMouseDrag.dragging == 1) and ISMouseDrag.dragging[1] or nil
    return ItemGridUtil.convertItemStackToItem(item)
end

function ISInventoryPane:render()
    self:renderBackGrid()
    self:renderGridItems()
    self:renderDragItemPreview()
end

function ItemGrid:renderBackGrid()
    local g = 1
    local b = 1
    
    if self.gridIsOverflowing then
        g = 0
        b = 0
    end
    
    self:drawRect(0, 0, CELL_SIZE * width, CELL_SIZE * height, 0.9, 0, 0, 0)

    for y = 0,height-1 do
        for x = 0,width-1 do
            self:drawRectBorder(CELL_SIZE * x, CELL_SIZE * y, CELL_SIZE, CELL_SIZE, 0.25, 1, g, b)
        end
    end
end

function ItemGrid:renderGridItems()
    local items = self.inventory:getItems();
    self:redoGridPositions(items) -- Temp code to fix the grid positions until we get things updating properly when items are added/removed
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y = ItemGridUtil.getItemPosition(item)
        if x and y then
            self:renderGridItem(item, x * CELL_SIZE, y * CELL_SIZE)
        end
    end
end

function ItemGrid:renderDragItemPreview()
    local item = getDraggedItem()
    if not item then
        return
    end
    
    local x = self:getMouseX()
    local y = self:getMouseY()
    local itemW, itemH = ItemGridUtil.getItemSize(item)

    local xPos = x - itemW * CELL_SIZE / 2
    local yPos = y - itemH * CELL_SIZE / 2

    -- Placement preview
    if self:isMouseOver() then
        local gridX, gridY = ItemGridUtil.mousePositionToGridPosition(xPos, yPos)
        self:drawRect(gridX * CELL_SIZE, gridY * CELL_SIZE, itemW * CELL_SIZE, itemH * CELL_SIZE, 1, 1, 1, 1)
    end
end

function ItemGrid.renderDragItem(drawer)
    local item = getDraggedItem()
    if not item then
        return
    end
    
    local x = drawer:getMouseX()
    local y = drawer:getMouseY()
    local itemW, itemH = ItemGridUtil.getItemSize(item)

    local xPos = x - itemW * CELL_SIZE / 2
    local yPos = y - itemH * CELL_SIZE / 2

    drawer:suspendStencil()
    ItemGrid.renderGridItem(drawer, item, xPos, yPos)
    drawer:resumeStencil()
end

function ItemGrid.renderGridItem(drawer, item, x, y)

    local w, h = ItemGridUtil.getItemSize(item)
    local minDimension = math.min(w, h)

    drawer:drawRect(x, y, w * CELL_SIZE, h * CELL_SIZE, 0.8, getItemBackgroundColor(item))
    drawer:drawRectBorder(x, y, w * CELL_SIZE, h * CELL_SIZE, 1, 0, 1, 1)

    local x2 = x + TEXTURE_PAD * w + (w - minDimension) * CELL_SIZE / 2
    local y2 = y + TEXTURE_PAD * h + (h - minDimension) * CELL_SIZE / 2
    
    drawer:drawTextureScaled(item:getTex(), x2, y2, TEXTURE_SIZE * minDimension, TEXTURE_SIZE * minDimension, 1, 1, 1, 1);
end



-- Returns a 2D array of booleans, where true means the cell is occupied
function ItemGrid:createItemGrid(width, height)
    local itemGrid = {}

    -- Fill the grid with false
    for y = 0,height-1 do
        itemGrid[y] = {}
        for x = 0,width-1 do
            itemGrid[y][x] = false
        end
    end

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
        end
    end

    return itemGrid
end

function ItemGrid:getUnpositionedItems()
    local unpositionedItemData = {}

    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y = ItemGridUtil.getItemPosition(item)
        if not x or not y then
            local w, h = ItemGridUtil.getItemSize(item)
            local size = w * h
            table.insert(unpositionedItemData, {item = item, size = size})
        end
    end

    return unpositionedItemData
end

-- Insert the item into the grid, no checks
function ItemGrid:insertItemIntoGrid(item, xPos, yPos) 
    ItemGridUtil.setItemPosition(item, xPos, yPos)
    local w, h = ItemGridUtil.getItemSize(item)
    for y = yPos, yPos+h-1 do
        for x = xPos, xPos+w-1 do
            self.itemGrid[y][x] = item
        end
    end
end

function ItemGrid:attemptToInsertItemIntoGrid(item, isRotationAttempt)
    local width = self.width
    local height = self.height

    local w, h = ItemGridUtil.getItemSize(item)
    for y = 0,height-h do
        for x = 0,width-w do
            local canPlace = true
            for y2 = y,y+h-1 do
                for x2 = x,x+w-1 do
                    if self.itemGrid[y2][x2] then
                        canPlace = false
                        break
                    end
                end
            end
            if canPlace then
                self:insertItemIntoGrid(item, x, y)
                return true
            end
        end
    end

    if not isRotationAttempt and w ~= h then
        -- Try rotating the item
        ItemGridUtil.rotateItem(item)
        return self:insertItemIntoGrid(item, true)
    end
    
    if w ~= h then
        -- Unrotate the item to its original state
        ItemGridUtil.rotateItem(item)
    end
    
    return false
end

function ItemGrid:getEquippedItemsMap()
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

function ItemGrid:redoGridPositions()
    local items = self.inventory:getItems()
    for i = 0, items:size()-1 do
        local item = items:get(i);
        ItemGridUtil.clearItemPosition(item)
    end
    self:updateGridPositions()
end

function ItemGrid:updateGridPositions()
    self.gridIsOverflowing = false

    local isEquippedMap = self:getEquippedItemsMap()

    -- Clear the positions of all equipped items
    --for item,_ in pairs(isEquippedMap) do
    --    ItemGridUtil.clearItemPosition(item)
    --end
    
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



function ItemGrid.new(x, y, inventory, width, height)
    local o = ISPanel.new(x, y, calculateWidth(width), calculateHeight(height))
    setmetatable(o, self)
    self.__index = self
    o.inventory = inventory
    o.width = width
    o.height = height
    o.itemGrid = o:createItemGrid(width, height)
    o.gridIsOverflowing = false
    return o
end
