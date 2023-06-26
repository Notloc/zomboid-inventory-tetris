---@diagnostic disable: duplicate-set-field

require "ISUI/ISInventoryPaneContextMenu"
local ModScope = require "Notloc/ModScope/ModScope"

local og_onCheckMap = ISInventoryPaneContextMenu.onCheckMap
function ISInventoryPaneContextMenu.onCheckMap(map, player)
    ModScope.withoutTransferNeededOnSelf(function()
        og_onCheckMap(map, player)
    end)
end