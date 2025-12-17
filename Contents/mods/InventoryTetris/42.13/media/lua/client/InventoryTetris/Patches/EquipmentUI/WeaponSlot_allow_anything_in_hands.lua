---@diagnostic disable-next-line: undefined-global
local WeaponSlot = require("EquipmentUI/UI/WeaponSlot") or WeaponSlot

-- TODO: Move this into EquipmentUI instead
---@diagnostic disable-next-line: undefined-global
function WeaponSlot:canAcceptItem(item)
    return self:isHandGood(item)
end