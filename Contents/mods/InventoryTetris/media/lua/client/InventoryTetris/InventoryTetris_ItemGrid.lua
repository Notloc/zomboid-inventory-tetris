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
    local item = (ISMouseDrag.dragging and #ISMouseDrag.dragging == 1 and ISMouseDrag.dragStarted) and ISMouseDrag.dragging[1] or nil
    return ItemGridUtil.convertItemStackToItem(item)
end

local function isDraggedItemRotated()
    return ISMouseDrag.rotateDrag
end

function ItemGrid:render()
    if self.inventory:isDrawDirty() then
        self.inventoryPane:refreshContainer()
    end

    self:renderBackGrid()
    self:renderGridItems()
    self:renderDragItemPreview()
    
    if ISMouseDrag.dragGrid == self then
        self:renderDragItem()
    end
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
    if item:isHidden() then
        return
    end

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

function ItemGrid:onMouseDown(x, y)
	if self.playerNum ~= 0 then return end

    ISMouseDrag.rotateDrag = false

	getSpecificPlayer(self.playerNum):nullifyAiming();

	local count = 0;

    self.downX = x;
    self.downY = y;

    local item = ItemGridUtil.findItemUnderMouseGrid(self, x, y)
    if item then
        self.itemToDrag = item

        ISMouseDrag.dragStarted = false
        ISMouseDrag.draggingFocus = self.inventoryPane
        ISMouseDrag.dragGrid = self
        return;
    end

	return true;
end

local function isQuickMoveDown()
    return isKeyDown(getCore():getKey("tetris_quick_move"))
end

local function isQuickEquipDown()
    return isKeyDown(getCore():getKey("tetris_quick_equip"))
end

function ItemGrid:onMouseUp(x, y)
	if self.playerNum ~= 0 then return end
    
    if not ISMouseDrag.dragStarted then
        local item = ItemGridUtil.findItemUnderMouseGrid(self, x, y)
        if item then
            if isQuickMoveDown() then
                self:quickMoveItem(item)
            elseif isQuickEquipDown() then
                self:quickEquipItem(item)
            end
        end

        return true
    end

    if not ISMouseDrag.dragging or #ISMouseDrag.dragging > 1 or not ISMouseDrag.dragGrid 
        or not ItemGridTransferUtil.shouldUseGridTransfer(self, ISMouseDrag.dragGrid)
    then
        return self.inventoryPane:onMouseUpNoGrid(x, y)
    end

    local playerObj = getSpecificPlayer(self.playerNum)

    local isSameInventory = self.inventory == ISMouseDrag.dragGrid.inventory
    if isSameInventory or self.inventoryPane:canPutIn() then         
        local item = ISMouseDrag.dragging[1]
        item = ItemGridUtil.convertItemStackToItem(item)
        luautils.walkToContainer(self.inventory, self.playerNum)

        if isSameInventory then
            ItemGridTransferUtil.moveGridItemMouse(item, ISMouseDrag.dragGrid, self, ISMouseDrag.rotateDrag)
        else
            ItemGridTransferUtil.transferGridItemMouse(item, ISMouseDrag.dragGrid, self, playerObj, ISMouseDrag.rotateDrag)
        end
    end

    self.itemToDrag = nil
	ISMouseDrag.dragging = nil;
	ISMouseDrag.draggingFocus = nil;
    ISMouseDrag.dragGrid = nil
    ISMouseDrag.dragStarted = false

	return true;
end

function ItemGrid:quickMoveItem(item)
    if not self.inventory:isInCharacterInventory(getSpecificPlayer(self.playerNum)) then
        local inventoryPage = getPlayerInventory(self.playerNum)
        local targetContainer = inventoryPage.inventoryPane.inventory
        self:quickMoveItemToContainer(item, targetContainer)
    else
        local lootPage = getPlayerLoot(self.playerNum)
        local targetContainer = lootPage.inventoryPane.inventory
        self:quickMoveItemToContainer(item, targetContainer)
    end
end

function ItemGrid:quickMoveItemToContainer(item, targetContainer)
    local playerObj = getSpecificPlayer(self.playerNum)
    local grids = ItemGrid.Create(targetContainer, self.playerNum)
    for _, grid in ipairs(grids) do
        if grid:canAddItem(item) then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), targetContainer))
            return
        end
    end
end



