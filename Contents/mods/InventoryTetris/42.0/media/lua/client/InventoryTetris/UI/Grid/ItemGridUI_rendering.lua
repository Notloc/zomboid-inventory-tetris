require("InventoryTetris/UI/Grid/ItemGridUI")
require("InventoryTetris/Data/TetrisItemCategory")
require("InventoryTetris/Data/TetrisItemData")
local ItemGridUI = ItemGridUI
local TetrisItemCategory = TetrisItemCategory
local isItemSquished = TetrisItemData.isSquished
local getItemSize = TetrisItemData.getItemSize

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

local MEDIA_CHECKMARK_TEX = getTexture("media/ui/Tick_Mark-10.png")
local COLD_TEX = getTexture("media/textures/InventoryTetris/Cold.png")

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

local SEAMLESS_ITEM_BG_TEX = getTexture("media/textures/InventoryTetris/ItemBg.png")

local ITEM_BG_TEXTURE = {
    [0.5] = getTexture("media/textures/InventoryTetris/0.5x/ItemBg.png"),
    [0.75] = getTexture("media/textures/InventoryTetris/0.75x/ItemBg.png"),
    [1] = getTexture("media/textures/InventoryTetris/1x/ItemBg.png"),
    [1.5] = getTexture("media/textures/InventoryTetris/1.5x/ItemBg.png"),
    [2] = getTexture("media/textures/InventoryTetris/2x/ItemBg.png"),
    [3] = getTexture("media/textures/InventoryTetris/3x/ItemBg.png"),
    [4] = getTexture("media/textures/InventoryTetris/4x/ItemBg.png")
}

local BROKEN_TEXTURE = getTexture("media/textures/InventoryTetris/Broken.png")
local HIDDEN_ITEM = getTexture("media/textures/InventoryTetris/Hidden.png")
local SQUISHED_TEXTURE = getTexture("media/textures/InventoryTetris/Squished.png")
local FAVOURITE_TEXTURE = {
    [0.5] =   getTexture("media/textures/InventoryTetris/0.5x/Favourite.png"),
    [0.75] =  getTexture("media/textures/InventoryTetris/0.5x/Favourite.png"),
    [1] =     getTexture("media/textures/InventoryTetris/1x/Favourite.png"),
    [1.5] =   getTexture("media/textures/InventoryTetris/1x/Favourite.png"),
    [2] =     getTexture("media/textures/InventoryTetris/2x/Favourite.png"),
    [3] =     getTexture("media/textures/InventoryTetris/3x/Favourite.png"),
    [4] =     getTexture("media/textures/InventoryTetris/4x/Favourite.png")
}

local function determineContainerHoverColor(draggedStack, hoveredStack, dragInv, hoverInv, playerNum)
    local draggedItem = ItemStack.getFrontItem(draggedStack, dragInv)
    local containerItem = ItemStack.getFrontItem(hoveredStack, hoverInv)

    if draggedItem and containerItem and containerItem:IsInventoryContainer() then
        ---@cast containerItem InventoryContainer
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
    ---@cast item InventoryContainer
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
    local width = self.grid.width
    local height = self.grid.height

    local background = 0.07
    local totalWidth = OPT.CELL_SIZE * width - width + 1
    local totalHeight = OPT.CELL_SIZE * height - height + 1
    self:drawRect(0, 0, totalWidth, totalHeight, 0.8, background, background, background)

    local background = 0.62
    local gridLines = 0.5

    local bgTex = GridBackgroundTexturesByScale[OPT.SCALE] or GridBackgroundTexturesByScale[1]
    local lineTex = GridLineTexturesByScale[OPT.SCALE] or GridLineTexturesByScale[1]
    self.javaObject:DrawTextureTiled(bgTex, 1, 1, totalWidth-1, totalHeight-1, background, background, background, 0.7)
    self.javaObject:DrawTextureTiled(lineTex, 0, 0, totalWidth, totalHeight, gridLines, gridLines, gridLines, 1)
end

function ItemGridUI.getGridBackgroundTexture()
    return GridBackgroundTexturesByScale[OPT.SCALE] or GridBackgroundTexturesByScale[1]
end

