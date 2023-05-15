require "ISUI/ISUIElement"

local BG_TEXTURE = getTexture("media/textures/InventoryTetris/ItemSlot.png")
local HORIZONTAL_LINE = getTexture("media/textures/InventoryTetris/HorizontalLine.png")
local BROKEN_TEXTURE = getTexture("media/textures/InventoryTetris/Broken.png")
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

function ItemGridUI:new(grid, inventoryPane, containerUi, playerNum)
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self

    o.grid = grid
    o.containerUi = containerUi
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

function ItemGridUI:findGridStackUnderMouse()
    local rawX, rawY = ItemGridUiUtil.mousePositionToGridPosition(self:getMouseX(), self:getMouseY())
    return self.grid:getStack(rawX, rawY)
end

function ItemGridUI:getValidContainerFromStack(stack)
    if not stack or stack.count > 1 then
        return nil
    end
    local item = ItemStack.getFrontItem(stack, self.grid.inventory)
    if not item:IsInventoryContainer() then
        return nil
    end

    return item:getInventory()
end

function ItemGridUI:render()
    self:renderBackGrid()
    self:renderGridItems()
    self:renderDragItemPreview()
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
    local totalWidth = CELL_SIZE * width - width + 1
    local totalHeight = CELL_SIZE * height - height + 1
    self:drawRect(0, 0, totalWidth, totalHeight, 0.8, background, background, background)

    local gridLines = 0.2

    self.javaObject:DrawTextureTiled(BG_TEXTURE, 1, 1, totalWidth-1, totalHeight-1, 1, 1, 1, 0.25)
    self.javaObject:DrawTextureTiled(HORIZONTAL_LINE, 0, 0, totalWidth, totalHeight, gridLines, gridLines, gridLines, 1)

end

function updateItem(item)
    if instanceof(item, 'InventoryItem') then
        item:updateAge()
    end
    if instanceof(item, 'Clothing') then
        item:updateWetness()
    end
end

function ItemGridUI:renderGridItems()
    local draggedItem = DragAndDrop.getDraggedItem()
    local stacks = self.grid:getStacks()
    local inventory = self.grid.inventory
    for _, stack in pairs(stacks) do
        local item = ItemStack.getFrontItem(stack, inventory)
        updateItem(item);

        local x, y = stack.x, stack.y
        if x and y then
            if item ~= draggedItem then
                self:_renderGridStack(stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1)
            else
                self:_renderGridStack(stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 0.4)
            end
        end
    end
end

function ItemGridUI:renderDragItemPreview()
    local item = DragAndDrop.getDraggedItem()
    if not item or not self:isMouseOver() then
        return
    end
    

    local stack = self:findGridStackUnderMouse()
    if stack and not ItemStack.containsItem(stack, item) and ItemStack.canAddItem(stack, item) then
        local stackItem = ItemStack.getFrontItem(stack, self.grid.inventory)
        local w, h = TetrisItemData.getItemSize(stackItem, stack.isRotated)
        self:_renderPlacementPreview(stack.x, stack.y, w, h, 1, 1, 1)
        return
    end

    local container = self:getValidContainerFromStack(stack)
    if container then
        local item = ItemStack.getFrontItem(stack, self.grid.inventory)
        local w, h = TetrisItemData.getItemSize(item)
        self:_renderPlacementPreview(stack.x, stack.y, w, h, 1, 1, 0)
        return
    end

    local x = self:getMouseX()
    local y = self:getMouseY()
    local isRotated = DragAndDrop.isDraggedItemRotated()
    
    local itemW, itemH = TetrisItemData.getItemSize(item, isRotated)

    local halfCell = CELL_SIZE / 2
    local xPos = x + halfCell - itemW * halfCell
    local yPos = y + halfCell - itemH * halfCell

    local gridX, gridY = ItemGridUiUtil.mousePositionToGridPosition(xPos, yPos)
    local canPlace = self.grid:doesItemFit(item, gridX, gridY, isRotated)
    if canPlace then
        self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 0, 1, 0)
    else
        self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 1, 0, 0)
    end