function ItemGrid:onRightMouseUp(x, y)
    if self.playerNum ~= 0 then return end

    local item = ItemGridUtil.findItemUnderMouseGrid(self, x, y)
    if not item then 
        return
    end
    
	if self.inventoryPane and self.inventoryPane.toolRender then
		self.inventoryPane.toolRender:setVisible(false)
	end
    
    local isInInv = self.inventory:isInCharacterInventory(getSpecificPlayer(self.playerNum))
    local menu = ISInventoryPaneContextMenu.createMenu(self.playerNum, isInInv, { item }, self:getAbsoluteX()+x, self:getAbsoluteY()+y)
    --+self:getYScroll());
    if menu and menu.numOptions > 1 and JoypadState.players[self.player+1] then
        menu.origin = self.inventoryPage
        menu.mouseOver = 1
        setJoypadFocus(self.player, menu)
    end

	return true;
end

local function startDragIfMouseMoved(self)
    if self.playerNum ~= 0 then return end

    if not ISMouseDrag.dragStarted and self.itemToDrag then
        local x = self:getMouseX()
        local y = self:getMouseY()

        local dragLimit = 8
        if math.abs(x - self.downX) > dragLimit or math.abs(y - self.downY) > dragLimit then
            ISMouseDrag.dragStarted = true
            ISMouseDrag.dragging = { self.itemToDrag }
            self.itemToDrag = nil
        end
    end
end

function ItemGrid:onMouseMove(dx, dy)
    startDragIfMouseMoved(self)
end

function ItemGrid:onMouseMoveOutside(dx, dy)
    startDragIfMouseMoved(self)
end

function ItemGrid:openContainerPopup(container, playerNum)
    local invPane = self.inventoryPane
    local itemGridWindow = ItemGridWindow:new(getMouseX(), getMouseY(), invPane, container, playerNum)
    itemGridWindow:initialise()
    itemGridWindow:addToUIManager()
    itemGridWindow:bringToTop()

    if not invPane.childWindows then
        invPane.childWindows = {}
    end
    table.insert(invPane.childWindows, itemGridWindow)
end

function ItemGrid:setInventory(inventory)
    self.inventory = inventory
    self:refreshGrid()
end

function ItemGrid:onMouseDoubleClick(x, y)
    if self.playerNum ~= 0 then return end

    self.itemToDrag = nil

    local item = ItemGridUtil.findItemUnderMouseGrid(self, x, y)
    if not item then 
        return
    end

    if item:IsInventoryContainer() then
        self:openContainerPopup(item:getInventory(), self.playerNum)
    end
end

function ItemGrid:initialise()
    ISPanel.initialise(self)
    self:setOnMouseDoubleClick(self, self.onMouseDoubleClick)
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
        grid:initialise()
        grids[i] = grid
    end

    return grids, gridType
end

local function rotateDraggedItem(key)
    if key == getCore():getKey("tetris_rotate_item") then
        if ISMouseDrag.rotateDrag then
            ISMouseDrag.rotateDrag = false
        else
            ISMouseDrag.rotateDrag = true
        end
    end
end

Events.OnKeyStartPressed.Add(rotateDraggedItem)



-- Positions the grids so they are nicely spaced out
-- Returns the size of all the grids
function ItemGrid.UpdateItemGridPositions(grids, offX, offY)
    -- Space out the grids
    local gridSpacing = 10
    
    local xPos = offX and offX or 0 -- The cursor position
    local maxX = 0 -- Tracks when to update the cursor position
    local largestX = grids[1]:getWidth() -- The largest grid seen for the current cursor position
    
    local yPos = offY and offY or 0
    local maxY = 0
    local largestY = grids[1]:getHeight()
    
    local gridsByX = {}
    local gridsByY = {}

    for _, grid in ipairs(grids) do
        table.insert(gridsByX, grid)
        table.insert(gridsByY, grid)
    end

    table.sort(gridsByX, function(a, b) return a.gridDefinition.position.x < b.gridDefinition.position.x end)
    table.sort(gridsByY, function(a, b) return a.gridDefinition.position.y < b.gridDefinition.position.y end)

    for _, grid in ipairs(gridsByX) do
        local x = grid.gridDefinition.position.x
        if x > maxX then
            maxX = x
            xPos = xPos + largestX + gridSpacing
            largestX = 0
        end
        
        grid:setX(xPos)
        if grid:getWidth() > largestX then
            largestX = grid:getWidth()
        end
    end
    xPos = xPos + largestX

    for _, grid in ipairs(gridsByY) do
        local y = grid.gridDefinition.position.y
        if y > maxY then
            maxY = y
            yPos = yPos + largestY + gridSpacing
            largestY = 0
        end
        
        grid:setY(yPos)
        if grid:getHeight() > largestY then
            largestY = grid:getHeight()
        end
    end
    yPos = yPos + largestY

    return xPos, yPos 
end