function ItemGridUI:renderIncomingTransfers()
    local incomingActions = self.itemTransferData:getIncomingActions(self.grid.inventory, self.grid.gridKey)
    local playerObj = self.playerObj

    for _, action in pairs(incomingActions) do
        local stack = ItemStack.createTempStack(action.item)
        local item = action.item
        if action.gridX and action.gridY then
            local x = action.gridX * OPT.CELL_SIZE - action.gridX
            local y = action.gridY * OPT.CELL_SIZE - action.gridY
            local w, h = getItemSize(item, action.isRotated)
            ItemGridUI._renderGridStack(self, playerObj, stack, item, x, y, w, h, 0.5, action.isRotated)
        end
    end
end

-- The vanilla inventory render is also in charge of aging and drying items, so we need to do that here as well
function ItemGridUI.updateItem(item)
    if not item then return end

    item:updateAge()
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
        w, h = getItemSize(item, stack.isRotated)
        x = stack.x
        y = stack.y
    end

    self:drawRect(x * OPT.CELL_SIZE - x, y * OPT.CELL_SIZE - y, w*OPT.CELL_SIZE - w + 1, h*OPT.CELL_SIZE - h + 1, 0.5, 0.2, 1, 1)
end

local instructionBuffer = table.newarray()
function ItemGridUI:renderStackLoop(inventory, stacks, alphaMult, searchSession)
    local CELL_SIZE = OPT.CELL_SIZE
    local isJoypad = JoypadState.players[self.playerNum+1]
    local draggedItem = isJoypad and ControllerDragAndDrop.getDraggedItem(self.playerNum) or DragAndDrop.getDraggedItem()
    local playerObj = self.playerObj

    local outgoingQueueData = self.itemTransferData:getOutgoingActions(inventory)

    local yCorrection = 0
    local yCullBottom = 0
    local yCullTop = 9999

    local isNotPopup = not self.containerUi.isPopup
    if isNotPopup then
        yCorrection = self:getY() + self.parent:getY() + self.parent.parent:getY() + self.parent.parent.parent:getY() - self.inventoryPane.scrollView:getYScroll()
        yCullBottom = -self.inventoryPane.scrollView:getYScroll() - yCorrection
        yCullTop = yCullBottom + self.inventoryPane.scrollView:getHeight()
    end

    local bgTex = ITEM_BG_TEXTURE[OPT.SCALE] or SEAMLESS_ITEM_BG_TEX

    local instructionCount = 0
    local count = #stacks
    for i=1,count do
        local stack = stacks[i]
        local item = stack._frontItem or ItemStack.getFrontItem(stack, inventory)
        local itemId = stack._frontItemId
        if item then
            local x, y = stack.x, stack.y
            if x and y then
                local w, h = getItemSize(item, stack.isRotated)
                local uiX = x * CELL_SIZE - x
                local uiY = y * CELL_SIZE - y

                local shouldCull = isNotPopup and (uiY + h * CELL_SIZE - h < yCullBottom or uiY > yCullTop)
                if not shouldCull then
                    -- Only update the first item in the stack, ISInventoryTransferAction handles the rest JIT style
                    item:updateAge()
                    if stack.category == TetrisItemCategory.CLOTHING then
                        ---@cast item Clothing
                        item:updateWetness()
                    end

                    local transferAlpha = outgoingQueueData[item] and 0.4 or 1
                    local hidden = searchSession and not searchSession.searchedStackIDs[itemId]

                    local alpha = alphaMult * transferAlpha
                    if item == draggedItem then
                        alpha = 0.4 * alpha
                    end

                    instructionCount = instructionCount + 1
                    local instruction = instructionBuffer[instructionCount] or table.newarray()
                    instruction[1] = stack
                    instruction[2] = item
                    instruction[3] = uiX
                    instruction[4] = uiY
                    instruction[5] = w
                    instruction[6] = h
                    instruction[7] = alpha
                    instruction[8] = stack.isRotated
                    instruction[9] = hidden
                    instruction[10] = false

                    instructionBuffer[instructionCount] = instruction
                end
            end
        end
    end

    self:_bulkRenderGridStacks(instructionBuffer, instructionCount, playerObj, bgTex)
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
        local itemW, itemH = getItemSize(item, isRotated)
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

    local w, h = getItemSize(ItemStack.getFrontItem(hoveredStack, self.grid.inventory), hoveredStack.isRotated)

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
        local x = self.selectedX * OPT.CELL_SIZE - self.selectedX
        local y = self.selectedY * OPT.CELL_SIZE - self.selectedY
        local w, h = getItemSize(item, isRotated)
        self:_renderGridStack(self.playerObj, stack, item, x, y, w, h, opacity, isRotated)
    end
