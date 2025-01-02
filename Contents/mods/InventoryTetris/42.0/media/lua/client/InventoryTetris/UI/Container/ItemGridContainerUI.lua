require("ISUI/ISUIElement")
require("ISUI/ISPanel")
require("Definitions/ContainerButtonIcons")
local OPT = require("InventoryTetris/Settings")

ItemGridContainerUI = ISPanel:derive("ItemGridContainerUI")

local ICON_PADDING_X = 12
local ICON_PADDING_Y = 8
local ICON_SIZE = 64

local GRID_PADDING = 5
local TITLE_Y_PADDING = 4

local BASIC_INV_TEXTURE = getTexture("media/ui/Icon_InventoryBasic.png")
local SHELF_TEXTURE = getTexture("media/ui/Container_Shelf.png")
local CONTAINER_BG = getTexture("media/textures/InventoryTetris/ContainerBG.png")
local PROX_INV_TEXTURE = getTexture("media/ui/ProximityInventory.png") or SHELF_TEXTURE

local BLACK = {r=0, g=0, b=0, a=1}

---@class ItemGridContainerUI : ISPanel
---@field inventory ItemContainer
---@field inventoryPane table
---@field playerNum number
---@field player IsoPlayer
---@field gridUis ItemGridUI[][]
---@field containerGrid ItemContainerGrid
function ItemGridContainerUI:new(inventory, inventoryPane, playerNum, containerDefOverride)
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

    if inventory:getType() == "proxInv" then
        o.invTexture = PROX_INV_TEXTURE
    end

    o.containerGrid = ItemContainerGrid.GetOrCreate(inventory, playerNum, containerDefOverride)
    o.containerGrid:addOnSecondaryGridsAdded(o, o._onSecondaryGridsAdded)
    o.containerGrid:addOnSecondaryGridsRemoved(o, o._onSecondaryGridsRemoved)

    o.keepOnScreen = false -- Keep on screen is a menace inside scroll panes and these are always inside scroll panes or other panels

    local player = getSpecificPlayer(playerNum)
    if inventory == player:getInventory() then
        o.isPlayerInventory = true
    end

    o.isOnPlayer = o.isPlayerInventory or (o.item and o.item:isInPlayerInventory())
    o.showTitle = true
    o.isGridCollapsed = false

    return o
end

function ItemGridContainerUI:unregisterEvents()
    self.containerGrid:removeOnSecondaryGridsAdded(self, self._onSecondaryGridsAdded)
    self.containerGrid:removeOnSecondaryGridsRemoved(self, self._onSecondaryGridsRemoved)
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

    local multiGridRenderer = ISPanel:new(0, 0, 5000, 5000)
    multiGridRenderer:initialise()
    multiGridRenderer.renderers = {}
    multiGridRenderer.sortedRenderers = {}

    self.gridUis = self:initItemGridUIs()
    local grids = self.gridUis[self.inventory]
    local gridRenderer = self:createGridRenderer(grids, self.inventory)
    multiGridRenderer:addChild(gridRenderer)
    multiGridRenderer.renderers[self.inventory] = gridRenderer
    multiGridRenderer.sortedRenderers[1] = gridRenderer

    local infoRenderer = GridContainerInfo:new(self)
    infoRenderer:initialise()

    local overflowRenderer = GridOverflowRenderer:new(0, 0, self, self.gridUis[self.inventory][1], self.inventory, self.inventoryPane, self.playerNum)
    overflowRenderer:initialise()

    local collapseButton = ISButton:new(0, 0, 16, 16, "V", self, ItemGridContainerUI.onCollapseButtonClick)
    collapseButton:initialise()
    collapseButton.borderColor = {r=1, g=1, b=1, a=0.1}
    collapseButton.backgroundColor = {r=1, g=1, b=1, a=0.1}

    self.infoRenderer = infoRenderer
    self.multiGridRenderer = multiGridRenderer
    self.overflowRenderer = overflowRenderer
    self.collapseButton = collapseButton

    self:addChild(multiGridRenderer)
    self:addChild(infoRenderer)
    self:addChild(overflowRenderer)
    self:addChild(collapseButton)

    self:applyScales(OPT.SCALE, OPT.CONTAINER_INFO_SCALE)

    self.containerGrid:refreshSecondaryGrids(true)
    self.isInitialized = true

    NotlocControllerNode
        :injectControllerNode(self)
        :setChildrenNodeProvider(function()
            local children = {}
            if not self.isGridCollapsed then
                for _, gridUis in pairs(self.gridUis) do
                    for _, gridUi in pairs(gridUis) do
                        table.insert(children, gridUi.controllerNode)
                    end
                end
            end
            table.insert(children, self.infoRenderer.controllerNode)
            return children
        end)
        :setGainJoypadFocusHandler(function()
            if self.isGridCollapsed then
                self.controllerNode:setSelectedChild(self.infoRenderer.controllerNode)
            end
        end)
