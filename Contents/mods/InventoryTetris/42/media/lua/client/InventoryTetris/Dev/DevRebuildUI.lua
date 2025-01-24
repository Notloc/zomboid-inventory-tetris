Events.OnLoad.Add(function()
    if not TetrisDevTool.isDebugEnabled() then return end
    Events.OnKeyPressed.Add(function (key)
        if key == getKeyCode("R") and isCtrlKeyDown() then
            local playerData = getPlayerData(0)

            if playerData.playerInventory then
                playerData.playerInventory:close()
            end

            if playerData.lootInventory then
                playerData.lootInventory:close()
            end

            playerData:createInventoryInterface()
        end
    end)
end)