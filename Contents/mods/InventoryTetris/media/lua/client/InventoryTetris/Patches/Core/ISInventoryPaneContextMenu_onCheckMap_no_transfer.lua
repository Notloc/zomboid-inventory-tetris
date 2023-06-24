require "ISUI/ISInventoryPaneContextMenu"

local og_onCheckMap = ISInventoryPaneContextMenu.onCheckMap
---@diagnostic disable-next-line: duplicate-set-field
function ISInventoryPaneContextMenu.onCheckMap(map, player)
    luautils.tetrisTransferOverride = true
    og_onCheckMap(map, player)
    luautils.tetrisTransferOverride = false
end