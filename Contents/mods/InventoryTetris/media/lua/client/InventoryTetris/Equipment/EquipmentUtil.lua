TetrisEquipmentUtil = {}

TetrisEquipmentUtil.getBodyLocation = function(item)
    if not item:IsClothing() and not item:IsInventoryContainer() then return nil end
    return item:IsClothing() and item:getBodyLocation() or item:canBeEquipped()
end