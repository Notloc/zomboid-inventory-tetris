require "ISUI/ISUIElement"
require "Definitions/ContainerButtonIcons"

ItemGridContainerUI = ISPanel:derive("ItemGridContainerUI")

local ICON_PADDING_X = 12
local ICON_PADDING_Y = 8
local ICON_SIZE = 64

local GRID_PADDING = 5

local CONTAINER_PADDING_X = 4
local CONTAINER_PADDING_Y = 10
local TITLE_Y_PADDING = 4

local BASIC_INV_TEXTURE = getTexture("media/ui/Icon_InventoryBasic.png")
local SHELF_TEXTURE = getTexture("media/ui/Container_Shelf.png")
local WEIGHT_TEXTURE = getTexture("media/textures/InventoryTetris/weight.png")
local ORGANIZED_TEXTURE = getTexture("media/textures/InventoryTetris/Organized.png")
local DISORGANIZED_TEXTURE = getTexture("media/textures/InventoryTetris/Disorganized.png")
local SELECTED_TEXTURE = getTexture("media/ui/FavoriteStar.png")

local CONTAINER_BG = getTexture("media/textures/InventoryTetris/ContainerBG.png")

local ORGANIZED_TEXT = "Organized"
local DISORGANIZED_TEXT = "Disorganized"

local OPT = require "InventoryTetris/Settings"

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

    self.gridUis = self:createItemGridUIs()
    
    local infoRenderer = ISUIElement:new(0, 0, 5000, 5000)
    infoRenderer.containerUi = self
    infoRenderer.organizationIcon = ISImage:new(0, 0, 16, 16, ORGANIZED_TEXTURE)
    infoRenderer.organizationIcon:initialise()
    infoRenderer:addChild(infoRenderer.organizationIcon)
    
    infoRenderer.prerender = ItemGridContainerUI.prerenderInfo
    infoRenderer.onMouseUp = ItemGridContainerUI.info_onMouseUp
    infoRenderer.onMouseDown = ItemGridContainerUI.info_onMouseDown
    infoRenderer.onMouseMove = ItemGridContainerUI.info_onMouseMove
    infoRenderer.onRightMouseUp = ItemGridContainerUI.info_onRightMouseUp
    infoRenderer.onMouseUpOutside = ItemGridContainerUI.info_onMouseUpOutside
    infoRenderer.onMouseMoveOutside = ItemGridContainerUI.info_onMouseMoveOutside
    infoRenderer.onMouseDoubleClick = ItemGridContainerUI.info_onMouseDoubleClick

    local gridRenderer = ISUIElement:new(0, 0, 5000, 5000)
    gridRenderer:initialise()
    for _, gridUi in ipairs(self.gridUis) do
        gridRenderer:addChild(gridUi)
    end
    gridRenderer.prerender = ItemGridContainerUI.prerenderGrids
    
    self.infoRenderer = infoRenderer
    self.gridRenderer = gridRenderer

    self:addChild(gridRenderer)
    self:addChild(infoRenderer)

    self:applyScales(OPT.SCALE, OPT.CONTAINER_INFO_SCALE)
end

function ItemGridContainerUI:onApplyGridScale(gridScale)
    self:applyScales(gridScale, OPT.CONTAINER_INFO_SCALE)
end

function ItemGridContainerUI:onApplyContainerInfoScale(infoScale)
    self:applyScales(OPT.SCALE, infoScale)
end


