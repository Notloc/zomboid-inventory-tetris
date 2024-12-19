require "ISUI/ISPanel"
local OPT = require "InventoryTetris/Settings"
local ItemUtil = require "Notloc/ItemUtil"

-- PARTIAL CLASS
if not ItemGridUI then
    ItemGridUI = ISPanel:derive("ItemGridUI")

    function ItemGridUI:new(grid, containerGrid, inventoryPane, playerNum)
        local o = ISPanel:new(0, 0, 0, 0)
        setmetatable(o, self)
        self.__index = self

        o.grid = grid
        o.containerGrid = containerGrid
        o.inventoryPane = inventoryPane
        o.playerNum = playerNum

        o:setWidth(o:calculateWidth())
        o:setHeight(o:calculateHeight())

        return o
    end
end

local function isCtrlButtonDown()
    return isKeyDown(getCore():getKey("tetris_ctrl_button"))
end

local function isAltButtonDown()
    return isKeyDown(getCore():getKey("tetris_alt_button"))
end

local function isShiftButtonDown()
    return isKeyDown(getCore():getKey("tetris_shift_button"))
end

local function isStackSplitDown()
    return isKeyDown(getCore():getKey("tetris_stack_split"))
end

function ItemGridUI:onMouseDown(x, y, gridStack)
	if self.playerNum ~= 0 then return end
	getSpecificPlayer(self.playerNum):nullifyAiming();
    gridStack = gridStack or self:findGridStackUnderMouse()
    if gridStack then 
        local vanillaStacks = ItemStack.convertToVanillaStacks(gridStack, self.grid.inventory, self.inventoryPane)
        DragAndDrop.prepareDrag(self, vanillaStacks, x, y)
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
    
    local menu = ItemGridUI.openStackContextMenu(self, x, y, gridStack, self.grid.inventory, self.inventoryPane, self.playerNum)
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
    local vanillaStack = DragAndDrop.getDraggedStack()
    if not vanillaStack or not vanillaStack.items[1] then return end

    local dragItem = vanillaStack.items[1]
    local dragInventory = dragItem:getContainer()
    local dragContainerGrid = ItemContainerGrid.Create(dragInventory, self.playerNum)
    local gridStack, otherGrid = dragContainerGrid:findGridStackByVanillaStack(vanillaStack)

    local isSameInventory = self.grid.inventory == dragInventory
    local isSameGrid = self.grid == otherGrid

    if isSameInventory or self:canPutIn(dragItem) then
        local gridX, gridY = ItemGridUiUtil.findGridPositionOfMouse(self, dragItem, DragAndDrop.isDraggedItemRotated())
        
        if isStackSplitDown() then
            self:openSplitStack(vanillaStack, gridX, gridY)
            return
        end
        
        luautils.walkToContainer(self.grid.inventory, self.playerNum)
        
        local stackUnderMouse = self:findGridStackUnderMouse()
        local isSameStack = stackUnderMouse and gridStack == stackUnderMouse

        if not isSameStack and stackUnderMouse and ItemStack.canAddItem(stackUnderMouse, dragItem) then
            self:handleDropOnStack(vanillaStack, stackUnderMouse, gridX, gridY)
            return
        end
        
        local container = self:getValidContainerFromStack(stackUnderMouse)
        if not isSameStack and container then
            self:handleDropOnContainer(vanillaStack, container)
            return
        end

        if stackUnderMouse and not isSameStack then
            local targetStack = ItemStack.convertToVanillaStacks(stackUnderMouse, self.grid.inventory, self.inventoryPane)[1]
            TetrisEvents.OnStackDroppedOnStack:trigger(vanillaStack, dragInventory, targetStack, self.grid.inventory, self.playerNum)
            return
        end

        if not isSameInventory then
            self:handleDragAndDropTransfer(vanillaStack, gridX, gridY)
            return
        end

        if isSameGrid then
            self.grid:moveStack(gridStack, gridX, gridY, DragAndDrop.isDraggedItemRotated())
        else
            self:handleSameContainerDifferentGrid(vanillaStack, gridX, gridY, otherGrid)
        end
    end
end

function ItemGridUI:handleSameContainerDifferentGrid(vanillaStack, gridX, gridY, otherGrid)
    local playerObj = getSpecificPlayer(self.playerNum)
    local hotbar = getPlayerHotbar(self.playerNum)

    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]
        if not item:isEquipped() and not hotbar:isItemAttached(item) then
            if self.grid:insertItem(item, gridX, gridY, DragAndDrop.isDraggedItemRotated()) then
                if otherGrid then 
                    otherGrid:removeItem(item) 
                end
            end
        else 
            if item:isEquipped() then
                ISTimedActionQueue.add(ISUnequipAction:new(playerObj, item, 50))
            end
            if hotbar:isItemAttached(item) then
                ISTimedActionQueue.add(ISDetachItemHotbar:new(playerObj, item))
            end
            
            local rotated = DragAndDrop.isDraggedItemRotated()
            ISTimedActionQueue.add(
                TetrisLambdaAction:new(playerObj, 
                    function()
                        if self.grid:insertItem(item, gridX, gridY, rotated) then
                            if otherGrid then 
                                otherGrid:removeItem(item) 
                            end
                        end
                    end
                )
            );
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

