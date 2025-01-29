-- Allow the player to read maps without needing to transfer them to their main inventory.
---@diagnostic disable: duplicate-set-field

require("ISUI/ISInventoryPaneContextMenu")
local ModScope = require("Notloc/ModScope/ModScope")

Events.OnGameBoot.Add(function ()
    local og_onCheckMap = ISInventoryPaneContextMenu.onCheckMap
    function ISInventoryPaneContextMenu.onCheckMap(map, player)
        ModScope.withoutTransferNeededOnSelf(function()
            og_onCheckMap(map, player)
        end)
    end
end)
