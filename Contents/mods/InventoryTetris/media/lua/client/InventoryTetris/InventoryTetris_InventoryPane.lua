require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISMouseDrag"
require "TimedActions/ISTimedActionQueue"
require "TimedActions/ISEatFoodAction"
require "ISUI/ISInventoryPane"

local function isGroundContainer(inventoryPane)
    return not inventoryPane.inventory or inventoryPane.inventory:getType() == 'floor'
end

local og_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
    self:refreshItemGrids()

    og_refreshContainer(self)
    if self.mode == "grid" then
        self:updateGridPositions()
    end
end

function ISInventoryPane:refreshItemGrids()
    self.mode = isGroundContainer(self) and "details" or "grid"
    
    if self.mode == "grid" then
        if self.activeGridType ~= getGridContainerTypeByInventory(self.inventory) then
            self:createItemGrids()
            self:updateItemGridPositions()
        else
            for _, grid in ipairs(self.grids) do
                grid:setInventory(self.inventory)
            end
        end
    else
        self:clearGrids()
    end
end

function ISInventoryPane:updateGridPositions()
    for _, grid in ipairs(self.grids) do
        grid:updateGridPositions()
    end
end

function ISInventoryPane:clearGrids()
    if self.grids then
        for _, grid in ipairs(self.grids) do
            self:removeChild(grid)
        end
    end
    self.activeGridType = nil
end

function ISInventoryPane:createItemGrids()
    self:clearGrids()
    
    self.grids = {}
    self.activeGridType = getGridContainerTypeByInventory(self.inventory)
    local gridDefinition = getGridDefinitionByContainerType(self.activeGridType)
    for i, definition in ipairs(gridDefinition) do
        local grid = ItemGrid:new(definition, i, self)
        self.grids[i] = grid
        self:addChild(grid)
    end
end

function ISInventoryPane:updateItemGridPositions()
    -- Space out the grids
    local gridSpacing = 20
    
    local xPos = 0 -- The cursor position
    local maxX = 0 -- Tracks when to update the cursor position
    local largestX = self.grids[1]:getWidth() -- The largest grid seen for the current cursor position
    
    local yPos = 0
    local maxY = 0
    local largestY = self.grids[1]:getHeight()
    
    local gridsByX = {}
    local gridsByY = {}

    for _, grid in ipairs(self.grids) do
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
end

local og_prerender = ISInventoryPane.prerender
function ISInventoryPane:prerender()
    og_prerender(self);
    if self.mode == "grid" then
        self.nameHeader:setVisible(false)
        self.typeHeader:setVisible(false)
    else
        self.nameHeader:setVisible(true)
        self.typeHeader:setVisible(true)
    end
end

local og_render = ISInventoryPane.render
function ISInventoryPane:render()
    if self.mode == "grid" then
        ItemGrid.renderDragItem(self)
    end
    og_render(self)
end

local og_updateTooltip = ISInventoryPane.updateTooltip
function ISInventoryPane:updateTooltip()
	if self.mode ~= "grid" then
        return og_updateTooltip(self)
    end

    if not self:isReallyVisible() then
		return -- in the main menu
	end

	local item = nil

	if not self.doController and not self.dragging and not self.draggingMarquis and self:isMouseOver() then
		local x = self:getMouseX()
		local y = self:getMouseY()
		item = ItemGridUtil.findItemUnderMouse(self, x, y)
	end

	local weightOfStack = 0.0
	if item and not instanceof(item, "InventoryItem") then
		if #item.items > 2 then
			weightOfStack = item.weight
		end
		item = item.items[1]
	end

	if getPlayerContextMenu(self.player):isAnyVisible() then
		item = nil
	end

	if item and self.toolRender and (item == self.toolRender.item) and
			(weightOfStack == self.toolRender.tooltip:getWeightOfStack()) and
			self.toolRender:isVisible() then
		return
	end

	if item then
		if self.toolRender then
			self.toolRender:setItem(item)
			self.toolRender:setVisible(true)
			self.toolRender:addToUIManager()
			self.toolRender:bringToTop()
		else
			self.toolRender = ISToolTipInv:new(item)
			self.toolRender:initialise()
			self.toolRender:addToUIManager()
			self.toolRender:setVisible(true)
			self.toolRender:setOwner(self)
			self.toolRender:setCharacter(getSpecificPlayer(self.player))
			self.toolRender.anchorBottomLeft = { x = self:getAbsoluteX() + self.column2, y = self:getParent():getAbsoluteY() }
		end
		self.toolRender.followMouse = not self.doController
		self.toolRender.tooltip:setWeightOfStack(weightOfStack)
	elseif self.toolRender then
		self.toolRender:removeFromUIManager()
		self.toolRender:setVisible(false)
	end

	-- Hack for highlighting doors when a Key tooltip is displayed.
	if self.parent.onCharacter then
		if not self.toolRender or not self.toolRender:getIsVisible() then
			item = nil
		end
		Key.setHighlightDoors(self.player, item)
	end

	local inventoryPage = getPlayerInventory(self.player)
	local inventoryTooltip = inventoryPage and inventoryPage.inventoryPane.toolRender
	local lootPage = getPlayerLoot(self.player)
	local lootTooltip = lootPage and lootPage.inventoryPane.toolRender
	UIManager.setPlayerInventoryTooltip(self.player,
		inventoryTooltip and inventoryTooltip.javaObject or nil,
		lootTooltip and lootTooltip.javaObject or nil)