function ItemGridUI:handleDropOnContainer(vanillaStack, container)
    if isClient() then -- Prevent MP duping
        if container:getContainingItem() then
            if not self.grid.isOnPlayer and self.grid.inventory:getType() ~= "floor" then
                return 
            end
        end 
    end

    local frontItem = vanillaStack.items[1]
    if not TetrisContainerData.validateInsert(container, frontItem) then
        return
    end

    local playerObj = getSpecificPlayer(self.playerNum)
    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]
        if item:isEquipped() then
            ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
        end
        local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), container, 1)
        action.enforceTetrisRules = true
        ISTimedActionQueue.add(action)
    end
end

function ItemGridUI:handleDragAndDropTransfer(vanillaStack, gridX, gridY)
    local frontItem = vanillaStack.items[1]
    if frontItem:IsInventoryContainer() and frontItem:getInventory() == self.grid.inventory then
        return
    end

    if not self.grid:doesItemFit(frontItem, gridX, gridY, DragAndDrop.isDraggedItemRotated()) then
        return
    end

    if not TetrisContainerData.validateInsert(self.grid.containerDefinition, frontItem) then
        return
    end

    local playerObj = getSpecificPlayer(self.playerNum)
    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]
        if item:isEquipped() then
            ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
        end
        local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), self.grid.inventory, 1)
        action:setTetrisTarget(gridX, gridY, self.grid.gridIndex, DragAndDrop.isDraggedItemRotated())
        ISTimedActionQueue.add(action)
    end
end

function ItemGridUI:handleDropOnStack(vanillaStack, targetStack)
    -- Prevent placing a container inside itself
    local frontItem = vanillaStack.items[1]
    if frontItem:IsInventoryContainer() and frontItem:getInventory() == self.grid.inventory then
        return
    end

    local isSameContainer = frontItem:getContainer() == self.grid.inventory
    if isSameContainer then
        self:handleDropOnStackSameContainer(vanillaStack, targetStack)
    else
        self:handleDropOnStackDifferentContainer(vanillaStack, targetStack)
    end
end

function ItemGridUI:handleDropOnStackSameContainer(vanillaStack, targetStack)
    local frontItem = vanillaStack.items[1]
    local fromStack, fromGrid = self.containerGrid:findStackByItem(frontItem)
    
    if not fromStack then
        self:sameContainerDifferentGrid(vanillaStack, targetStack.x, targetStack.y, nil)
        return
    end
    
    if fromStack == targetStack then return end

    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]
        if ItemStack.canAddItem(targetStack, item) and fromGrid:removeItem(item) then 
            self.grid:insertItem(item, targetStack.x, targetStack.y, targetStack.isRotated)
        end
    end
end

function ItemGridUI:handleDropOnStackDifferentContainer(vanillaStack, targetStack)
    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]
        if item:isEquipped() then
            ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
        end
        
        local playerObj = getSpecificPlayer(self.playerNum)
        local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), self.grid.inventory, 1)
        action:setTetrisTarget(targetStack.x, targetStack.y, self.grid.gridIndex, targetStack.isRotated)
        ISTimedActionQueue.add(action)
    end
end

function ItemGridUI:openSplitStack(vanillaStack, targetX, targetY)
    if not vanillaStack or vanillaStack.count-1 < 2 then return end

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

    if vanillaStack.count-1 <= 2 then
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
        if isCtrlButtonDown() then
            self:doAction(gridStack, OPT.CTRL_CLICK_ACTION)
        elseif isAltButtonDown() then
            self:doAction(gridStack, OPT.ALT_CLICK_ACTION)
        elseif isShiftButtonDown() then
            self:doAction(gridStack, OPT.SHIFT_CLICK_ACTION)
        end
    end
end

function ItemGridUI:doAction(gridStack, action)
    if action == "interact" then
        self:interact(gridStack)
    elseif action == "move" then
        self:quickMoveItems(gridStack)
    elseif action == "equip" then
        local item = ItemStack.getFrontItem(gridStack, self.grid.inventory)
        if item then
            self:quickEquipItem(item)
        end
    elseif action == "drop" then
        self:drop(gridStack)
    elseif action == "contextualAction" then
        self:contextualAction(gridStack)
    end
