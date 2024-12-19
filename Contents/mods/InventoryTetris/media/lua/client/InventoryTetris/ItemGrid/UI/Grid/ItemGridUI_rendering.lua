require "ISUI/ISPanel"
require "InventoryTetris/TetrisItemCategory"

-- PARTIAL CLASS
if not ItemGridUI then
    ItemGridUI = ISPanel:derive("ItemGridUI")

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
    [TetrisItemCategory.MOVEABLE] = {0.7, 0.7, 0.7},
}

ItemGridUI.GENERIC_ACTION_COLOR = {0, 0.7, 1}

local containerItemHoverColor = {1, 1, 0}
local invalidItemHoverColor = {1, 0, 0}
local stackableColor = {0.4, 0.6, 0.6}

local function unpackColors(cols, brightness)
    if not brightness then
        brightness = 1
    end
    return cols[1] * brightness, cols[2] * brightness, cols[3] * brightness
end

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

local function determineContainerHoverColor(draggedStack, hoveredStack, dragInv, hoverInv, playerNum)
    local draggedItem = ItemStack.getFrontItem(draggedStack, dragInv)
    local containerItem = ItemStack.getFrontItem(hoveredStack, hoverInv)

    if draggedItem and containerItem and containerItem:IsInventoryContainer() then
        local container = containerItem:getInventory()
        local gridContainer = ItemContainerGrid.CreateTemp(container, playerNum)
        if gridContainer:canAddItem(draggedItem) and container:hasRoomFor(getSpecificPlayer(playerNum), draggedItem) then
            return unpack(containerItemHoverColor)
        end
    end

    return unpack(invalidItemHoverColor)
end

-- Drag category -> hover category -> color
local StackHoverColorsByCategories = {
    ["any"] = {
        [TetrisItemCategory.CONTAINER] = determineContainerHoverColor
    }
}

function ItemGridUI.registerItemHoverColor(dragCategory, hoverCategory, color)
    if not StackHoverColorsByCategories[dragCategory] then
        StackHoverColorsByCategories[dragCategory] = {}
    end

    StackHoverColorsByCategories[dragCategory][hoverCategory] = color
end

function ItemGridUI:getColorForStackHover(draggedStack, hoveredStack, dragInv, hoverInv)
    local colorProvider = nil

    if StackHoverColorsByCategories[draggedStack.category] then
        if StackHoverColorsByCategories[draggedStack.category][hoveredStack.category] then
            colorProvider = StackHoverColorsByCategories[draggedStack.category][hoveredStack.category]
        end
    end

    if not colorProvider then
        if StackHoverColorsByCategories["any"][hoveredStack.category] then
            colorProvider = StackHoverColorsByCategories["any"][hoveredStack.category]
        end
    end

    if not colorProvider then
        return unpackColors(invalidItemHoverColor)
    end

    if type(colorProvider) == "function" then
        return colorProvider(draggedStack, hoveredStack, dragInv, hoverInv, self.playerNum)
    else
        return unpackColors(colorProvider)
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
    ItemGridUI.lineHeight = getTextManager():getFontHeight(UIFont.Small)

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
    self:drawRect(1, 1, self:getWidth()-2, self:getHeight()-2, 0.8, 0.2, 0.2, 0.2)
    self:drawTextCentre("?", self:getWidth()/2, self:getHeight()/2 - ItemGridUI.lineHeight, 1, 1, 1, 1, UIFont.Large)
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
    local inventory = self.grid.inventory
    local stacks = self.grid:getStacks()
    self:renderStackLoop(inventory, stacks, 1, searchSession)
end

