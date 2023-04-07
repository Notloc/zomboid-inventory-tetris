require "ISUI/ISUIElement"

ItemGridContainerUI = ISPanel:derive("ItemGridContainerUI")

local ICON_PADDING = 4
local ICON_SIZE = 64
local INFO_SPACING = 6

local CONTAINER_PADDING_X = 4
local CONTAINER_PADDING_Y = 8

function ItemGridContainerUI:new(inventory, inventoryPane, playerNum)
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self
    
    o.inventory = inventory
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum

    local containingItem = inventory:getContainingItem()
    o.invTexture = containingItem and containingItem:getTex() or getTexture("media/ui/Icon_InventoryBasic.png");
    o.item = inventory:getContainingItem()
    o.containerGrid = ItemContainerGrid.Create(inventory, playerNum)
    o.keepOnScreen = false -- Keep on screen is a menace inside scroll panes and these are always inside scroll panes or other panels

    local player = getSpecificPlayer(playerNum)
    if inventory == player:getInventory() then
        o.isPlayerInventory = true
    end

    return o
end

function ItemGridContainerUI:initialise()
    ISPanel.initialise(self)

    local lineHeight = getTextManager():getFontHeight(UIFont.Small)
    self.minimumHeight = ICON_SIZE + 2 * ICON_PADDING + INFO_SPACING + lineHeight

    local itemGridUis = self:createItemGridUIs()
    local width, height = ItemGridContainerUI.updateItemGridPositions(itemGridUis, 2 * ICON_PADDING + ICON_SIZE + CONTAINER_PADDING_X, CONTAINER_PADDING_Y)
    self:setWidth(width + CONTAINER_PADDING_X + 2)
    self:setHeight(height + CONTAINER_PADDING_Y)

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
    local inv = self.inventory

    if true or inv:isDrawDirty() then
        if self.containerGrid:refresh() then
            inv:setDrawDirty(false)
        end
    end
    ISPanel.prerender(self)

    local r,g,b = 1,1,1
    if self.item then
        r,g,b = ItemGridUI.getItemColor(self.item, 0.5)
    end
    
    local offset = ICON_SIZE/2 + ICON_PADDING
    self:drawTextureCenteredAndSquare(self.invTexture, offset, offset, ICON_SIZE, 1, r,g,b)
    
    local capacity = inv:getCapacity()
    if self.isPlayerInventory then
        capacity = getSpecificPlayer(self.playerNum):getMaxWeight()
    end

    local roundedWeight = round(inv:getCapacityWeight(), 2)
    self:drawTextCentre(roundedWeight .. " / " .. inv:getCapacity(), ICON_SIZE/2 + ICON_PADDING, ICON_SIZE + INFO_SPACING, 1,1,1,1);
    local lineHeight = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()

    local borderSizeX = ICON_PADDING + ICON_SIZE
    local borderSizeY = borderSizeX + INFO_SPACING + lineHeight
    self:drawRectBorder(ICON_PADDING/2, ICON_PADDING/2, borderSizeX, borderSizeY, 0.5,1,1,1)    
end
