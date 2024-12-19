require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISMouseDrag"
require "TimedActions/ISTimedActionQueue"
require "TimedActions/ISEatFoodAction"
require "ISUI/ISInventoryPane"
local OPT = require "InventoryTetris/Settings"

-- Aggressively ensure we load last
-- If the user has this mod enabled, I think its safe to assume they want it to take priority
Events.OnGameBoot.Add(function()
    local og_new = ISInventoryPane.new
    function ISInventoryPane:new(x, y, width, height, inventory, player)
        local o = og_new(self, x, y, width, height, inventory, player)
        o.tetrisWindowManager = TetrisWindowManager:new(o)
        o.gridContainerUis = {}
        return o
    end

    local og_createChildren = ISInventoryPane.createChildren
    function ISInventoryPane:createChildren()
        og_createChildren(self)

        self.scrollView = NotlocScrollView:new(0,0, self.width, self.height)
        self.scrollView:initialise()
        self:addChild(self.scrollView)
        self.scrollView:setAnchorLeft(true)
        self.scrollView:setAnchorRight(true)
        self.scrollView:setAnchorTop(true)
        self.scrollView:setAnchorBottom(true)
        self.scrollView.scrollSensitivity = 40


        self.expandAll:setVisible(false)
        self.collapseAll:setVisible(false)
        self.filterMenu:setVisible(false)

        self.onApplyGridScaleCallback = function(scale)
            self:onApplyGridScale(scale)
        end
        OPT.OnApplyGridScale:add(self.onApplyGridScaleCallback)

        self.onApplyContainerInfoScaleCallback = function(scale)
            self:onApplyContainerInfoScale(scale)
        end
        OPT.OnApplyContainerInfoScale:add(self.onApplyContainerInfoScaleCallback)
    end

    function ISInventoryPane:onApplyGridScale(scale)
        for _, gridContainerUi in ipairs(self.gridContainerUis) do
            gridContainerUi:onApplyGridScale(scale)
        end

        local windows = self:getChildWindows()
        for _, window in ipairs(windows) do
            window:onApplyGridScale(scale)
        end

        self:refreshContainer()
    end

    function ISInventoryPane:onApplyContainerInfoScale(scale)
        for _, gridContainerUi in ipairs(self.gridContainerUis) do
            gridContainerUi:onApplyContainerInfoScale(scale)
        end

        local windows = self:getChildWindows()
        for _, window in ipairs(windows) do
            window:onApplyContainerInfoScale(scale)
        end

        self:refreshContainer()
    end

    local og_refreshContainer = ISInventoryPane.refreshContainer
    function ISInventoryPane:refreshContainer()
        -- Do this for mod compatibility only, tetris has no use for this
        og_refreshContainer(self)

        -- Tetris time
        self:refreshItemGrids()
    end

    function ISInventoryPane:refreshItemGrids(forceFullRefresh)
        local oldGridContainerUis = {}
        for _, gridContainerUi in ipairs(self.gridContainerUis) do
            self.scrollView:removeScrollChild(gridContainerUi)
            oldGridContainerUis[gridContainerUi.inventory] = gridContainerUi
        end

        self.gridContainerUis = {}

        local inventories = {}

        if self.parent.onCharacter then
            if ISInventoryPage.applyBackpackOrder then
                self.parent:applyBackpackOrder()
            end

            local buttonsAndY = {}
            for _, button in ipairs(self.parent.backpacks) do
                table.insert(buttonsAndY, {button = button, y = button:getY()})
            end
            table.sort(buttonsAndY, function(a, b) return a.y < b.y end)

            for _, buttonAndY in ipairs(buttonsAndY) do
                local button = buttonAndY.button
                local inventory = button.inventory

                if inventory:getType() ~= "KeyRing" then            
                    table.insert(inventories, inventory)
                end
            end
        else
            inventories[1] = self.inventory
        end

        local y = 10
        for _, inventory in ipairs(inventories) do
            local itemGridContainerUi = not forceFullRefresh and oldGridContainerUis[inventory] or nil
            if not itemGridContainerUi then
                itemGridContainerUi = ItemGridContainerUI:new(inventory, self, self.player)
                itemGridContainerUi:initialise()
            end

            itemGridContainerUi:setY(y)
            itemGridContainerUi:setX(10)
            self.scrollView:addScrollChild(itemGridContainerUi)

            y = y + itemGridContainerUi:getHeight() + 8

            table.insert(self.gridContainerUis, itemGridContainerUi)
        end

        self.scrollView:setScrollHeight(y)
    end

    function ISInventoryPane:findContainerGridUiUnderMouse()
        if not self.gridContainerUis then return nil end
        for _, containerUi in ipairs(self.gridContainerUis) do
            if containerUi:isMouseOver() then
                return containerUi
            end
        end

        for _, window in ipairs(self:getChildWindows()) do
            if window:isMouseOver() then
                return window.gridContainerUi
            end
        end

        return nil
    end

    local og_prerender = ISInventoryPane.prerender
    function ISInventoryPane:prerender()
        og_prerender(self);
        self.nameHeader:setVisible(false)
        self.typeHeader:setVisible(false)
        
        -- Draw the version at the bottom left
        if self.parent.onCharacter then
            local version = "Inventory Tetris - " .. InventoryTetris.version
            self:drawText(version, 8, self.height - 18, 0.3, 0.3, 0.3, 0.82, UIFont.Small)
        end
    end

    local og_render = ISInventoryPane.render
    function ISInventoryPane:render()
        og_render(self)
        self.mode = "grid" -- Let a single frame pass before we start rendering the grid
    end

    local og_doButtons = ISInventoryPane.doButtons
    function ISInventoryPane:doButtons()
    end

    local og_updateTooltip = ISInventoryPane.updateTooltip
    function ISInventoryPane:updateTooltip()
        if self.mode ~= "grid" or not self.gridContainerUis then
            return og_updateTooltip(self)
        end

        if not self:isReallyVisible() then
            return -- in the main menu
        end

        if self.parent:isMouseOverEquipmentUi() then
            return self.parent.equipmentUi:updateTooltip()
        else
            local item = nil

            if not self.doController and not self.dragging and not self.draggingMarquis then
                local containerGrid = self:findContainerGridUiUnderMouse()
                if containerGrid then
                    local stack = containerGrid:findGridStackUnderMouse()
                    item = stack and ItemStack.getFrontItem(stack, containerGrid.inventory) or nil
                end
            end

            self:doTooltipForItem(item)
        end
    end

    function ISInventoryPane:doTooltipForItem(item)
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

        if item and not DragAndDrop.getDraggedStack() then
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

        for _, gridContainerUi in ipairs(self.gridContainerUis) do
            local containerUi = self:findContainerGridUiUnderMouse()
            if containerUi then
                return containerUi:onMouseDoubleClick(containerUi:getMouseX(), containerUi:getMouseY())
            end
        end
    end

    local og_onMouseWheel = ISInventoryPane.onMouseWheel
    function ISInventoryPane:onMouseWheel(del)
        return false -- Disabled scrolling to rotate items because of scrollviews

        --if DragAndDrop.isDragging() then
        --   DragAndDrop.rotateDraggedItem()
        --  return true;
        --end
        --return og_onMouseWheel(self, del)
    end

    local og_getActualItems = ISInventoryPane.getActualItems
    function ISInventoryPane.getActualItems(items)
        if items.items then
            return og_getActualItems(items.items)
        end
        return og_getActualItems(items)
    end

    local og_transferItemsByWeight = ISInventoryPane.transferItemsByWeight
    function ISInventoryPane:transferItemsByWeight(items, container)
        ISInventoryTransferAction.globalTetrisRules = true
        og_transferItemsByWeight(self, items, container)
        ISInventoryTransferAction.globalTetrisRules = false
    end

    function ISInventoryPane:getChildWindows()
        if self.tetrisWindowManager then
            return self.tetrisWindowManager.childWindows
        end
        return {}
    end
end)