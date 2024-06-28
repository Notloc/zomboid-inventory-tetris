-- There is a sizable amount of vanilla actions that do not properly unequip items from the player's hands before destroying them.
-- Lets just do this and forget about it.

TetrisHandMonitor = {}
TetrisHandMonitor.ticksByPlayer = {}

function TetrisHandMonitor.validateEquippedItems(playerObj)
    local playerNum = playerObj:getPlayerNum()
    if not playerNum or playerNum >= 4 then return end -- Some NPC mod or something

    local tick = TetrisHandMonitor.ticksByPlayer[playerNum] or 0
    if tick < 30 then
        TetrisHandMonitor.ticksByPlayer[playerObj:getPlayerNum()] = tick + 1
        return
    end

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
