require("ISUI/ISUIElement")

---@class TetrisCraftingGridUI : ISUIElement
TetrisCraftingGridUI = ISUIElement:derive("TetrisCraftingGridUI")

function TetrisCraftingGridUI:new(x, y, w, h, inventoryPane, playerNum)
    local o = ISUIElement:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self

    o.inventoryPane = inventoryPane
    o.playerNum = playerNum

    return o
end


function TetrisCraftingGridUI:createChildren()
    local playerObj = getSpecificPlayer(self.playerNum)
    local playerInv = playerObj:getInventory()
    local itemGridContainerUi = TetrisCraftingContainerUI:new(playerInv, self.inventoryPane, self.playerNum)

    itemGridContainerUi:initialise()
    itemGridContainerUi:setX(20)
    itemGridContainerUi:setY(20)

    self:addChild(itemGridContainerUi)
end