function ItemGridUI:renderStackLoop(inventory, stacks, alphaMult, searchSession)
    local CELL_SIZE = OPT.CELL_SIZE
    local gravityEnabled = SandboxVars.InventoryTetris.EnableGravity
    local draggedItem = DragAndDrop.getDraggedItem()

    local playerObj = getSpecificPlayer(self.playerNum)

    local count = #stacks
    for i=count,1,-1 do
        local stack = stacks[i]
        local item = ItemStack.getFrontItem(stack, inventory)

        if item then
            if stack.count > 1 and stack.category == TetrisItemCategory.FOOD then
                for itemId, _ in pairs(stack.itemIDs) do
                    local item = inventory:getItemById(itemId)
                    updateItem(item)
                end
            else
                updateItem(item);
            end

            local x, y = stack.x, stack.y
            if x and y then

                local isBuried = gravityEnabled and self.grid:isStackBuried(stack)

                if searchSession then
                    local revealed = searchSession.searchedStackIDs[item:getID()]
                    if revealed then
                        self:_renderGridStack(playerObj, stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult, false, isBuried)
                    else
                        self:_renderHiddenStack(playerObj, stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult, false)
                    end
                else
                    if item ~= draggedItem then
                        self:_renderGridStack(playerObj, stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult, false, isBuried)
                    else
                        self:_renderGridStack(playerObj, stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 0.4 * alphaMult, false, isBuried)
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

    local hoveredStack = self:findGridStackUnderMouse()
    local hoveredItem = hoveredStack and ItemStack.getFrontItem(hoveredStack, self.grid.inventory) or nil

    if not hoveredStack or hoveredItem == item then 
        local x = self:getMouseX()
        local y = self:getMouseY()
        local isRotated = DragAndDrop.isDraggedItemRotated()
        
        local itemW, itemH = TetrisItemData.getItemSize(item, isRotated)

        local halfCell = OPT.CELL_SIZE / 2
        local xPos = x + halfCell - itemW * halfCell
        local yPos = y + halfCell - itemH * halfCell

        local gridX, gridY = ItemGridUiUtil.mousePositionToGridPosition(xPos, yPos)
        
        local canPlace = self.grid:doesItemFit(item, gridX, gridY, isRotated)
        canPlace = canPlace and self.containerGrid:isItemAllowed(item) 
        canPlace = canPlace and (self.grid.inventory == item:getContainer() or self.grid.inventory:hasRoomFor(getSpecificPlayer(0), item))
        
        if canPlace then
            self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 0, 1, 0)
        else
            self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 1, 0, 0)
        end
        return
    end
    
    local w, h = TetrisItemData.getItemSize(ItemStack.getFrontItem(hoveredStack, self.grid.inventory), hoveredStack.isRotated)
    
    if ItemStack.canAddItem(hoveredStack, item) then
        self:_renderPlacementPreview(hoveredStack.x, hoveredStack.y, w, h, unpackColors(stackableColor))
        return
    end

    local otherContainerGrid = ItemContainerGrid.Create(item:getContainer(), self.playerNum)
    local draggedStack = otherContainerGrid:findGridStackByVanillaStack(DragAndDrop.getDraggedStack()) or ItemStack.createTempStack(item)

    self:_renderPlacementPreview(hoveredStack.x, hoveredStack.y, w, h, self:getColorForStackHover(draggedStack, hoveredStack, otherContainerGrid.inventory, self.grid.inventory))    
end

function ItemGridUI:_renderPlacementPreview(gridX, gridY, itemW, itemH, r, g, b)
    self:drawRect(gridX * OPT.CELL_SIZE - gridX + 1, gridY * OPT.CELL_SIZE - gridY + 1, itemW * OPT.CELL_SIZE - itemW - 1, itemH * OPT.CELL_SIZE - itemH - 1, 0.55, r, g, b)
end

function ItemGridUI.getItemColor(item, limit)
    if not item then
        return 1,1,1
    end
    if not item:allowRandomTint() then
        return item:getR(), item:getG(), item:getB()
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

function ItemGridUI._renderGridStack(drawingContext, playerObj, stack, item, x, y, alphaMult, force1x1, isBuried)
    ItemGridUI._renderGridItem(drawingContext, playerObj, item, stack, x, y, stack.isRotated, alphaMult, force1x1, isBuried)
    if stack.count > 1 then
        local text = tostring(stack.count)
        ItemGridUI._drawTextOnTopLeft(drawingContext, text, item, x, y, stack.isRotated, alphaMult, force1x1)
    end
    
    if item:getMaxAmmo() > 0 then
        local text = tostring(item:getCurrentAmmoCount())
        ItemGridUI._drawTextOnBottomRight(drawingContext, text, item, x, y, stack.isRotated, alphaMult, force1x1)
    elseif item:IsFood() then
        local percent = item:getHungerChange() / item:getBaseHunger()
        if percent < 1.0 then
            ItemGridUI._drawVerticalBar(drawingContext, percent, item, x, y, stack.isRotated, alphaMult, force1x1)
        end
    elseif item:IsDrainable() then
        local percent = item:getDelta()
        if percent < 1.0 then
            ItemGridUI._drawVerticalBar(drawingContext, percent, item, x, y, stack.isRotated, alphaMult, force1x1)
        end
    end
end

