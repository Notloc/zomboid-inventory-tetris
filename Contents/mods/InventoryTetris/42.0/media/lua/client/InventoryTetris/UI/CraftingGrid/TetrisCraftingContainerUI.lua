require("ISUI/ISUIElement")
require("ISUI/ISPanel")
require("Definitions/ContainerButtonIcons")
local OPT = require("InventoryTetris/Settings")

TetrisCraftingContainerUI = ISPanel:derive("TetrisCraftingContainerUI")

local CONTAINER_BG = getTexture("media/textures/InventoryTetris/ContainerBG.png")

---@class TetrisCraftingContainerUI : ISPanel
function TetrisCraftingContainerUI:new(inventory, inventoryPane, playerNum)
    local o = ISPanel:new(0, 0, 1000, 1000)
    setmetatable(o, self)
    self.__index = self

    o.inventory = inventory
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum
    o.player = getSpecificPlayer(playerNum)
    o.isPlayerInventory = true

    o.containerGrid = ItemContainerGrid.CreateCraftingContainerGrid(playerNum)

    o.keepOnScreen = false

    o.isOnPlayer = true
    o.showTitle = false

    return o
end

function TetrisCraftingContainerUI:initialise()
    ISPanel.initialise(self)

    self.gridUis = self:initItemGridUIs()
    self:addChild(self.gridUis[self.inventory][1])

    self.isInitialized = true
end

function TetrisCraftingContainerUI:createGridRenderer(gridUis, target)
    local gridRenderer = ISUIElement:new(0, 0, 5000, 5000)
    gridRenderer:initialise()
    for _, gridUi in ipairs(gridUis) do
        gridRenderer:addChild(gridUi)
    end

    gridRenderer.containerUi = self
    gridRenderer.prerender = TetrisCraftingContainerUI.prerenderGrids
    gridRenderer.grids = gridUis

    return gridRenderer
end

function TetrisCraftingContainerUI:initItemGridUIs()
    local itemGridUIs = {}

    local uis = self:createItemGridUIs(self.containerGrid.grids)
    itemGridUIs[self.inventory] = uis

    return itemGridUIs
end

function TetrisCraftingContainerUI:createItemGridUIs(grids, secondaryKey)
    local uis = {}
    for _, grid in ipairs(grids) do
        local itemGridUI = ItemGridUI:new(grid, self, self.containerGrid, self.inventoryPane, self.playerNum)
        itemGridUI:initialise()
        table.insert(uis, itemGridUI)
    end
    return uis
end

function TetrisCraftingContainerUI:findGridStackUnderMouse()
    for _, grids in pairs(self.gridUis) do
        for _, gridUi in pairs(grids) do
            if gridUi:isMouseOver() then
                return gridUi:findGridStackUnderMouse(gridUi:getMouseX(), gridUi:getMouseY())
            end
        end
    end
    return nil
end

function TetrisCraftingContainerUI:prerender()
    local inv = self.inventory

    if self.containerGrid:shouldRefresh() or inv:isDrawDirty() then
        self.containerGrid:refresh(self)
        inv:setDrawDirty(false)
    end
end

function TetrisCraftingContainerUI.prerenderGrids(self)
    self:drawRect(0, 0, self.width, self.height, 0.9,0,0,0)
    self:drawTextureScaled(CONTAINER_BG, 0, 0, self.width, self.height, 0.225, 1, 1, 1)
    self:drawRectBorder(0, 0, self.width, self.height, 0.5,1,1,1)
end

function TetrisCraftingContainerUI:onMouseDoubleClick(x, y)
    local gridUi = self:findGridUiUnderMouse(x,y)
    if gridUi then
        gridUi:onMouseDoubleClick(gridUi:getMouseX(), gridUi:getMouseY())
        return
    end
end

function TetrisCraftingContainerUI:findGridUiUnderMouse(x, y)
    return self.gridUis[self.inventory][1]
end
