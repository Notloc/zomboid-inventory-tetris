-- There is a sizable amount of vanilla actions that do not properly unequip items from the player's hands before destroying them.
-- Lets just do this and forget about it.

local TetrisHandMonitor = {}
TetrisHandMonitor.ticksByPlayer = {}

function TetrisHandMonitor.validateEquippedItems(playerObj)
    if playerObj:isNPC() then return end

    local playerNum = playerObj:getPlayerNum()
    local tick = TetrisHandMonitor.ticksByPlayer[playerNum] or 0
    if tick < 15 then
        TetrisHandMonitor.ticksByPlayer[playerNum] = tick + 1
        return
    end
    TetrisHandMonitor.ticksByPlayer[playerNum] = 0

    local primHand = playerObj:getPrimaryHandItem()
    if primHand and not primHand:getContainer() then
        playerObj:setPrimaryHandItem(nil)
    end

    local secHand = playerObj:getSecondaryHandItem()
    if secHand and not secHand:getContainer() then
        playerObj:setSecondaryHandItem(nil)
    end
end
Events.OnPlayerUpdate.Add(TetrisHandMonitor.validateEquippedItems)

return TetrisHandMonitor
