require "ISUI/ISUIElement"

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

local ORGANIZED_TEXT = getText("UI_trait_Organized")
local DISORGANIZED_TEXT = getText("UI_trait_Disorganized")

local OPT = require "InventoryTetris/Settings"

GridContainerInfo = ISUIElement:derive("GridContainerInfo")

function GridContainerInfo:new(containerUi)
    local o = ISUIElement:new(0,0, 500, 500)
    setmetatable(o, self)
    self.__index = self

    o.containerUi = containerUi
    return o
end

function GridContainerInfo:createChildren()
    self.organizationIcon = ISImage:new(0, 0, 16, 16, ORGANIZED_TEXTURE)
    self.organizationIcon:initialise()
    self:addChild(self.organizationIcon)
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

function GridContainerInfo:prerender()
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
    self.organizationIcon:setMouseOverText(isContainerOrganized and ORGANIZED_TEXT or DISORGANIZED_TEXT)

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

function GridContainerInfo:onRightMouseUp(x, y)
    if self.containerUi.item and isPointOverContainerIcon(x, y) then
        local menu = ItemGridUI.openItemContextMenu(self, x, y, self.containerUi.item, self.containerUi.inventoryPane, self.containerUi.playerNum)
        TetrisDevTool.insertContainerDebugOptions(menu, self.containerUi)
    else
        local menu = ISContextMenu.get(0, getMouseX(), getMouseY());
        TetrisDevTool.insertContainerDebugOptions(menu, self.containerUi)
    end
end

function GridContainerInfo:onMouseDown(x, y)
    if self.containerUi.item and isPointOverContainerIcon(x, y) then
        local vanillaStack = DragAndDrop.convertItemToStack(self.containerUi.item)
        DragAndDrop.prepareDrag(self, vanillaStack, x, y)
    end
end

function GridContainerInfo:onMouseMove(dx, dy)
    if self.containerUi.item then
        DragAndDrop.startDrag(self)
    end
end

function GridContainerInfo:onMouseMoveOutside(dx, dy)
    if self.containerUi.item then
        DragAndDrop.startDrag(self)
    end
end

function GridContainerInfo:onMouseUp(x, y)
    local stack = DragAndDrop.getDraggedStack()
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

function GridContainerInfo:onMouseDoubleClick(x, y)
    if self.containerUi.item and isPointOverContainerIcon(x, y) then
        self.containerUi.inventoryPane.tetrisWindowManager:openContainerPopup(self.containerUi.item, self.containerUi.playerNum, self.containerUi.inventoryPane)
    end
    DragAndDrop.endDrag(self)
end

function GridContainerInfo:onMouseUpOutside(x, y)
    if self.containerUi.item then
        DragAndDrop.cancelDrag(self, self.cancelDragDropItem)
    end
end

function GridContainerInfo:cancelDragDropItem()
    local stack = DragAndDrop.getDraggedStack()
    if not stack or not stack.items then return end

    local item = stack.items[1]
    if not item then return end

    if not ISUIElement.isMouseOverAnyUI() then
        ISInventoryPaneContextMenu.dropItem(item, self.containerUi.playerNum)
    end
end