end

function ItemGridUI:_renderPlacementPreview(gridX, gridY, itemW, itemH, r, g, b)
    self:drawRect(gridX * CELL_SIZE - gridX + 1, gridY * CELL_SIZE - gridY + 1, itemW * CELL_SIZE - itemW - 1, itemH * CELL_SIZE - itemH - 1, 0.55, r, g, b)
end

function ItemGridUI.getItemColor(item, limit)
    if not item or not item:allowRandomTint() then
        return 1,1,1
    end

    local colorInfo = item:getColorInfo()
    local r = colorInfo:getR()
    local g = colorInfo:getG()
    local b = colorInfo:getB()
    
    if not limit then
        limit = 0.2
    end

    -- Limit how dark the item can appear if all colors are close to 0
    while r < limit and g < limit and b < limit do
        r = r + limit / 4
        g = g + limit / 4
        b = b + limit / 4
    end
    return r,g,b
end

function ItemGridUI._renderGridItem(drawingContext, item, x, y, rotate, alphaMult, force1x1)
    local w, h = TetrisItemData.getItemSize(item, rotate)

    if force1x1 then
        w, h = 1, 1
    end

    local minDimension = math.min(w, h)
    drawingContext:drawRect(x+1, y+1, w * CELL_SIZE - w - 1, h * CELL_SIZE - h - 1, 0.24 * alphaMult, getItemBackgroundColor(item))

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
    targetScale = targetScale * minDimension

    local r,g,b = ItemGridUI.getItemColor(item)
    drawingContext:drawTextureScaledUniform(texture, x2, y2, targetScale, alphaMult, r, g, b);
    
    if item:isBroken() then
        drawingContext:drawTextureScaledUniform(BROKEN_TEXTURE, x2, y2, targetScale, alphaMult * 0.5, 1, 1, 1);
    end

    drawingContext:drawRectBorder(x, y, w * CELL_SIZE - w + 1, h * CELL_SIZE - h + 1, alphaMult, 0.55, 0.55, 0.55)
end

function ItemGridUI._renderGridStack(drawingContext, stack, item, x, y, alphaMult)
    ItemGridUI._renderGridItem(drawingContext, item, x, y, stack.isRotated, alphaMult)
    if stack.count > 1 then
        -- Draw the item count
        local font = UIFont.Small
        local text = tostring(stack.count)
        drawingContext:drawText(text, x+3, y-3, 0, 0, 0, alphaMult, font)
        drawingContext:drawText(text, x+2, y-4, 1, 1, 1, alphaMult, font)
    end
end

function ItemGridUI:onMouseDown(x, y)
	if self.playerNum ~= 0 then return end
	getSpecificPlayer(self.playerNum):nullifyAiming();
    local gridStack = self:findGridStackUnderMouse()
    if gridStack then 
        local vanillaStack = ItemStack.convertToVanillaStack(gridStack, self.grid.inventory)
        DragAndDrop.prepareDrag(self, vanillaStack, x, y)
    end

	return true;
end

function ItemGridUI:onMouseUp(x, y)
	if self.playerNum ~= 0 then return end
    
    if not DragAndDrop.isDragging() then
        self:handleClick(x, y)
        return true
    end

    self:handleDragAndDrop(x, y)
    DragAndDrop.endDrag()

	return true;
end

function ItemGridUI:onMouseUpOutside(x, y)
    if self.playerNum ~= 0 then return end
    if not DragAndDrop.isDragOwner(self) then return end

    DragAndDrop.cancelDrag(self, ItemGridUI.cancelDragDropItem)
end