end

function ItemGridUI:_renderPlacementPreview(gridX, gridY, itemW, itemH, r, g, b)
    self:drawRect(gridX * OPT.CELL_SIZE - gridX + 1, gridY * OPT.CELL_SIZE - gridY + 1, itemW * OPT.CELL_SIZE - itemW - 1, itemH * OPT.CELL_SIZE - itemH - 1, 0.55, r, g, b)
end

function ItemGridUI.getItemColor(item, limit)
    if not item or item:getTextureColorMask() then
        return 1,1,1
    end

    local r = item:getR()
    local g = item:getG()
    local b = item:getB()

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

ItemGridUI.doLiteratureCheckmark = true

function ItemGridUI._showLiteratureCheckmark(player, item)
    return
        ItemGridUI.doLiteratureCheckmark and
        (
            (player:isLiteratureRead(item:getModData().literatureTitle)) or
            (SkillBook[item:getSkillTrained()] ~= nil and item:getMaxLevelTrained() < player:getPerkLevel(SkillBook[item:getSkillTrained()].perk) + 1) or
            (item:getNumberOfPages() > 0 and player:getAlreadyReadPages(item:getFullType()) == item:getNumberOfPages()) or
            (item:getTeachedRecipes() ~= nil and player:getKnownRecipes():containsAll(item:getTeachedRecipes())) or
            (item:getModData().teachedRecipe ~= nil and player:getKnownRecipes():contains(item:getModData().teachedRecipe))
        )
end

-- A bit finnicky, the changes are not permanent and reset shortly after.
-- Seems to work fine during grid rendering in its current state.
local spriteRenderer = SpriteRenderer.instance
function ItemGridUI.setTextureAsCrunchy(texture)
    local TEXTURE_2D = 3553

    -- Fixes blurry textures from other mods
    local MAG_FILTER = 10240
    --local MIN_FILTER = 10241
    local NEAREST = 9728
    spriteRenderer:glBind(texture:getID());
    spriteRenderer:glTexParameteri(TEXTURE_2D, MAG_FILTER, NEAREST);

    -- Fixes pixel bleeding on the edge of textures from other mods
    --local TEXTURE_WRAP_S = 10242
    --local TEXTURE_WRAP_T = 10243
    --local CLAMP_TO_EDGE = 33071
    --SpriteRenderer.instance:glTexParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE);
    --SpriteRenderer.instance:glTexParameteri(TEXTURE_2D, TEXTURE_WRAP_T, CLAMP_TO_EDGE);
end

local col3 = {r=0, g=1,b=1,a=1}
local col2 = {r=1,g=1,b=0,a=1}
local col1 = {r=1,g=0,b=0,a=1}
local function triLerpColors(value)
    if value < 0 then value = 0; end
    if value > 1 then value = 1; end

    if value <= 0.5 then
        value = value * 2
        return col1.a + (col2.a - col1.a) * value,
               col1.r + (col2.r - col1.r) * value,
               col1.g + (col2.g - col1.g) * value,
               col1.b + (col2.b - col1.b) * value
    else
        value = (value - 0.5) * 2
        return col2.a + (col3.a - col2.a) * value,
               col2.r + (col3.r - col2.r) * value,
               col2.g + (col3.g - col2.g) * value,
               col2.b + (col3.b - col2.b) * value
    end
end

-- Precache the sin and cos of 90 degree rotations
local sinTheta = math.sin(math.rad(90))
local cosTheta = math.cos(math.rad(90))

local floor = math.floor
local ceil = math.ceil

