-- Small convenience that ended up under used.
-- TODO: Remove this
require("ISUI/PlayerData/ISPlayerDataObject")

Events.OnGameBoot.Add(function ()
    local og_createInventoryInterface = ISPlayerDataObject.createInventoryInterface
    ---@diagnostic disable-next-line: duplicate-set-field
    function ISPlayerDataObject:createInventoryInterface()
        og_createInventoryInterface(self)
        self.playerInventory.sisterPage = self.lootInventory
        self.lootInventory.sisterPage = self.playerInventory
    end
end)

