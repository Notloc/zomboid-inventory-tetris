require "InventoryTetris/TetrisEvents"
require "Notloc/NotUtil"

TetrisEvents.OnStackDroppedOnStack:add(function(eventData, droppedStack, fromGrid, targetStack, targetGrid, playerNum)
    if not droppedStack.category == TetrisItemCategory.AMMO then
        return
    end
    if not targetStack.category == TetrisItemCategory.MAGAZINE then
        return
    end
    
    eventData:consume()

    if not targetGrid.isOnPlayer then
        return
    end
    
    local magazine = ItemStack.getFrontItem(targetStack, targetGrid.inventory)
    if not magazine then return end

    local bullets = ItemStack.getAllItems(droppedStack, fromGrid.inventory)
    if #bullets == 0 then return end
    
    if magazine:getAmmoType() ~= bullets[1]:getFullType() then return end

    local missingBullets = magazine:getMaxAmmo() - magazine:getCurrentAmmoCount()
    if missingBullets <= 0 then return end

    if #bullets > missingBullets then
        bullets = NotUtil.slice(bullets, 1, missingBullets)
    end

    local playerObj = getSpecificPlayer(playerNum)

    local returnMag = nil
    if not targetGrid.isPlayerInventory then    
        transferMag, returnMag = NotUtil.createTransferActionWithReturn(magazine, targetGrid.inventory, playerObj:getInventory(), playerObj)
        returnMag:setTetrisTarget(targetStack.x, targetStack.y, targetGrid.gridIndex, targetStack.isRotated)
        ISTimedActionQueue.add(transferMag)
    end

    if not fromGrid.isPlayerInventory then
        for _, bullet in ipairs(bullets) do
            local transferBullet = ISInventoryTransferAction:new(playerObj, bullet, fromGrid.inventory, playerObj:getInventory())
            transferBullet.tetrisForceAllow = true
            ISTimedActionQueue.add(transferBullet)
        end
    end

    ISTimedActionQueue.add(ISLoadBulletsInMagazine:new(playerObj, magazine, #bullets))

    if returnMag then
        ISTimedActionQueue.add(returnMag)
    end
end)


