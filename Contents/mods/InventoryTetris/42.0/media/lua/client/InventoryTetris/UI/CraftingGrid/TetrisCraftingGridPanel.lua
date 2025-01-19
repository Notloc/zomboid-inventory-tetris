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
    local craftingGridUi = TetrisCraftingGridUI:new(0, 0, self.width, self.height, self.inventoryPane, self.playerNum)
    craftingGridUi:initialise()
    self:addChild(craftingGridUi)
end