function ItemGridUI._drawTextOnBottomRight(drawingContext, text, item, x, y, isRotated, alphaMult, force1x1)
    local font = UIFont.Small

    local w,h = 1,1
    if not force1x1 then
        w,h = TetrisItemData.getItemSize(item, isRotated)
    end

    x = x + OPT.CELL_SIZE*w - w - 2
    y = y + OPT.CELL_SIZE*h - h - ItemGridUI.lineHeight - 1

    drawingContext:drawTextRight(text, x+1, y+1, 0, 0, 0, alphaMult, font)
    drawingContext:drawTextRight(text, x, y, 1, 1, 1, alphaMult, font)
end

function ItemGridUI._drawTextOnTopLeft(drawingContext, text, item, x, y, isRotated, alphaMult, force1x1)
    local font = UIFont.Small

    local w,h = 1,1
    if not force1x1 then
        w,h = TetrisItemData.getItemSize(item, isRotated)
    end

    x = x + 2
    y = y - 1

    drawingContext:drawText(text, x+1, y+1, 0, 0, 0, alphaMult, font)
    drawingContext:drawText(text, x, y, 1, 1, 1, alphaMult, font)
end

local function lerp(value, a, b)
    if value < 0 then value = 0; end
    if value > 1 then value = 1; end

    local diff = b - a;
    return a + (diff * value);
end

local function lerpColorsARGB(value, col1, col2)
    return 
        lerp(value, col1.a, col2.a),
        lerp(value, col1.r, col2.r),
        lerp(value, col1.g, col2.g),
        lerp(value, col1.b, col2.b)
end

local function triLerpColors(value, col1, col2, col3)
    if value <= 0.5 then
        return lerpColorsARGB(value * 2, col1, col2);
    else
        return lerpColorsARGB((value - 0.5) * 2, col2, col3);
    end
end


local fullCol = {r=0, g=1,b=1,a=1}
local halfCol = {r=1,g=1,b=0,a=1}
local emptyCol = {r=1,g=0,b=0,a=1}
function ItemGridUI._drawVerticalBar(drawingContext, percent, item, x, y, isRotated, alphaMult, force1x1)
    local font = UIFont.Small

    local w,h = 1,1
    if not force1x1 then
        w,h = TetrisItemData.getItemSize(item, isRotated)
    end

    x = x + OPT.CELL_SIZE*w - w - 3
    local top = y + 1
    local bottom = y + OPT.CELL_SIZE*h - h+1
    local missing = (bottom - top) * (1.0 - percent)

    local a,r,g,b = triLerpColors(percent, emptyCol, halfCol, fullCol)
    drawingContext:drawRect(x, top, 3, bottom - top - 1, alphaMult,0.1,0.1,0.1)
    drawingContext:drawRect(x, top + missing, 2, bottom - top - missing, alphaMult*a,r,g,b)
end

function ItemGridUI._renderGridItem(drawingContext, playerObj, item, stack, x, y, rotate, alphaMult, force1x1, isBuried)
    local w, h = TetrisItemData.getItemSize(item, rotate)
    local CELL_SIZE = OPT.CELL_SIZE
    local TEXTURE_SIZE = OPT.TEXTURE_SIZE
    local TEXTURE_PAD = OPT.TEXTURE_PAD

    if force1x1 then
        w, h = 1, 1
    end

    local bgBright = isBuried and 0.35 or 1

    local minDimension = math.min(w, h)
    drawingContext:drawRect(x+1, y+1, w * CELL_SIZE - w - 1, h * CELL_SIZE - h - 1, 0.3 * alphaMult, unpackColors(colorsByCategory[stack.category], bgBright))

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
    r = r * bgBright
    g = g * bgBright
    b = b * bgBright
    
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

    local totalWidth = w * CELL_SIZE - w + 1
    local totalHeight = h * CELL_SIZE - h + 1
    if isBuried then
        drawingContext:drawRectBorder(x, y, totalWidth, totalHeight, 0.5, 0.55, 0.15, 0.15)
    else
        drawingContext:drawRectBorder(x, y, totalWidth, totalHeight, alphaMult, 0.55, 0.55, 0.55)
    end

    TetrisEvents.OnPostRenderGridItem:trigger(drawingContext, item, stack, x, y, totalWidth, totalHeight, playerObj)
end



function ItemGridUI._renderHiddenStack(drawingContext, playerObj, stack, item, x, y, alphaMult, force1x1)
    local w, h = TetrisItemData.getItemSize(item, stack.isRotated)
    if force1x1 then
        w, h = 1, 1
    end
    
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

