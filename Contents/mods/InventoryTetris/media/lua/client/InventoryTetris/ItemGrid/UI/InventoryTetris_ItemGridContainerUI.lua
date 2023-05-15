require "ISUI/ISUIElement"
require "Definitions/ContainerButtonIcons"

ItemGridContainerUI = ISPanel:derive("ItemGridContainerUI")

local ICON_PADDING_X = 12
local ICON_PADDING_Y = 10
local ICON_SIZE = 64
local INFO_SPACING = 20

local GRID_PADDING = 2

local CONTAINER_PADDING_X = 4
local CONTAINER_PADDING_Y = 10

local TITLE_Y_OFFSET = 22

local BASIC_INV_TEXTURE = getTexture("media/ui/Icon_InventoryBasic.png")
local SHELF_TEXTURE = getTexture("media/ui/Container_Shelf.png")
local WEIGHT_TEXTURE = getTexture("media/textures/InventoryTetris/weight.png")
local ORGANIZED_TEXTURE = getTexture("media/textures/InventoryTetris/Organized.png")
local DISORGANIZED_TEXTURE = getTexture("media/textures/InventoryTetris/Disorganized.png")
local SELECTED_TEXTURE = getTexture("media/ui/FavoriteStar.png")

local CONTAINER_BG = getTexture("media/textures/InventoryTetris/ContainerBG.png")

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
    o.item = inventory:getContainingItem()

    local isPlayerInv = inventory == o.player:getInventory()

    if not o.item and not isPlayerInv then
        o.invTexture = o.getWorldTexture(inventory) or ContainerButtonIcons[inventory:getType()] or SHELF_TEXTURE
    else
        o.invTexture = o.item and o.item:getTex() or BASIC_INV_TEXTURE;
    end

    o.containerGrid = ItemContainerGrid.Create(inventory, playerNum)
    o.keepOnScreen = false -- Keep on screen is a menace inside scroll panes and these are always inside scroll panes or other panels

    local player = getSpecificPlayer(playerNum)
    if inventory == player:getInventory() then
        o.isPlayerInventory = true
    end
    
    o.isOnPlayer = o.isPlayerInventory or (o.item and o.item:isInPlayerInventory())
    o.showTitle = true

    return o
end

ItemGridContainerUI.movableItemCache = {}
function ItemGridContainerUI.getWorldTexture(inventory)
    local parent = inventory:getParent()
    if not parent then
        return nil
    end

    local sprite = parent:getSprite()
    if not sprite or not sprite:getName() then
        return nil;
    end

    local itemKey = "Moveables."..sprite:getName()
    if ItemGridContainerUI.movableItemCache[itemKey] then
        return ItemGridContainerUI.movableItemCache[itemKey]:getTexture()
    end

    local props = sprite:getProperties()
    
    local isMultiSprite = sprite:getSpriteGrid() ~= nil
    if isMultiSprite then
        return nil;
    end

    local isMoveable = sprite:getName() and props:Is("IsMoveAble") or false;
    if not isMoveable then
        return nil;
    end

    local itemInstance = instanceItem(itemKey)
    if not itemInstance then
        return nil;
    end
    ItemGridContainerUI.movableItemCache[itemKey] = itemInstance
    return itemInstance:getTexture();
end

