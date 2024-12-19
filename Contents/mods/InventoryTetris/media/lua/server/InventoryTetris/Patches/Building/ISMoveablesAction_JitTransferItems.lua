require "BuildingObjects/ISMoveableCursor"
require "Moveables/ISMoveablesAction"
require "Notloc/NotUtil"

-- Transfer items to the player's main inventory just in time for MoveablesAction to use them

local function doesItemMatch(moveProps, item, validNameMap)
    if moveProps.customItem and (item:getFullType() == moveProps.customItem) and (item:getName() == moveProps.name) then
        return true
    end
    if item:getCustomNameFull() and validNameMap[item:getCustomNameFull()] then
        validNameMap[item:getCustomNameFull()] = nil -- Prevent duplicate items from being transferred
        return true
    end
    return false
end

local function jitTransferItems(playerObj, moveProps, _origSpriteName)
    local playerNum = playerObj:getPlayerNum()
    if not ISMoveableCursor.mode[playerNum] == "place" then
        return
    end

    local playerInv = playerObj:getInventory()

    local foundItem = false
    if not moveProps.isMultiSprite then
        NotUtil.forEachItemOnPlayer(playerObj, function(item, container)
            if not foundItem and instanceof(item, "Moveable") then
                if item:getWorldSprite() == _origSpriteName then
                    if container ~= playerInv then
                        local action = ISInventoryTransferAction:new(playerObj, item, container, playerInv)
                        ISTimedActionQueue.add(action)
                    else
                        ISInventoryPaneContextMenu.unequipItem(item, playerNum)
                    end
                    foundItem = true
                end
            end
        end)
        return
    end

    local targetNames = {}
    if not moveProps.isForceSingleItem then
        local spriteGrid = moveProps.sprite:getSpriteGrid();
        local max = spriteGrid:getSpriteCount();

        for i=1, max do
            local name = moveProps.name .. " (" .. i .. "/" .. max .. ")"
            targetNames[name] = true
        end
    else
        targetNames[moveProps.name .. " (1/1)"] = true
    end

    NotUtil.forEachItemOnPlayer(playerObj, function(item)
        if instanceof(item, "Moveable") then
            if doesItemMatch(moveProps, item, targetNames) then
                ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item)
                ISInventoryPaneContextMenu.unequipItem(item, playerNum)
            end
        end
    end)
end

local og_new = ISMoveablesAction.new
function ISMoveablesAction:new(character, _sq, _moveProps, _mode, _origSpriteName, _moveCursor)
    jitTransferItems(character, _moveProps, _origSpriteName)
    return og_new(self, character, _sq, _moveProps, _mode, _origSpriteName, _moveCursor)
end
