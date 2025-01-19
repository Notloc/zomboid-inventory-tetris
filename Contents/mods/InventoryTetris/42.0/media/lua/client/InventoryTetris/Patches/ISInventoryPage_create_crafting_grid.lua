Events.OnGameBoot.Add(function()

    local og_createChildren = ISInventoryPage.createChildren

    ---@diagnostic disable-next-line: duplicate-set-field
    function ISInventoryPage:createChildren()
        og_createChildren(self)
        if self.onCharacter then
            self:createTetrisCraftingGrid()
        end
    end

    function ISInventoryPage:createTetrisCraftingGrid()
        local craftingGrid = TetrisCraftingGridPanel:new(250, self.inventoryPane, self.player)
        craftingGrid:addToInventoryPage(self)

        self.tetrisCraftingGrid = craftingGrid

        local ogOnDestroy = self.removeFromUIManager
        function self:removeFromUIManager()
            ogOnDestroy(self)
            self.tetrisCraftingGrid:removeFromUIManager()
        end

    end

end)