function ItemGridContainerUI:initialise()
    ISPanel.initialise(self)

    local yOffset = self.showTitle and TITLE_Y_OFFSET or 1

    self.gridUis = self:createItemGridUIs()
    
    local infoWidth = ICON_SIZE + ICON_PADDING_X * 2
    local infoHeight = ICON_SIZE + ICON_PADDING_Y * 2 + INFO_SPACING
    local infoRenderer = ISUIElement:new(0, yOffset, infoWidth, infoHeight)
    infoRenderer.onRightMouseUp = nil
    infoRenderer.containerUi = self
    infoRenderer.organizationIcon = ISImage:new(0, 0, 16, 16, ORGANIZED_TEXTURE)
    infoRenderer.organizationIcon:initialise()
    
    infoRenderer.prerender = ItemGridContainerUI.prerenderInfo
    infoRenderer.onMouseUp = ItemGridContainerUI.info_onMouseUp
    infoRenderer.onMouseUpOutside = ItemGridContainerUI.info_onMouseUpOutside
    infoRenderer.onMouseMove = ItemGridContainerUI.info_onMouseMove
    infoRenderer.onMouseMoveOutside = ItemGridContainerUI.info_onMouseMoveOutside
    infoRenderer.onRightMouseUp = ItemGridContainerUI.info_onRightMouseUp
    infoRenderer.onMouseDown = ItemGridContainerUI.info_onMouseDown

    infoRenderer:addChild(infoRenderer.organizationIcon)

    self.infoRenderer = infoRenderer

    local width, height = ItemGridContainerUI.updateItemGridPositions(self.gridUis)
    local gridRenderer = ISUIElement:new(infoWidth+2, yOffset, width+GRID_PADDING*2, height+GRID_PADDING*2)
    gridRenderer:initialise()
    for _, gridUi in ipairs(self.gridUis) do
        gridUi:setX(gridUi:getX() + GRID_PADDING)
        gridUi:setY(gridUi:getY() + GRID_PADDING)
        gridRenderer:addChild(gridUi)
    end
    gridRenderer.prerender = ItemGridContainerUI.prerenderGrids

    self:setWidth(gridRenderer:getWidth() + infoWidth+2)
    self:setHeight(math.max(gridRenderer:getHeight(), infoRenderer:getHeight()) + yOffset)
    
    self:addChild(gridRenderer)
    self:addChild(infoRenderer)
end

function ItemGridContainerUI:createItemGridUIs()
    local itemGridUIs = {}
    for i, grid in ipairs(self.containerGrid.grids) do
        local itemGridUI = ItemGridUI:new(grid, self.inventoryPane, self, self.playerNum)
        itemGridUI:initialise()
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
function ItemGridContainerUI.updateItemGridPositions(_gridUis)
    local xOffset = 0
    local yOffset = 0

    -- Space out the grids
    local gridSpacing = 10
    
    local gridUis = {}
    for _, gridUi in ipairs(_gridUis) do
        table.insert(gridUis, gridUi)
    end

    --Sort by y then x
    table.sort(gridUis, function(a,b)
        if a:getY() == b:getY() then
            return a:getX() < b:getX()
        else
            return a:getY() < b:getY()
        end
    end)

    -- Map by y
    local gridUisByY = {}
    for _, gridUi in ipairs(gridUis) do
        local y = gridUi.grid.gridDefinition.position.y
        if not gridUisByY[y] then
            gridUisByY[y] = {}
        end
        table.insert(gridUisByY[y], gridUi)
    end

    for y, gridUis in pairs(gridUisByY) do
        -- Sort by x
        table.sort(gridUis, function(a,b)
            return a:getX() < b:getX()
        end)
    end

    -- Find the largest row
    local widestRow = 0

    local rowWidths = {}
    for y, gridUis in pairs(gridUisByY) do
        local totalWidth = 0
        for _, gridUi in ipairs(gridUis) do
            totalWidth = totalWidth + gridUi:getWidth() + gridSpacing
        end
        totalWidth = totalWidth - gridSpacing
        rowWidths[y] = totalWidth
        if totalWidth > widestRow then
            widestRow = totalWidth
        end
    end

    -- Row heights
    local rowHeights = {}
    for y, gridUis in pairs(gridUisByY) do
        local rowHeight = 0
        for _, gridUi in ipairs(gridUis) do
            if gridUi:getHeight() > rowHeight then
                rowHeight = gridUi:getHeight()
            end
        end
        rowHeights[y] = rowHeight
    end

    -- Position the grids
    local startX = xOffset
    for y, gridUisByX in pairs(gridUisByY) do
        xOffset = startX
        for x, gridUi in pairs(gridUisByX) do
            gridUi:setX(xOffset + (widestRow - rowWidths[y]) / 2)
            gridUi:setY(yOffset + (rowHeights[y] - gridUi:getHeight()))
            xOffset = xOffset + gridUi:getWidth() + gridSpacing
        end
        yOffset = yOffset + rowHeights[y] + gridSpacing
    end

    return xOffset - gridSpacing, yOffset - gridSpacing