end

function ItemGridContainerUI:createGridRenderer(gridUis, target)
    local gridRenderer = ISUIElement:new(0, 0, 5000, 5000)
    gridRenderer:initialise()
    for _, gridUi in ipairs(gridUis) do
        gridRenderer:addChild(gridUi)
    end

    gridRenderer.containerUi = self
    gridRenderer.prerender = self.isPlayerInventory and gridRenderer.prerender or ItemGridContainerUI.prerenderGrids
    gridRenderer.render = self.isPlayerInventory and ItemGridContainerUI.renderItemPreview or gridRenderer.render
    gridRenderer.grids = gridUis
    gridRenderer.secondaryTarget = target

    if instanceof(target, "ItemContainer") then
        gridRenderer.previewTex = BASIC_INV_TEXTURE
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    gridRenderer.onRightMouseUp = function(self, x, y)
        self.containerUi:onRightMouseUp(x, y)
    end

    return gridRenderer
end

function ItemGridContainerUI:onApplyGridScale(gridScale)
    self:applyScales(gridScale, OPT.CONTAINER_INFO_SCALE)
end

function ItemGridContainerUI:onApplyContainerInfoScale(infoScale)
    self:applyScales(OPT.SCALE, infoScale)
end

function ItemGridContainerUI:applyScales(gridScale, infoScale)
    local lineHeight = getTextManager():getFontHeight(UIFont.Small)
    local titleOffset = self.showTitle and lineHeight + (TITLE_Y_PADDING * 2) - 5 or 1

    local infoWidth = (ICON_SIZE + ICON_PADDING_X * 2) * infoScale
    local infoHeight = (ICON_SIZE + ICON_PADDING_Y * 2) * infoScale + (lineHeight + 4)

    self.infoRenderer:setWidth(infoWidth)
    self.infoRenderer:setHeight(infoHeight)
    self.infoRenderer:setY(titleOffset)

    self.multiGridRenderer:setX(infoWidth + 2)
    self.multiGridRenderer:setY(titleOffset)

    local maxX = 0
    local yOffset = 0
    local xOffset = self.isPlayerInventory and (OPT.CELL_SIZE + 4 + GRID_PADDING) or 0
    for _, renderer in ipairs(self.multiGridRenderer.sortedRenderers) do
        local containerDef = self.containerGrid.containerDefinition
        local target = renderer.secondaryTarget
        if target ~= self.inventory then
            containerDef = TetrisPocketData.getPocketDefinition(target)
        end

        for _, grid in ipairs(renderer.grids) do
            grid:onApplyScale(gridScale)
        end

        local width, height = self:updateItemGridPositions(renderer.grids, gridScale, containerDef)
        renderer:setWidth(width+(GRID_PADDING*2*gridScale) + xOffset)
        renderer:setHeight(height+(GRID_PADDING*2*gridScale))
        renderer:setX(0)
        renderer:setY(yOffset)

        for _, gridUi in ipairs(renderer.grids) do
            gridUi:setX(gridUi:getX() + GRID_PADDING*gridScale + xOffset)
            gridUi:setY(gridUi:getY() + GRID_PADDING*gridScale)
        end

        
        width = width + GRID_PADDING*2*gridScale + xOffset
        if width > maxX then
            maxX = width
        end

        yOffset = yOffset + height + GRID_PADDING*2*gridScale
    end

    self.multiGridRenderer:setWidth(maxX)
    self.multiGridRenderer:setHeight(yOffset)

    self:setWidth(maxX + infoWidth+2)

    if self.isGridCollapsed then
        self:setMaxDrawHeight(lineHeight + (TITLE_Y_PADDING * 2))
        self:setHeight(20)
        self.overflowRenderer:setVisible(false)
        self.infoRenderer:setVisible(false)
        self.multiGridRenderer:setVisible(false)
    else
        self:clearMaxDrawHeight()
        self:setHeight(math.max(self.multiGridRenderer:getHeight(), self.infoRenderer:getHeight()) + titleOffset)
        self.overflowRenderer:setVisible(true)
        self.infoRenderer:setVisible(true)
        self.multiGridRenderer:setVisible(true)
    end
