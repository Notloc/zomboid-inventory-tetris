require("InventoryTetris/UI/Grid/ItemGridUI")
require("InventoryTetris/Data/TetrisItemCategory")

-- Premade textures for supported scales so that any scale gets pixel perfect grids
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

-- Color code the items by category
local colorsByCategory = {
    [TetrisItemCategory.MELEE] = {0.95, 0.15, 0.7},
    [TetrisItemCategory.RANGED] = {0.45, 0, 0},
    [TetrisItemCategory.AMMO] = {1, 1, 0},
    [TetrisItemCategory.MAGAZINE] = {0.85, 0.5, 0.05},
    [TetrisItemCategory.ATTACHMENT] = {0.85, 0.4, 0.2},
    [TetrisItemCategory.FOOD] = {0.1, 0.8, 0.25},
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

-- When hover a stack over a stack that has an interaction handler, color the hovered stack with this color (or the interaction handler's color if it has one)
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

local OPT = require("InventoryTetris/Settings")
local BROKEN_TEXTURE = getTexture("media/textures/InventoryTetris/Broken.png")
local HIDDEN_ITEM = getTexture("media/textures/InventoryTetris/Hidden.png")
local SQUISHED_TEXTURE = getTexture("media/textures/InventoryTetris/Squished.png")

local function determineContainerHoverColor(draggedStack, hoveredStack, dragInv, hoverInv, playerNum)
    local draggedItem = ItemStack.getFrontItem(draggedStack, dragInv)
    local containerItem = ItemStack.getFrontItem(hoveredStack, hoverInv)

    if draggedItem and containerItem and containerItem:IsInventoryContainer() then
        local container = containerItem:getInventory()
        local gridContainer = ItemContainerGrid.CreateTemp(container, playerNum)
        if gridContainer:canAddItem(draggedItem) then
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

function ItemGridUI:findGridStackUnderMouse(x, y)
    local effectiveCellSize = OPT.CELL_SIZE - 1
    local gridX = math.floor(x / effectiveCellSize)
    local gridY = math.floor(y / effectiveCellSize)
    return self.grid:getStack(gridX, gridY, self.playerNum)
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

    self.itemTransferData = GridTransferQueueData.build(self.playerNum)

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
        self:renderIncomingTransfers()
        self:renderDragItemPreview()
    end
end

function ItemGridUI:renderUnsearched()
    self:drawRect(1, 1, self:getWidth()-2, self:getHeight()-2, 0.8, 0.2, 0.2, 0.2)
    self:drawTextCentre("?", self:getWidth()/2, self:getHeight()/2 - ItemGridUI.lineHeight, 1, 1, 1, 1, UIFont.Large)
end

-- 3 draw calls
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

function ItemGridUI.getGridBackgroundTexture()
    return GridBackgroundTexturesByScale[OPT.SCALE] or GridBackgroundTexturesByScale[1]
end

function ItemGridUI:renderIncomingTransfers()
    local incomingActions = self.itemTransferData:getIncomingActions(self.grid.inventory, self.grid.gridKey)
    local playerObj = getSpecificPlayer(self.playerNum)

    for item, action in pairs(incomingActions) do
        local stack = ItemStack.createTempStack(action.item)
        local item = action.item
        if action.gridX and action.gridY then
            ItemGridUI._renderGridItem(self, playerObj, item, stack, action.gridX * OPT.CELL_SIZE - action.gridX, action.gridY * OPT.CELL_SIZE - action.gridY, action.isRotated, 0.18, false, false)
        end
    end
end

-- The vanilla inventory render is also in charge of aging and drying items, so we need to do that here as well
function ItemGridUI.updateItem(item)
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

    if self.controllerNode.isFocused then
        self:renderControllerSelection()
    end
end

function ItemGridUI:renderControllerSelection()
    if ControllerDragAndDrop.isDragging(self.playerNum) then
        return
    end

    local x = self.selectedX
    local y = self.selectedY

    local w = 1
    local h = 1

    local stack = self.grid:getStack(x, y, self.playerNum)
    if stack then
        local item = ItemStack.getFrontItem(stack, self.grid.inventory)
        if not item then return end
        w, h = TetrisItemData.getItemSize(item, stack.isRotated)
        x = stack.x
        y = stack.y
    end

    self:drawRect(x * OPT.CELL_SIZE - x, y * OPT.CELL_SIZE - y, w*OPT.CELL_SIZE - w + 1, h*OPT.CELL_SIZE - h + 1, 0.5, 0.2, 1, 1)
end

function ItemGridUI:renderStackLoop(inventory, stacks, alphaMult, searchSession)
    local CELL_SIZE = OPT.CELL_SIZE
    local gravityEnabled = SandboxVars.InventoryTetris.EnableGravity
    local isJoypad = JoypadState.players[self.playerNum+1]
    local draggedItem = isJoypad and ControllerDragAndDrop.getDraggedItem(self.playerNum) or DragAndDrop.getDraggedItem()

    local playerObj = getSpecificPlayer(self.playerNum)
    local transferQueueData = self.itemTransferData

    local count = #stacks
    for i=count,1,-1 do
        local stack = stacks[i]
        local item = ItemStack.getFrontItem(stack, inventory)

        if item then
            if stack.count > 1 and stack.category == TetrisItemCategory.FOOD then
                for itemId, _ in pairs(stack.itemIDs) do
                    local item = inventory:getItemById(itemId)
                    ItemGridUI.updateItem(item)
                end
            else
                ItemGridUI.updateItem(item);
            end

            local x, y = stack.x, stack.y
            if x and y then
                local isBuried = gravityEnabled and self.grid:isStackBuried(stack)

                local transferAlpha = transferQueueData:getOutgoingActions(inventory)[item] and 0.4 or 1
                if searchSession then
                    local revealed = searchSession.searchedStackIDs[item:getID()]
                    if revealed then
                        self:_renderGridStack(playerObj, stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult * transferAlpha, false, isBuried)
                    else
                        self:_renderHiddenStack(playerObj, stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult, false)
                    end
                else
                    if item ~= draggedItem then
                        self:_renderGridStack(playerObj, stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 1 * alphaMult * transferAlpha, false, isBuried)
                    else
                        self:_renderGridStack(playerObj, stack, item, x * CELL_SIZE - x, y * CELL_SIZE - y, 0.4 * alphaMult * transferAlpha, false, isBuried)
                    end
                end
            end
        end
    end
end

function ItemGridUI:renderDragItemPreview()
    local isJoyPad = JoypadState.players[self.playerNum+1]
    local noMouse = not isJoyPad and not self:isMouseOver()
    local noController = isJoyPad and not self.controllerNode.isFocused

    local item = isJoyPad and ControllerDragAndDrop.getDraggedItem(self.playerNum) or DragAndDrop.getDraggedItem()
    if not item or noMouse or noController then
        return
    end

    local hoveredStack = isJoyPad and self.grid:getStack(self.selectedX, self.selectedY, self.playerNum) or self:findGridStackUnderMouse(self:getMouseX(), self:getMouseY())
    local hoveredItem = hoveredStack and ItemStack.getFrontItem(hoveredStack, self.grid.inventory) or nil

    -- Hovering over nothing or self
    if not hoveredStack or hoveredItem == item then
        local gridX, gridY = -1, -1
        local isRotated = isJoyPad and ControllerDragAndDrop.isDraggedItemRotated(self.playerNum) or DragAndDrop.isDraggedItemRotated()
        local itemW, itemH = TetrisItemData.getItemSize(item, isRotated)
        if not isJoyPad then
            local x = self:getMouseX()
            local y = self:getMouseY()

            local halfCell = OPT.CELL_SIZE / 2
            local xPos = x + halfCell - itemW * halfCell
            local yPos = y + halfCell - itemH * halfCell
            gridX, gridY = ItemGridUI.mousePositionToGridPosition(xPos, yPos)
        else
            gridX, gridY = self.selectedX, self.selectedY
        end

        local isSameInv = self.grid.inventory == item:getContainer()
        local canPlace = self.grid:doesItemFit(item, gridX, gridY, isRotated) and (isSameInv or self.containerGrid:isItemAllowed(item))

        if canPlace then
            self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 0, 1, 0)
        else
            self:_renderPlacementPreview(gridX, gridY, itemW, itemH, 1, 0, 0)
        end

        self:_renderControllerDrag(canPlace and 0.8 or 0.4)
        return
    end

    local w, h = TetrisItemData.getItemSize(ItemStack.getFrontItem(hoveredStack, self.grid.inventory), hoveredStack.isRotated)

    -- Hovering another stack
    if ItemStack.canAddItem(hoveredStack, item) then
        self:_renderPlacementPreview(hoveredStack.x, hoveredStack.y, w, h, unpackColors(stackableColor))
        self:_renderControllerDrag(0.8)
        return
    end

    local otherContainerGrid = ItemContainerGrid.GetOrCreate(item:getContainer(), self.playerNum)
    local draggedStack = otherContainerGrid:findGridStackByVanillaStack(DragAndDrop.getDraggedStack()) or ItemStack.createTempStack(item)

    -- Container hover
    self:_renderPlacementPreview(hoveredStack.x, hoveredStack.y, w, h, self:getColorForStackHover(draggedStack, hoveredStack, otherContainerGrid.inventory, self.grid.inventory))
    self:_renderControllerDrag(0.8)
end

function ItemGridUI:_renderControllerDrag(opacity)
    if ControllerDragAndDrop.isDragging(self.playerNum) then
        local item = ControllerDragAndDrop.getDraggedItem(self.playerNum)
        local stack = ControllerDragAndDrop.getDraggedTetrisStack(self.playerNum)
        local isRotated = ControllerDragAndDrop.isDraggedItemRotated(self.playerNum)
        local gridX, gridY = self.selectedX, self.selectedY
        local player = getSpecificPlayer(self.playerNum)
        self:_renderGridItem(player, item, stack, gridX * OPT.CELL_SIZE - gridX, gridY * OPT.CELL_SIZE - gridY, isRotated, opacity, false, false)
    end
end

function ItemGridUI:_renderPlacementPreview(gridX, gridY, itemW, itemH, r, g, b)
    self:drawRect(gridX * OPT.CELL_SIZE - gridX + 1, gridY * OPT.CELL_SIZE - gridY + 1, itemW * OPT.CELL_SIZE - itemW - 1, itemH * OPT.CELL_SIZE - itemH - 1, 0.55, r, g, b)
end

function ItemGridUI.getItemColor(item, limit)
    if not item or item:getTextureColorMask() ~= nil then
        return 1,1,1
    end

    local r = item:getR()
    local g = item:getG()
    local b = item:getB()

    --if not limit then
    --    limit = 0.2
    --end

    -- Limit how dark the item can appear if all colors are close to 0
    --while r < limit and g < limit and b < limit do
    --    r = r + limit / 4
    --    g = g + limit / 4
    --    b = b + limit / 4
    --end
    return r,g,b
end

function ItemGridUI.getMaskColor(item)
    if not item or item:getTextureColorMask() == nil then
        return 1,1,1
    end

    local r = item:getR()
    local g = item:getG()
    local b = item:getB()

    return r,g,b
end

---comment
---@param drawingContext any
---@param playerObj any
---@param stack any
---@param item InventoryItem
---@param x any
---@param y any
---@param alphaMult any
---@param force1x1 any
---@param isBuried any
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
        ---@cast item Food
        local percent = item:getHungerChange() / item:getBaseHunger()
        if percent < 1.0 then
            ItemGridUI._drawVerticalBar(drawingContext, percent, item, x, y, stack.isRotated, alphaMult, force1x1)
        end
    elseif item:IsDrainable() then
        ---@cast item DrainableComboItem
        local percent = item:getCurrentUses() / item:getMaxUses()
        if percent < 1.0 then
            ItemGridUI._drawVerticalBar(drawingContext, percent, item, x, y, stack.isRotated, alphaMult, force1x1)
        end
    elseif item:getFluidContainer() then
        local fluidContainer = item:getFluidContainer()
        local percent = fluidContainer:getAmount() / fluidContainer:getCapacity()
        if percent > 0 then
            local color = fluidContainer:getColor()
            ItemGridUI._drawVerticalBarWithColor(drawingContext, percent, item, x, y, stack.isRotated, alphaMult, force1x1, color:getAlpha(), color:getR(), color:getG(), color:getB())
        end
    elseif stack.category == TetrisItemCategory.CONTAINER then
        if TetrisItemData.isSquished(item) then
            local w,h = TetrisItemData.getItemSize(item, stack.isRotated)
            local x2 = x + OPT.CELL_SIZE*w - w - 16
            local y2 = y + 1
            drawingContext:drawTexture(SQUISHED_TEXTURE, x2, y2, alphaMult, 1, 1, 1);
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

function ItemGridUI._drawVerticalBarWithColor(drawingContext, percent, item, x, y, isRotated, alphaMult, force1x1, a,r,g,b)
    local font = UIFont.Small

    local w,h = 1,1
    if not force1x1 then
        w,h = TetrisItemData.getItemSize(item, isRotated)
    end

    x = x + OPT.CELL_SIZE*w - w - 3
    local top = y + 1
    local bottom = y + OPT.CELL_SIZE*h - h+1
    local missing = (bottom - top) * (1.0 - percent)

    local isDark = r + g + b < 0.6
    local bgCol = isDark and 1 or 0.1

    drawingContext:drawRect(x, top, 3, bottom - top - 1, alphaMult*0.5,bgCol,bgCol,bgCol)
    drawingContext:drawRect(x+1, top + missing, 2, bottom - top - missing, alphaMult*a,r,g,b)
end

-- A bit finnicky, the changes are not permanent and reset shortly after.
-- Seems to work fine during grid rendering in its current state.
function ItemGridUI.setTextureAsCrunchy(texture)
    local TEXTURE_2D = 3553

    -- Fixes blurry textures from other mods
    local MAG_FILTER = 10240
    --local MIN_FILTER = 10241
    local NEAREST = 9728
    SpriteRenderer.instance:glBind(texture:getID());
    SpriteRenderer.instance:glTexParameteri(TEXTURE_2D, MAG_FILTER, NEAREST);
    --SpriteRenderer.instance:glTexParameteri(TEXTURE_2D, MIN_FILTER, NEAREST); Is a bit hit or miss on improving the quality of textures, so I'm leaving it out for now

    -- Fixes pixel bleeding on the edge of textures from other mods
    local TEXTURE_WRAP_S = 10242
    local TEXTURE_WRAP_T = 10243
    local CLAMP_TO_EDGE = 33071
    SpriteRenderer.instance:glTexParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE);
    SpriteRenderer.instance:glTexParameteri(TEXTURE_2D, TEXTURE_WRAP_T, CLAMP_TO_EDGE);