end

function ItemGridUI:drop(gridStack)
    local items = ItemStack.getAllItems(gridStack, self.grid.inventory)
    ISInventoryPaneContextMenu.onDropItems(items, self.playerNum)
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
    if not item then return end

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
        self:wearClothes(item)
    end

    self:equipItem(item)
end

function ItemGridUI:wearClothes(item)
    ISInventoryPaneContextMenu.wearItem(item, self.playerNum)
end

function ItemGridUI:equipItem(item)
    if not ItemUtil.canEquipItem(item) then return end

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

function ItemGridUI:handleDoubleClick(x, y, gridStack)
    DragAndDrop.endDrag()
    
    gridStack = gridStack or self:findGridStackUnderMouse()
    if not gridStack then 
        return
    end

    self:doAction(gridStack, OPT.DOUBLE_CLICK_ACTION)
end

-- Mirrors the vanilla behavior of double clicking an item in the inventory with a few exceptions
function ItemGridUI:interact(gridStack)
    local item = ItemStack.getFrontItem(gridStack, self.grid.inventory)
    if not item then return end
    
    if item:IsInventoryContainer() then
        self.inventoryPane.tetrisWindowManager:openContainerPopup(item, self.playerNum, self.inventoryPane)
        return
    end

    if not self.grid.isOnPlayer then
        self:quickMoveItems(gridStack)
        return
    end
    
    if item:IsClothing() then
        self:wearClothes(item)
        return
    end
    
    if item:IsWeapon() then
        self:equipItem(item)
        return
    end
    
    local items = ItemStack.getAllItems(gridStack, self.grid.inventory)
    if TetrisEvents.OnItemInteract:trigger(items, self.playerNum) then
        return
    end

    local maxStack = TetrisItemData.getMaxStackSize(item)
    if maxStack > 1 then
        self.grid:gatherSameItems(gridStack)
        return
    end
end

function ItemGridUI:contextualAction(gridStack)
    local item = ItemStack.getFrontItem(gridStack, self.grid.inventory)
    if not item then return end
    
    local playerObj = getSpecificPlayer(self.playerNum)

    if ItemUtil.canBeRead(item, playerObj) then
        ISInventoryPaneContextMenu.readItem(item, self.playerNum)
        return
    end

    if ItemUtil.canEat(item) then
        ISInventoryPaneContextMenu.onEatItems({item}, 1, self.playerNum)
        return
    end

    local vanillaStack = ItemStack.convertToVanillaStacks(gridStack, item:getContainer(), self.inventoryPane)[1]    
    if GenericSingleItemRecipeHandler.call(nil, vanillaStack, item:getContainer(), self.playerNum) then
        return
    end
end

local function rotateDraggedItem(key)
    if key == getCore():getKey("tetris_rotate_item") then
        if DragAndDrop.isDragging() then
            GameKeyboard.eatKeyPress(key)
            DragAndDrop.rotateDraggedItem()
        end
    end
end


Events.OnKeyStartPressed.Add(rotateDraggedItem)

function ItemGridUI.openItemContextMenu(uiContext, x, y, item, inventoryPane, playerNum)
    local container = item:getContainer()
    local isInInv = container and container:isInCharacterInventory(getSpecificPlayer(playerNum))
    local menu = ISInventoryPaneContextMenu.createMenu(playerNum, isInInv, ItemStack.createVanillaStacksFromItem(item, inventoryPane), uiContext:getAbsoluteX()+x, uiContext:getAbsoluteY()+y)
    --+self:getYScroll());
    if menu and menu.numOptions > 1 and JoypadState.players[playerNum+1] then
        menu.origin = self.inventoryPage
        menu.mouseOver = 1
        setJoypadFocus(playerNum, menu)
    end
    return menu
end

function ItemGridUI.openStackContextMenu(uiContext, x, y, gridStack, inventory, inventoryPane, playerNum)
    local item = ItemStack.getFrontItem(gridStack, inventory)
    if not item then return end
    
    local items = ItemStack.getAllItems(gridStack, inventory)
    local container = item:getContainer()
    local isInInv = container and container:isInCharacterInventory(getSpecificPlayer(playerNum))
    local menu = ISInventoryPaneContextMenu.createMenu(playerNum, isInInv, ItemStack.createVanillaStacksFromItems(items, inventoryPane), uiContext:getAbsoluteX()+x, uiContext:getAbsoluteY()+y)
    --+self:getYScroll());
    if menu and menu.numOptions > 1 and JoypadState.players[playerNum+1] then
        menu.origin = self.inventoryPage
        menu.mouseOver = 1
        setJoypadFocus(playerNum, menu)
    end
    return menu
end