end

local function getWeightColor(weight, capacity)
    local ratio = weight / capacity
    if ratio <= 1.0 then
        return 1,1,1
    elseif ratio <= 1.25 then
        return 1,1,0
    elseif ratio <= 1.5 then 
        return 1,0.3,0
    elseif ratio <= 1.75 then
        return 1,0,0
    else 
        return 0.6,0,0
    end
end

function ItemGridContainerUI:prerender()
    local inv = self.inventory
    
    if self.containerGrid:shouldRefresh() or inv:isDrawDirty() then
        self.containerGrid:refresh(self)
        inv:setDrawDirty(false)
    end

    if self.showTitle then
        local invName = ""
        if self.item then
            invName = self.item:getName()
        elseif self.isPlayerInventory then
            invName = getText("IGUI_InventoryName", self.player:getDescriptor():getForename(), self.player:getDescriptor():getSurname())
        else
            invName = getTextOrNull("IGUI_ContainerTitle_" .. inv:getType()) or "Container"
        end

        self:renderTitle(invName, 0, 0, 4, 1)
    end
end

function ItemGridContainerUI.prerenderGrids(self)
    self:drawRect(0, 0, self.width, self.height, 0.9,0,0,0)
    self:drawTextureScaled(CONTAINER_BG, 0, 0, self.width, self.height, 0.225, 1, 1, 1)
    self:drawRectBorder(0, 0, self.width, self.height, 0.5,1,1,1)
end




function ItemGridContainerUI.prerenderInfo(self)
    local containerUi = self.containerUi
    local inv = containerUi.inventory
    
    local r,g,b = 1,1,1
    if containerUi.item then
        r,g,b = ItemGridUI.getItemColor(containerUi.item, 0.5)
    end
    
    local offsetX = ICON_SIZE/2 + ICON_PADDING_X
    local offsetY = ICON_SIZE/2 + ICON_PADDING_Y
    self:drawTextureCenteredAndSquare(containerUi.invTexture, offsetX, offsetY+4, ICON_SIZE, 1, r,g,b)

    local hasOrganized = containerUi.player:HasTrait("Organized")
    local hasDisorganized = containerUi.player:HasTrait("Disorganized")

    local isContainerOrganized = containerUi.containerGrid:isOrganized()
    if hasOrganized then
        isContainerOrganized = true
    elseif hasDisorganized then
        isContainerOrganized = false
    end

    local topIconY = offsetY - ICON_SIZE/2 - ICON_PADDING_Y

    self.organizationIcon:setX(offsetX + ICON_SIZE/2 - ICON_PADDING_X/2 - 2)
    self.organizationIcon:setY(topIconY)
    
    self.organizationIcon.texture = isContainerOrganized and ORGANIZED_TEXTURE or DISORGANIZED_TEXTURE
    self.organizationIcon:setMouseOverText(isContainerOrganized and "Organized" or "Disorganized")

    local isSelected = containerUi.isOnPlayer and containerUi.inventory == containerUi.inventoryPane.inventory
    if isSelected then
        self:drawTexture(SELECTED_TEXTURE, 4, topIconY+2, 1, 1, 1, 1)
    end

    local capacity = inv:getCapacity()
    if hasOrganized then
        capacity = capacity * 1.3
    elseif hasDisorganized then
        capacity = capacity * 0.7
    end
    capacity = math.floor(capacity)

    if containerUi.isPlayerInventory then
        capacity = getSpecificPlayer(containerUi.playerNum):getMaxWeight()
    end

    local realWeight = inv:getCapacityWeight()
    local roundedWeight = round(realWeight, 1)
    local weightText = roundedWeight .. " / " .. capacity

    local r,g,b = 1,1,1
    
    if containerUi.isPlayerInventory then
        r,g,b = getWeightColor(realWeight, capacity)
    end
    
    self:drawTextCentre(weightText, ICON_SIZE/2 + ICON_PADDING_X - 7, ICON_PADDING_Y*2 + ICON_SIZE - 1, r,g,b, 1);
    local lineHeight = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
    local lineWidth = getTextManager():MeasureStringX(UIFont.Small, weightText)
    
    local weightXOff = 3
    local weightYOff = 2
    if g == 0 then
        weightXOff = weightXOff + ZombRand(-1/r,1/r)
        weightYOff = weightYOff + ZombRand(-1/r,1/r)
    end

    if r == 1 and g == 1 and b == 1 then
        self:drawTexture(WEIGHT_TEXTURE, ICON_SIZE/2 + ICON_PADDING_X - 7 + lineWidth/2 + weightXOff, ICON_PADDING_Y*2 + ICON_SIZE + weightYOff, 1, 1, 0.92, 0.75);
    else
        self:drawTexture(WEIGHT_TEXTURE, ICON_SIZE/2 + ICON_PADDING_X - 7 + lineWidth/2 + weightXOff, ICON_PADDING_Y*2 + ICON_SIZE + weightYOff, 1, math.max(r*0.65, 0.4), g*0.65, b*0.65);
    end

    self:drawRectBorder(0, 0, self.width, self.height, 0.5,1,1,1)   