end



local og_onMouseDown = ISInventoryPane.onMouseDown
function ISInventoryPane:onMouseDown(x, y)
	if self.player ~= 0 then return true end

    if self.mode ~= "grid" then
        return og_onMouseDown(self, x, y)
    end

	getSpecificPlayer(self.player):nullifyAiming();

	local count = 0;

    self.downX = x;
    self.downY = y;

    if self.selected == nil then
		self.selected = {}
    end

    local item = ItemGridUtil.findItemUnderMouse(self, x, y)
    if item then
        self.dragging = self.mouseOverOption;
        self.draggingX = x;
        self.draggingY = y;
        self.dragStarted = false
        ISMouseDrag.dragging = {}
        table.insert(ISMouseDrag.dragging, item);
        ISMouseDrag.draggingFocus = self;
        self.dragGrid = ItemGridUtil.findGridUnderMouse(self, x, y)
        return;
    end

    if self.dragging == nil and x >= 0 and y >= 0 and (x<=self.column3 and y <= self:getScrollHeight() - self.itemHgt) then

	elseif count == 0 then
		self.draggingMarquis = true;
		self.draggingMarquisX = x;
		self.draggingMarquisY = y;
		self.dragging = nil;
		self.draggedItems:reset()
		ISMouseDrag.dragging = nil;
		ISMouseDrag.draggingFocus = nil;
	end

	return true;
end

local og_mouseUp = ISInventoryPane.onMouseUp
function ISInventoryPane:onMouseUp(x, y)
	if self.player ~= 0 then return end
    
    local selfGrid = ItemGridUtil.findGridUnderMouse(self, x, y)
    if not ISMouseDrag.dragging or #ISMouseDrag.dragging > 1 or 
        not ISMouseDrag.draggingFocus or not ISMouseDrag.draggingFocus.dragGrid 
        or not ItemGridTransferUtil.shouldUseGridTransfer(selfGrid, ISMouseDrag.draggingFocus.dragGrid)
    then
        return og_mouseUp(self, x, y)
    end

    local playerObj = getSpecificPlayer(self.player)


    if ISMouseDrag.draggingFocus ~= self then
        if self:canPutIn() then         
            local item = ISMouseDrag.dragging[1]
            item = ItemGridUtil.convertItemStackToItem(item)
            local transfer = item:getContainer() and not self.inventory:isInside(item)
            if transfer then
                luautils.walkToContainer(self.inventory, self.player)
            end

            ItemGridTransferUtil.transferGridItemMouse(item, ISMouseDrag.draggingFocus.dragGrid, selfGrid, playerObj)
            self.selected = {};
            getPlayerLoot(self.player).inventoryPane.selected = {};
            getPlayerInventory(self.player).inventoryPane.selected = {};
        end
    
        if ISMouseDrag.draggingFocus then
            ISMouseDrag.draggingFocus:onMouseUp(0,0);
        end
        
        ISMouseDrag.draggingFocus = nil;
        ISMouseDrag.dragging = nil;
        return;
    elseif ISMouseDrag.draggingFocus == self then
        if self:canPutIn() then
            local item = ISMouseDrag.dragging[1]
            item = ItemGridUtil.convertItemStackToItem(item)
            
            luautils.walkToContainer(self.inventory, self.player)

            ItemGridTransferUtil.moveGridItemMouse(item, selfGrid, playerObj)
            self.selected = {};
            getPlayerLoot(self.player).inventoryPane.selected = {};
            getPlayerInventory(self.player).inventoryPane.selected = {};
        end
    end

	self.dragging = nil;
	self.draggedItems:reset();
	ISMouseDrag.dragging = nil;
    ISMouseDrag.draggingFocus.dragGrid = nil;
	ISMouseDrag.draggingFocus = nil;

	return true;
end

local og_onRightMouseUp = ISInventoryPane.onRightMouseUp
function ISInventoryPane:onRightMouseUp(x, y)
    if self.player ~= 0 then return end
    if self.mode ~= "grid" then
        return og_onRightMouseUp(self, x, y)
    end

    if self.selected == nil then
		self.selected = {}
	end

    local item = ItemGridUtil.findItemUnderMouse(self, x, y)
    if not item then 
        return
    end
    
	if self.toolRender then
		self.toolRender:setVisible(false)
	end
    
    local isInInv = self.inventory:isInCharacterInventory(getSpecificPlayer(self.player))
    local menu = ISInventoryPaneContextMenu.createMenu(self.player, isInInv, { item }, self:getAbsoluteX()+x, self:getAbsoluteY()+y+self:getYScroll());
    if menu and menu.numOptions > 1 and JoypadState.players[self.player+1] then
        menu.origin = self.inventoryPage
        menu.mouseOver = 1
        setJoypadFocus(self.player, menu)
    end

	return true;
end





















local og_createMenu = ISInventoryPaneContextMenu.createMenu
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)
    og_createMenu(player, isInPlayerInventory, items, x, y, origin)
    
    
    local item = items[1]
    if not item then return end

    if items[1].items then 
        item = items[1].items[1]
    end
    if not item then return end

    -- Pull a bunch of fields into local variables so we can view them in the debugger

    local itemCategory = item:getDisplayCategory()
    local itemDisplayName = item:getDisplayName()
    local itemFullType = item:getFullType()
    local itemWeight = item:getActualWeight()
    local itemType = item:getType()
    local itemKlass = item:getCat()

    return
end
