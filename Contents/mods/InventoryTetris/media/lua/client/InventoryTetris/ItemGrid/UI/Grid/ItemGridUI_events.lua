require "ISUI/ISPanel"
local OPT = require "InventoryTetris/Settings"

-- PARTIAL CLASS
if not ItemGridUI then
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

function ItemGridUI:onMouseDown(x, y, gridStack)
	if self.playerNum ~= 0 then return end
	getSpecificPlayer(self.playerNum):nullifyAiming();
    gridStack = gridStack or self:findGridStackUnderMouse()
    if gridStack then 
        local vanillaStack = ItemStack.convertToVanillaStack(gridStack, self.grid.inventory)
        DragAndDrop.prepareDrag(self, vanillaStack, x, y)
    end

	return true;
end

function ItemGridUI:onMouseUp(x, y, gridStack)
	if self.playerNum ~= 0 then return end
    
    if not DragAndDrop.isDragging() then
        self:handleClick(x, y, gridStack)
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
    local vanillaStack = DragAndDrop.getDraggedStack()
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

function ItemGridUI:onRightMouseUp(x, y, gridStack)
    if self.playerNum ~= 0 then return end

    gridStack = gridStack or self:findGridStackUnderMouse()
    if not gridStack then 
        return
    end
    
	if self.inventoryPane and self.inventoryPane.toolRender then
		self.inventoryPane.toolRender:setVisible(false)
	end
    
    local menu = ItemGridUI.openStackContextMenu(self, x, y, gridStack, self.grid.inventory, self.playerNum)
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
    local vanillaStack = DragAndDrop.getDraggedStack()
    if not vanillaStack or not vanillaStack.items[1] then return end

    local dragInventory = vanillaStack.items[1]:getContainer()
    local otherContainerGrid = ItemContainerGrid.Create(dragInventory, self.playerNum)
    local gridStack, otherGrid = otherContainerGrid:findGridStackByVanillaStack(vanillaStack)

    local isSameInventory = self.grid.inventory == dragInventory
    local isSameGrid = self.grid == otherGrid

    if isSameInventory or self:canPutIn(vanillaStack.items[1]) then
        luautils.walkToContainer(self.grid.inventory, self.playerNum)

        local stackUnderMouse = self:findGridStackUnderMouse()
        local isSameStack = gridStack == stackUnderMouse

        if not isSameStack and stackUnderMouse and ItemStack.canAddItem(stackUnderMouse, vanillaStack.items[1]) then
            local x, y = ItemGridUiUtil.mousePositionToGridPosition(x, y)
            self:handleDragAndDropTransfer(playerObj, x, y, stackUnderMouse)
            return
        end
        
        local container = self:getValidContainerFromStack(stackUnderMouse)
        if not isSameStack and container then
            self:handleDropOnContainer(playerObj, vanillaStack, container)
        end

        if stackUnderMouse and not isSameStack then
            TetrisEvents.OnStackDroppedOnStack:trigger(gridStack, otherGrid, stackUnderMouse, self.grid, self.playerNum)
            return
        end

        local x, y = ItemGridUiUtil.findGridPositionOfMouse(self, vanillaStack.items[1], DragAndDrop.isDraggedItemRotated())
        if isSameGrid then
            if isStackSplitDown() then
                self:openSplitStack(vanillaStack, x, y)
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
    local frontItem = vanillaStack.items[1]
    if not TetrisContainerData.validateInsert(container, frontItem) then
        return
    end

    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]
        if item:isEquipped() then
            ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
        end
        ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), container, 1))
    end
end

