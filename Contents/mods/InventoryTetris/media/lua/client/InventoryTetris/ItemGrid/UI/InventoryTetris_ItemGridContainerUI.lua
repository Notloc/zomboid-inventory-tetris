require "ISUI/ISUIElement"

ItemGridContainerUI = ISPanel:derive("ItemGridContainerUI")

function ItemGridContainerUI:new(inventory, inventoryPane, playerNum)
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self
    
    o.inventory = inventory
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum

    o.containerGrid = ItemContainerGrid.Create(inventory, playerNum)
    return o
end

function ItemGridContainerUI:initialise()
    ISPanel.initialise(self)
    local itemGridUis = self:createItemGridUIs()
    local width, height = ItemGridContainerUI.updateItemGridPositions(itemGridUis)
    self:setWidth(width)
    self:setHeight(height)

    self.gridUis = itemGridUis
end

function ItemGridContainerUI:createItemGridUIs()
    local itemGridUIs = {}
    for i, grid in ipairs(self.containerGrid.grids) do
        local itemGridUI = ItemGridUI:new(grid, self.inventoryPane, self.playerNum)
        itemGridUI:initialise()
        self:addChild(itemGridUI)
        table.insert(itemGridUIs, itemGridUI)
    end
    return itemGridUIs
end

-- Positions the grids so they are nicely spaced out
-- Returns the size of all the grids plus the spacing
function ItemGridContainerUI.updateItemGridPositions(gridUis, offX, offY)
    -- Space out the grids
    local gridSpacing = 10
    
    local xPos = offX and offX or 0 -- The cursor position
    local maxX = 0 -- Tracks when to update the cursor position
    local largestX = gridUis[1]:getWidth() -- The largest grid seen for the current cursor position
    
    local yPos = offY and offY or 0
    local maxY = 0
    local largestY = gridUis[1]:getHeight()
    
    local gridsByX = {}
    local gridsByY = {}

    for _, grid in ipairs(gridUis) do
        table.insert(gridsByX, grid)
        table.insert(gridsByY, grid)
    end

    table.sort(gridsByX, function(a, b) return a.grid.gridDefinition.position.x < b.grid.gridDefinition.position.x end)
    table.sort(gridsByY, function(a, b) return a.grid.gridDefinition.position.y < b.grid.gridDefinition.position.y end)

    for _, gridUi in ipairs(gridsByX) do
        local x = gridUi.grid.gridDefinition.position.x
        if x > maxX then
            maxX = x
            xPos = xPos + largestX + gridSpacing
            largestX = 0
        end
        
        gridUi:setX(xPos)
        if gridUi:getWidth() > largestX then
            largestX = gridUi:getWidth()
        end
    end
    xPos = xPos + largestX

    for _, gridUi in ipairs(gridsByY) do
        local y = gridUi.grid.gridDefinition.position.y
        if y > maxY then
            maxY = y
            yPos = yPos + largestY + gridSpacing
            largestY = 0
        end
        
        gridUi:setY(yPos)
        if gridUi:getHeight() > largestY then
            largestY = gridUi:getHeight()
        end
    end
    yPos = yPos + largestY

    return xPos, yPos 
end

function ItemGridContainerUI:prerender()
    if self.inventory:isDrawDirty() then
        self.containerGrid:refresh()
    end
    ISPanel.prerender(self)
end
