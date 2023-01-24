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
            self:clearGrids()

            local grids, gridType = ItemGrid.Create(self.inventory, self.player)
            self.grids = grids
            self.activeGridType = gridType

            for _, grid in ipairs(self.grids) do
                grid:registerInventoryPane(self)
                self:addChild(grid)
            end

            ItemGrid.UpdateItemGridPositions(self.grids)
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

local og_prerender = ISInventoryPane.prerender
function ISInventoryPane:prerender()
    og_prerender(self);
    if self.mode == "grid" then
        self.nameHeader:setVisible(false)
        self.typeHeader:setVisible(false)

        if self.childWindows then
            for _, child in ipairs(self.childWindows) do
                child:bringToTop()
            end
        end
    else
        self.nameHeader:setVisible(true)
        self.typeHeader:setVisible(true)
    end
end

local og_updateTooltip = ISInventoryPane.updateTooltip
function ISInventoryPane:updateTooltip()
	if self.mode ~= "grid" then
        return og_updateTooltip(self)
    end

    if not self:isReallyVisible() then
		return -- in the main menu
	end

    if ISMouseDrag.dragging then
        return
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
    if self.mode ~= "grid" then
        return og_onMouseDown(self, x, y)
    end
	return true;
end

local og_mouseUp = ISInventoryPane.onMouseUp
function ISInventoryPane:onMouseUp(x, y)
    if self.mode ~= "grid" then
        return og_mouseUp(self, x, y)
    end
    return true;
end

function ISInventoryPane:onMouseUpNoGrid(x, y)
    return og_mouseUp(self, x, y)
end

local og_onRightMouseUp = ISInventoryPane.onRightMouseUp
function ISInventoryPane:onRightMouseUp(x, y)
    if self.mode ~= "grid" then
        return og_onRightMouseUp(self, x, y)
    end
	return false;
end

local og_onMouseDoubleClick = ISInventoryPane.onMouseDoubleClick
function ISInventoryPane:onMouseDoubleClick(x, y)
	if self.mode ~= "grid" then
        return og_onMouseDoubleClick(self, x, y)
    end

    local grid = ItemGridUtil.findGridUnderMouse(self, x, y)
    if grid then
        grid:onMouseDoubleClick(grid:getMouseX(), grid:getMouseY())
    end
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

    local itemCategory = item:getDisplayCategory()
    local itemDisplayName = item:getDisplayName()
    local itemFullType = item:getFullType()
    local itemWeight = item:getActualWeight()
    local itemType = item:getType()
    local itemKlass = item:getCat()

    print ("itemCategory: " .. itemCategory)
    print ("itemDisplayName: " .. itemDisplayName)
    print ("itemFullType: " .. itemFullType)
    print ("itemWeight: " .. itemWeight)
    print ("itemType: " .. itemType)
    print ("itemKlass: " .. tostring(itemKlass))

    return
end

local og_close = ISInventoryPage.close
function ISInventoryPage:close()
    og_close(self)
    if self.inventoryPane.childWindows then
        for _, window in ipairs(self.inventoryPane.childWindows) do
            window:removeFromUIManager()
        end
        table.wipe(self.inventoryPane.childWindows)
    end
end
