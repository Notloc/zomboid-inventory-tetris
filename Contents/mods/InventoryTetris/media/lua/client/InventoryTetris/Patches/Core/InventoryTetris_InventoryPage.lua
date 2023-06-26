---@diagnostic disable: duplicate-set-field

Events.OnGameBoot.Add(function()

	local og_createChildren = ISInventoryPage.createChildren
	function ISInventoryPage:createChildren()
		og_createChildren(self)

		--- Button to replace the "LOOT ALL" and ""TRANSFER ALL" buttons when container needs to be searched.
		self.tetrisSearchButton = ISButton:new(3 + self:titleBarHeight() * 2 + 1, 0, 50, self:titleBarHeight(), getText("UI_tetris_buttons_search"), self, ISInventoryPage.tetrisSearchAll)
		self.tetrisSearchButton:initialise()
		self.tetrisSearchButton.borderColor.a = 0.0
		self.tetrisSearchButton.backgroundColor.a = 0.0
		self.tetrisSearchButton.backgroundColorMouseOver.a = 0.7
		self.tetrisSearchButton:setVisible(false)
		self:addChild(self.tetrisSearchButton)

		if self.onCharacter then
            self.dragItemRenderer = DragItemRenderer:new(self.equipmentUi, self.player);
			self.dragItemRenderer:initialise();
			self.dragItemRenderer:addToUIManager();
		end
	end

	function ISInventoryPage:tetrisSearchAll()
		for _, containerUi in ipairs(self.inventoryPane.gridContainerUis) do
			containerUi.containerGrid:searchAll()
		end
	end

	function ISInventoryPage:checkTetrisSearch()
		self.needSearch = false
        if not self.inventoryPane.gridContainerUis or not SandboxVars.InventoryTetris.EnableSearch then
            return
        end

        for _, containerUi in ipairs(self.inventoryPane.gridContainerUis) do
            local isLootOrSelected = not self.onCharacter or containerUi.inventory == self.inventoryPane.inventory
            if isLootOrSelected then
                self.needSearch = containerUi.containerGrid:areAnyUnsearched()
                if self.needSearch then
                    return
                end
            end
        end
	end

	function ISInventoryPage:updateLootButtonsForTetrisSearch()
        local needsSearch = self.needSearch or self.sisterPage.needSearch
        if self.onCharacter then
			self.transferAll:setVisible(not needsSearch)
            self.tetrisSearchButton:setX(self.transferAll:getX())

            -- Support for "Easy Drop n' Loot"
			if self.EDNLDropItems then
				self.EDNLDropItems:setVisible(not needsSearch)
			end
		else
			self.lootAll:setVisible(not needsSearch)
			self.removeAll:setVisible(not needsSearch and self:isRemoveButtonVisible())

			-- Support for "Easy Drop n' Loot"
			if self.EDNLLootItems then
				self.EDNLLootItems:setVisible(not needsSearch)
			end
		end

		self.tetrisSearchButton:setVisible(needsSearch and self.needSearch)
	end

	local og_prerender = ISInventoryPage.prerender
	function ISInventoryPage:prerender()
		og_prerender(self)
		self:updateLootButtonsForTetrisSearch()
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