end

local function isPointOverContainerIcon(x, y)
    return x > ICON_PADDING_X and x < ICON_SIZE + ICON_PADDING_X and y > ICON_PADDING_Y/2 and y < ICON_SIZE + ICON_PADDING_Y/2
end

function ItemGridContainerUI.info_onRightMouseUp(self, x, y)
    if self.containerUi.item and isPointOverContainerIcon(x, y) then
        ItemGridUI.openItemContextMenu(self, x, y, self.containerUi.item, self.containerUi.playerNum)
    end
end

function ItemGridContainerUI.info_onMouseDown(self, x, y)
    if self.containerUi.item and isPointOverContainerIcon(x, y) then
        local vanillaStack = DragAndDrop.convertItemToStack(self.containerUi.item)
        DragAndDrop.prepareDrag(self, vanillaStack, x, y)
    end
end

function ItemGridContainerUI.info_onMouseMove(self, dx, dy)
    if self.containerUi.item then
        DragAndDrop.startDrag(self)
    end
end

function ItemGridContainerUI.info_onMouseMoveOutside(self, dx, dy)
    if self.containerUi.item then
        DragAndDrop.startDrag(self)
    end
end

function ItemGridContainerUI.info_onMouseUp(self, x, y)
    local stack = ISMouseDrag.dragging
    if stack and stack.items then
        local item = stack.items[1]
        local playerObj = getSpecificPlayer(self.containerUi.playerNum)
        if self.containerUi.containerGrid:canAddItem(item) then
            for i=2, #stack.items do
                local item = stack.items[i]
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, item, item:getContainer(), self.containerUi.inventory))
            end
        end
    end

    DragAndDrop.endDrag(self)
end

function ItemGridContainerUI.info_onMouseUpOutside(self, x, y)
    if self.containerUi.item then
        DragAndDrop.cancelDrag(self, self.containerUi.cancelDragDropItem)
    end
end

function ItemGridContainerUI:cancelDragDropItem()
    local stack = ISMouseDrag.dragging
    if not stack or not stack.items then return end

    local item = stack.items[1]
    if not item then return end

    if not ISUIElement.isMouseOverAnyUI() then
        ISInventoryPaneContextMenu.dropItem(item, self.containerUi.playerNum)
    end
end

function ItemGridContainerUI:renderTitle(text, xOffset, yOffset, paddingX, paddingY)
    local textW = getTextManager():MeasureStringX(UIFont.Small, text);
    local textH = getTextManager():getFontHeight(UIFont.Small);
    
    self:drawRect(xOffset, yOffset, textW+paddingX*2, textH+paddingY*2, 0.9,0,0,0)
    self:drawRectBorder(xOffset, yOffset, textW+paddingX*2, textH+paddingY*2, 0.5,1,1,1)
    self:drawText(text, xOffset+paddingX, yOffset+paddingY, 1, 1, 1, 1, UIFont.Small);
end