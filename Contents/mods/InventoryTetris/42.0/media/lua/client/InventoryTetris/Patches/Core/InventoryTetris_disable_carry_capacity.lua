-- This patch disables the carry weight capacity check for all containers except for the player's main inventory.
-- This implementation avoids lasting changes to the container's capacity by temporarily setting it to a very high value during the check.
---@diagnostic disable: duplicate-set-field

local function isPlayerInv(container)
    local player1 = getSpecificPlayer(0)
    local player2 = getSpecificPlayer(1)
    local player3 = getSpecificPlayer(2)
    local player4 = getSpecificPlayer(3)

    local inv1 = player1 and player1:getInventory() or nil
    local inv2 = player2 and player2:getInventory() or nil
    local inv3 = player3 and player3:getInventory() or nil
    local inv4 = player4 and player4:getInventory() or nil

    return container == inv1 or container == inv2 or container == inv3 or container == inv4
end

-- Sets the container's capacity to a very high value, calls the callback function, and then resets the container's capacity
-- Even if an error occurs, the container's capacity will be reset to its original value
local function disableCarryWeightSafe(container, callback, ...)
    -- Skip player's main inventory or fragile containers or if the option is disabled
    if not container or SandboxVars.InventoryTetris.EnforceCarryWeight or isPlayerInv(container) then
        return callback(...)
    end
    local containerDef = TetrisContainerData.getContainerDefinition(container)
    if containerDef.isFragile then
        return callback(...)
    end

    local originalCapacity = container:getCapacity()
    container:setCapacity(99995)
    -- Because definition is retrieved and calculated by capacity we set it manually here to avoid issues
    TetrisContainerData.setContainerDefinition(container, containerDef)

    local results = {pcall(callback, ...)}

    TetrisContainerData.setContainerDefinition(container, nil)
    container:setCapacity(originalCapacity)

    if results[1] then
        return unpack(results, 2)
    else
        error(results[2])
    end
end

-- All vanilla functions that I found that check the container's capacity
Events.OnGameStart.Add(function()
    require("ISUI/ISInventoryPane")
    local og_canPutIn_pane = ISInventoryPane.canPutIn
    function ISInventoryPane:canPutIn()
        return disableCarryWeightSafe(self.inventory, og_canPutIn_pane, self)
    end

    local og_update_draggedItems = ISInventoryPaneDraggedItems.update
    function ISInventoryPaneDraggedItems:update()
        local container = self:getDropContainer()
        return disableCarryWeightSafe(container, og_update_draggedItems, self)
    end

    require("ISUI/ISInventoryPage")
    local og_canPutIn_page = ISInventoryPage.canPutIn
    function ISInventoryPage:canPutIn()
        local container = self.mouseOverButton and self.mouseOverButton.inventory or nil
        return disableCarryWeightSafe(container, og_canPutIn_page, self)
    end

    require("TimedActions/ISInventoryTransferAction")
    local og_isValid = ISInventoryTransferAction.isValid
    function ISInventoryTransferAction:isValid()
        return disableCarryWeightSafe(self.destContainer, og_isValid, self)
    end

    require("ISUI/ISInventoryPaneContextMenu")
    local og_hasRoomForAny = ISInventoryPaneContextMenu.hasRoomForAny
    function ISInventoryPaneContextMenu.hasRoomForAny(playerObj, container, items)
        return disableCarryWeightSafe(container, og_hasRoomForAny, playerObj, container, items)
    end

    require("Foraging/ISBaseIcon")
    local og_doContextMenu = ISBaseIcon.doContextMenu
    function ISBaseIcon:doContextMenu(_context)
        local plInventory = self.character:getInventory();
        return disableCarryWeightSafe(plInventory, og_doContextMenu, self, _context)
    end

    require("ISUI/ISVehicleMenu")
    local og_moveItemsOnSeat = ISVehicleMenu.moveItemsOnSeat
    function ISVehicleMenu.moveItemsOnSeat(seat, newSeat, playerObj, moveThem, itemListIndex)
        local container = newSeat:getItemContainer()
        return disableCarryWeightSafe(container, og_moveItemsOnSeat, seat, newSeat, playerObj, moveThem, itemListIndex)
    end
end)
