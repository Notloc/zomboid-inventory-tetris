require("InventoryTetris/Notloc/NotlocSidePanel")

TetrisCraftingGridPanel = NotlocSidePanel:derive("TetrisCraftingGridPanel")

function TetrisCraftingGridPanel:new(width, inventoryPane, playerNum)
    local o = NotlocSidePanel:new("Crafting Grid", "TetrisCraftingGridPanel", width, inventoryPane, playerNum)
    setmetatable(o, self);
    self.__index = self;

    self.buttonTexture = getTexture("media/textures/InventoryTetris/CraftingGrid/CraftingGridButton.png")

    return o;
end

function TetrisCraftingGridPanel:createChildren()
    
end