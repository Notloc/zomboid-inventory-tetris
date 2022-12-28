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
    self:updateActiveGrids()

    og_refreshContainer(self)
    if self.mode == "grid" then
        self:updateGridPositions()
    end
end

function ISInventoryPane:updateActiveGrids()
    self.activeGrids = {}
    for i=1,self.inventory:getWidth() do
        for j=1,self.inventory:getHeight() do
            local grid = self.inventory:getGrid(i, j)
            if grid and grid.items and #grid.items > 0 then
                table.insert(self.activeGrids, grid)
            end
        end
    end

    self.mode = isGroundContainer(self) and "details" or "grid"
end


local og_prerender = ISInventoryPane.prerender
function ISInventoryPane:prerender()
    og_prerender(self);
    if self.mode == "grid" then
        self:renderBackGrid();
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
        self:renderGridItems()
        self:renderDragItem()
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
		item = ItemGridUtil.findItemUnderMouse(self.inventory, x, y)
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

    if self.grselected == nil then
		self.selected = {}
    end

    local item = ItemGridUtil.findItemUnderMouse(self.inventory, x, y)
    if item then
        self.dragging = self.mouseOverOption;
        self.draggingX = x;
        self.draggingY = y;
        self.dragStarted = false
        ISMouseDrag.dragging = {}
        table.insert(ISMouseDrag.dragging, item);
        ISMouseDrag.draggingFocus = self;
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

    if not ISMouseDrag.dragging or #ISMouseDrag.dragging > 1 then
        return og_mouseUp(self, x, y)
    end

    local playerObj = getSpecificPlayer(self.player)

    if ISMouseDrag.draggingFocus ~= self and ISMouseDrag.draggingFocus ~= nil then
        if self:canPutIn() then         
            local item = ISMouseDrag.dragging[1]
            item = ItemGridUtil.convertItemStackToItem(item)
            local transfer = item:getContainer() and not self.inventory:isInside(item)
            if transfer then
                luautils.walkToContainer(self.inventory, self.player)
            end

            ItemGridTransferUtil.transferGridItem(item, ISMouseDrag.draggingFocus, self, playerObj)
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
    end

	self.dragging = nil;
	self.draggedItems:reset();
	ISMouseDrag.dragging = nil;
	ISMouseDrag.draggingFocus = nil;

	return true;
end
























local og_createMenu = ISInventoryPaneContextMenu.createMenu
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)
    og_createMenu(player, isInPlayerInventory, items, x, y, origin)
    
    
    local item = items[1]
    
    if items[1].items then 
        item = items[1].items[1]
    end

    -- Pull a bunch of fields into local variables so we can view them in the debugger

    local itemCategory = item:getDisplayCategory()
    local itemDisplayName = item:getDisplayName()
    local itemFullType = item:getFullType()
    local itemWeight = item:getActualWeight()
    local itemType = item:getType()
    local itemKlass = item:getCat()

    return
end
