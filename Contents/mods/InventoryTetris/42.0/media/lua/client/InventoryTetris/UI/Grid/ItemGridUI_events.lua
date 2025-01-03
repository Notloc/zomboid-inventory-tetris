require("InventoryTetris/UI/Grid/ItemGridUI")
local OPT = require("InventoryTetris/Settings")
local ItemUtil = require("Notloc/ItemUtil")

local CONTROLLER_DOUBLE_PRESS_TIME = 200

function ItemGridUI:initialise()
    ISPanel.initialise(self)

    self.selectedX = 0
    self.selectedY = 0
    NotlocControllerNode
        :injectControllerNode(self)
        :doSimpleFocusHighlight()
        :setJoypadDirHandler(self.controllerNodeOnJoypadDir)
        :setJoypadDownHandler(self.controllerNodeOnJoypadDown)
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
    gridStack = gridStack or self:findGridStackUnderMouse(x, y)
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

    gridStack = gridStack or self:findGridStackUnderMouse(x, y)
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

function ItemGridUI.covertItemAndLocalMouseToGridPosition(x, y, item, isRotated)
    if item then
        local w, h = TetrisItemData.getItemSize(item, isRotated)
        x = x - OPT.CELL_SIZE * w / 2 + OPT.CELL_SIZE / 2
        y = y - OPT.CELL_SIZE * h / 2 + OPT.CELL_SIZE / 2
    end

    return ItemGridUI.mousePositionToGridPosition(x, y)
end

-- Rounds a mouse position to the nearest grid position, for the top left corner of the item
function ItemGridUI.mousePositionToGridPosition(x, y)
    local effectiveCellSize = OPT.CELL_SIZE - 1
    local gridX = math.floor(x / effectiveCellSize)
    local gridY = math.floor(y / effectiveCellSize)
    return gridX, gridY
end


function ItemGridUI:handleDragAndDrop(mouseX, mouseY)
    local vanillaStack = DragAndDrop.getDraggedStack()
    if not vanillaStack or not vanillaStack.items[1] then return end
    local dragItem = vanillaStack.items[1]
    local gridX, gridY = ItemGridUI.covertItemAndLocalMouseToGridPosition(mouseX, mouseY, dragItem, DragAndDrop.isDraggedItemRotated())
    local x, y = ItemGridUI.covertItemAndLocalMouseToGridPosition(mouseX, mouseY)
    local hoveredStack = self.grid:getStack(x, y, self.playerNum)
    return self:handleDragAndDrop_generic(vanillaStack, gridX, gridY, hoveredStack)
end

function ItemGridUI:handleDragAndDrop_generic(vanillaStack, gridX, gridY, hoveredStack)
    local dragItem = vanillaStack.items[1]
    local dragInventory = dragItem:getContainer()
    local dragContainerGrid = ItemContainerGrid.GetOrCreate(dragInventory, self.playerNum)
    local gridStack, otherGrid = dragContainerGrid:findGridStackByVanillaStack(vanillaStack)

    local isSameInventory = self.grid.inventory == dragInventory
    local isSameGrid = self.grid == otherGrid

    if isSameInventory or self:canPutIn(dragItem) then     
        if isStackSplitDown() then
            self:openSplitStack(vanillaStack, gridX, gridY)
            return
        end

        luautils.walkToContainer(self.grid.inventory, self.playerNum)

        local isSameStack = hoveredStack and gridStack == hoveredStack

        if not isSameStack and hoveredStack and ItemStack.canAddItem(hoveredStack, dragItem) then
            self:handleDropOnStack(vanillaStack, hoveredStack)
            return
        end

        local container = self:getValidContainerFromStack(hoveredStack)
        if not isSameStack and container then
            self:handleDropOnContainer(vanillaStack, container)
            return
        end

        if hoveredStack and not isSameStack then
            local targetStack = ItemStack.convertToVanillaStacks(hoveredStack, self.grid.inventory, self.inventoryPane)[1]
            TetrisEvents.OnStackDroppedOnStack:trigger(vanillaStack, dragInventory, targetStack, self.grid.inventory, self.playerNum)
            return
        end

        if not isSameInventory then
            self:handleDragAndDropTransfer(vanillaStack, gridX, gridY)
            return
        end

        if isSameGrid then
            self.grid:moveStack(gridStack, gridX, gridY, self:_isDragItemRotated())
        else
            self:handleSameContainerDifferentGrid(vanillaStack, gridX, gridY, otherGrid)
        end
    end
end

function ItemGridUI:handleSameContainerDifferentGrid(vanillaStack, gridX, gridY, otherGrid)
    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]
        if self.grid:insertItem(item, gridX, gridY, self:_isDragItemRotated()) then
            if otherGrid then
                otherGrid:removeItem(item)
            end
            if item:isEquipped() then
                ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
            end
        end
    end
