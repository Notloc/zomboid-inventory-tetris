require "ISUI/ISUIElement"

local BG_TEXTURE = getTexture("media/textures/InventoryTetris/ItemSlot.png")
local CONSTANTS = require "InventoryTetris/Data/Constants"

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
    local itemStack = (ISMouseDrag.dragging and ISMouseDrag.dragStarted) and ISMouseDrag.dragging or nil
    return ItemGridUtil.convertItemStackToItem(itemStack)
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

local function isStackSplitDown()
    return isKeyDown(getCore():getKey("tetris_stack_split"))
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

function ItemGridUI:findStackUnderMouse()
    local rawX, rawY = ItemGridUiUtil.mousePositionToGridPosition(self:getMouseX(), self:getMouseY())
    return self.grid:get(rawX, rawY)
end

function ItemGridUI:getValidContainerFromStack(stack)
    if not stack or #stack.items > 1 then
        return nil
    end
    local item = stack.items[1]
    if not item:IsInventoryContainer() then
        return nil
    end

    return item:getInventory()
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
    
    if self.isOverflowing then
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
    local stacks = self.grid.stacks
    for _, stack in pairs(stacks) do
        local item = stack.items[1]
        local x, y, i = ItemGridUtil.getItemPosition(item)
        if self.grid.gridIndex == i and x and y then
            if item ~= draggedItem then
                self:renderGridStack(stack, x * CELL_SIZE - x, y * CELL_SIZE - y)
            else
                self:renderGridStackFaded(stack, x * CELL_SIZE - x, y * CELL_SIZE - y)
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
    

    local stack = self:findStackUnderMouse()
    if stack and ItemGrid.canAddToStack(stack, item) then
        local stackItem = stack.items[1]
        local x, y, i = ItemGridUtil.getItemPosition(stackItem)
        local w, h = ItemGridUtil.getItemSize(stackItem)
        self:_renderPlacementPreview(x, y, w, h, 1, 1, 1)
        return
    end

    local container = self:getValidContainerFromStack(stack)
    if container then
        local x, y, i = ItemGridUtil.getItemPosition(stack.items[1])
        local w, h = ItemGridUtil.getItemSize(stack.items[1])
        self:_renderPlacementPreview(x, y, w, h, 1, 1, 0)
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

    local gridX, gridY = ItemGridUiUtil.mousePositionToGridPosition(xPos, yPos)
    local canPlace = self.grid:doesItemFit_WH(item, gridX, gridY, itemW, itemH)
    if canPlace then
        self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 0, 1, 0)
    else
        self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 1, 0, 0)
    end
end

function ItemGridUI:_renderPlacementPreview(gridX, gridY, itemW, itemH, r, g, b)
    self:drawRect(gridX * CELL_SIZE - gridX + 1, gridY * CELL_SIZE - gridY + 1, itemW * CELL_SIZE - itemW - 1, itemH * CELL_SIZE - itemH - 1, 0.55, r, g, b)
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

function ItemGridUI._renderGridItem(drawer, item, x, y, forceRotate, alphaMult)
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

function ItemGridUI._renderGridStack(drawer, stack, x, y, forceRotate, alphaMult)
    ItemGridUI._renderGridItem(drawer, stack.items[1], x, y, forceRotate, alphaMult)
    if #stack.items > 1 then
        -- Draw the item count
        local font = UIFont.Small
        local text = tostring(#stack.items)
        drawer:drawText(text, x+2, y, 1, 1, 1, alphaMult, font)
    end
end

function ItemGridUI.renderGridStack(drawer, stack, x, y, forceRotate)
    ItemGridUI._renderGridStack(drawer, stack, x, y, forceRotate, 1)
end

function ItemGridUI.renderGridStackFaded(drawer, stack, x, y, forceRotate)
    ItemGridUI._renderGridStack(drawer, stack, x, y, forceRotate, 0.4)
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
    ItemGridUI._renderGridItem(drawer, item, xPos, yPos, isDraggedItemRotated(), 1)
    drawer:resumeStencil()
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

    self:handleDragAndDrop(x, y)
    self:endDrag()

	return true;
end

function ItemGridUI:onRightMouseUp(x, y)
    if self.playerNum ~= 0 then return end

    local itemStack = ItemGridUiUtil.findItemStackUnderMouseGrid(self, x, y)
    if not itemStack then 
        return
    end
    
	if self.inventoryPane and self.inventoryPane.toolRender then
		self.inventoryPane.toolRender:setVisible(false)
	end
    

    local item = itemStack.items[1]
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
    ISMouseDrag.dragStarted = false
    self.downX = x;
    self.downY = y;

    local itemStack = ItemGridUiUtil.findItemStackUnderMouseGrid(self, x, y)
    if itemStack then
        self.itemStackToDrag = itemStack
        ISMouseDrag.draggingFocus = self.inventoryPane
        ISMouseDrag.dragGridUi = self
    end
end

function ItemGridUI:startDrag()
    if self.playerNum ~= 0 then return end

    if not ISMouseDrag.dragStarted and self.itemStackToDrag then
        local x = self:getMouseX()
        local y = self:getMouseY()

        local dragLimit = 8
        if math.abs(x - self.downX) > dragLimit or math.abs(y - self.downY) > dragLimit then
            ISMouseDrag.dragStarted = true
            ISMouseDrag.dragging = self.itemStackToDrag
            self.itemStackToDrag = nil
        end
    end
end

function ItemGridUI:endDrag()
    self.itemStackToDrag = nil
	ISMouseDrag.dragging = nil;
	ISMouseDrag.draggingFocus = nil;
    ISMouseDrag.dragGridUi = nil
    ISMouseDrag.dragStarted = false
end

function ItemGridUI:handleDragAndDrop(x, y)
    local playerObj = getSpecificPlayer(self.playerNum)
    local itemStack = ISMouseDrag.dragging

    local isSameInventory = self.grid.inventory == ISMouseDrag.dragGridUi.grid.inventory
    if isSameInventory or self:canPutIn(itemStack.items[1]) then
        luautils.walkToContainer(self.grid.inventory, self.playerNum)

        local stack = self:findStackUnderMouse()
        if stack and ItemGrid.canAddToStack(stack, itemStack.items[1]) then
            local x, y = ItemGridUiUtil.mousePositionToGridPosition(x, y)
            self:handleDragAndDropTransfer(playerObj, x, y)
            return
        end
        
        local container = self:getValidContainerFromStack(stack)
        if container then
            for _, item in ipairs(itemStack.items) do
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), container, 1))
            end
            return
        end

        local x, y = ItemGridUiUtil.findGridPositionOfMouse(self, itemStack.items[1], isDraggedItemRotated())
        self:handleDragAndDropTransfer(playerObj, x, y)
    end