end

---@param drawingContext ISUIElement
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

    local texture = item:getTex() or HIDDEN_ITEM

    local texW = texture:getWidth()
    local texH = texture:getHeight()
    local largestDimension = math.max(texW, texH)

    local x2, y2 = nil, nil
    local targetScale = OPT.SCALE
    local correctiveScale = 1.0

    if largestDimension > 34 then -- Handle large textures
        correctiveScale = 34 / largestDimension
    end

    x2 = 1 + x + TEXTURE_PAD * w + (w - minDimension) * (TEXTURE_SIZE) / 2
    y2 = 1 + y + TEXTURE_PAD * h + (h - minDimension) * (TEXTURE_SIZE) / 2

    targetScale = targetScale * minDimension

    local r,g,b = ItemGridUI.getItemColor(item)

    if rotate then
        local width = texW * targetScale * correctiveScale
        local height = texH * targetScale * correctiveScale
        local xInset = (minDimension*TEXTURE_SIZE - height) / 2
        local yInset = (minDimension*TEXTURE_SIZE - width) / 2
        ItemGridUI._drawItemRotated2(drawingContext, texture, x2 + xInset, y2 + yInset, width, height, alphaMult, r*bgBright, g*bgBright, b*bgBright)

        local fluidContainer = item:getFluidContainer()
        local fluidMask = item:getTextureFluidMask()
        if fluidContainer and fluidMask then
            
            local texW = texture:getWidth()
            local texH = texture:getHeight()
            local largestDimension = math.max(texW, texH)

            local correctiveScale = 1.0
            if largestDimension > 34 then
                correctiveScale = 34 / largestDimension
            end

            width = fluidMask:getWidth() * targetScale * correctiveScale
            height = fluidMask:getHeight() * targetScale * correctiveScale

            local percent = fluidContainer:getAmount() / fluidContainer:getCapacity()
            local col = fluidContainer:getColor()
            ItemGridUI._drawMask(drawingContext, fluidMask, percent, x2 + xInset, y2 + yInset, width, height, col:getR()*bgBright, col:getG()*bgBright, col:getB()*bgBright, alphaMult * col:getAlpha(), true)
        end
    else
        ItemGridUI._drawItem(drawingContext, item, x2, y2, targetScale * correctiveScale, alphaMult, bgBright)
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

