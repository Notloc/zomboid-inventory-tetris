require "ISUI/ISPanel"
require "InventoryTetris/TetrisItemCategory"

-- PARTIAL CLASS
if not ItemGridUI then
    ItemGridUI = ISPanel:derive("ItemGridUI")

    function ItemGridUI:new(grid, inventoryPane, containerUi, playerNum)
        local o = ISPanel:new(0, 0, 0, 0)
        setmetatable(o, self)
        self.__index = self

        o.grid = grid
        o.containerUi = containerUi
        o.inventoryPane = inventoryPane
        o.playerNum = playerNum

        o:setWidth(o:calculateWidth())
        o:setHeight(o:calculateHeight())

        return o
    end
end

local GridBackgroundTexturesByScale = {
    [0.5] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX0.5.png"),
    [0.75] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX0.75.png"),
    [1] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX1.png"),
    [1.5] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX1.5.png"),
    [2] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX2.png"),
    [3] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX3.png"),
    [4] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX4.png")
}

local GridLineTexturesByScale = {
    [0.5] = getTexture("media/textures/InventoryTetris/Grid/GridLineX0.5.png"),
    [0.75] = getTexture("media/textures/InventoryTetris/Grid/GridLineX0.75.png"),
    [1] = getTexture("media/textures/InventoryTetris/Grid/GridLineX1.png"),
    [1.5] = getTexture("media/textures/InventoryTetris/Grid/GridLineX1.5.png"),
    [2] = getTexture("media/textures/InventoryTetris/Grid/GridLineX2.png"),
    [3] = getTexture("media/textures/InventoryTetris/Grid/GridLineX3.png"),
    [4] = getTexture("media/textures/InventoryTetris/Grid/GridLineX4.png")
}

local colorsByCategory = {
    [TetrisItemCategory.MELEE] = {0.95, 0.15, 0.7},
    [TetrisItemCategory.RANGED] = {0.45, 0, 0},
    [TetrisItemCategory.AMMO] = {1, 1, 0},
    [TetrisItemCategory.MAGAZINE] = {0.85, 0.5, 0.05},
    [TetrisItemCategory.FOOD] = {0.1, 0.8, 0.25},
    [TetrisItemCategory.DRINK] = {0.1, 0.6, 0.2},
    [TetrisItemCategory.CLOTHING] = {0.5, 0.5, 0.5},
    [TetrisItemCategory.CONTAINER] = {0.65, 0.6, 0.4},
    [TetrisItemCategory.HEALING] = {0.1, 0.95, 1},
    [TetrisItemCategory.BOOK] = {0.3, 0, 0.5},
    [TetrisItemCategory.ENTERTAINMENT] = {0.3, 0, 0.5},
    [TetrisItemCategory.KEY] = {0.5, 0.5, 0.5},
    [TetrisItemCategory.MISC] = {0.5, 0.5, 0.5},
    [TetrisItemCategory.SEED] = {0.5, 0.5, 0.5},
}

local containerItemHoverColor = {1, 1, 0}
local invalidItemHoverColor = {1, 0, 0}

local OPT = require "InventoryTetris/Settings"
local BROKEN_TEXTURE = getTexture("media/textures/InventoryTetris/Broken.png")
local HIDDEN_ITEM = getTexture("media/textures/InventoryTetris/Hidden.png")

local function getBackgroundColorByCategory(category)
    local itemType = item:getDisplayCategory()
    if itemType == "Ammo" then
        return 0.5, 0.5, 0.5
    elseif itemType == "Weapon" then
        return 0.8, 0.2, 0.2
    elseif itemType == "Clothing" then
        return 0.8, 0.8, 0.1
    elseif itemType == "Food" then
        return 0.1, 0.7, 0.9
    elseif itemType == "Medical" then
        return 
    else
        return 
    end
end

function ItemGridUI:onApplyScale(scale)
    self:setWidth(self:calculateWidth())
    self:setHeight(self:calculateHeight())
end

function ItemGridUI:calculateWidth()
    return self.grid.width * OPT.CELL_SIZE - self.grid.width + 1
