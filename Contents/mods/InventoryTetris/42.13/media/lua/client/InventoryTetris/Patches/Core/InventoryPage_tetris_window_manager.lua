local TetrisWindowManager = require("InventoryTetris/UI/Windows/TetrisWindowManager")

---@class(partial) ISInventoryPane
---@field tetrisWindowManager TetrisWindowManager

Events.OnGameStart.Add(function()

    local og_createChildren = ISInventoryPage.createChildren
    function ISInventoryPage:createChildren()
        og_createChildren(self)

        
        ---@diagnostic disable-next-line: undefined-field
        ---@type integer
        local playerNum = self.player

        self.inventoryPane.tetrisWindowManager = TetrisWindowManager:new(self, playerNum)
    end

    -- TODO: Move the manager and this function to the Page instead of the Pane
    -- NOTE that this is on PANE, not PAGE
    function ISInventoryPane:getChildWindows()
        if self.tetrisWindowManager then
            return self.tetrisWindowManager.childWindows
        end
        return {}
    end

end)