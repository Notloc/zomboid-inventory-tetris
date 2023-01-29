require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISMouseDrag"
require "TimedActions/ISTimedActionQueue"
require "TimedActions/ISEatFoodAction"
require "ISUI/ISInventoryPane"

local function isGroundContainer(inventoryPane)
    return not inventoryPane.inventory or inventoryPane.inventory:getType() == 'floor_disabled'
end


local og_new = ISInventoryPane.new
function ISInventoryPane:new(x, y, width, height, inventory, player)
    local o = og_new(self, x, y, width, height, inventory, player)
    o.tetrisWindowManager = TetrisWindowManager:new(o)
    return o
end

local og_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
    self.mode = isGroundContainer(self) and "details" or "grid"
    og_refreshContainer(self) -- TODO: Can I skip this?
    self:refreshItemGrids()
end

function ISInventoryPane:refreshItemGrids()
    local sameInventory = self.previousGridInventory == self.inventory
    if self.mode == "grid" and not sameInventory then
        if self.gridContainerUi then
            self:removeChild(self.gridContainerUi)
        end
        
        self.gridContainerUi = ItemGridContainerUI:new(self.inventory, self, self.player)
        self.gridContainerUi:initialise()
        self:addChild(self.gridContainerUi)
        
        self.previousGridInventory = self.inventory

    elseif self.mode ~= "grid" and self.gridContainerUi then
        self:removeChild(self.gridContainerUi)
        self.gridContainerUi = nil
        self.previousGridInventory = nil
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

local og_updateTooltip = ISInventoryPane.updateTooltip
function ISInventoryPane:updateTooltip()
	if self.mode ~= "grid" or not self.gridContainerUi then
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
		item = ItemGridUiUtil.findItemUnderMouse(self.gridContainerUi.gridUis, x, y)
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

    local gridUi = ItemGridUiUtil.findGridUiUnderMouse(self.gridContainerUi.gridUis, x, y)
    if gridUi then
        gridUi:onMouseDoubleClick(gridUi:getMouseX(), gridUi:getMouseY())
    end
end


-- Just for debugging
local og_createMenu = ISInventoryPaneContextMenu.createMenu
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)
    local menu = og_createMenu(player, isInPlayerInventory, items, x, y, origin)
    
    
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

    TetrisDevTool.insertEditItemOption(menu, item)

    return menu
end


local og_onMouseWheel = ISInventoryPane.onMouseWheel
function ISInventoryPane:onMouseWheel(del)
    if ISMouseDrag.dragStarted then
        if ISMouseDrag.rotateDrag then
            ISMouseDrag.rotateDrag = false
        else
            ISMouseDrag.rotateDrag = true
        end
        return true;
    end
    return og_onMouseWheel(self, del)
end



-- WINDOW MANAGER RELATED

local og_bringToTop = ISInventoryPage.bringToTop
function ISInventoryPage:bringToTop()
    og_bringToTop(self)
    if self.inventoryPane.tetrisWindowManager then
        self.inventoryPane.tetrisWindowManager:keepChildWindowsOnTop()
    end
end

local og_close = ISInventoryPage.close
function ISInventoryPage:close()
    og_close(self)
    if self.inventoryPane.tetrisWindowManager then
        self.inventoryPane.tetrisWindowManager:closeAll()
    end
end
