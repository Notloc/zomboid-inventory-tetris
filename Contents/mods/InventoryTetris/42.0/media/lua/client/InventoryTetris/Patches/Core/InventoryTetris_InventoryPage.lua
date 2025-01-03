-- Injects the new control scheme into the InventoryPage class.
---@diagnostic disable: duplicate-set-field

Events.OnGameBoot.Add(function()

	function ISInventoryPage:tetrisGetSisterPage()
		local inv = getPlayerInventory(self.player)
		if inv ~= self then
			return inv
		end
		return getPlayerLoot(self.player)
	end

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

		NotlocControllerNode
			:injectControllerNode(self, true)
			:setChildrenNodeProvider(function()
				local children = {}
				for _, containerUi in ipairs(self.inventoryPane.gridContainerUis) do
					table.insert(children, containerUi.controllerNode)
					if not containerUi.overflowRenderer:isEmpty() then
						table.insert(children, containerUi.overflowRenderer.controllerNode)
					end
				end
				return children
			end)
			:setJoypadDownHandler(function(self, button)
				local playerInventory = getPlayerInventory(self.player)
				local lootInventory = getPlayerLoot(self.player)
				if button == Joypad.LBumper and self ~= playerInventory then
					setJoypadFocus(self.player, playerInventory)
					return true
				elseif button == Joypad.RBumper and self ~= lootInventory then
					setJoypadFocus(self.player, lootInventory)
					return true
				end

				-- Move to the next container input
				if self == playerInventory and button == Joypad.LBumper or self == lootInventory and button == Joypad.RBumper then
					-- Find the lowest container (support for ReorderContainers mod)
					local lastButton = self.selectedButton
					for _, button in ipairs(self.backpacks) do
						if button:getY() > lastButton:getY() then
							lastButton = button
						end
					end

					if lastButton == self.selectedButton and self.inventoryPane.tetrisWindowManager:hasOpenWindows() then
						self.inventoryPane.tetrisWindowManager:focusFirstWindow()
					end
				end

				return false
			end)
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
		local sisterPage = self:tetrisGetSisterPage()
        local needsSearch = self.needSearch or (sisterPage and sisterPage.needSearch)
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
			self.inventoryPane.tetrisWindowManager:closeIfInvalid(self)
		end

		if self.controllerNode and self.controllerNode.isFocused then
			self.controllerNode:refreshSelectedChild()
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
			--   There is an awkward bug where the selected backpack is double refreshed and
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

	local og_setVisible = ISInventoryPage.setVisible
	function ISInventoryPage:setVisible(state)
		og_setVisible(self, state)
		if not state and self.inventoryPane.tetrisWindowManager then
			self.inventoryPane.tetrisWindowManager:closeAll()
		end
	end

	local og_onRightMouseDownOutside = ISInventoryPage.onRightMouseDownOutside
	function ISInventoryPage:onRightMouseDownOutside(x, y)
		og_onRightMouseDownOutside(self, x, y)
		local sisterPage = self:tetrisGetSisterPage()
		if (sisterPage and sisterPage:isMouseOver()) then
			self.isCollapsed = false;
			self:clearMaxDrawHeight();
		end
	end

	local og_onMouseDownOutside = ISInventoryPage.onMouseDownOutside
	function ISInventoryPage:onMouseDownOutside(x, y)
		og_onMouseDownOutside(self, x, y)
		local sisterPage = self:tetrisGetSisterPage()
		if (sisterPage and sisterPage:isMouseOver()) then
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

	local og_selectNextContainer = ISInventoryPage.selectNextContainer
	function ISInventoryPage:selectNextContainer()
		og_selectNextContainer(self)
		if self.controllerNode.isFocused then
			self.controllerNode:refreshSelectedChild()
		end
	end

	local og_selectContainer = ISInventoryPage.selectContainer
	function ISInventoryPage:selectContainer(button)
		og_selectContainer(self, button)
		self.inventoryPane:scrollToContainer(button.inventory)

		-- Move cursor to the selected container when using a controller.
		if self.joyfocus then
			for i, containerUi in ipairs(self.inventoryPane.gridContainerUis) do
				if containerUi.inventory == button.inventory then
					self.controllerNode:setSelectedChild(containerUi.controllerNode)
					return
				end
			end
		end
	end

	Events.OnKeyPressed.Remove(og_onKeyPressed);
	Events.OnKeyPressed.Add(ISInventoryPage.onKeyPressed);
end);