end

function ItemGridUI:canPutIn(item)
    local ogInventory = self.inventoryPane.inventory
    self.inventoryPane.inventory = self.grid.inventory -- In case we're a popup displaying a different inventory
    local canPutIn = self.inventoryPane:canPutIn()
    self.inventoryPane.inventory = ogInventory
    return canPutIn --TODO: item type restrictions and anti-TARDIS stacking
end

function ItemGridUI:handleDragAndDropTransfer(playerObj, gridX, gridY)
    local itemStack = ISMouseDrag.dragging
    if isStackSplitDown() then
        self:splitStack(itemStack, gridX, gridY)
    else 
        for _, item in ipairs(itemStack.items) do
            ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), self.grid.inventory, 1, gridX, gridY, self.grid.gridIndex, isDraggedItemRotated()))
        end
    end
end

function ItemGridUI:splitStack(stack, targetX, targetY)
    local isSameInventory = self.grid.inventory == ISMouseDrag.dragGridUi.grid.inventory
    if isSameInventory and self.grid:willItemOverlapSelf(stack.items[1], targetX, targetY) then
        return
    end

    local playerObj = getSpecificPlayer(self.playerNum)

    local half = math.ceil(#stack.items / 2)
    for i = 1, half do
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, stack.items[i], stack.items[i]:getContainer(), self.grid.inventory, 1, targetX, targetY, self.grid.gridIndex, isDraggedItemRotated()))
    end
end

function ItemGridUI:handleClick(x, y)
    self:endDrag()

    local itemStack = ItemGridUiUtil.findItemStackUnderMouseGrid(self, x, y)
    if itemStack then
        if isQuickMoveDown() then
            self:quickMoveItems(itemStack)
        elseif isQuickEquipDown() then
            self:quickEquipItem(itemStack.items[1])
        end
    end
end

function ItemGridUI:quickMoveItems(itemStack)
    local invPage = nil;
    if not self.grid.inventory:isInCharacterInventory(getSpecificPlayer(self.playerNum)) then
        invPage = getPlayerInventory(self.playerNum)
        local targetContainer = invPage.inventoryPane.inventory
        self:quickMoveItemToContainer(itemStack, targetContainer)
    else
        invPage = getPlayerLoot(self.playerNum)
        local targetContainer = invPage.inventoryPane.inventory
        self:quickMoveItemToContainer(itemStack, targetContainer)
    end

    invPage.isCollapsed = false;
    invPage:clearMaxDrawHeight();
    invPage.collapseCounter = 0;
end

function ItemGridUI:quickMoveItemToContainer(itemStack, targetContainer)
    local playerObj = getSpecificPlayer(self.playerNum)
    local gridContainer = ItemContainerGrid.Create(targetContainer, self.playerNum)
    for _, item in ipairs(itemStack.items) do
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), targetContainer))
    end
end


function ItemGridUI:handleDoubleClick(x, y)
    self:endDrag()
    
    local itemStack = ItemGridUiUtil.findItemStackUnderMouseGrid(self, x, y)
    if not itemStack then 
        return
    end

    local item = itemStack.items[1]
    if item:IsInventoryContainer() then
        self.inventoryPane.tetrisWindowManager:openContainerPopup(item, self.playerNum, self.inventoryPane)
    end
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
