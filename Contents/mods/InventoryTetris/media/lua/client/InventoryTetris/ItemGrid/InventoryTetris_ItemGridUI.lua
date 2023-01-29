require "ISUI/ISUIElement"

local BG_TEXTURE = getTexture("media/textures/InventoryTetris/ItemSlot.png")
local CONSTANTS = require "InventoryTetris/Constants"

local CELL_SIZE = CONSTANTS.CELL_SIZE
local TEXTURE_SIZE = CONSTANTS.TEXTURE_SIZE
local TEXTURE_PAD = CONSTANTS.TEXTURE_PAD
local ICON_SCALE = CONSTANTS.ICON_SCALE


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

local function getDraggedItem()
    -- Only return the item being dragged if it's the only item being dragged
    -- We can't render a list being dragged from the ground
    local item = (ISMouseDrag.dragging and #ISMouseDrag.dragging == 1 and ISMouseDrag.dragStarted) and ISMouseDrag.dragging[1] or nil
    return ItemGridUtil.convertItemStackToItem(item)
end

local function isDraggedItemRotated()
    return ISMouseDrag.rotateDrag
end

local function isQuickMoveDown()
    return isKeyDown(getCore():getKey("tetris_quick_move"))
end

local function isQuickEquipDown()
    return isKeyDown(getCore():getKey("tetris_quick_equip"))
end


ItemGridUI = ISPanel:derive("ItemGridUI")

function ItemGridUI:new(grid, inventoryPane, playerNum)
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self

    o.grid = grid
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum

    o:setWidth(o:calculateWidth())
    o:setHeight(o:calculateHeight())

    return o
end

function ItemGridUI:calculateWidth()
    return self.grid.width * CELL_SIZE - self.grid.width + 1
end

function ItemGridUI:calculateHeight()
    return self.grid.height * CELL_SIZE - self.grid.height + 1
end


function ItemGridUI:render()
    self:renderBackGrid()
    self:renderGridItems()
    self:renderDragItemPreview()
    
    if ISMouseDrag.dragGridUi == self then
        self:renderDragItem()
    end
end

function ItemGridUI:renderBackGrid()
    local g = 1
    local b = 1
    
    if self.grid.gridIsOverflowing then
        g = 0
        b = 0
    end
    
    local width = self.grid.width
    local height = self.grid.height
    
    local background = 0.07
    self:drawRect(0, 0, CELL_SIZE * width - width, CELL_SIZE * height - height, 0.8, background, background, background)

    local gridLines = 0.2
    for y = 0,height-1 do
        for x = 0,width-1 do
            local posX = CELL_SIZE * x - x
            local posY = CELL_SIZE * y - y
            self:drawTextureScaled(BG_TEXTURE, posX, posY, CELL_SIZE, CELL_SIZE, 0.25, 1, g, b)
            self:drawRectBorder(posX, posY, CELL_SIZE, CELL_SIZE, 1, gridLines, gridLines, gridLines)
        end
    end
end

function ItemGridUI:renderGridItems()
    local draggedItem = getDraggedItem()
    local items = self.grid.inventory:getItems();
    for i = 0, items:size()-1 do
        local item = items:get(i);
        local x, y, i = ItemGridUtil.getItemPosition(item)
        if self.grid.gridIndex == i and x and y then
            if item ~= draggedItem then
                self:renderGridItem(item, x * CELL_SIZE - x, y * CELL_SIZE - y)
            else
                self:renderGridItemFaded(item, x * CELL_SIZE - x, y * CELL_SIZE - y)
            end
        end
    end
end

-- TODO: Make this render cell by cell, so we can filter out of bounds cells
function ItemGridUI:renderDragItemPreview()
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
    local gridX, gridY = ItemGridUiUtil.mousePositionToGridPosition(xPos, yPos)

    local canPlace = self.grid:doesItemFit_WH(item, gridX, gridY, itemW, itemH)
    if canPlace then
        self:drawRect(gridX * CELL_SIZE - gridX + 1, gridY * CELL_SIZE - gridY + 1, itemW * CELL_SIZE - itemW - 1, itemH * CELL_SIZE - itemH - 1, 0.55, 0, 1, 0)
    else
        self:drawRect(gridX * CELL_SIZE - gridX + 1, gridY * CELL_SIZE - gridY + 1, itemW * CELL_SIZE - itemW - 1, itemH * CELL_SIZE - itemH - 1, 0.55, 1, 0, 0)
    end
end

-- TODO: Move this out of here, we need a dedicated UI for this that keeps itself on-top of everything
function ItemGridUI.renderDragItem(drawer)
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
    ItemGridUI.renderGridItem(drawer, item, xPos, yPos, isDraggedItemRotated())
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

    local texture = item:getTex()
    local texW = texture:getWidth()
    local texH = texture:getHeight()
    local largestDimension = math.max(texW, texH)
    
    local x2, y2 = nil, nil
    local targetScale = ICON_SCALE
    
    local precisionFactor = 4
    if largestDimension > TEXTURE_SIZE + TEXTURE_PAD then -- Handle large textures
        local mult = precisionFactor * largestDimension / TEXTURE_SIZE 
        mult = math.ceil(mult) / precisionFactor
        targetScale = targetScale / mult
    end

    x2 = 1 + x + TEXTURE_PAD * w + (w - minDimension) * (TEXTURE_SIZE) / 2
    y2 = 1 + y + TEXTURE_PAD * h + (h - minDimension) * (TEXTURE_SIZE) / 2
    if (targetScale < 1.0) then -- Center weirdly sized textures
        x2 = x2 + 0.5 * (TEXTURE_SIZE - texW * targetScale) * minDimension
        y2 = y2 + 0.5 * (TEXTURE_SIZE - texH * targetScale) * minDimension
    end

    local r,g,b = getItemColor(item)
    drawer:drawTextureScaledUniform(texture, x2, y2, targetScale * minDimension, alphaMult, r, g, b);
    drawer:drawRectBorder(x, y, w * CELL_SIZE - w + 1, h * CELL_SIZE - h + 1, alphaMult, 0.55, 0.55, 0.55)
end

function ItemGridUI.renderGridItem(drawer, item, x, y, forceRotate)
    _renderGridItem(drawer, item, x, y, forceRotate, 1)
end

function ItemGridUI.renderGridItemFaded(drawer, item, x, y, forceRotate)
    _renderGridItem(drawer, item, x, y, forceRotate, 0.4)
end


function ItemGridUI:onMouseDown(x, y)
	if self.playerNum ~= 0 then return end
	getSpecificPlayer(self.playerNum):nullifyAiming();
    self:prepareDrag(x, y)
	return true;
end

function ItemGridUI:onMouseUp(x, y)
	if self.playerNum ~= 0 then return end
    
    if not ISMouseDrag.dragStarted then
        self:handleClick(x, y)
        return true
    end

    -- TODO: Figure out what the fuck I've got going on here
    if not ISMouseDrag.dragging or #ISMouseDrag.dragging > 1 or not ISMouseDrag.dragGridUi
        or not ItemGridTransferUtil.shouldUseGridTransfer(self.grid, ISMouseDrag.dragGridUi.grid)
    then
        return self.inventoryPane:onMouseUpNoGrid(x, y)
    end

    self:handleDragAndDrop(x, y)
    self:endDrag()

	return true;
end

function ItemGridUI:onRightMouseUp(x, y)
    if self.playerNum ~= 0 then return end

    local item = ItemGridUiUtil.findItemUnderMouseGrid(self, x, y)
    if not item then 
        return
    end
    
	if self.inventoryPane and self.inventoryPane.toolRender then
		self.inventoryPane.toolRender:setVisible(false)
	end
    
    local isInInv = self.grid.inventory:isInCharacterInventory(getSpecificPlayer(self.playerNum))
    local menu = ISInventoryPaneContextMenu.createMenu(self.playerNum, isInInv, { item }, self:getAbsoluteX()+x, self:getAbsoluteY()+y)
    --+self:getYScroll());
    if menu and menu.numOptions > 1 and JoypadState.players[self.playerNum+1] then
        menu.origin = self.inventoryPage
        menu.mouseOver = 1
        setJoypadFocus(self.playerNum, menu)
    end

	return true;
