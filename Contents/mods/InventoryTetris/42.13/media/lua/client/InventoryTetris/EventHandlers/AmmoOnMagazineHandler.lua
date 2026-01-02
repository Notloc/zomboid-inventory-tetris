local ItemGridUI = require("InventoryTetris/UI/Grid/ItemGridUI")
local TetrisItemCategory = require("InventoryTetris/Data/TetrisItemCategory")
local ItemContainerGrid = require("InventoryTetris/Model/ItemContainerGrid")
local TetrisEvents = require("InventoryTetris/Events")
local ItemUtil = require("Notloc/ItemUtil")

ItemGridUI.registerItemHoverColor(TetrisItemCategory.AMMO, TetrisItemCategory.MAGAZINE, ItemGridUI.GENERIC_ACTION_COLOR)

---@param tbl any[]
---@param start integer
---@param stop integer
---@return any[]
local function slice(tbl, start, stop)
    local sliced = {}
    for i = start, stop do
        table.insert(sliced, tbl[i])
    end
    return sliced
end

local ammoMagazineHandler = {}

-- Used to determine if this handler should be called for these particular items
-- Additional checks may be done in the call function,
-- this one is just to determine if the handler should consume the event and prevent other handlers from being called

-- In this case, we only validate that bullets are being dropped on a magazine, as we want this handler to "own" this interaction
-- The specific checks for the magazine and bullets are done in the call function
---@param eventData any
---@param droppedStack VanillaStack
---@param fromInventory ItemContainer
---@param targetStack VanillaStack
---@param targetInventory ItemContainer
---@param playerNum integer
function ammoMagazineHandler.validate(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)
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
---@param eventData any
---@param droppedStack VanillaStack
---@param fromInventory ItemContainer
---@param targetStack VanillaStack
---@param targetInventory ItemContainer
---@param playerNum integer
function ammoMagazineHandler.call(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)
    local magazine = targetStack.items[1]
    local bullets = droppedStack.items
    local protoBullet = bullets[1]
    
    if not magazine then return end
    if not protoBullet then return end

    if magazine:getAmmoType() ~= protoBullet:getFullType() then return end

    local missingBullets = magazine:getMaxAmmo() - magazine:getCurrentAmmoCount()
    if missingBullets <= 0 then return end

    local sliceEnd = #bullets
    if #bullets - 1 > missingBullets then
        sliceEnd = missingBullets + 1
    end
    bullets = slice(bullets, 2, sliceEnd)

    local playerObj = getSpecificPlayer(playerNum)
    local playerInv = playerObj:getInventory()

    local returnMag = nil
    if targetInventory ~= playerInv then
        local containerGrid = ItemContainerGrid.GetOrCreate(targetInventory, playerNum)
        local magStack, grid = containerGrid:findStackByItem(magazine)

        local transferMag = nil
        transferMag, returnMag = ItemUtil.createTransferActionWithReturn(magazine, targetInventory, playerInv, playerObj)
        if magStack and grid then
            returnMag:setTetrisTarget(magStack.x, magStack.y, grid.gridIndex, magStack.isRotated, grid.secondaryTarget)
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
