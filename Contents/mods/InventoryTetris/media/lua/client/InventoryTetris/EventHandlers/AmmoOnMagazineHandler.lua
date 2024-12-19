require "InventoryTetris/Events"
require "InventoryTetris/ItemGrid/UI/Grid/ItemGridUI_rendering"
require "Notloc/NotUtil"

ItemGridUI.registerItemHoverColor(TetrisItemCategory.AMMO, TetrisItemCategory.MAGAZINE, ItemGridUI.GENERIC_ACTION_COLOR)


local ammoMagazineHandler = {}

-- Used to determine if this handler should be called for these particular items
-- Additional checks may be done in the call function,
-- this one is just to determine if the handler should consume the event and prevent other handlers from being called

-- In this case, we only validate that bullets are being dropped on a magazine, as we want this handler to "own" this interaction
-- The specific checks for the magazine and bullets are done in the call function
ammoMagazineHandler.validate = function(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)
    local dropItem = droppedStack.items[1]
    local targetItem = targetStack.items[1]
    
    if not dropItem or not targetItem then return false end

    if TetrisItemCategory.getCategory(dropItem) ~= TetrisItemCategory.AMMO then
        return false
    end

    if TetrisItemCategory.getCategory(targetItem) ~= TetrisItemCategory.MAGAZINE then
        return false
    end

    return true;
end

-- The stacks are vanilla item stacks, not TetrisItemStacks, as drops may be sourced from outside of the Tetris grids
ammoMagazineHandler.call = function(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)    
    local magazine = targetStack.items[1]
    local bullets = droppedStack.items
    
    if magazine:getAmmoType() ~= bullets[1]:getFullType() then return end

    local missingBullets = magazine:getMaxAmmo() - magazine:getCurrentAmmoCount()
    if missingBullets <= 0 then return end

    local sliceEnd = #bullets
    if #bullets - 1 > missingBullets then
        sliceEnd = missingBullets + 1
    end
    bullets = NotUtil.slice(bullets, 2, sliceEnd)

    local playerObj = getSpecificPlayer(playerNum)
    local playerInv = playerObj:getInventory()

    local returnMag = nil
    if targetInventory ~= playerInv then
        local containerGrid = ItemContainerGrid.Create(targetInventory, playerNum)
        local magStack, grid = containerGrid:findStackByItem(magazine)
        
        transferMag, returnMag = NotUtil.createTransferActionWithReturn(magazine, targetInventory, playerInv, playerObj)
        if magStack then
            returnMag:setTetrisTarget(magStack.x, magStack.y, grid.gridIndex, magStack.isRotated)
        end
        ISTimedActionQueue.add(transferMag)
    end

    if fromInventory ~= playerInv then
        for _, bullet in ipairs(bullets) do
            local transferBullet = ISInventoryTransferAction:new(playerObj, bullet, fromInventory, playerInv)
            ISTimedActionQueue.add(transferBullet)
        end
    end

    ISTimedActionQueue.add(ISLoadBulletsInMagazine:new(playerObj, magazine, #bullets))

    if returnMag then
        ISTimedActionQueue.add(returnMag)
    end
end

TetrisEvents.OnStackDroppedOnStack:add(ammoMagazineHandler)
