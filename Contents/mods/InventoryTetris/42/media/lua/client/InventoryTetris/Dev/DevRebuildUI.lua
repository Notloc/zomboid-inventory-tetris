local TetrisDevTool = require("InventoryTetris/Dev/TetrisDevTool")

Events.OnLoad.Add(function()
    if not TetrisDevTool.isDebugEnabled() then return end
    Events.OnKeyPressed.Add(function (key)
        if key == getKeyCode("R") and isCtrlKeyDown() then
            local player = getSpecificPlayer(0)

            destroyPlayerData(player)
            createPlayerData(0)
        end
    end)
end)