-- Color code the items by category
local neutral = 0.65
local colorsByCategory = {
    [TetrisItemCategory.MELEE] = {0.825, 0.1, 0.6},
    [TetrisItemCategory.RANGED] = {0.65, 0.05, 0.05},
    [TetrisItemCategory.AMMO] = {1, 1, 0.1},
    [TetrisItemCategory.MAGAZINE] = {0.85, 0.5, 0.05},
    [TetrisItemCategory.ATTACHMENT] = {0.9, 0.5, 0.3},
    [TetrisItemCategory.FOOD] = {0.05, 0.65, 0.15},
    [TetrisItemCategory.CLOTHING] = {neutral, neutral, neutral},
    [TetrisItemCategory.CONTAINER] = {0.65, 0.6, 0.4},
    [TetrisItemCategory.HEALING] = {0.1, 0.95, 1},
    [TetrisItemCategory.BOOK] = {0.3, 0, 0.5},
    [TetrisItemCategory.ENTERTAINMENT] = {0.3, 0, 0.5},
    [TetrisItemCategory.KEY] = {0.5, 0.5, 0.5},
    [TetrisItemCategory.MISC] = {neutral, neutral, neutral},
    [TetrisItemCategory.SEED] = {neutral, neutral, neutral},
    [TetrisItemCategory.MOVEABLE] = {0.7, 0.7, 0.7},
    [TetrisItemCategory.CORPSEANIMAL] = {0.7, 0.7, 0.7}
}

local stackFont = UIFont.Small
local postRenderGrid = TetrisEvents.OnPostRenderGrid

local maskQueue = table.newarray()
maskQueue[1] = table.newarray()
maskQueue[2] = table.newarray()

---@type table<string, ItemRenderData>
local itemDataCache = {}

local textureIdCache = {}
local fluidColorCache = {}
local textureDataCache = {}
local stringCache = {}

---@class ItemRenderData
---@field isFood boolean
---@field isFluidContainer boolean
---@field fluidCapacity number
---@field isDrainable boolean
---@field maxUses number
---@field hasAmmo boolean
---@field isLiterature boolean

---@param item InventoryItem
---@return ItemRenderData
local function getItemData(item, itemType)
    local isFood = item:isFood()
    local isFluidContainer = item:getFluidContainer() ~= nil
    local fluidCapacity = isFluidContainer and item:getFluidContainer():getCapacity()
    local isDrainable = item:IsDrainable()
    local maxUses = isDrainable and item:getMaxUses()
    local hasAmmo = item:getMaxAmmo() > 0
    local isLiterature = instanceof(item, "Literature")

    local data = {
        isFood = isFood,
        isFluidContainer = isFluidContainer,
        fluidCapacity = fluidCapacity,
        isDrainable = isDrainable,
        maxUses = maxUses,
        hasAmmo = hasAmmo,
        isLiterature = isLiterature
    }
    itemDataCache[itemType] = data
    return data
end

---@param texture Texture
local function getTextureId(texture)
    local id = texture:getID()
    textureIdCache[texture] = id
    return id
end

---@param texture Texture
local function getTextureData(texture)
    local data = {
        widthOrig = texture:getWidthOrig(),
        heightOrig = texture:getHeightOrig(),
        width = texture:getWidth(),
        height = texture:getHeight(),
        offsetX = texture:getOffsetX(),
        offsetY = texture:getOffsetY(),
        xStart = texture:getXStart(),
        yStart = texture:getYStart(),
        xEnd = texture:getXEnd(),
        yEnd = texture:getYEnd()
    }
    textureDataCache[texture] = data
    return data
end

---@param fluid Fluid|nil
local function getFluidColor(fluid)
    if not fluid then return {r=1,g=1,b=1,a=1} end
    local color = {}
    local colorObj = fluid:getColor()
    color.r = colorObj:getR()
    color.g = colorObj:getG()
    color.b = colorObj:getB()
    color.a = colorObj:getAlpha()
    fluidColorCache[fluid] = color
    return color
end

---@param obj any
local function getString(obj)
    local str = tostring(obj)
    stringCache[obj] = str
    return str
end