end

function ItemGridUI:_isDragItemRotated()
    local isJoyPad = JoypadState.players[self.playerNum+1] ~= nil
    return isJoyPad and ControllerDragAndDrop.isDraggedItemRotated(self.playerNum) or DragAndDrop.isDraggedItemRotated()
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
            if not self.grid.isOnPlayer and self.grid.containerDefinition.trueType ~= "floor" then
                return
            end
        end
    end

    local frontItem = vanillaStack.items[1]
    local containerDef = TetrisContainerData.getContainerDefinition(container)
    if not TetrisContainerData.validateInsert(container, containerDef, frontItem) then
        return
    end

    local playerObj = getSpecificPlayer(self.playerNum)
    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]

        self:unequipIfNeeded(playerObj, item)

        local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), container)
        action.enforceTetrisRules = true
        ISTimedActionQueue.add(action)
    end
end

function ItemGridUI:handleDragAndDropTransfer(vanillaStack, gridX, gridY)
    local frontItem = vanillaStack.items[1]
    if frontItem:IsInventoryContainer() and frontItem:getInventory() == self.grid.inventory then
        return
    end

    if not self.grid:doesItemFit(frontItem, gridX, gridY, self:_isDragItemRotated()) then
        return
    end

    if not TetrisContainerData.validateInsert(self.grid.inventory, self.grid.containerDefinition, frontItem) then
        return
    end

    local playerObj = getSpecificPlayer(self.playerNum)
    for i=2, #vanillaStack.items do
        local item = vanillaStack.items[i]

        self:unequipIfNeeded(playerObj, item)

        local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), self.grid.inventory)
        action:setTetrisTarget(gridX, gridY, self.grid.gridIndex, self:_isDragItemRotated(), self.grid.secondaryTarget)
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

    if not fromStack or not fromGrid then
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

        local playerObj = getSpecificPlayer(self.playerNum)
        self:unequipIfNeeded(playerObj, item)

        local action = ISInventoryTransferAction:new(playerObj, item, item:getContainer(), self.grid.inventory)
        action:setTetrisTarget(targetStack.x, targetStack.y, self.grid.gridIndex, targetStack.isRotated, self.grid.secondaryTarget)
        ISTimedActionQueue.add(action)
    end
end

function ItemGridUI:openSplitStack(vanillaStack, targetX, targetY)
    if not vanillaStack or vanillaStack.count-1 < 2 then return end

    local dragInventory = vanillaStack.items[1]:getContainer()
    local isSameInventory = self.grid.inventory == dragInventory
    if isSameInventory then
        local gridStack = self.grid:findStackByItem(vanillaStack.items[1])
        if gridStack and self.grid:willStackOverlapSelf(gridStack, targetX, targetY, self:_isDragItemRotated()) then
            return
        end
    end

    local window = ItemGridStackSplitWindow:new(self.grid, vanillaStack, targetX, targetY, self:_isDragItemRotated(), self.playerNum)
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

    gridStack = gridStack or self:findGridStackUnderMouse(x, y)
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
        local targetContainers = ItemGridUI.getOrderedBackpacks(invPage)
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
        local gridContainer = ItemContainerGrid.GetOrCreate(testContainer, self.playerNum)
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

    gridStack = gridStack or self:findGridStackUnderMouse(x, y)
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
        self.inventoryPane.tetrisWindowManager:openContainerPopup(item)
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

function ItemGridUI:unequipIfNeeded(playerObj, item)
    -- Formality for clothes, we skip hands because items in your hands are already in your hands... Why would it take time to drop them?
    if item:isEquipped() and not playerObj:isPrimaryHandItem(item) and not playerObj:isSecondaryHandItem(item) then
        ISInventoryPaneContextMenu.unequipItem(item, self.playerNum)
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

    if menu and menu.numOptions > 1 and JoypadState.players[playerNum+1] then
        NotlocControllerNode:focusContextMenu(playerNum, menu)
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

    if menu and menu.numOptions > 1 and JoypadState.players[playerNum+1] then
        NotlocControllerNode:focusContextMenu(playerNum, menu)
    end
    return menu
end

function ItemGridUI:getControllerSelectedItem()
    local stack = self.grid:getStack(self.selectedX, self.selectedY, self.playerNum)
    if stack then
        return ItemStack.getFrontItem(stack, self.grid.inventory)
    end
    return nil
end