end

function ItemGridUI:onMouseDoubleClick(x, y)
    if self.playerNum ~= 0 then return end
    self:handleDoubleClick(x, y)
end

function ItemGridUI:onMouseMove(dx, dy)
    self:startDrag()
end

function ItemGridUI:onMouseMoveOutside(dx, dy)
    self:startDrag()
end


function ItemGridUI:prepareDrag(x, y)
    ISMouseDrag.rotateDrag = false
    self.downX = x;
    self.downY = y;

    local item = ItemGridUiUtil.findItemUnderMouseGrid(self, x, y)
    if item then
        self.itemToDrag = item
        ISMouseDrag.dragStarted = false
        ISMouseDrag.draggingFocus = self.inventoryPane
        ISMouseDrag.dragGridUi = self
    end
end

function ItemGridUI:startDrag()
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

function ItemGridUI:endDrag()
    self.itemToDrag = nil
	ISMouseDrag.dragging = nil;
	ISMouseDrag.draggingFocus = nil;
    ISMouseDrag.dragGridUi = nil
    ISMouseDrag.dragStarted = false
end

function ItemGridUI:handleDragAndDrop(x, y)
    local playerObj = getSpecificPlayer(self.playerNum)

    local isSameInventory = self.grid.inventory == ISMouseDrag.dragGridUi.grid.inventory
    if isSameInventory or self.inventoryPane:canPutIn() then -- TODO: Check if we can put in the correct inventory, not the pane
        local item = ISMouseDrag.dragging[1]
        item = ItemGridUtil.convertItemStackToItem(item)
        luautils.walkToContainer(self.grid.inventory, self.playerNum)

        if isSameInventory then
            ItemGridTransferUtil.moveGridItemMouse(item, ISMouseDrag.dragGridUi, self, ISMouseDrag.rotateDrag)
        else
            ItemGridTransferUtil.transferGridItemMouse(item, ISMouseDrag.dragGridUi, self, playerObj, ISMouseDrag.rotateDrag)
        end
    end