end

function ItemGridUI:calculateHeight()
    return self.grid.height * OPT.CELL_SIZE - self.grid.height + 1
end

function ItemGridUI:findGridStackUnderMouse()
    local rawX, rawY = ItemGridUiUtil.mousePositionToGridPosition(self:getMouseX(), self:getMouseY())
    return self.grid:getStack(rawX, rawY)
end

function ItemGridUI:getValidContainerFromStack(stack)
    if not stack or stack.count > 1 then
        return nil
    end
    local item = ItemStack.getFrontItem(stack, self.grid.inventory)
    if not item or not item:IsInventoryContainer() then
        return nil
    end

    return item:getInventory()
end

function ItemGridUI:render()
    if self.grid:isUnsearched(self.playerNum) then

        local searchSession = self.grid:getSearchSession(self.playerNum)
        if searchSession then
            self:renderBackGrid()
            if searchSession.isGridRevealed then
                self:renderGridItems(searchSession)
            else
                self:renderUnsearched()
            end
        else
            self:renderBackGrid()
            self:renderUnsearched()
        end
    else
        self:renderBackGrid()
        self:renderGridItems()
        self:renderDragItemPreview()
    end
end

function ItemGridUI:renderUnsearched()
    local lineHeight = 20 / 2

    self:drawRect(1, 1, self:getWidth()-2, self:getHeight()-2, 0.8, 0.2, 0.2, 0.2)
    self:drawTextCentre("?", self:getWidth()/2, self:getHeight()/2 - lineHeight, 1, 1, 1, 1, UIFont.Large)
end

function ItemGridUI:renderBackGrid()
    local g = 1
    local b = 1
    
    if self.isOverflowing then
        g = 0
        b = 0
    end
    
    local width = self.grid.width
    local height = self.grid.height
    
    local background = 0.07
    local totalWidth = OPT.CELL_SIZE * width - width + 1
    local totalHeight = OPT.CELL_SIZE * height - height + 1
    self:drawRect(0, 0, totalWidth, totalHeight, 0.8, background, background, background)

    local gridLines = 0.28

    local bgTex = GridBackgroundTexturesByScale[OPT.SCALE] or GridBackgroundTexturesByScale[1]
    local lineTex = GridLineTexturesByScale[OPT.SCALE] or GridLineTexturesByScale[1]
    self.javaObject:DrawTextureTiled(bgTex, 1, 1, totalWidth-1, totalHeight-1, 1, 1, 1, 0.35)
    self.javaObject:DrawTextureTiled(lineTex, 0, 0, totalWidth, totalHeight, gridLines, gridLines, gridLines, 1)
end

function updateItem(item)
    if instanceof(item, 'InventoryItem') then
        item:updateAge()
    end
    if instanceof(item, 'Clothing') then
        item:updateWetness()
    end
end

function ItemGridUI:renderGridItems(searchSession)
    local draggedItem = DragAndDrop.getDraggedItem()
    local inventory = self.grid.inventory
    local stacks = self.grid:getStacks()
    local backStacks = self.grid.backStacks

    self:renderStackLoop(inventory, stacks, 1, searchSession)
    self:renderStackLoop(inventory, backStacks, 1, searchSession) 
end

function ItemGridUI:renderStackLoop(inventory, stacks, alphaMult, searchSession)
    local CELL_SIZE = OPT.CELL_SIZE
    
    local count = #stacks
    for i=count,1,-1 do
        local stack = stacks[i]
        local item = ItemStack.getFrontItem(stack, inventory)

        if item then
            updateItem(item);

            local x, y = stack.x, stack.y
            if x and y then
                if searchSession then
                    local revealed = searchSession.searchedStackIDs[item:getID()]
                    if revealed then
                        self:_renderGridStack(stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult)
                    else
                        self:_renderHiddenStack(stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult)
                    end
                else
                    if item ~= draggedItem then
                        self:_renderGridStack(stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult)
                    else
                        self:_renderGridStack(stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 0.4 * alphaMult)
                    end
                end
            end
        end
    end
