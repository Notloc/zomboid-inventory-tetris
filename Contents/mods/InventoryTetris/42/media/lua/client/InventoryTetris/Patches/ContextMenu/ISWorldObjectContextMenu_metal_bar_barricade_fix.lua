local ItemUtil = require("Notloc/ItemUtil")
local ModScope = require("Notloc/ModScope/ModScope")

Events.OnGameBoot.Add(function()
    local og_onMetalBarBarricade = ISWorldObjectContextMenu.onMetalBarBarricade

    ---@diagnostic disable-next-line: duplicate-set-field
    ISWorldObjectContextMenu.onMetalBarBarricade = function(worldobjects, window, playerNum)
        ISTimedActionQueue.clear(getSpecificPlayer(playerNum))
        if not ItemUtil.gatherItems(playerNum, "Base.MetalBar", 3) then
            return
        end

        ModScope.withNoActionQueueClear(function()
            og_onMetalBarBarricade(worldobjects, window, playerNum)
        end)
    end
end)