end


function ItemGridUI:handleClick(x, y)
    self:endDrag()

    local item = ItemGridUiUtil.findItemUnderMouseGrid(self, x, y)
    if item then
        if isQuickMoveDown() then
            self:quickMoveItem(item)
        elseif isQuickEquipDown() then
            self:quickEquipItem(item)
        end
    end
end

function ItemGridUI:quickMoveItem(item)
    local invPage = nil;
    if not self.grid.inventory:isInCharacterInventory(getSpecificPlayer(self.playerNum)) then
        invPage = getPlayerInventory(self.playerNum)
        local targetContainer = invPage.inventoryPane.inventory
        self:quickMoveItemToContainer(item, targetContainer)
    else
        invPage = getPlayerLoot(self.playerNum)
        local targetContainer = invPage.inventoryPane.inventory
        self:quickMoveItemToContainer(item, targetContainer)
    end

    invPage.isCollapsed = false;
    invPage:clearMaxDrawHeight();
    invPage.collapseCounter = 0;
end

function ItemGridUI:quickMoveItemToContainer(item, targetContainer)
    local playerObj = getSpecificPlayer(self.playerNum)
    local grids = ItemGrid.CreateGrids(targetContainer, self.playerNum)
    for _, grid in ipairs(grids) do
        if grid:canAddItem(item) then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), targetContainer))
            return
        end
    end
end


function ItemGridUI:handleDoubleClick(x, y)
    self:endDrag()
    
    local item = ItemGridUiUtil.findItemUnderMouseGrid(self, x, y)
    if not item then 
        return
    end

    if item:IsInventoryContainer() then
        self:openContainerPopup(item:getInventory(), self.playerNum)
    end
end

function ItemGridUI:openContainerPopup(container, playerNum)
    local invPane = self.inventoryPane
    local itemGridWindow = ItemGridWindow:new(getMouseX(), getMouseY(), container, invPane, playerNum)
    itemGridWindow:initialise()
    itemGridWindow:addToUIManager()
    itemGridWindow:bringToTop()

    invPane.tetrisWindowManager:addChildWindow(itemGridWindow)
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
