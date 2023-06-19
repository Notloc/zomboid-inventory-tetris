require "ISUI/ISInventoryPaneContextMenu"

local og_onCheckMap = ISInventoryPaneContextMenu.onCheckMap
ISInventoryPaneContextMenu.onCheckMap = function(map, player)
    luautils.tetrisTransferOverride = true
    og_onCheckMap(map, player)
    luautils.tetrisTransferOverride = false
end