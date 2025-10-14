local TetrisContainerData = require("InventoryTetris/Data/TetrisContainerData")

-- This patch disables the carry weight capacity check for all containers except for the player's main inventory.
-- This implementation avoids lasting changes to the container's capacity by temporarily setting it to a very high value during the check.
-- Includes KeyringFix for proper keyring and moveable item handling.
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

-- Spoofs the game's capacity check by pretending the target container is the floor, which does not enforce capacity limits.
local function disableCarryWeightOnContainer(container, callback, ...)
    if instanceof(container, "InventoryContainer") then
        container = container:getInventory()
    end

    local originalCapacity = container:getCapacity()
    local originalType = container:getType()

    -- Skip player's main inventory or fragile containers or if the option is disabled
    if not container or originalType == "floor" or SandboxVars.InventoryTetris.EnforceCarryWeight then
        return callback(...)
    end

    local containerDef = TetrisContainerData.getContainerDefinition(container)
    if containerDef.isFragile then
        return callback(...)
    end

    if originalCapacity == 50 then
        container:setCapacity(49) -- 49 so we don't match the real floor's key of floor_50
    end
    container:setType("floor") -- Pretend we're the floor
    TetrisContainerData.setContainerDefinition(container, containerDef)

    local results = {pcall(callback, ...)}

    TetrisContainerData.setContainerDefinition(container, nil)
    container:setType(originalType)
    if originalCapacity == 50 then
        container:setCapacity(originalCapacity)
    end

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
        local container = self.inventory
        return disableCarryWeightOnContainer(container, og_canPutIn_pane, self)
    end

    local og_update_draggedItems = ISInventoryPaneDraggedItems.update
    function ISInventoryPaneDraggedItems:update()
        local container = self:getDropContainer()
        return disableCarryWeightOnContainer(container, og_update_draggedItems, self)
    end

    require("ISUI/ISInventoryPage")
    local og_canPutIn_page = ISInventoryPage.canPutIn
    function ISInventoryPage:canPutIn()
        local container = self.mouseOverButton and self.mouseOverButton.inventory or nil
        return disableCarryWeightOnContainer(container, og_canPutIn_page, self)
    end

    require("TimedActions/ISInventoryTransferAction")
    local og_isValid = ISInventoryTransferAction.isValid
    function ISInventoryTransferAction:isValid()
        -- Validate required fields
        if not self or not self.destContainer or not self.item or not self.character then
            return false
        end

        -- Check if destination is a keyring
        local destContainerItem = self.destContainer:getContainingItem()
        local isKeyRing = destContainerItem and 
                         type(destContainerItem.hasTag) == "function" and 
                         destContainerItem:hasTag("KeyRing")
        
        -- Keyrings bypass all restrictions (they don't use grids)
        if isKeyRing then
            return true
        end

        -- Check if item is a Moveable
        local isMoveable = instanceof(self.item, "Moveable")
        local destDef = TetrisContainerData.getContainerDefinition(self.destContainer)
        
        -- Non-floor containers with moveables need special handling
        if destDef and destDef.trueType ~= "floor" and isMoveable then
            -- Temporarily exclude Moveable from instanceof checks
            local valid
            _G.ModScope.withInstanceofExclusion(function()
                valid = disableCarryWeightOnContainer(self.destContainer, og_isValid, self)
            end, "Moveable")
            
            if not valid then
                return false
            end
        else
            -- Standard validation with carry weight disabled
            if not disableCarryWeightOnContainer(self.destContainer, og_isValid, self) then
                return false
            end
        end
        
        -- Skip Tetris validation if not enforced
        if not self.enforceTetrisRules then
            return true
        end

        -- Additional Tetris-specific validation
        return self:validateTetrisRules()
    end

    require("ISUI/ISInventoryPaneContextMenu")
    local og_hasRoomForAny = ISInventoryPaneContextMenu.hasRoomForAny
    function ISInventoryPaneContextMenu.hasRoomForAny(playerObj, container, items)
        return disableCarryWeightOnContainer(container, og_hasRoomForAny, playerObj, container, items)
    end

    require("Foraging/ISBaseIcon")
    local og_doContextMenu = ISBaseIcon.doContextMenu
    function ISBaseIcon:doContextMenu(_context)
        local plInventory = self.character:getInventory()
        return disableCarryWeightOnContainer(plInventory, og_doContextMenu, self, _context)
    end

    require("ISUI/ISVehicleMenu")
    local og_moveItemsOnSeat = ISVehicleMenu.moveItemsOnSeat
    function ISVehicleMenu.moveItemsOnSeat(seat, newSeat, playerObj, moveThem, itemListIndex)
        local container = newSeat:getItemContainer()
        return disableCarryWeightOnContainer(container, og_moveItemsOnSeat, seat, newSeat, playerObj, moveThem, itemListIndex)
    end
end)
