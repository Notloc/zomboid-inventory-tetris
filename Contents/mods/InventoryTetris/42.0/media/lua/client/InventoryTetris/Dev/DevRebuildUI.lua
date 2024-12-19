if not isDebugEnabled then return end

Events.OnKeyPressed.Add(function (key)
    if key == getKeyCode("R") and isCtrlKeyDown() then
        local playerData = getPlayerData(0)

        playerData.playerInventory:close()
        playerData.lootInventory:close()

        playerData:createInventoryInterface()
    end
end)