local og_createChildren = ISInventoryPage.createChildren
function ISInventoryPage:createChildren()
    og_createChildren(self)
    
    if self.onCharacter then
        self.equipmentUi = EquipmentUI:new(0, 15, 250, 400, self.inventoryPane, self.player);
        self.equipmentUi:initialise()
        self:addChild(self.equipmentUi)
        
        self.dragItemRenderer = DragItemRenderer:new(self.equipmentUi, self.player);
        self.dragItemRenderer:initialise();
        self.dragItemRenderer:addToUIManager();

        self.inventoryPane:setX(250)
    end
end

local og_update = ISInventoryPage.update
function ISInventoryPage:update()
    og_update(self)
    if ISMouseDrag.dragging and ISMouseDrag.dragging.items then
        self.collapseCounter = 0;
        if isClient() and self.isCollapsed then
            self.inventoryPane.inventory:requestSync();
        end
        self.isCollapsed = false;
        self:clearMaxDrawHeight();
        self.collapseCounter = 0;
    end
end

local og_refreshBackpacks = ISInventoryPage.refreshBackpacks
function ISInventoryPage:refreshBackpacks()
    og_refreshBackpacks(self)
    if self.inventoryPane.tetrisWindowManager then
        local inventoryMap = {}
        for _, backpack in ipairs(self.backpacks) do
            inventoryMap[backpack.inventory] = true
        end

        self.inventoryPane.tetrisWindowManager:closeIfNotInMap(inventoryMap)
    end
end

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