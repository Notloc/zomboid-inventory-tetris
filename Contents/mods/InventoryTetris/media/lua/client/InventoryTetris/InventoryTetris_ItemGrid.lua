local TETRIS = require "InventoryTetris/Constants"
require "ISUI/ISUIElement"

ItemGrid = ISPanel:derive("ItemGrid")

local CELL_SIZE = TETRIS.CELL_SIZE
local TEXTURE_SIZE = TETRIS.TEXTURE_SIZE
local TEXTURE_PAD = TETRIS.TEXTURE_PAD

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

function ItemGrid:calculateWidth()
    return self.gridWidth * CELL_SIZE
end

function ItemGrid:calculateHeight()
    return self.gridHeight * CELL_SIZE
end

local function getDraggedItem()
    -- Only return the item being dragged if it's the only item being dragged
    -- We can't render a list being dragged from the ground
    local item = (ISMouseDrag.dragging and #ISMouseDrag.dragging == 1) and ISMouseDrag.dragging[1] or nil
    return ItemGridUtil.convertItemStackToItem(item)
end

function ItemGrid:render()
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
    
    local width = self.gridWidth
    local height = self.gridHeight
    self:drawRect(0, 0, CELL_SIZE * width, CELL_SIZE * height, 0.9, 0, 0, 0)

    for y = 0,height-1 do
        for x = 0,width-1 do
            self:drawRectBorder(CELL_SIZE * x, CELL_SIZE * y, CELL_SIZE, CELL_SIZE, 0.25, 1, g, b)
        end
    end
end

function ItemGrid:renderGridItems()
    local items = self.inventory:getItems();
    --self:redoGridPositions(items) -- Temp code to fix the grid positions until we get things updating properly when items are added/removed
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y, i = ItemGridUtil.getItemPosition(item)
        if self.gridIndex == i and x and y then
            self:renderGridItem(item, x * CELL_SIZE, y * CELL_SIZE)
        end
    end
end

function ItemGrid:renderDragItemPreview()
    local item = getDraggedItem()
    if not item or not self:isMouseOver() then
        return
    end
    
    local x = self:getMouseX()
    local y = self:getMouseY()
    local itemW, itemH = ItemGridUtil.getItemSize(item)

    local halfCell = CELL_SIZE / 2
    local xPos = x + halfCell - itemW * halfCell
    local yPos = y + halfCell - itemH * halfCell

    -- Placement preview
    local gridX, gridY = ItemGridUtil.mousePositionToGridPosition(xPos, yPos)
    self:drawRect(gridX * CELL_SIZE, gridY * CELL_SIZE, itemW * CELL_SIZE, itemH * CELL_SIZE, 1, 1, 1, 1)
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
                    if self:isInBounds(x2, y2) then
                        itemGrid[y2][x2] = true
                    end
                end
            end
        end
    end

    return itemGrid
end

function ItemGrid:refreshGrid()
    self:clearGrid()
    self:updateGridPositions()
end

function ItemGrid:clearGrid()
    local items = self.inventory:getItems();
    for y = 0, self.gridHeight-1 do
        for x = 0, self.gridWidth-1 do
            self.itemGrid[y][x] = false
        end
    end
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
    return x >= 0 and x < self.gridWidth and y >= 0 and y < self.gridHeight
end

function ItemGrid:removeItemFromGrid(item)
    local x, y = ItemGridUtil.getItemPosition(item)
    if x and y then
        local w, h = ItemGridUtil.getItemSize(item)
        for y2 = y,y+h-1 do
            for x2 = x,x+w-1 do
                if self:isInBounds(x2, y2) then
                    self.itemGrid[y2][x2] = false
                end
            end
        end
    end
    ItemGridUtil.clearItemPosition(item)
end

-- Insert the item into the grid, no checks
function ItemGrid:insertItemIntoGrid(item, xPos, yPos) 
    ItemGridUtil.setItemPosition(item, xPos, yPos, self.gridIndex)
    local w, h = ItemGridUtil.getItemSize(item)
    for y = yPos, yPos+h-1 do
        for x = xPos, xPos+w-1 do
            if self:isInBounds(x, y) then
                self.itemGrid[y][x] = true
            end
        end
    end
end

function ItemGrid:attemptToInsertItemIntoGrid(item, isRotationAttempt)
    local width = self.gridWidth
    local height = self.gridHeight

    local w, h = ItemGridUtil.getItemSize(item)
    for y = 0,height-h do
        for x = 0,width-w do
            local canPlace = self:doesItemFitWH(item, x, y, w, h)
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

function ItemGrid:doesItemFit(item, xPos, yPos)
    local w, h = ItemGridUtil.getItemSize(item)
    return self:doesItemFitWH(item, xPos, yPos, w, h)
end

function ItemGrid:doesItemFitWH(item, xPos, yPos, w, h)
    if not self:isInBounds(xPos+w-1, yPos+h-1) then
        return false
    end

    for y = yPos, yPos+h-1 do
        for x = xPos, xPos+w-1 do
            if self.itemGrid[y][x] then
                return false
            end
        end
    end
    return true
end

function ItemGrid:getEquippedItemsMap()
    local playerObj = getSpecificPlayer(self.inventoryPane.player)
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
        local gridIndex = ItemGridUtil.getItemGridIndex(item)
        if gridIndex == self.gridIndex then
            ItemGridUtil.clearItemPosition(item)
        end
    end
    self:refreshGrid()
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
        local x, y, gridIndex = ItemGridUtil.getItemPosition(item)
        if gridIndex == self.gridIndex then
            if x and y then
                self:insertItemIntoGrid(item, x, y)
            else
                self:attemptToInsertItemIntoGrid(item)
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

function ItemGrid:onMouseDown(x,y)
    self.inventoryPane:onMouseDown(self.inventoryPane:getMouseX(), self.inventoryPane:getMouseY())
end

function ItemGrid:onMouseUp(x,y)
    self.inventoryPane:onMouseUp(self.inventoryPane:getMouseX(), self.inventoryPane:getMouseY())
end

function ItemGrid:onRightMouseUp(x,y)
    self.inventoryPane:onRightMouseUp(self.inventoryPane:getMouseX(), self.inventoryPane:getMouseY())
end

function ItemGrid:setInventory(inventory)
    self.inventory = inventory
    self:refreshGrid()
end

function ItemGrid:new(gridDefinition, gridIndex, inventoryPane)
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self

    o.inventoryPane = inventoryPane
    o.inventory = inventoryPane.inventory
    o.gridIndex = gridIndex
    o.gridWidth = gridDefinition.size.width
    o.gridHeight = gridDefinition.size.height
    o.gridDefinition = gridDefinition
    o.gridIsOverflowing = false
    o.itemGrid = o:createItemGrid(o.gridWidth, o.gridHeight)

    o:setWidth(o:calculateWidth())
    o:setHeight(o:calculateHeight())
    return o
end
