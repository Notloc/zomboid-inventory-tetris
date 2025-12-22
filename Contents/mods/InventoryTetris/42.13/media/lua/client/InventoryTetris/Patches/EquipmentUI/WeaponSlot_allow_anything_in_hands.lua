local WeaponSlot = require("EquipmentUI/UI/Slots/WeaponSlot")

function WeaponSlot:canAcceptItem(item)
    return self:isHandGood(item)
end