end

function ItemGridContainerUI:initItemGridUIs()
    local itemGridUIs = {}

    local uis = self:createItemGridUIs(self.containerGrid.grids)
    itemGridUIs[self.inventory] = uis

    return itemGridUIs
end

function ItemGridContainerUI:createItemGridUIs(grids, secondaryKey)
    local uis = {}
    for _, grid in ipairs(grids) do
        local itemGridUI = ItemGridUI:new(grid, self.containerGrid, self.inventoryPane, self.playerNum)
        itemGridUI:initialise()
        table.insert(uis, itemGridUI)
    end
    return uis
end

function ItemGridContainerUI:findGridStackUnderMouse()
    for _, grids in pairs(self.gridUis) do
        for _, gridUi in pairs(grids) do
            if gridUi:isMouseOver() then
                return gridUi:findGridStackUnderMouse(gridUi:getMouseX(), gridUi:getMouseY())
            end
        end
    end
    return nil
end

-- Positions the grids so they are nicely spaced out
-- Returns the size of all the grids plus the spacing
function ItemGridContainerUI:updateItemGridPositions(_gridUis, scale, containerDef)
    local xOffset = 0
    local yOffset = 0

    -- Space out the grids
    local gridSpacing = 6 * scale

    local gridUis = {}
    for _, gridUi in ipairs(_gridUis) do
        table.insert(gridUis, gridUi)
    end
    table.sort(gridUis, function(a,b)
        return a.grid.gridDefinition.position.x < b.grid.gridDefinition.position.x
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

    local mode = containerDef.centerMode
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

function ItemGridContainerUI:prerender()
    local inv = self.inventory
    
    if self.containerGrid:shouldRefresh() or inv:isDrawDirty() then
        self.containerGrid:refresh(self)
        inv:setDrawDirty(false)
    end

    local infoWidth = (ICON_SIZE + ICON_PADDING_X * 2) * OPT.CONTAINER_INFO_SCALE
    local overflowPadding = #self.containerGrid.overflow > 0 and 8 or 0
    self:setWidth(self.multiGridRenderer:getWidth() + infoWidth+2 + self.overflowRenderer:getWidth() + overflowPadding)

    if self.showTitle then
        local invName = ""
        if self.item then
            invName = self.item:getName()
        elseif self.isPlayerInventory then
            invName = getText("IGUI_InventoryName", self.player:getDescriptor():getForename(), self.player:getDescriptor():getSurname())
        else
            invName = getTextOrNull("IGUI_ContainerTitle_" .. inv:getType()) or "Container"
        end

        local collapseX = self:renderTitle(invName, 0, 0, TITLE_Y_PADDING, 1) + 3
        
        self.collapseButton:setVisible(true)
        self.collapseButton:setX(collapseX)
    else
        self.collapseButton:setVisible(false)
    end
end

function ItemGridContainerUI.prerenderGrids(self)
    self:drawRect(0, 0, self.width, self.height, 0.9,0,0,0)
    self:drawTextureScaled(CONTAINER_BG, 0, 0, self.width, self.height, 0.225, 1, 1, 1)
    self:drawRectBorder(0, 0, self.width, self.height, 0.5,1,1,1)
end

function ItemGridContainerUI.renderItemPreview(self)
    local scale = OPT.SCALE
    local size = OPT.CELL_SIZE
    local x = GRID_PADDING*scale + 1
    local y = GRID_PADDING*scale

    self:drawTextureScaledAspect(ItemGridUI.getGridBackgroundTexture(), x, y, size, size, 0.35,1,1,1)
    self:drawRectBorder(x-1, y-1, size+2, size+2, 1,1,1,1)


    if self.previewTex then
        self:drawTextureScaledAspect(self.previewTex, x, y, size, size, 1, 1, 1, 1)
    else
        local tex = self.secondaryTarget:getTex()
        self:drawTextureScaledAspect(tex, x, y, size, size, 1, ItemGridUI.getItemColor(self.secondaryTarget))
    end

    local containerDef = self.grids[1].grid.containerDefinition
    local category = TetrisContainerData.getSingleValidCategory(containerDef)
    if category then
        local icon = TetrisItemCategory.getCategoryIcon(category)
        self:drawTextureScaledAspect(icon, x, y, 16, 16, 1, 1, 1, 1)
    end
end

function ItemGridContainerUI:renderTitle(text, xOffset, yOffset, paddingX, paddingY)
    local textW = getTextManager():MeasureStringX(UIFont.Small, text);
    local textH = getTextManager():getFontHeight(UIFont.Small);

    local color = (self.isGridCollapsed and self.controllerNode.isFocused) and NotlocControllerNode.FOCUS_COLOR or BLACK

    self:drawRect(xOffset, yOffset, textW+paddingX*2, textH+paddingY*2, color.a, color.r, color.g, color.b)
    self:drawRectBorder(xOffset, yOffset, textW+paddingX*2, textH+paddingY*2, 0.5,1,1,1)
    self:drawText(text, xOffset+paddingX, yOffset+paddingY, 1, 1, 1, 1, UIFont.Small);

    return xOffset + textW + paddingX*2
end

function ItemGridContainerUI:onCollapseButtonClick(button)
    self.isGridCollapsed = not self.isGridCollapsed

    if self.isGridCollapsed then
        self.collapseButton:setTitle(">")
    else
        self.collapseButton:setTitle("V")
    end

    self:applyScales(OPT.SCALE, OPT.CONTAINER_INFO_SCALE)
    self.inventoryPane:refreshContainer()
end


function ItemGridContainerUI:onMouseDoubleClick(x, y)
    if self.infoRenderer:isMouseOver() then
        self.infoRenderer:onMouseDoubleClick(self.infoRenderer:getMouseX(), self.infoRenderer:getMouseY())
        return
    end

    local gridUi = self:findGridUiUnderMouse(x,y)
    if gridUi then
        gridUi:onMouseDoubleClick(gridUi:getMouseX(), gridUi:getMouseY())
        return
    end

    self.overflowRenderer:onMouseDoubleClick(self.overflowRenderer:getMouseX(), self.overflowRenderer:getMouseY())
end

function ItemGridContainerUI:onRightMouseUp(x, y)
    if not self.isPlayerInventory then
        return
    end

    local target = self:didClickOnPocketPreview(x, y)
    if target then
        local menu = ItemGridUI.openItemContextMenu(self, self:getMouseX(), self:getMouseY(), target, self.inventoryPane, self.playerNum)
        TetrisDevTool.insertContainerDebugOptions(menu, self)
    end
end

function ItemGridContainerUI:didClickOnPocketPreview(x,y)
    for target, renderer in pairs(self.multiGridRenderer.renderers) do
        if target ~= self.inventory and renderer:isMouseOver(x, y) then
            local rX = renderer:getMouseX()
            local rY = renderer:getMouseY()

            if rX < OPT.CELL_SIZE + GRID_PADDING * OPT.SCALE and rY < OPT.CELL_SIZE + GRID_PADDING * OPT.SCALE then
                return target
            end
        end
    end
    return false
end

function ItemGridContainerUI:findGridUiUnderMouse(x, y)
    for _, renderer in pairs(self.multiGridRenderer.renderers) do
        if renderer:isMouseOver(x, y) then
            for _, gridUi in pairs(renderer.grids) do
                if gridUi:isMouseOver(x, y) then
                    return gridUi
                end
            end
        end
    end
    return nil
end

-- For render sorting
ItemGridContainerUI.itemSlotPriority = {
    "Neck",
    "Necklace",
    "Necklace_Long",
    "Scarf",
    "JacketHat",
    "JacketHat_Bulky",
    "Jacket",
    "JacketSuit",
    "Jacket_Bulky",
    "Jacket_Down",
    "TorsoExtra",
    "TorsoExtraPlus1",
    "TorsoExtraVest",
    "Shirt",
    "Tshirt",
    "ShortSleeveShirt",
    "Sweater",
    "SweaterHat",
    "Dress",
    "BathRobe",
    "TankTop",
    "Torso1Legs1",
    "FullSuit",
    "FullSuitHead",
    "FullTop",
    "SMUIJumpsuitPlus",
    "SMUITorsoRigPlus",
    "SMUIWebbingPlus",
    "Boilersuit",
    "EHEPilotVest",
    "TorsoRig",
    "TorsoRig2",
    "TorsoRigPlus2",
    "RifleSling",
    "AmmoStrap",
    "Belt",
    "Belt419",
    "Belt420",
    "BeltExtra",
    "BeltExtraHL",
    "SpecialBelt",
    "FannyPackBack",
    "FannyPackFront",
    "waistbags",
    "waistbagsComplete",
    "waistbagsf",
    "Underwear",
    "UnderwearBottom",
    "UnderwearExtra1",
    "UnderwearExtra2",
    "UnderwearInner",
    "UnderwearTop",
    "LowerBody",
    "Legs1",
    "Pants",
    "Skirt",
    "Shoes",
    "Back",
}

ItemGridContainerUI.itemSlotPriorityMap = {}
for i, slot in ipairs(ItemGridContainerUI.itemSlotPriority) do
    ItemGridContainerUI.itemSlotPriorityMap[slot] = i
end

function ItemGridContainerUI:_sortRenderers()
    local sortedOwners = {}
    for owner, renderer in pairs(self.multiGridRenderer.renderers) do
        if owner ~= self.inventory then
            table.insert(sortedOwners, owner)
        end
    end

    table.sort(sortedOwners, function(a,b)
        local aSlot = ItemGridContainerUI.itemSlotPriorityMap[a:getBodyLocation()] or 9999
        local bSlot = ItemGridContainerUI.itemSlotPriorityMap[b:getBodyLocation()] or 9999
        return aSlot < bSlot
    end)
    table.insert(sortedOwners, self.inventory)

    self.multiGridRenderer.sortedRenderers = {}
    for _, owner in ipairs(sortedOwners) do
        table.insert(self.multiGridRenderer.sortedRenderers, self.multiGridRenderer.renderers[owner])
    end
end

function ItemGridContainerUI:_countSlotsInGrids(gridUis)
    local count = 0
    for _, gridUi in ipairs(gridUis) do
        count = count + gridUi.grid.width * gridUi.grid.height
    end
    return count
end

function ItemGridContainerUI:_onSecondaryGridsAdded(target, grids)
    local uis = self:createItemGridUIs(grids, target)
    self.gridUis[target] = uis

    local renderer = self:createGridRenderer(uis, target)
    self.multiGridRenderer:addChild(renderer)
    self.multiGridRenderer.renderers[target] = renderer

    self:_sortRenderers()

    self:applyScales(OPT.SCALE, OPT.CONTAINER_INFO_SCALE)
    if self.isInitialized then
        self.inventoryPane:refreshItemGrids()
    end
end

function ItemGridContainerUI:_onSecondaryGridsRemoved(target)
    self.gridUis[target] = nil
    local renderer = self.multiGridRenderer.renderers[target]
    if renderer then
        self.multiGridRenderer:removeChild(renderer)
        self.multiGridRenderer.renderers[target] = nil
    end

    self:_sortRenderers()

    self:applyScales(OPT.SCALE, OPT.CONTAINER_INFO_SCALE)
    if self.isInitialized then
        self.inventoryPane:refreshItemGrids()
    end
end
