require("ISUI/ISPanel")

---@class ItemGridUI : ISPanel
---@field grid ItemGrid
---@field containerGrid ItemContainerGrid
---@field inventoryPane ISInventoryPane
---@field playerNum number
ItemGridUI = ISPanel:derive("ItemGridUI")

---@param grid ItemGrid
---@param containerGrid ItemContainerGrid
---@param inventoryPane ISInventoryPane
---@param playerNum number
---@return ItemGridUI
function ItemGridUI:new(grid, containerGrid, inventoryPane, playerNum)
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self

    o.grid = grid
    o.containerGrid = containerGrid
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum

    o:setWidth(o:calculateWidth())
    o:setHeight(o:calculateHeight())

    ---@diagnostic disable-next-line: return-type-mismatch
    return o
end