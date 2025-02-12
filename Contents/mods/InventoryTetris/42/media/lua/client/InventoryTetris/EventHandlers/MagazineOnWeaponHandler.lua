local TetrisEvents = require("InventoryTetris/Events")
local TetrisItemCategory = require("InventoryTetris/Data/TetrisItemCategory")
local ItemGridUI = require("InventoryTetris/UI/Grid/ItemGridUI")

ItemGridUI.registerItemHoverColor(TetrisItemCategory.MAGAZINE, TetrisItemCategory.RANGED, ItemGridUI.GENERIC_ACTION_COLOR)


local MagazineWeaponHandler = {}

-- Used to determine if this handler should be called for these particular items
-- Additional checks may be done in the call function,
-- this one is just to determine if the handler should consume the event and prevent other handlers from being called

-- In this case, we only validate that bullets are being dropped on a magazine, as we want this handler to "own" this interaction
-- The specific checks for the magazine and bullets are done in the call function
function MagazineWeaponHandler.validate(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)
    local dropItem = droppedStack.items[1]
    local targetItem = targetStack.items[1]
    
    if not dropItem or not targetItem then return false end

    if TetrisItemCategory.getCategory(dropItem) ~= TetrisItemCategory.MAGAZINE then
        return false
    end

    if TetrisItemCategory.getCategory(targetItem) ~= TetrisItemCategory.RANGED then
        return false
    end

    return true;
end

function MagazineWeaponHandler.call(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)    
    local magazine = droppedStack.items[1]
    local weapon = targetStack.items[1]
    
    if not weapon:IsWeapon() then return end
    if weapon:getMagazineType() ~= magazine:getFullType() then return end

    local playerObj = getSpecificPlayer(playerNum)
    ISInventoryPaneContextMenu.onInsertMagazine(playerObj, weapon, magazine)
end

TetrisEvents.OnStackDroppedOnStack:add(MagazineWeaponHandler)
