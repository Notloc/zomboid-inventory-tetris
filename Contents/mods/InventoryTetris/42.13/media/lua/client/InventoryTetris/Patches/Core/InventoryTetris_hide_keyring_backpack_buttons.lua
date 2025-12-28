---@diagnostic disable: duplicate-set-field

require("ISUI/ISInventoryPage")
require("ISUI/ISInventoryPaneContextMenu")

Events.OnGameBoot.Add(function()

    -- Ensure the keyringList is reset on refresh
    local og_refreshBackpacks = ISInventoryPage.refreshBackpacks
    function ISInventoryPage:refreshBackpacks()
        self.tetrisKeyRings = self.tetrisKeyRings or {}
        table.wipe(self.tetrisKeyRings)
        og_refreshBackpacks(self)
    end

    -- Removes the keyring backpack buttons from the visible backpack buttons in the inventory page
    -- Adds them to a separate list for later use
    local og_addContainerButton = ISInventoryPage.addContainerButton
    function ISInventoryPage:addContainerButton(container, texture, name, tooltip)
        local button = og_addContainerButton(self, container, texture, name, tooltip)

        local containingItem = container:getContainingItem()
        local isKeyRing = containingItem and containingItem:hasTag(ItemTag.KEY_RING)
        if (isKeyRing) then
            self.containerButtonPanel:removeChild(button)
            self.backpacks[#self.backpacks] = nil
            -- Prepend the button to buttonPool.
            --   There is an awkward bug where the selected backpack is double refreshed and
            --   if the button objects are not in the exact same order between refreshes a different backpack will be opened.
            table.insert(self.buttonPool, 1, button)

            self.tetrisKeyRings = self.tetrisKeyRings or {}
            table.insert(self.tetrisKeyRings, container)
        end

        return button;
    end

    -- Inject the keyrings back into the list of containers for context menu operations
    local og_getContainers = ISInventoryPaneContextMenu.getContainers

    ---@param character IsoPlayer
    ---@return ArrayList|nil
    ISInventoryPaneContextMenu.getContainers = function(character)
        local containerList = og_getContainers(character)
        if not containerList then
            return nil
        end

        local playerNum = character:getPlayerNum()
        local invPage = getPlayerInventory(playerNum).inventoryPane.inventoryPage
        if not invPage.tetrisKeyRings then
            return containerList
        end

        for _, keyRingContainer in ipairs(invPage.tetrisKeyRings) do
            containerList:add(keyRingContainer)
        end

        return containerList
    end
end)
