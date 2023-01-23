local TETRIS = require "InventoryTetris/Constants"
require "ISUI/ISUIElement"

ItemGrid = ISPanel:derive("ItemGrid")

local CELL_SIZE = TETRIS.CELL_SIZE
local TEXTURE_SIZE = TETRIS.TEXTURE_SIZE
local TEXTURE_PAD = TETRIS.TEXTURE_PAD
local ICON_SCALE = TETRIS.ICON_SCALE

local backgroundTexture = getTexture("media/textures/InventoryTetris/ItemSlot.png")

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
    return self.gridWidth * CELL_SIZE - self.gridWidth + 1
end

function ItemGrid:calculateHeight()
    return self.gridHeight * CELL_SIZE - self.gridHeight + 1
end

local function getDraggedItem()
    -- Only return the item being dragged if it's the only item being dragged
    -- We can't render a list being dragged from the ground
    local item = (ISMouseDrag.dragging and #ISMouseDrag.dragging == 1) and ISMouseDrag.dragging[1] or nil
    return ItemGridUtil.convertItemStackToItem(item)
end

local function isDraggedItemRotated()
    return ISMouseDrag.rotateDrag
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
    
    local background = 0.07
    self:drawRect(0, 0, CELL_SIZE * width - width, CELL_SIZE * height - height, 0.8, background, background, background)

    local gridLines = 0.2
    for y = 0,height-1 do
        for x = 0,width-1 do
            local posX = CELL_SIZE * x - x
            local posY = CELL_SIZE * y - y
            self:drawTextureScaled(backgroundTexture, posX, posY, CELL_SIZE, CELL_SIZE, 0.25, 1, g, b)
            self:drawRectBorder(posX, posY, CELL_SIZE, CELL_SIZE, 1, gridLines, gridLines, gridLines)
        end
    end
end

function ItemGrid:renderGridItems()
    local draggedItem = getDraggedItem()
    local items = self.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y, i = ItemGridUtil.getItemPosition(item)
        if self.gridIndex == i and x and y then
            if item ~= draggedItem then
                self:renderGridItem(item, x * CELL_SIZE - x, y * CELL_SIZE - y)
            else
                self:renderGridItemFaded(item, x * CELL_SIZE - x, y * CELL_SIZE - y)
            end
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
    if isDraggedItemRotated() then
        itemW, itemH = itemH, itemW
    end

    local halfCell = CELL_SIZE / 2
    local xPos = x + halfCell - itemW * halfCell
    local yPos = y + halfCell - itemH * halfCell

    -- Placement preview
    local gridX, gridY = ItemGridUtil.mousePositionToGridPosition(xPos, yPos)

    local canPlace = self:doesItemFitWH(item, gridX, gridY, itemW, itemH)
    if canPlace then
        self:drawRect(gridX * CELL_SIZE - gridX + 1, gridY * CELL_SIZE - gridY + 1, itemW * CELL_SIZE - itemW - 1, itemH * CELL_SIZE - itemH - 1, 0.55, 0, 1, 0)
    else
        self:drawRect(gridX * CELL_SIZE - gridX + 1, gridY * CELL_SIZE - gridY + 1, itemW * CELL_SIZE - itemW - 1, itemH * CELL_SIZE - itemH - 1, 0.55, 1, 0, 0)
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
    if isDraggedItemRotated() then
        itemW, itemH = itemH, itemW
    end

    local xPos = x - itemW * CELL_SIZE / 2
    local yPos = y - itemH * CELL_SIZE / 2

    drawer:suspendStencil()
    ItemGrid.renderGridItem(drawer, item, xPos, yPos, isDraggedItemRotated())
    drawer:resumeStencil()
end

local function getItemColor(item)
    if not item or not item:allowRandomTint() then
        return 1,1,1
    end

    local colorInfo = item:getColorInfo()
    local r = colorInfo:getR()
    local g = colorInfo:getG()
    local b = colorInfo:getB()
    
    -- Limit how dark the item can appear if all colors are close to 0
    local limit = 0.1
    while r < limit and g < limit and b < limit do
        r = r + limit / 3
        g = g + limit / 3
        b = b + limit / 3
    end
    return r,g,b
end

local function _renderGridItem(drawer, item, x, y, forceRotate, alphaMult)
    local w, h = ItemGridUtil.getItemSize(item)
    if forceRotate then
        w, h = h, w
    end

    local minDimension = math.min(w, h)
    
    drawer:drawRect(x+1, y+1, w * CELL_SIZE - w - 1, h * CELL_SIZE - h - 1, 0.24 * alphaMult, getItemBackgroundColor(item))

    local x2 = x + TEXTURE_PAD * w + (w - minDimension) * TEXTURE_SIZE / 2 + 1
    local y2 = y + TEXTURE_PAD * h + (h - minDimension) * TEXTURE_SIZE / 2 + 1

    local r,g,b = getItemColor(item)
    drawer:drawTextureScaledUniform(item:getTex(), x2, y2, minDimension * ICON_SCALE, alphaMult, r, g, b);
    drawer:drawRectBorder(x, y, w * CELL_SIZE - w + 1, h * CELL_SIZE - h + 1, alphaMult, 0.55, 0.55, 0.55)
end

function ItemGrid.renderGridItem(drawer, item, x, y, forceRotate)
    _renderGridItem(drawer, item, x, y, forceRotate, 1)
end

function ItemGrid.renderGridItemFaded(drawer, item, x, y, forceRotate)
    _renderGridItem(drawer, item, x, y, forceRotate, 0.4)
end

-- Returns a 2D array of booleans, where true means the cell is occupied
function ItemGrid:createItemGrid(width, height)
    local itemGrid = {}

    -- Fill the grid with false
    for y = 0,height-1 do
        itemGrid[y] = {}
        for x = 0,width-1 do
            itemGrid[y][x] = -1
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
                        itemGrid[y2][x2] = item:getID()
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
            self.itemGrid[y][x] = -1
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
                    self.itemGrid[y2][x2] = -1
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
                self.itemGrid[y][x] = item:getID()
            end
        end
    end
end

function ItemGrid:canAddItem(item)
    local x, y = self:findPositionForItem(item)
    return x >= 0 and y >= 0
end

function ItemGrid:attemptToInsertItemIntoGrid(item)
    local x, y = self:findPositionForItem(item)
    if x >= 0 and y >= 0 then
        self:insertItemIntoGrid(item, x, y)
        return true
    end
    return false
end

function ItemGrid:findPositionForItem(item, isRotationAttempt)
    local width = self.gridWidth
    local height = self.gridHeight

    local w, h = ItemGridUtil.getItemSize(item)
    for y = 0,height-h do
        for x = 0,width-w do
            local canPlace = self:doesItemFitWH(item, x, y, w, h)
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
    return self:doesItemFitWH(item, xPos, yPos, w, h)
end

function ItemGrid:doesItemFitWH(item, xPos, yPos, w, h)
    if not self:isInBounds(xPos, yPos) or not self:isInBounds(xPos+w-1, yPos+h-1) then
        return false
    end

    for y = yPos, yPos+h-1 do
        for x = xPos, xPos+w-1 do
            if self.itemGrid[y][x] ~= -1 and self.itemGrid[y][x] ~= item:getID() then
                return false
            end
        end
    end
    return true
end

function ItemGrid:getEquippedItemsMap()
    local playerObj = getSpecificPlayer(self.playerNum)
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
    self.inventoryPane:onMouseUp(x, y)
end

function ItemGrid:onRightMouseUp(x,y)
    self.inventoryPane:onRightMouseUp(self.inventoryPane:getMouseX(), self.inventoryPane:getMouseY())
end

function ItemGrid:setInventory(inventory)
    self.inventory = inventory
    self:refreshGrid()
end

function ItemGrid:new(gridDefinition, gridIndex, inventory, playerNum)
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self

    o.inventory = inventory
    o.playerNum = playerNum
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

function ItemGrid:registerInventoryPane(inventoryPane)
    self.inventoryPane = inventoryPane
end


function ItemGrid.Create(container, playerNum)
    local grids = {}
    local gridType = getGridContainerTypeByInventory(container)
    local gridDefinition = getGridDefinitionByContainerType(gridType)
    for i, definition in ipairs(gridDefinition) do
        local grid = ItemGrid:new(definition, i, container, playerNum)
        grids[i] = grid
    end

    return grids, gridType
end