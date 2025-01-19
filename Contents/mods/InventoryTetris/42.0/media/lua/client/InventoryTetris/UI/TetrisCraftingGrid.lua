require("InventoryTetris/Notloc/NotlocSidePanel")

TetrisCraftingGrid = NotlocSidePanel:derive("TetrisCraftingGrid")

function TetrisCraftingGrid:new(width, inventoryPane, playerNum)
    local o = NotlocSidePanel:new("Crafting Grid", "TetrisCraftingGrid", width, inventoryPane, playerNum)
    setmetatable(o, self);
    self.__index = self;

    self.buttonTexture = getTexture("media/textures/InventoryTetris/CraftingGrid/CraftingGridButton.png")

    return o;
end