function ItemGridUI:controllerNodeOnJoypadDir(dx, dy, joypadData)
    local xSelected = self.selectedX
    local ySelected = self.selectedY
    local originX = xSelected
    local originY = ySelected
    local w, h = 1, 1

    local isDragging = ControllerDragAndDrop.isDragging(self.playerNum)
    local stack = self.grid:getStack(xSelected, ySelected, self.playerNum)
    if stack and not isDragging then
        local item = ItemStack.getFrontItem(stack, self.grid.inventory)
        w, h = TetrisItemData.getItemSize(item, stack.isRotated)
        originX = stack.x
        originY = stack.y
    end

    if dx == -1 then
        xSelected = originX - 1
    elseif dx == 1 then
        xSelected = originX + w
    end
    if dy == -1 then
        ySelected = originY - 1
    elseif dy == 1 then
        ySelected = originY + h
    end

    self:accelerateDpadMovement(dx, dy, joypadData)

    if xSelected < 0 then
        return false
    end
    if xSelected >= self.grid.width then
        return false
    end

    if ySelected < 0 then
        return false
    end
    if ySelected >= self.grid.height then
        return false
    end

    self.selectedX = xSelected
    self.selectedY = ySelected
    return true
end

-- Make the Dpad repeat movement faster
-- DISABLED for now
function ItemGridUI:accelerateDpadMovement(dx, dy, joypadData)
    if true then return end

    local dtSkip = 2500 -- Hook this up mod options
    local dtKey = nil

    if dx == -1 then
        dtKey = "dtleft"
    elseif dx == 1 then
        dtKey = "dtright"
    elseif dy == -1 then
        dtKey = "dtup"
    elseif dy == 1 then
        dtKey = "dtdown"
    end

    if not dtKey then
        return
    end

    local dtDown = joypadData.controller[dtKey]
    if not dtDown or dtDown < dtSkip then
        joypadData.controller[dtKey] = dtSkip
    end
end

function ItemGridUI:controllerNodeOnJoypadDown(button)
    if ControllerDragAndDrop.isDragging(self.playerNum) then
        -- Rotate item
        if button == Joypad.AButton then
            ControllerDragAndDrop.rotateDraggedItem(self.playerNum)
            return true
        end
        
        -- Place item / do double click action
        if button == Joypad.BButton then
            local stack = ControllerDragAndDrop.getDraggedTetrisStack(self.playerNum)
            local time = getTimestampMs() - (self.startTime or 0)
            local doInteract = stack and stack == self.doublePressStack and stack.x == self.selectedX and stack.y == self.selectedY and time < CONTROLLER_DOUBLE_PRESS_TIME

            local hoveredStack = self.grid:getStack(self.selectedX, self.selectedY, self.playerNum)
            self:handleDragAndDrop_generic(ControllerDragAndDrop.getDraggedStack(self.playerNum), self.selectedX, self.selectedY, hoveredStack)
            ControllerDragAndDrop.endDrag(self.playerNum)

            if doInteract then
                self:interact(stack)
            end
            return true
        end

        -- Cancel drag without moving item
        if button == Joypad.YButton then
            ControllerDragAndDrop.endDrag(self.playerNum)
            return true
        end

    else
        -- Open item context menu
        if button == Joypad.AButton then
            local stack = self.grid:getStack(self.selectedX, self.selectedY, self.playerNum)
            if stack then
                self:openStackContextMenu((self.selectedX+0.5)*OPT.CELL_SIZE, (self.selectedY+0.5)*OPT.CELL_SIZE, stack, self.grid.inventory, self.inventoryPane, self.playerNum)
            end
            return true
        end

        -- Pick up item
        if button == Joypad.BButton then
            local stack = self.grid:getStack(self.selectedX, self.selectedY, self.playerNum)
            if stack then
                local vanillaStack = ItemStack.convertToVanillaStacks(stack, self.grid.inventory, self.inventoryPane)[1]
                ControllerDragAndDrop.startDrag(self.playerNum, self, stack, vanillaStack)
                self.selectedX = stack.x
                self.selectedY = stack.y

                self.startTime = getTimestampMs()
                self.doublePressStack = stack
            end
            return true
        end

        -- Quick move item
        if button == Joypad.XButton then
            local stack = self.grid:getStack(self.selectedX, self.selectedY, self.playerNum)
            if stack then
                self:doAction(stack, "move")
            end
            return true
        end

    end

    return false
end

function ItemGridUI.getOrderedBackpacks(inventoryPage)
    local orderedBackpacks = {}

    local selectedBackpack = inventoryPage.inventory
    if selectedBackpack then
        table.insert(orderedBackpacks, selectedBackpack)
    end

    local sortedButtons = {}
    for _, button in ipairs(inventoryPage.backpacks) do
        table.insert(sortedButtons, button)
    end
    table.sort(sortedButtons, function(a, b) return a:getY() < b:getY() end)

    for _, button in ipairs(sortedButtons) do
        if button.inventory ~= selectedBackpack then
            table.insert(orderedBackpacks, button.inventory)
        end
    end

    return orderedBackpacks
end