function ItemGridContainerUI:applyScales(gridScale, infoScale)
    local lineHeight = getTextManager():getFontHeight(UIFont.Small)
    local yOffset = self.showTitle and lineHeight + (TITLE_Y_PADDING * 2) - 5 or 1

    local infoWidth = (ICON_SIZE + ICON_PADDING_X * 2) * infoScale
    local infoHeight = (ICON_SIZE + ICON_PADDING_Y * 2) * infoScale + (lineHeight + 4)

    self.infoRenderer:setWidth(infoWidth)
    self.infoRenderer:setHeight(infoHeight)
    self.infoRenderer:setY(yOffset)

    self.infoRenderer.organizationIcon:setWidth(16 * infoScale)
    self.infoRenderer.organizationIcon:setHeight(16 * infoScale)
    self.infoRenderer.organizationIcon.scaledWidth = 16 * infoScale
    self.infoRenderer.organizationIcon.scaledHeight = 16 * infoScale

    for _, grid in ipairs(self.gridUis) do
        grid:onApplyScale(gridScale)
    end

    local width, height = self:updateItemGridPositions(self.gridUis, gridScale)
    self.gridRenderer:setWidth(width+(GRID_PADDING*2*gridScale))
    self.gridRenderer:setHeight(height+(GRID_PADDING*2*gridScale))
    self.gridRenderer:setX(infoWidth+2)
    self.gridRenderer:setY(yOffset)

    for _, gridUi in ipairs(self.gridUis) do
        gridUi:setX(gridUi:getX() + GRID_PADDING*gridScale)
        gridUi:setY(gridUi:getY() + GRID_PADDING*gridScale)
    end

    self:setWidth(self.gridRenderer:getWidth() + infoWidth+2)
    self:setHeight(math.max(self.gridRenderer:getHeight(), self.infoRenderer:getHeight()) + yOffset)
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
function ItemGridContainerUI:updateItemGridPositions(_gridUis, scale)
    local xOffset = 0
    local yOffset = 0

    -- Space out the grids
    local gridSpacing = 6 * scale
    
    local gridUis = {}
    for _, gridUi in ipairs(_gridUis) do
        table.insert(gridUis, gridUi)
    end

    -- Map by y
    local gridUisByY = {}
    for _, gridUi in ipairs(gridUis) do
        local y = gridUi.grid.gridDefinition.position.y
        if not gridUisByY[y] then
            gridUisByY[y] = {}
        end
        table.insert(gridUisByY[y], gridUi)
    end
    table.sort(gridUis, function(a,b)
        return a.grid.gridDefinition.position.y < b.grid.gridDefinition.position.y
    end)

    for y, gridUis in pairs(gridUisByY) do
        -- Sort by x
        table.sort(gridUis, function(a,b)
            return a.grid.gridDefinition.position.x < b.grid.gridDefinition.position.x
        end)
    end

    -- Map by x
    local gridUisByX = {}
    for _, gridUi in ipairs(gridUis) do
        local x = gridUi.grid.gridDefinition.position.x
        if not gridUisByX[x] then
            gridUisByX[x] = {}
        end
        table.insert(gridUisByX[x], gridUi)
    end

    for x, gridUis in pairs(gridUisByX) do
        -- Sort by y
        table.sort(gridUis, function(a,b)
            return a.grid.gridDefinition.position.y < b.grid.gridDefinition.position.y
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


    -- Find the tallest column
    local tallestColumn = 0
    local columnHeights = {}
    for x, gridUis in pairs(gridUisByX) do
        local totalHeight = 0
        for _, gridUi in ipairs(gridUis) do
            totalHeight = totalHeight + gridUi:getHeight() + gridSpacing
        end
        totalHeight = totalHeight - gridSpacing
        columnHeights[x] = totalHeight
        if totalHeight > tallestColumn then
            tallestColumn = totalHeight
        end
    end

    -- Column widths
    local columnWidths = {}
    for x, gridUis in pairs(gridUisByX) do
        local columnWidth = 0
        for _, gridUi in ipairs(gridUis) do
            if gridUi:getWidth() > columnWidth then
                columnWidth = gridUi:getWidth()
            end
        end
        columnWidths[x] = columnWidth
    end

    local maxX = 0
    local maxY = 0

    local mode = self.containerGrid.containerDefinition.centerMode
    if mode == "horizontal" or mode == nil then 
        -- center on x axis
        local startX = xOffset
        for y, gridUisByX in pairs(gridUisByY) do
            xOffset = startX
            for x, gridUi in pairs(gridUisByX) do
                gridUi:setX(xOffset + (widestRow - rowWidths[y]) / 2)
                gridUi:setY(yOffset + (rowHeights[y] - gridUi:getHeight()))
                xOffset = xOffset + gridUi:getWidth() + gridSpacing
            end
            yOffset = yOffset + rowHeights[y] + gridSpacing

            if xOffset > maxX then
                maxX = xOffset
            end
        end

        maxY = yOffset
    else
        -- center on y axis
        local startY = yOffset
        for x, gridUisByY in pairs(gridUisByX) do
            yOffset = startY
            for y, gridUi in pairs(gridUisByY) do
                gridUi:setX(xOffset + (columnWidths[x] - gridUi:getWidth()))
                gridUi:setY(yOffset + (tallestColumn - columnHeights[x]) / 2)
                yOffset = yOffset + gridUi:getHeight() + gridSpacing
            end
            xOffset = xOffset + columnWidths[x] + gridSpacing

            if yOffset > maxY then
                maxY = yOffset
            end
        end

        maxX = xOffset
    end

    return maxX - gridSpacing, maxY - gridSpacing
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

        self:renderTitle(invName, 0, 0, TITLE_Y_PADDING, 1)
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
    local scale = OPT.CONTAINER_INFO_SCALE

    local r,g,b = 1,1,1
    if containerUi.item then
        r,g,b = ItemGridUI.getItemColor(containerUi.item, 0.5)
    end
    
    local offsetX = (ICON_SIZE/2 + ICON_PADDING_X) * scale
    local offsetY = (ICON_SIZE/2 + ICON_PADDING_Y) * scale
    self:drawTextureCenteredAndSquare(containerUi.invTexture, offsetX, offsetY+4, ICON_SIZE * scale, 1, r,g,b)

    local hasOrganized = containerUi.player:HasTrait("Organized")
    local hasDisorganized = containerUi.player:HasTrait("Disorganized")

    local isContainerOrganized = containerUi.containerGrid:isOrganized()
    if hasOrganized then
        isContainerOrganized = true
    elseif hasDisorganized then
        isContainerOrganized = false
    end

    local topIconY = 3 * scale

    self.organizationIcon:setX(self.width - (18*scale))
    self.organizationIcon:setY(topIconY)
    
    self.organizationIcon.texture = isContainerOrganized and ORGANIZED_TEXTURE or DISORGANIZED_TEXTURE
    self.organizationIcon:setMouseOverText(isContainerOrganized and "Organized" or "Disorganized")

    local isSelected = containerUi.isOnPlayer and containerUi.inventory == containerUi.inventoryPane.inventory
    if isSelected then
        local tx = SELECTED_TEXTURE:getWidth() * scale
        local ty = SELECTED_TEXTURE:getHeight() * scale
        self:drawTextureScaled(SELECTED_TEXTURE, 4, topIconY+2, tx, ty, 1, 1, 1, 1)
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
    
    local centerX = (ICON_SIZE/2 + ICON_PADDING_X) * scale - 8 * scale
    local textY = (ICON_PADDING_Y*2 + ICON_SIZE) * scale - scale
    self:drawTextCentre(weightText, centerX, textY, r,g,b, 1);
    local lineHeight = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
    local lineWidth = getTextManager():MeasureStringX(UIFont.Small, weightText)
    
    local weightXOff = 5
    local weightYOff = 0
    if g == 0 then
        weightXOff = weightXOff + ZombRand(-1/r,1/r)
        weightYOff = weightYOff + ZombRand(-1/r,1/r)
    end

    local weightX = centerX + lineWidth/2 + weightXOff * scale
    local weightY = textY + lineHeight*0.75 + weightYOff - (8 * scale) --half height of weight icon 
    if r == 1 and g == 1 and b == 1 then
        self:drawTextureScaledUniform(WEIGHT_TEXTURE, weightX, weightY, scale, 1, 1, 0.92, 0.75);
    else
        self:drawTextureScaledUniform(WEIGHT_TEXTURE, weightX, weightY, scale, 1, math.max(r*0.65, 0.4), g*0.65, b*0.65);
    end

    self:drawRectBorder(0, 0, self.width, self.height, 0.5,1,1,1)   
end

local function isPointOverContainerIcon(x, y)
    local scale = OPT.CONTAINER_INFO_SCALE
    return x > ICON_PADDING_X * scale and x < (ICON_SIZE + ICON_PADDING_X) * scale  and y > ICON_PADDING_Y * scale and y < (ICON_SIZE + ICON_PADDING_Y) * scale
end

function ItemGridContainerUI.info_onRightMouseUp(self, x, y)
    if self.containerUi.item and isPointOverContainerIcon(x, y) then
        local menu = ItemGridUI.openItemContextMenu(self, x, y, self.containerUi.item, self.containerUi.playerNum)
        TetrisDevTool.insertContainerDebugOptions(menu, self.containerUi)
    else
        local menu = ISContextMenu.get(0, getMouseX(), getMouseY());
        TetrisDevTool.insertContainerDebugOptions(menu, self.containerUi)
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

function ItemGridContainerUI:onMouseDoubleClick(x, y)
    if self.infoRenderer:isMouseOver(x, y) then
        self.infoRenderer:onMouseDoubleClick(self.infoRenderer:getMouseX(), self.infoRenderer:getMouseY())
    else
        local gridUi = ItemGridUiUtil.findGridUiUnderMouse(self.gridUis, x, y)
        if gridUi then
            gridUi:onMouseDoubleClick(gridUi:getMouseX(), gridUi:getMouseY())
            return
        end
    end
end

function ItemGridContainerUI.info_onMouseDoubleClick(self, x, y)
    if self.containerUi.item and isPointOverContainerIcon(x, y) then
        self.containerUi.inventoryPane.tetrisWindowManager:openContainerPopup(self.containerUi.item, self.containerUi.playerNum, self.containerUi.inventoryPane)
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