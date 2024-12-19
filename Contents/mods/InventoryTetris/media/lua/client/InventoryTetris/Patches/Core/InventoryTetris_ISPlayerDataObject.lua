require "ISUI/PlayerData/ISPlayerDataObject"

local og_createInventoryInterface = ISPlayerDataObject.createInventoryInterface
function ISPlayerDataObject:createInventoryInterface()
    og_createInventoryInterface(self)
    self.playerInventory.sisterPage = self.lootInventory
    self.lootInventory.sisterPage = self.playerInventory
end