function ItemGridUI:cancelDragDropItem()
    local vanillaStack = ISMouseDrag.dragging
    if not vanillaStack or not vanillaStack.items then return end

    local item = vanillaStack.items[1]
    local gridStack = self.grid:findStackByItem(item)
    if gridStack then
        local playerObj = getSpecificPlayer(self.playerNum)
        local vehicle = playerObj:getVehicle()
        if vehicle then
            return
        end

        if not ISUIElement.isMouseOverAnyUI() then
            for itemId, _ in pairs(gridStack.itemIDs) do
                local itm = self.grid.inventory:getItemById(itemId)
                ISInventoryPaneContextMenu.dropItem(itm, self.playerNum)
            end
        end
    end
end

function ItemGridUI:onRightMouseUp(x, y)
    if self.playerNum ~= 0 then return end

    local itemStack = self:findGridStackUnderMouse()
    if not itemStack then 
        return
    end
    
	if self.inventoryPane and self.inventoryPane.toolRender then
		self.inventoryPane.toolRender:setVisible(false)
	end
    
    local item = ItemStack.getFrontItem(itemStack, self.grid.inventory)
    local menu = ItemGridUI.openItemContextMenu(self, x, y, item, self.playerNum)
	TetrisDevTool.insertContainerDebugOptions(menu, self.containerUi.containerGrid)
    
    return true;
end

function ItemGridUI:onMouseDoubleClick(x, y)
    if self.playerNum ~= 0 then return end
    self:handleDoubleClick(x, y)
end

function ItemGridUI:onMouseMove(dx, dy)
    if self.playerNum ~= 0 then return end
    DragAndDrop.startDrag(self)
end

function ItemGridUI:onMouseMoveOutside(dx, dy)
    if self.playerNum ~= 0 then return end
    DragAndDrop.startDrag(self)
end

function ItemGridUI:handleDragAndDrop(x, y)
    local playerObj = getSpecificPlayer(self.playerNum)
    local vanillaStack = ISMouseDrag.dragging
    if not vanillaStack or not vanillaStack.items[1] then return end

    local gridStack, grid = self.containerUi.containerGrid:findGridStackByVanillaStack(vanillaStack) -- Might be null if we are dragging from a different inventory
    local dragInventory = vanillaStack.items[1]:getContainer()

    local isSameInventory = self.grid.inventory == dragInventory
    local isSameGrid = self.grid == grid

    if isSameInventory or self:canPutIn(vanillaStack.items[1]) then
        luautils.walkToContainer(self.grid.inventory, self.playerNum)

        local stackUnderMouse = self:findGridStackUnderMouse()
        local isSameStack = gridStack == stackUnderMouse

        if not isSameStack and stackUnderMouse and ItemStack.canAddItem(stackUnderMouse, vanillaStack.items[1]) then
            local x, y = ItemGridUiUtil.mousePositionToGridPosition(x, y)
            self:handleDragAndDropTransfer(playerObj, x, y)
            return
        end
        
        local container = self:getValidContainerFromStack(stackUnderMouse)
        if not isSameStack and container then
            self:handleDropOnContainer(playerObj, vanillaStack, container)
        end

        local x, y = ItemGridUiUtil.findGridPositionOfMouse(self, vanillaStack.items[1], DragAndDrop.isDraggedItemRotated())
        if isSameGrid then
            if isStackSplitDown() then
                self:splitStackSameGrid(vanillaStack, x, y)
            else
                self.grid:moveStack(gridStack, x, y, DragAndDrop.isDraggedItemRotated())
            end
        else
            self:handleDragAndDropTransfer(playerObj, x, y)
        end
    end
end

function ItemGridUI:canPutIn(item)
    local ogInventory = self.inventoryPane.inventory
    self.inventoryPane.inventory = self.grid.inventory -- In case we're a popup displaying a different inventory
    local canPutIn = self.inventoryPane:canPutIn()
    self.inventoryPane.inventory = ogInventory
    return canPutIn --TODO: item type restrictions and anti-TARDIS stacking
end

function ItemGridUI:handleDropOnContainer(playerObj, vanillaStack, container)
    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]
        if item:isEquipped() then
            ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
        end
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), container, 1))
    end
end

