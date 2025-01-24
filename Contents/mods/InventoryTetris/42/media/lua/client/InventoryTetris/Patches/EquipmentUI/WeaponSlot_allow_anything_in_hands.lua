require("EquipementUI/UI/WeaponSlot")

-- TODO: Move this into EquipmentUI instead
---@diagnostic disable-next-line: undefined-global
function WeaponSlot:canAcceptItem(item)
    return self:isHandGood(item)
end