end

function ItemGridUI:renderDragItemPreview()
    local item = DragAndDrop.getDraggedItem()
    if not item or not self:isMouseOver() then
        return
    end
    
    local stack = self:findGridStackUnderMouse()
    if stack and not ItemStack.containsItem(stack, item) and ItemStack.canAddItem(stack, item) then
        local stackItem = ItemStack.getFrontItem(stack, self.grid.inventory)
        local w, h = TetrisItemData.getItemSize(stackItem, stack.isRotated)
        self:_renderPlacementPreview(stack.x, stack.y, w, h, 1, 1, 1)
        return
    end

    local container = self:getValidContainerFromStack(stack)
    if container and not ItemStack.containsItem(stack, item) then
        local containerItem = ItemStack.getFrontItem(stack, self.grid.inventory)
        local w, h = TetrisItemData.getItemSize(containerItem)

        local gridContainer = ItemContainerGrid.CreateTemp(container, self.playerNum)
        if gridContainer:canAddItem(item) and container:hasRoomFor(getSpecificPlayer(self.playerNum), item) then
            self:_renderPlacementPreview(stack.x, stack.y, w, h, unpack(containerItemHoverColor))
        else
            self:_renderPlacementPreview(stack.x, stack.y, w, h, unpack(invalidItemHoverColor))
        end
        return
    end

    local x = self:getMouseX()
    local y = self:getMouseY()
    local isRotated = DragAndDrop.isDraggedItemRotated()
    
    local itemW, itemH = TetrisItemData.getItemSize(item, isRotated)

    local halfCell = OPT.CELL_SIZE / 2
    local xPos = x + halfCell - itemW * halfCell
    local yPos = y + halfCell - itemH * halfCell

    local gridX, gridY = ItemGridUiUtil.mousePositionToGridPosition(xPos, yPos)
    local canPlace = self.grid:doesItemFit(item, gridX, gridY, isRotated) and self.containerUi.containerGrid:canAddItem(item) and self.grid.inventory:hasRoomFor(getSpecificPlayer(0), item)
    if canPlace then
        self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 0, 1, 0)
    else
        self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 1, 0, 0)
    end
end

function ItemGridUI:_renderPlacementPreview(gridX, gridY, itemW, itemH, r, g, b)
    self:drawRect(gridX * OPT.CELL_SIZE - gridX + 1, gridY * OPT.CELL_SIZE - gridY + 1, itemW * OPT.CELL_SIZE - itemW - 1, itemH * OPT.CELL_SIZE - itemH - 1, 0.55, r, g, b)
end

function ItemGridUI.getItemColor(item, limit)
    if not item or not item:allowRandomTint() then
        return 1,1,1
    end

    local colorInfo = item:getColorInfo()
    local r = colorInfo:getR()
    local g = colorInfo:getG()
    local b = colorInfo:getB()
    
    if not limit then
        limit = 0.2
    end

    -- Limit how dark the item can appear if all colors are close to 0
    while r < limit and g < limit and b < limit do
        r = r + limit / 4
        g = g + limit / 4
        b = b + limit / 4
    end
    return r,g,b
end

function ItemGridUI._renderGridStack(drawingContext, stack, item, x, y, alphaMult, force1x1)
    ItemGridUI._renderGridItem(drawingContext, item, stack.category, x, y, stack.isRotated, alphaMult, force1x1)
    if stack.count > 1 then
        -- Draw the item count
        local font = UIFont.Small
        local text = tostring(stack.count)
        drawingContext:drawText(text, x+3, y-1, 0, 0, 0, alphaMult, font)
        drawingContext:drawText(text, x+2, y-2, 1, 1, 1, alphaMult, font)
    end
end

