---@diagnostic disable: duplicate-set-field

Events.OnGameBoot.Add(function()

    local og_createChildren = ISInventoryPage.createChildren
    function ISInventoryPage:createChildren()
        og_createChildren(self)

        --- Button to replace the "LOOT ALL" and ""TRANSFER ALL" buttons when container needs to be searched.
        self.searchButton = ISButton:new(3 + self:titleBarHeight() * 2 + 1, 0, 50, self:titleBarHeight(), getText("UI_tetris_buttons_search"), self, ISInventoryPage.searchAll)
        self.searchButton:initialise()
        self.searchButton.borderColor.a = 0.0
        self.searchButton.backgroundColor.a = 0.0
        self.searchButton.backgroundColorMouseOver.a = 0.7
        self:addChild(self.searchButton)
        self.searchButton:setVisible(false)

        if self.onCharacter then
            self.dragItemRenderer = DragItemRenderer:new(self.equipmentUi, self.player);
            self.dragItemRenderer:initialise();
            self.dragItemRenderer:addToUIManager();

            -- Set Search to Transfer All button's location
            self.searchButton:setX(self.transferAll:getX())
        else
            -- The loot panel is created 2nd always, so we can run this here
            --- Names are reused in SpiffUI-Inventory
            ---- Assign the player's inventory reference
            self.friend = getPlayerInventory(self.player)
            ---- Provide a reference to this loot panel to the player's inventory
            self.friend.friend = self
            
        end
    end

    --- Perform search through all Container Grids
    function ISInventoryPage:searchAll()
        for _, containerUi in ipairs(self.inventoryPane.gridContainerUis) do
            containerUi.containerGrid:searchAll()
        end
    end

    --- Checks if any grids need searching in the active inventory, store it in var needSearch
    function ISInventoryPage:checkNeedSearch()
        self.needSearch = false -- default false
        if self.inventoryPane.gridContainerUis and SandboxVars.InventoryTetris.EnableSearch then
            if self.onCharacter then
                for _, containerUi in ipairs(self.inventoryPane.gridContainerUis) do
                    -- Only check for the currently selected
                    if containerUi.inventory == containerUi.inventoryPane.inventory then
                        self.needSearch = containerUi.containerGrid:areAnyUnsearched()
                        return
                    end
                end
            else
                -- Do all, return true on the first unsearched
                for _, containerUi in ipairs(self.inventoryPane.gridContainerUis) do
                    if containerUi.containerGrid:areAnyUnsearched() then
                        self.needSearch = true
                        return
                    end
                end
            end
        end
    end

    -- true if buttons should be hidden, false if shown
    function ISInventoryPage:hideLootButtons(val)
        -- invert
        val = not val
        if self.onCharacter then
            -- set transfer
            self.transferAll:setVisible(val)
            if self.EDNLDropItems  then
                self.EDNLDropItems:setVisible(val)
            end
        else
            -- set loot
            self.lootAll:setVisible(val)
            -- Handle Remove
            self.removeAll:setVisible((val and self:isRemoveButtonVisible()) or false)

            -- Support for "Easy Drop n' Loot" too
            if self.EDNLLootItems then
                self.EDNLLootItems:setVisible(val)
            end
        end
        -- set search buttons
        self.searchButton:setVisible((not val and self.needSearch) or false)       
    end

    -- override to handle the buttons
    local og_prerender = ISInventoryPage.prerender
    function ISInventoryPage:prerender()
        og_prerender(self)
        --- Checks if any containers need to be searched, show/hide the respective buttons
        ---- The Loot panel is what updates both
        self:hideLootButtons(self.needSearch or self.friend.needSearch)
        if self.onCharacter then
            -- Set the Search All button to the same place as "Transfer All" (resize)
            self.searchButton:setX(self.transferAll:getX())
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

            --- Checks if active container needs to be searched on refresh, cache result
            self:checkNeedSearch()
        end
    end

    local og_update = ISInventoryPage.update
    function ISInventoryPage:update()
        og_update(self)
        if DragAndDrop.getDraggedStack() then
            self.collapseCounter = 0;
            if isClient() and self.isCollapsed then
                self.inventoryPane.inventory:requestSync();
            end
            self.isCollapsed = false;
            self:clearMaxDrawHeight();
            self.collapseCounter = 0;
        end
    end

    local og_addContainerButton = ISInventoryPage.addContainerButton
    function ISInventoryPage:addContainerButton(container, texture, name, tooltip)
        local button = og_addContainerButton(self, container, texture, name, tooltip)

        if (container:getType() == "KeyRing") then
            self:removeChild(button)
            self.backpacks[#self.backpacks] = nil
            -- Prepend the button to buttonPool.
            --   There is an awkward bug where the selected backpack is double refresh and
            --   if the button objects are not in the exact same order between refreshes a different backpack will be opened.
            table.insert(self.buttonPool, 1, button)
        end

        return button;
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

    local og_onRightMouseDownOutside = ISInventoryPage.onRightMouseDownOutside
    function ISInventoryPage:onRightMouseDownOutside(x, y)
        og_onRightMouseDownOutside(self, x, y)
        if (self.sisterPage and self.sisterPage:isMouseOver()) then
            self.isCollapsed = false;
            self:clearMaxDrawHeight();
        end
    end

    local og_onMouseDownOutside = ISInventoryPage.onMouseDownOutside
    function ISInventoryPage:onMouseDownOutside(x, y)
        og_onMouseDownOutside(self, x, y)

        if (self.sisterPage and self.sisterPage:isMouseOver()) then
            self.isCollapsed = false;
            self:clearMaxDrawHeight();
        end
    end

    local og_onKeyPressed = ISInventoryPage.onKeyPressed
    function ISInventoryPage.onKeyPressed(key)
        local closeKey = getCore():getKey("tetris_close_window")
        if key == closeKey then
            local closedAWindow = getPlayerInventory(0).inventoryPane.tetrisWindowManager:closeTopWindow()
            if closedAWindow and closeKey == getCore():getKey("Toggle Inventory") then
                return
            end
        end
        og_onKeyPressed(key)
    end

    Events.OnKeyPressed.Remove(og_onKeyPressed);
    Events.OnKeyPressed.Add(ISInventoryPage.onKeyPressed);

end);