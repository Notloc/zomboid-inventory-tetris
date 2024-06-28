require("InventoryTetris/Events")
require("InventoryTetris/UI/Grid/ItemGridUI_rendering")
local ItemUtil = require("Notloc/ItemUtil")

ItemGridUI.registerItemHoverColor(TetrisItemCategory.ATTACHMENT, TetrisItemCategory.RANGED, ItemGridUI.GENERIC_ACTION_COLOR)

local AttachmentWeaponHandler = {}

function AttachmentWeaponHandler.validate(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)
    local dropItem = droppedStack.items[1]
    local targetItem = targetStack.items[1]

    if not dropItem or not targetItem then return false end

    if TetrisItemCategory.getCategory(dropItem) ~= TetrisItemCategory.ATTACHMENT then
        return false
    end

    if TetrisItemCategory.getCategory(targetItem) ~= TetrisItemCategory.RANGED then
        return false
    end

    return true;
end

local function createTransfersIfNeeded(playerObj, item, itemInventory, desiredInventory)
    if itemInventory == desiredInventory then
        return
    end

    local prevGrid = ItemContainerGrid.Create(itemInventory, playerObj:getPlayerNum())
    local stack, grid = prevGrid:findStackByItem(item)

    local transferAction, returnAction = ItemUtil.createTransferActionWithReturn(item, itemInventory, desiredInventory, playerObj)
    if stack and grid then
        returnAction:setTetrisTarget(stack.x, stack.y, grid.gridIndex, stack.isRotated, grid.secondaryTarget)
    end

    return transferAction, returnAction
end

function AttachmentWeaponHandler.call(eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)    
    local attachment = droppedStack.items[1]
    local weapon = targetStack.items[1]

    if not weapon:IsWeapon() then return end
    if not attachment:getMountOn():contains(weapon:getFullType()) then return end

    local playerObj = getSpecificPlayer(playerNum)
    local playerInv = playerObj:getInventory()

    local transferWeapon, returnWeapon = createTransfersIfNeeded(playerObj, weapon, targetInventory, playerInv)
    local transferAttachment, returnAttachment = createTransfersIfNeeded(playerObj, attachment, fromInventory, playerInv)

    if transferWeapon then
        ISTimedActionQueue.add(transferWeapon)
    end

    if transferAttachment then
        ISTimedActionQueue.add(transferAttachment)
    end

    ISInventoryPaneContextMenu.onUpgradeWeapon(weapon, attachment, getSpecificPlayer(playerNum))

    if returnWeapon then
        ISTimedActionQueue.add(returnWeapon)
    end
end

TetrisEvents.OnStackDroppedOnStack:add(AttachmentWeaponHandler)