---@deprecated Use ItemGridUI._bulkRenderGridStacks instead.
---@param drawingContext ISUIElement
---@param playerObj any
---@param stack ItemStack
---@param item InventoryItem
---@param x any
---@param y any
---@param alphaMult any
function ItemGridUI._renderGridStack(drawingContext, playerObj, stack, item, x, y, w, h, alphaMult, isRotated, itemBgTex, doBorder)
    local renderInstructions = table.newarray()
    renderInstructions[1] = {stack, item, x, y, w, h, alphaMult, isRotated, false, doBorder}
    ItemGridUI._bulkRenderGridStacks(drawingContext, renderInstructions, 1, playerObj, itemBgTex)
end

-- HEY MODDER!
-- Want to add something to the item rendering? Use the OnPostRenderGrid event!
-- See /client/InventoryTetris/Events.lua for more info.
function ItemGridUI._bulkRenderGridStacks(drawingContext, renderInstructions, instructionCount, playerObj, itemBgTex)
    local SCALE = OPT.SCALE
    local CELL_SIZE = OPT.CELL_SIZE
    local TEXTURE_SIZE = OPT.TEXTURE_SIZE
    local TEXTURE_PAD = OPT.TEXTURE_PAD

    local javaObject = drawingContext.javaObject
    local absX = javaObject:getAbsoluteX()
    local absY = javaObject:getAbsoluteY()

    itemBgTex = itemBgTex or SEAMLESS_ITEM_BG_TEX

    for r=1,instructionCount do
        local instruction = renderInstructions[r]
        local stack = instruction[1]
        local item = instruction[2]
        local x = instruction[3]
        local y = instruction[4]
        local w = instruction[5]
        local h = instruction[6]
        local alphaMult = instruction[7]
        local isRotated = instruction[8]
        local hidden = instruction[9]
        local doBorder = instruction[10]

        local totalWidth = w * CELL_SIZE - w + 1
        local totalHeight = h * CELL_SIZE - h + 1

        if hidden then
            local minDimension = w
            if h < w then
                minDimension = h
            end

            drawingContext:drawRect(x+1, y+1, totalWidth, totalHeight, 0.24 * alphaMult, 0.5, 0.5, 0.5)

            local x2 = x + totalWidth * 0.5
            local y2 = y + totalHeight * 0.5
            local size = minDimension * TEXTURE_SIZE

            drawingContext:drawTextureCenteredAndSquare(HIDDEN_ITEM, x2, y2, size, alphaMult, 1,1,1);
        else
            local itemType = stack.itemType
            local itemData = itemDataCache[itemType] or getItemData(item, itemType)

            local fluidContainer = itemData.isFluidContainer and item:getFluidContainer()
            local fluid = fluidContainer and fluidContainer:getPrimaryFluid() or nil
            local fluidPercent = fluidContainer and (fluidContainer:getAmount() / itemData.fluidCapacity) or 0

            ---@cast item Food
            local hungerPercent = itemData.isFood and (item:getHungerChange() / item:getBaseHunger()) or 1
            ---@cast item DrainableComboItem
            local drainPercent = itemData.isDrainable and (item:getCurrentUses() / itemData.maxUses) or 1
            ---@cast item InventoryItem

            local doVerticalBar = fluidPercent > 0 or hungerPercent < 1.0 or drainPercent < 1.0

            -- BACKGROUND EFFECTS
            if itemData.isFood then
                ---@cast item Food
                local heat = item:getHeat() -- 1 = room, 0.2 = frozen, 3 = max
                if heat < 1.0 then
                    local coldPercent =  -(heat - 1.0) / 0.8
                    javaObject:DrawTextureScaledColor(nil, x, y, totalWidth, totalHeight, 0.1, 0.5, 1, alphaMult * coldPercent)
                elseif heat > 1.0 then
                    local hotPercent = (heat - 1.0) / 1.5
                    if hotPercent > 1 then hotPercent = 1 end
                    javaObject:DrawTextureScaledColor(nil, x, y, totalWidth, totalHeight, 1, 0.0, 0.0, alphaMult * hotPercent)
                end
            end
            -- END BACKGROUND EFFECTS

            local minDimension = w
            if h < w then
                minDimension = h
            end

            local cellW = CELL_SIZE * w - w
            local cellH = CELL_SIZE * h - h

            local barOffset = doVerticalBar and 3 or 0

            local cols = colorsByCategory[stack.category]
            javaObject:DrawTextureTiled(itemBgTex, x+1, y+1, cellW - 1 - barOffset, cellH - 1, cols[1], cols[2], cols[3], 0.725 * alphaMult)

            if doBorder then
                drawingContext:drawRectBorder(x, y+1, cellW, cellH, 0.5, 1, 1, 1)
            end

            local texture = item:getTex() or HIDDEN_ITEM

            local textureData = textureDataCache[texture] or getTextureData(texture)

            local texW = textureData.widthOrig
            local texH = textureData.heightOrig
            local largestDimension = texW
            if texW < texH then
                largestDimension = texH
            end

            local correctiveScale = 1.0
            if largestDimension > 32 then -- Handle large textures
                correctiveScale = 32 / largestDimension
            end

            local texHalf = TEXTURE_SIZE * 0.5
            local x2 = 1 + x + TEXTURE_PAD * w + (w - minDimension) * texHalf
            local y2 = 1 + y + TEXTURE_PAD * h + (h - minDimension) * texHalf

            local targetScale = SCALE * minDimension
            local mainTexScale = correctiveScale * targetScale
            local colorMask = item:getTextureColorMask()

            local r,g,b = 1,1,1
            if not colorMask then
                r,g,b = item:getR(), item:getG(), item:getB()
            end

            -- draw main tex
            --do
                local mainTexX = x2 + absX
                local mainTexY = y2 + absY

                local width = textureData.width * mainTexScale
                local height = textureData.height * mainTexScale

                local xOffset = textureData.offsetX * mainTexScale
                local yOffset = textureData.offsetY * mainTexScale

                local lx = mainTexX + xOffset
                local rx = mainTexX + width + xOffset
                local ty = mainTexY + yOffset
                local by = mainTexY + height + yOffset

                local tlX, tlY = lx, ty
                local trX, trY = rx, ty
                local brX, brY = rx, by
                local blX, blY = lx, by

                local centerX = (lx + rx) * 0.5
                local centerY = (ty + by) * 0.5
                if isRotated then -- Rotate the UVs
                    tlX = tlX - centerX
                    tlY = tlY - centerY
                    trX = trX - centerX
                    trY = trY - centerY
                    brX = brX - centerX
                    brY = brY - centerY
                    blX = blX - centerX
                    blY = blY - centerY

                    local tlX2 = tlX * cosTheta - tlY * sinTheta
                    local tlY2 = tlX * sinTheta + tlY * cosTheta
                    local trX2 = trX * cosTheta - trY * sinTheta
                    local trY2 = trX * sinTheta + trY * cosTheta
                    local brX2 = brX * cosTheta - brY * sinTheta
                    local brY2 = brX * sinTheta + brY * cosTheta
                    local blX2 = blX * cosTheta - blY * sinTheta
                    local blY2 = blX * sinTheta + blY * cosTheta

                    tlX = tlX2 + centerX
                    tlY = tlY2 + centerY
                    trX = trX2 + centerX
                    trY = trY2 + centerY
                    brX = brX2 + centerX
                    brY = brY2 + centerY
                    blX = blX2 + centerX
                    blY = blY2 + centerY
                end

                -- Set the texture to crunchy
                local texId = textureIdCache[texture] or getTextureId(texture)
                spriteRenderer:glBind(texId);
                spriteRenderer:glTexParameteri(3553, 10240, 9728);
                javaObject:DrawTexture(
                    texture,
                    tlX, tlY,
                    trX, trY,
                    brX, brY,
                    blX, blY,
                    r, g, b, alphaMult
                )

                centerX = centerX - absX
                centerY = centerY - absY
            --end

            if fluidContainer and fluidPercent > 0 then
                local fluidMask = item:getTextureFluidMask()
                if fluidMask then
                    local color = fluidColorCache[fluid] or getFluidColor(fluid)
                    local maskData = maskQueue[1]
                    maskData[1] = true
                    maskData[2] = fluidMask
                    maskData[3] = fluidPercent
                    maskData[4] = color.r
                    maskData[5] = color.g
                    maskData[6] = color.b
                    maskData[7] = color.a
                else
                    maskQueue[1][1] = false
                end
            else
                maskQueue[1][1] = false
            end

            if colorMask then
                local maskData = maskQueue[2]
                maskData[1] = true
                maskData[2] = colorMask
                maskData[3] = 1.0
                maskData[4] = item:getR()
                maskData[5] = item:getG()
                maskData[6] = item:getB()
                maskData[7] = 1.0
            else
                maskQueue[2][1] = false
            end

            for i=1, 2 do
                local maskData = maskQueue[i]
                if maskData[1] then
                    local texture = maskData[2]
                    local percentage = maskData[3]
                    local r = maskData[4]
                    local g = maskData[5]
                    local b = maskData[6]
                    local a = maskData[7] * alphaMult

                    if percentage < 0.15 then
                        percentage = 0.15
                    end

                    local textureData = textureDataCache[texture] or getTextureData(texture)
                    local texW = textureData.width
                    local texH = textureData.height
                    if (texW <= 0 or texH <= 0) then
                        return
                    end

                    local lX = textureData.xStart
                    local rX = textureData.xEnd
                    local tY = textureData.yStart
                    local bY = textureData.yEnd

                    local tlX, tlY = lX, tY
                    local trX, trY = rX, tY
                    local brX, brY = rX, bY
                    local blX, blY = lX, bY

                    local w, h = texW, texH
                    local offsetX = textureData.offsetX * mainTexScale
                    local offsetY = textureData.offsetY * mainTexScale
                    local maskX = x2 + offsetX
                    local maskY = y2 + offsetY

                    if isRotated then
                        -- Rotate the UVs
                        local tempX, tempY = tlX, tlY
                        tlX, tlY = blX, blY
                        blX, blY = brX, brY
                        brX, brY = trX, trY
                        trX, trY = tempX, tempY

                        -- Lower the mask by the percentage
                        local yX = tlX - blX
                        tlX = tlX - yX * (1.0 - percentage)
                        trX = trX - yX * (1.0 - percentage)

                        -- Rotate the render point
                        local rotX = maskX - centerX
                        local rotY = maskY - centerY
                        maskX = rotX * cosTheta - rotY * sinTheta + centerX
                        maskY = rotX * sinTheta + rotY * cosTheta + centerY
                        maskX = maskX - h * mainTexScale

                        -- Swap the width and height
                        local temp = w
                        w = h
                        h = temp

                        -- Account for the percentage of the texture
                        maskY = maskY + floor((1.0 - percentage) * h * mainTexScale)
                        h = ceil(h * percentage * mainTexScale)
                    else
                        -- Lower the mask by the percentage
                        local missing = 1.0 - percentage
                        local yD = tlY - blY
                        tlY = tlY - yD * missing
                        trY = trY - yD * missing

                        -- Account for the percentage of the texture
                        maskY = maskY + floor(missing * h * mainTexScale)
                        h = ceil(h * mainTexScale * percentage)
                    end

                    maskX = maskX + absX
                    maskY = maskY + absY

                    -- No crunchy texture fix here, I'm just gonna assume the people who are making texture masks are the type of people who pack their textures properly
                    spriteRenderer:render(texture, maskX, maskY, w * mainTexScale, h, r, g, b, a, tlX, tlY, trX, trY, brX, brY, blX, blY)
                end
            end

            -- FOREGROUND EFFECTS

            if item:isBroken() then
                drawingContext:drawTextureScaledUniform(BROKEN_TEXTURE, x2, y2, targetScale, alphaMult * 0.5, 1, 1, 1);
            end

            local doShadow = OPT.DO_STACK_SHADOWS
            local count = stack.count
            if count > 1 then
                local text = stringCache[count] or getString(count)
                if doShadow then
                    javaObject:DrawText(stackFont, text, x+3, y, 0, 0, 0, alphaMult)
                end
                javaObject:DrawText(stackFont, text, x+2, y-1, 1, 1, 1, alphaMult)
            end

            if itemData.isFood then
                if hungerPercent < 1.0 then
                    local barX = x + totalWidth - 3
                    local top = y + 1
                    local bottom = y + totalHeight
                    local missing = (bottom - top) * (1.0 - hungerPercent)

                    local a,r,g,b = triLerpColors(hungerPercent)
                    javaObject:DrawTextureScaledColor(nil, barX, top + missing, 2, bottom - top - missing,r,g,b,alphaMult*a)
                end

                ---@cast item Food
                if item:isFrozen() then
                    --ItemGridUI.setTextureAsCrunchy(COLD_TEX) -- Just make a texture per grid scale
                    javaObject:DrawTextureScaledUniform(COLD_TEX, x+totalWidth-8*SCALE, y+totalHeight-8*SCALE, SCALE, 0.8, 0.8, 1, alphaMult)
                end

            elseif drainPercent < 1.0 then
                local barX = x + totalWidth - 3
                local top = y + 1
                local bottom = y + totalHeight
                local missing = (bottom - top) * (1.0 - drainPercent)

                local a,r,g,b = triLerpColors(drainPercent)
                javaObject:DrawTextureScaledColor(nil, barX, top + missing, 2, bottom - top - missing,r,g,b,alphaMult*a)

            elseif fluidPercent > 0 then
                local color = fluidColorCache[fluid] or getFluidColor(fluid)

                local barX = x + totalWidth - 3
                local top = y + 1
                local bottom = y + totalHeight - 1
                local missing = (bottom - top) * (1.0 - fluidPercent)
                javaObject:DrawTextureScaledColor(nil, barX, top + missing, 2, bottom - top - missing, color.r, color.g, color.b, alphaMult)


            elseif stack.category == TetrisItemCategory.CONTAINER then
                if isItemSquished(item) then
                    local x2 = x + CELL_SIZE*w - w - 16
                    local y2 = y + 1
                    javaObject:DrawTextureColor(SQUISHED_TEXTURE, x2, y2, 1, 1, 1, alphaMult);
                end

            elseif itemData.hasAmmo then
                local ammo = item:getCurrentAmmoCount()
                local text = stringCache[ammo] or getString(ammo)
                local brX = x + CELL_SIZE*w - w - 2
                local brY = y + CELL_SIZE*h - h - ItemGridUI.lineHeight - 1
                if doShadow then
                    javaObject:DrawTextRight(stackFont, text, brX+1, brY+1, 0, 0, 0, alphaMult)
                end
                javaObject:DrawTextRight(stackFont, text, brX, brY, 1, 1, 1, alphaMult)

            elseif itemData.isLiterature and ItemGridUI._showLiteratureCheckmark(playerObj, item) then
                -- bottom right
                local x2 = x + CELL_SIZE*w - w - 16
                local y2 = y + CELL_SIZE*h - h - 16
                javaObject:DrawTextureColor(MEDIA_CHECKMARK_TEX, x2, y2, 1, 1, 1, 1);
            end

            if item:isFavorite() then
                local favTex = FAVOURITE_TEXTURE[SCALE]
                javaObject:DrawTextureColor(favTex, x + totalWidth - favTex:getWidth() - 1, y+1, 1, 1, 1, alphaMult)
            end
        end
    end

    postRenderGrid:trigger(drawingContext, renderInstructions, instructionCount, playerObj)
end

function ItemGridUI._renderHiddenStack(drawingContext, playerObj, stack, item, x, y, w, h, alphaMult)
    local CELL_SIZE = OPT.CELL_SIZE
    local TEXTURE_SIZE = OPT.TEXTURE_SIZE

    local minDimension = math.min(w, h)

    local width = w * CELL_SIZE - w - 1
    local height = h * CELL_SIZE - h - 1

    drawingContext:drawRect(x+1, y+1, width, height, 0.24 * alphaMult, 0.5, 0.5, 0.5)


    local x2, y2 = x + width / 2, y + height / 2
    local size = minDimension * TEXTURE_SIZE

    drawingContext:drawTextureCenteredAndSquare(HIDDEN_ITEM, x2, y2, size, alphaMult, 1,1,1);
    drawingContext:drawRectBorder(x, y, w * CELL_SIZE - w + 1, h * CELL_SIZE - h + 1, alphaMult, 0.55, 0.55, 0.55)
end