function ItemGridUI._renderGridItem(drawingContext, item, category, x, y, rotate, alphaMult, force1x1)
    local w, h = TetrisItemData.getItemSize(item, rotate)
    local CELL_SIZE = OPT.CELL_SIZE
    local TEXTURE_SIZE = OPT.TEXTURE_SIZE
    local TEXTURE_PAD = OPT.TEXTURE_PAD

    if force1x1 then
        w, h = 1, 1
    end

    local minDimension = math.min(w, h)
    drawingContext:drawRect(x+1, y+1, w * CELL_SIZE - w - 1, h * CELL_SIZE - h - 1, 0.24 * alphaMult, unpack(colorsByCategory[category]))

    local texture = item:getTex()
    local texW = texture:getWidth()
    local texH = texture:getHeight()
    local largestDimension = math.max(texW, texH)

    local x2, y2 = nil, nil
    local targetScale = OPT.ICON_SCALE
    
    local precisionFactor = 8
    if largestDimension > TEXTURE_SIZE + TEXTURE_PAD then -- Handle large textures
        local mult = precisionFactor * largestDimension / TEXTURE_SIZE 
        mult = math.ceil(mult) / precisionFactor
        targetScale = targetScale / mult
    end

    x2 = 1 + x + TEXTURE_PAD * w + (w - minDimension) * (TEXTURE_SIZE) / 2
    y2 = 1 + y + TEXTURE_PAD * h + (h - minDimension) * (TEXTURE_SIZE) / 2
    if (targetScale < 1.0) then -- Center weirdly sized textures
        x2 = x2 + 0.5 * (TEXTURE_SIZE - texW * targetScale) * minDimension
        y2 = y2 + 0.5 * (TEXTURE_SIZE - texH * targetScale) * minDimension
    end
    targetScale = targetScale * minDimension

    local r,g,b = ItemGridUI.getItemColor(item)
    
    if rotate then
        if OPT.SCALE == 1.0 and w == 1 and h == 1 and largestDimension <= TEXTURE_SIZE then -- Can only rotate 1x1 items if they fit in the texture perfectly
            local half = TEXTURE_SIZE / 2
            drawingContext.javaObject:DrawTextureAngle(texture, x2+half, y2+half, -90.0, alphaMult, r, g, b)
        else -- Gotta flip the rest, rotation is off the table when scaling
            local width = texW * targetScale
            local height = texH * targetScale
            local xInset = (minDimension*TEXTURE_SIZE - width) / 2
            local yInset = (minDimension*TEXTURE_SIZE - height) / 2
            drawingContext:drawTextureScaledAspect(texture, x2 + width + xInset, y2 + height + yInset, -width, -height, alphaMult, r, g, b);
        end
    else
        drawingContext:drawTextureScaledUniform(texture, x2, y2, targetScale, alphaMult, r, g, b);
    end

    if item:isBroken() then
        drawingContext:drawTextureScaledUniform(BROKEN_TEXTURE, x2, y2, targetScale, alphaMult * 0.5, 1, 1, 1);
    end

    drawingContext:drawRectBorder(x, y, w * CELL_SIZE - w + 1, h * CELL_SIZE - h + 1, alphaMult, 0.55, 0.55, 0.55)
end



function ItemGridUI._renderHiddenStack(drawingContext, stack, item, x, y, alphaMult)
    local w, h = TetrisItemData.getItemSize(item, stack.isRotated)
    local CELL_SIZE = OPT.CELL_SIZE
    local TEXTURE_SIZE = OPT.TEXTURE_SIZE
    local TEXTURE_PAD = OPT.TEXTURE_PAD

    local minDimension = math.min(w, h)

    local width = w * CELL_SIZE - w - 1
    local height = h * CELL_SIZE - h - 1

    drawingContext:drawRect(x+1, y+1, width, height, 0.24 * alphaMult, 0.5, 0.5, 0.5)


    local x2, y2 = x + width / 2, y + height / 2
    local size = minDimension * TEXTURE_SIZE

    drawingContext:drawTextureCenteredAndSquare(HIDDEN_ITEM, x2, y2, size, alphaMult, 1,1,1);
    drawingContext:drawRectBorder(x, y, w * CELL_SIZE - w + 1, h * CELL_SIZE - h + 1, alphaMult, 0.55, 0.55, 0.55)
end

