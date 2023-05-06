require "ISUI/ISUIElement"

ItemGridContainerUI = ISPanel:derive("ItemGridContainerUI")

local ICON_PADDING_X = 16
local ICON_PADDING_Y = 8
local ICON_SIZE = 64
local INFO_SPACING = 6

local CONTAINER_PADDING_X = 4
local CONTAINER_PADDING_Y = 8

local WEIGHT_TEXTURE = getTexture("media/textures/InventoryTetris/weight.png")
local ORGANIZED_TEXTURE = getTexture("media/textures/InventoryTetris/Organized.png")
local DISORGANIZED_TEXTURE = getTexture("media/textures/InventoryTetris/Disorganized.png")

local ORGANIZED_TEXT = "Organized"
local DISORGANIZED_TEXT = "Disorganized"

function ItemGridContainerUI:new(inventory, inventoryPane, playerNum)
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self
    
    o.inventory = inventory
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum
    o.player = getSpecificPlayer(playerNum)

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
    self.minimumHeight = ICON_SIZE + 2 * ICON_PADDING_Y + INFO_SPACING + lineHeight

    local itemGridUis = self:createItemGridUIs()
    local width, height = ItemGridContainerUI.updateItemGridPositions(itemGridUis, 2 * ICON_PADDING_X + ICON_SIZE + CONTAINER_PADDING_X, CONTAINER_PADDING_Y)
    self:setWidth(width + CONTAINER_PADDING_X + 2)
    self:setHeight(height + CONTAINER_PADDING_Y)

    self.gridUis = itemGridUis

    self.organizationIcon = ISImage:new(0, 0, 16, 16, ORGANIZED_TEXTURE)
    self.organizationIcon:initialise()
    self:addChild(self.organizationIcon)
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

function ItemGridContainerUI:findGridStackUnderMouse()
    for _, gridUi in pairs(self.gridUis) do
        if gridUi:isMouseOver() then
            return gridUi:findGridStackUnderMouse()
        end
    end
    return nil
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
        self.containerGrid:refresh(self)
        inv:setDrawDirty(false)
    end
    ISPanel.prerender(self)

    local r,g,b = 1,1,1
    if self.item then
        r,g,b = ItemGridUI.getItemColor(self.item, 0.5)
    end
    
    local offsetX = ICON_SIZE/2 + ICON_PADDING_X
    local offsetY = ICON_SIZE/2 + ICON_PADDING_Y
    self:drawTextureCenteredAndSquare(self.invTexture, offsetX, offsetY, ICON_SIZE, 1, r,g,b)
    
    local isOrganized = self.containerGrid:isOrganized()
    if self.player:HasTrait("Organized") then
        isOrganized = true
    elseif self.player:HasTrait("Disorganized") then
        isOrganized = false
    end

    self.organizationIcon:setX(offsetX + ICON_SIZE/2 - ICON_PADDING_X/2 - 3)
    self.organizationIcon:setY(offsetY - ICON_SIZE/2 - ICON_PADDING_Y + 4)
    
    self.organizationIcon.texture = isOrganized and ORGANIZED_TEXTURE or DISORGANIZED_TEXTURE
    self.organizationIcon:setMouseOverText(isOrganized and "Organized" or "Disorganized")

    local capacity = inv:getCapacity()
    if self.isPlayerInventory then
        capacity = getSpecificPlayer(self.playerNum):getMaxWeight()
    end

    local roundedWeight = round(inv:getCapacityWeight(), 1)
    local weightText = roundedWeight .. " / " .. inv:getCapacity()
    self:drawTextCentre(weightText, ICON_SIZE/2 + ICON_PADDING_X - 7, ICON_PADDING_Y + ICON_SIZE + INFO_SPACING, 1,1,1,1);
    local lineHeight = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
    local lineWidth = getTextManager():MeasureStringX(UIFont.Small, weightText)

    self:drawTexture(WEIGHT_TEXTURE, ICON_SIZE/2 + ICON_PADDING_X - 7 + lineWidth/2 + 2, ICON_PADDING_Y + ICON_SIZE + INFO_SPACING + 5, 1, 1, 0.92, 0.75);

    local borderSizeX = ICON_PADDING_X + ICON_SIZE
    local borderSizeY = ICON_PADDING_Y + ICON_SIZE + INFO_SPACING + lineHeight
    self:drawRectBorder(ICON_PADDING_X/2, ICON_PADDING_Y/2, borderSizeX, borderSizeY, 0.5,1,1,1)    
end

local function isPointOverContainerIcon(x, y)
    return x > ICON_PADDING_X/2 and x < ICON_SIZE + ICON_PADDING_X/2 and y > ICON_PADDING_Y/2 and y < ICON_SIZE + ICON_PADDING_Y/2
end

function ItemGridContainerUI:onRightMouseUp(x, y)
    if self.item and isPointOverContainerIcon(x, y) then
        ItemGridUI.openItemContextMenu(self, x, y, self.item, self.playerNum)
    end
end

function ItemGridContainerUI:onMouseDown(x, y)
    if self.item and isPointOverContainerIcon(x, y) then
        local vanillaStack = DragAndDrop.convertItemToStack(self.item)
        DragAndDrop.prepareDrag(self, vanillaStack, x, y)
    end
end

function ItemGridContainerUI:onMouseMove(dx, dy)
    if self.item then
        DragAndDrop.startDrag(self)
    end
end

function ItemGridContainerUI:onMouseUp(x, y)
    if self.item then
        DragAndDrop.endDrag(self)
    end
end

function ItemGridContainerUI:onMouseUpOutside(x, y)
    if self.item then
        DragAndDrop.cancelDrag(self, self.cancelDragDropItem)
    end
end

function ItemGridContainerUI:cancelDragDropItem()
    local stack = ISMouseDrag.dragging
    if not stack or not stack.items then return end

    local item = stack.items[1]
    if not item then return end

    local playerObj = getSpecificPlayer(self.playerNum)
    ISInventoryPaneContextMenu.dropItem(item, self.playerNum)
end