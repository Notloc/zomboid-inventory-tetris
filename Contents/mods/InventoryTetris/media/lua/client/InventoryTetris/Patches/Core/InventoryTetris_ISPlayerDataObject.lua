require "ISUI/PlayerData/ISPlayerDataObject"

local og_createInventoryInterface = ISPlayerDataObject.createInventoryInterface

---@diagnostic disable-next-line: duplicate-set-field
function ISPlayerDataObject:createInventoryInterface()
    og_createInventoryInterface(self)
    self.playerInventory.sisterPage = self.lootInventory
    self.lootInventory.sisterPage = self.playerInventory
end