function ItemGridUI:handleDragAndDropTransfer(playerObj, gridX, gridY)
    local vanillaStack = ISMouseDrag.dragging
    if isStackSplitDown() then
        self:splitStackDifferentGrid(vanillaStack, gridX, gridY)
    else 
        for i, item in ipairs(vanillaStack.items) do
            if i > 1 then
                if item:isEquipped() then
                    ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
                end
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), self.grid.inventory, 1, gridX, gridY, self.grid.gridIndex, DragAndDrop.isDraggedItemRotated()))
            end
        end
    end
end

function ItemGridUI:splitStackDifferentGrid(vanillaStack, targetX, targetY)
    if not vanillaStack or vanillaStack.count < 2 then return end

    local isRotated = DragAndDrop.isDraggedItemRotated()
    local dragInventory = vanillaStack.items[1]:getContainer()
    local isSameInventory = self.grid.inventory == dragInventory
    local gridStack = self.grid:findStackByItem(vanillaStack.items[1])

    local playerObj = getSpecificPlayer(self.playerNum)

    local half = math.ceil(vanillaStack.count / 2)
    for i = 2, half+1 do
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, vanillaStack.items[i], vanillaStack.items[i]:getContainer(), self.grid.inventory, 1, targetX, targetY, self.grid.gridIndex, DragAndDrop.isDraggedItemRotated()))
    end
end

function ItemGridUI:splitStackSameGrid(vanillaStack, targetX, targetY)
    if not vanillaStack or vanillaStack.count < 2 then return end

    local isRotated = DragAndDrop.isDraggedItemRotated()
    local dragInventory = vanillaStack.items[1]:getContainer()
    local isSameInventory = self.grid.inventory == dragInventory
    local gridStack = self.grid:findStackByItem(vanillaStack.items[1])
    if isSameInventory and self.grid:willStackOverlapSelf(gridStack, targetX, targetY, isRotated) then
        return
    end

    local playerObj = getSpecificPlayer(self.playerNum)

    local half = math.ceil(vanillaStack.count / 2)
    for i = 2, half+1 do
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, vanillaStack.items[i], vanillaStack.items[i]:getContainer(), self.grid.inventory, 1, targetX, targetY, self.grid.gridIndex, DragAndDrop.isDraggedItemRotated()))
    end
end

function ItemGridUI:handleClick(x, y)
    DragAndDrop.endDrag()

    local gridStack = self:findGridStackUnderMouse()
    if gridStack then
        if isQuickMoveDown() then
            self:quickMoveItems(gridStack)
        elseif isQuickEquipDown() then
            local item = ItemStack.getFrontItem(gridStack, self.grid.inventory)
            self:quickEquipItem(item)
        end
    end
end

function ItemGridUI:quickMoveItems(gridStack)
    local invPage = nil;
    if not self.grid.inventory:isInCharacterInventory(getSpecificPlayer(self.playerNum)) then
        invPage = getPlayerInventory(self.playerNum)
        local targetContainers = { invPage.inventoryPane.inventory }
        for _, backpack in pairs(invPage.backpacks) do
            if backpack.inventory ~= invPage.inventoryPane.inventory then
                table.insert(targetContainers, backpack.inventory)
            end
        end
        self:quickMoveItemToContainer(gridStack, targetContainers)
    else
        invPage = getPlayerLoot(self.playerNum)
        local targetContainers = { invPage.inventoryPane.inventory }
        self:quickMoveItemToContainer(gridStack, targetContainers)
    end

    invPage.isCollapsed = false;
    invPage:clearMaxDrawHeight();
    invPage.collapseCounter = 0;
end