-- Rotation moves the top-left corner to the top right position
function ItemGridUI._drawItemRotated2(drawingContext, texture, x, y, width, height, alphaMult, r, g, b)
    x = x + drawingContext:getAbsoluteX()
    y = y + drawingContext:getAbsoluteY()

    local realScalar = math.min(width / texture:getWidthOrig(), height / texture:getHeightOrig())
    x = x + texture:getOffsetY() * realScalar
    y = y + texture:getOffsetX() * realScalar

    local lx = x
    local rx = x + height
    local ty = y
    local by = y + width

    ItemGridUI.setTextureAsCrunchy(texture)
    drawingContext:drawTextureAllPoint(
        texture,
        rx, ty,
        rx, by,
        lx, by,
        lx, ty,
        r, g, b, alphaMult
    )
end

function ItemGridUI._drawItem(drawingContext, item, x, y, scale, alphaMult, brightness)
    local r,g,b = ItemGridUI.getItemColor(item)
    r = r * brightness
    g = g * brightness
    b = b * brightness

    local texture = item:getTex() or HIDDEN_ITEM
    local scalar = math.min(texture:getWidth() * scale / texture:getWidthOrig(), texture:getHeight() * scale / texture:getHeightOrig())

    local itemX = x + texture:getOffsetX() * scalar
    local itemY = y + texture:getOffsetY() * scalar

    ItemGridUI.setTextureAsCrunchy(texture)
    drawingContext:drawTextureScaledUniform(texture, itemX, itemY, scale, alphaMult, r, g, b);

    local fluidContainer = item:getFluidContainer()
    local fluidMask = item:getTextureFluidMask()
    if fluidContainer and fluidMask then
        local col = fluidContainer:getColor()
        local percent = fluidContainer:getAmount() / fluidContainer:getCapacity()
        ItemGridUI.setTextureAsCrunchy(fluidMask)
        ItemGridUI._drawMask(drawingContext, fluidMask, percent, x, y, fluidMask:getWidth()*scale, fluidMask:getHeight()*scale, col:getR(), col:getG(), col:getB(), alphaMult * col:getAlpha());
    end