function ItemGridUI:handleDragAndDropTransfer(playerObj, gridX, gridY, targetStack)
    local vanillaStack = DragAndDrop.getDraggedStack()
    local frontItem = vanillaStack.items[1]
    
    if not targetStack and not self.grid:doesItemFit(frontItem, gridX, gridY, DragAndDrop.isDraggedItemRotated()) then
        return
    end

    if not targetStack then
        -- Verify the item can be put in this particular container
        -- We'll let stacking happen even if the item type is wrong, since the stack being there is already wrong
        if not TetrisContainerData.validateInsert(self.grid.containerDefinition, frontItem) then
            return
        end
    end

    if isStackSplitDown() then
        self:openSplitStack(vanillaStack, gridX, gridY)
    else 
        for i, item in ipairs(vanillaStack.items) do
            if i > 1 then
                if item:isEquipped() then
                    ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
                end
                local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), self.grid.inventory, 1)
                action:setTetrisTarget(gridX, gridY, self.grid.gridIndex, DragAndDrop.isDraggedItemRotated())
                ISTimedActionQueue.add(action)
            end
        end
    end
end

function ItemGridUI:openSplitStack(vanillaStack, targetX, targetY)
    if not vanillaStack or vanillaStack.count < 2 then return end

    local dragInventory = vanillaStack.items[1]:getContainer()
    local isSameInventory = self.grid.inventory == dragInventory
    if isSameInventory then
        local gridStack = self.grid:findStackByItem(vanillaStack.items[1])
        if gridStack and self.grid:willStackOverlapSelf(gridStack, targetX, targetY, DragAndDrop.isDraggedItemRotated()) then
            return
        end
    end

    local window = ItemGridStackSplitWindow:new(self.grid, vanillaStack, targetX, targetY, DragAndDrop.isDraggedItemRotated(), self.playerNum)
    window:initialise()
    window:addToUIManager()
    window:setX(getMouseX() - window:getWidth() / 2)
    window:setY(getMouseY() - window:getHeight() / 2)

    if vanillaStack.count <= 3 then
        window:onOK()
    end


end

function ItemGridUI:handleClick(x, y, gridStack)
    DragAndDrop.endDrag()

    if self.grid:isUnsearched(self.playerNum) then
        local searchAction = SearchGridAction:new(getSpecificPlayer(self.playerNum), self.grid)
        ISTimedActionQueue.add(searchAction)
        return
    end

    gridStack = gridStack or self:findGridStackUnderMouse()
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
        local targetContainers = ItemGridUiUtil.getOrderedBackpacks(invPage)
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
    if not self:_canEquipItem(item) then return end

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

function ItemGridUI:_canEquipItem(item)
    local isFood = item:getCategory() == "Food" and not item:getScriptItem():isCantEat()
    if isFood then
        return false
    end

    local isClothes = item:getCategory() == "Clothing"
    if isClothes then
        return false
    end

    return true
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
    local menu = ISInventoryPaneContextMenu.createMenu(playerNum, isInInv, ItemStack.createVanillaStackFromItem(item), uiContext:getAbsoluteX()+x, uiContext:getAbsoluteY()+y)
    --+self:getYScroll());
    if menu and menu.numOptions > 1 and JoypadState.players[playerNum+1] then
        menu.origin = self.inventoryPage
        menu.mouseOver = 1
        setJoypadFocus(playerNum, menu)
    end
    return menu
end

function ItemGridUI.openStackContextMenu(uiContext, x, y, gridStack, inventory, playerNum)
    local item = ItemStack.getFrontItem(gridStack, inventory)
    local items = ItemStack.getAllItems(gridStack, inventory)

    local container = item:getContainer()
    local isInInv = container and container:isInCharacterInventory(getSpecificPlayer(playerNum))
    local menu = ISInventoryPaneContextMenu.createMenu(playerNum, isInInv, ItemStack.createVanillaStackFromItems(items), uiContext:getAbsoluteX()+x, uiContext:getAbsoluteY()+y)
    --+self:getYScroll());
    if menu and menu.numOptions > 1 and JoypadState.players[playerNum+1] then
        menu.origin = self.inventoryPage
        menu.mouseOver = 1
        setJoypadFocus(playerNum, menu)
    end
    return menu
end