function ItemGridUI:quickMoveItemToContainer(gridStack, targetContainers)
    local playerObj = getSpecificPlayer(self.playerNum)
    local item = ItemStack.getFrontItem(gridStack, self.grid.inventory)
    
    local targetContainer = nil
    for _, testContainer in ipairs(targetContainers) do
        local gridContainer = ItemContainerGrid.Create(testContainer, self.playerNum)
        if gridContainer:canAddItem(item) then
            targetContainer = testContainer
            break
        end
    end

    if not targetContainer then return end
    
    for itemId, _ in pairs(gridStack.itemIDs) do
        local item = self.grid.inventory:getItemById(itemId)
        local transfer = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), targetContainer)
        transfer.isRotated = gridStack.isRotated
        ISTimedActionQueue.add(transfer)
    end
end

function ItemGridUI:quickEquipItem(item)
    if item:IsClothing() then
        self:quickEquipClothes(item)
    end

    self:quickEquipWeapon(item)
end

function ItemGridUI:quickEquipClothes(item)
    local playerObj = getSpecificPlayer(self.playerNum)
    -- TODO: equip quick equip clothes
end

function ItemGridUI:quickEquipWeapon(item)
    local playerObj = getSpecificPlayer(self.playerNum)
    local hasPrimaryHand = playerObj:getPrimaryHandItem()
    local hasSecondaryHand = playerObj:getSecondaryHandItem()
    local isTwoHanding = hasPrimaryHand == hasSecondaryHand
    
    local requiresBothHands = item:isRequiresEquippedBothHands()
    if item:IsWeapon() then
        local useBothHands = requiresBothHands or (item:isTwoHandWeapon() and (not hasSecondaryHand or isTwoHanding))
        ISInventoryPaneContextMenu.equipWeapon(item, true, useBothHands, self.playerNum)
    elseif requiresBothHands and not hasPrimaryHand and not hasSecondaryHand then
            ISInventoryPaneContextMenu.equipWeapon(item, true, true, self.playerNum)
    elseif not requiresBothHands then
        if not hasPrimaryHand then
            ISInventoryPaneContextMenu.equipWeapon(item, true, false, self.playerNum)
        elseif not hasSecondaryHand then
            ISInventoryPaneContextMenu.equipWeapon(item, false, false, self.playerNum)
        end
    end
end

function ItemGridUI:handleDoubleClick(x, y)
    DragAndDrop.endDrag()
    
    local itemStack = self:findGridStackUnderMouse()
    if not itemStack then 
        return
    end

    local item = ItemStack.getFrontItem(itemStack, self.grid.inventory)
    if item:IsInventoryContainer() then
        self.inventoryPane.tetrisWindowManager:openContainerPopup(item, self.playerNum, self.inventoryPane)
    end

    local maxStack = TetrisItemData.getMaxStackSize(item)
    if maxStack > 1 then
        self.grid:gatherSameItems(itemStack)
    end
end



local function rotateDraggedItem(key)
    if key == getCore():getKey("tetris_rotate_item") then
        if DragAndDrop.isDragging() then
            DragAndDrop.rotateDraggedItem()
        end
    end
end

local function debugOpenEquipmentWindow(key)
    -- open with zero
    if key == Keyboard.KEY_0 then
        --local playerObj = getSpecificPlayer(0)
        local equipmentWindow = EquipmentUIParentWindow:new(0, 0, 0)
        equipmentWindow:initialise()
        equipmentWindow:addToUIManager()
        equipmentWindow:setVisible(true)
    end
end

Events.OnKeyStartPressed.Add(rotateDraggedItem)
Events.OnKeyStartPressed.Add(debugOpenEquipmentWindow)

function ItemGridUI.openItemContextMenu(uiContext, x, y, item, playerNum)
    local container = item:getContainer()
    local isInInv = container and container:isInCharacterInventory(getSpecificPlayer(playerNum))
    local menu = ISInventoryPaneContextMenu.createMenu(playerNum, isInInv, { item }, uiContext:getAbsoluteX()+x, uiContext:getAbsoluteY()+y)
    --+self:getYScroll());
    if menu and menu.numOptions > 1 and JoypadState.players[playerNum+1] then
        menu.origin = self.inventoryPage
        menu.mouseOver = 1
        setJoypadFocus(playerNum, menu)
    end
    return menu
end