end

local function rotateUVs(
    tlX, tlY,
    trX, trY,
    brX, brY,
    blX, blY,
    rotation, texture
)

    local sinTheta = math.sin(rotation)
    local cosTheta = math.cos(rotation)

    local centerX = texture:getXEnd() - (texture:getXEnd() - texture:getXStart()) / 2
    local centerY = texture:getYEnd() - (texture:getYEnd() - texture:getYStart()) / 2

    -- Localize the points
    local tlX = tlX - centerX
    local tlY = tlY - centerY
    local trX = trX - centerX
    local trY = trY - centerY
    local brX = brX - centerX
    local brY = brY - centerY
    local blX = blX - centerX
    local blY = blY - centerY

    -- Rotate the points
    local tlX2 = tlX * cosTheta - tlY * sinTheta
    local tlY2 = tlX * sinTheta + tlY * cosTheta
    local trX2 = trX * cosTheta - trY * sinTheta
    local trY2 = trX * sinTheta + trY * cosTheta
    local brX2 = brX * cosTheta - brY * sinTheta
    local brY2 = brX * sinTheta + brY * cosTheta
    local blX2 = blX * cosTheta - blY * sinTheta
    local blY2 = blX * sinTheta + blY * cosTheta

    return
        tlX2 + centerX, tlY2 + centerY,
        trX2 + centerX, trY2 + centerY,
        brX2 + centerX, brY2 + centerY,
        blX2 + centerX, blY2 + centerY
end

-- Ripped directly from the Java and modified a bit
function ItemGridUI._drawMask(drawingContext, texture, percentage, x, y, w, h, r, g, b, a, rotate)
    local realX = x + drawingContext:getAbsoluteX();
    local realY = y + drawingContext:getAbsoluteY();
    local hPercent;
    local cutoffH;

    local texW = texture:getWidth()
    local texH = texture:getHeight()

    if (texW > 0 and texH > 0 and w > 0.0 and h > 0.0) then
        local realScalar = math.min(w / texture:getWidthOrig(), h / texture:getHeightOrig());

        local insetX = (texture:getOffsetX() * realScalar);
        local insetY = (texture:getOffsetY() * realScalar);

        if rotate then
            local temp = insetX;
            insetX = insetY;
            insetY = temp;
        end

        realX = realX + insetX;
        realY = realY + insetY;
    end

    percentage = PZMath.max(0.15, percentage);
    hPercent = math.floor((h * percentage));
    realY = realY + h - hPercent;
    h = hPercent;
    hPercent = math.floor((texH * percentage));
    cutoffH = texH - hPercent;

    local texStartX = texture:getXStart();
    local texStartY = texture:getYStart();
    local texEndX = texture:getXEnd();
    local texEndY = texture:getYEnd();

    if (not (realY + h < 0.0) and not (realY > 4096.0)) then
        local left = 0.0
        local top = PZMath.clamp(cutoffH, 0.0, texH);
        local right = PZMath.clamp((left + texW), 0.0, texW) - left;
        local bottom = PZMath.clamp((top + hPercent), 0.0, texH) - top;
        local lX = left / texW;
        local tY = top / texH;
        local rX = (left + right) / texW;
        local bY = (top + bottom) / texH;
        local texWidth = texEndX - texStartX;
        local texHeight = texEndY - texStartY;

        lX = texStartX + lX * texWidth;
        rX = texStartX + rX * texWidth;
        tY = texStartY + tY * texHeight;
        bY = texStartY + bY * texHeight;


        local tlX = lX
        local tlY = tY
        local trX = rX
        local trY = tY
        local brX = rX
        local brY = bY
        local blX = lX
        local blY = bY

        if rotate then
            tlX, tlY, trX, trY, brX, brY, blX, blY = rotateUVs(tlX, tlY, trX, trY, brX, brY, blX, blY, math.rad(-90), texture)
        end

        SpriteRenderer.instance:render(texture, realX, realY, w, h, r, g, b, a, tlX, tlY, trX, trY, brX, brY, blX, blY)
    end

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
