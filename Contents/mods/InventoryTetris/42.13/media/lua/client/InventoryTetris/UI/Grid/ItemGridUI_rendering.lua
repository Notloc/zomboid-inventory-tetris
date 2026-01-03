-- Split rendering into a separate file because of how much code it is

local TetrisItemData = require("InventoryTetris/Data/TetrisItemData")
local TetrisContainerData = require("InventoryTetris/Data/TetrisContainerData")
local TetrisItemCategory = require("InventoryTetris/Data/TetrisItemCategory")
local TetrisEvents = require("InventoryTetris/Events")
local ItemStack = require("InventoryTetris/Model/ItemStack")
local ItemContainerGrid = require("InventoryTetris/Model/ItemContainerGrid")
local GridTransferQueueData = require("InventoryTetris/Model/GridTransferQueueData")
local DragAndDrop = require("InventoryTetris/System/DragAndDrop")
local ControllerDragAndDrop = require("InventoryTetris/System/ControllerDragAndDrop")

local ScalableGridTextures = require("InventoryTetris/UI/Grid/ScalableGridTextures")

local getItemSize = TetrisItemData.getItemSize

-- Premade textures for supported scales so that any scale gets pixel perfect grids
local GridBackgroundTexturesByScale = ScalableGridTextures.GridBackgroundTexturesByScale
local GridLineTexturesByScale = ScalableGridTextures.GridLineTexturesByScale
local ITEM_BG_TEXTURE = ScalableGridTextures.ITEM_BG_TEXTURE
local FAVOURITE_TEXTURE = ScalableGridTextures.FAVOURITE_TEXTURE
local POISON_TEXTURE = ScalableGridTextures.POISON_TEXTURE

local MEDIA_CHECKMARK_TEX = getTexture("media/ui/Tick_Mark-10.png")
local COLD_TEX = getTexture("media/textures/InventoryTetris/Cold.png")

local ENABLED_TAINTED = true

---@class(partial) ItemGridUI : ISPanel
---@field grid ItemGrid
---@field containerGrid ItemContainerGrid
---@field containerUi ItemGridContainerUI
---@field inventoryPane ISInventoryPane
---@field controllerNode ControllerNode
---@field playerNum integer
---@field playerObj IsoPlayer
local ItemGridUI = ISUIElement:derive("ItemGridUI")
ItemGridUI.__index = ItemGridUI

---@param grid ItemGrid
---@param containerGrid ItemContainerGrid
---@param inventoryPane ISInventoryPane
---@param playerNum integer
---@return ItemGridUI
function ItemGridUI:new(grid, containerUi, containerGrid, inventoryPane, playerNum)
    ---@type ItemGridUI
    local o = ISUIElement:new(0, 0, 0, 0)
    setmetatable(o, self)

    o.grid = grid
    o.containerUi = containerUi
    o.containerGrid = containerGrid
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum
    o.playerObj = getSpecificPlayer(playerNum)

    o:setWidth(o:calculateWidth())
    o:setHeight(o:calculateHeight())

    return o
end

-- When hover a stack over a stack that has an interaction handler, color the hovered stack with this color (or the interaction handler's color if it has one)
ItemGridUI.GENERIC_ACTION_COLOR = {0, 0.7, 1}

---@type ColorArray
local containerItemHoverColor = {1, 1, 0}
---@type ColorArray
local invalidItemHoverColor = {1, 0, 0}
---@type ColorArray
local stackableColor = {0.4, 0.6, 0.6}


local OPT = require("InventoryTetris/Settings")

local SEAMLESS_ITEM_BG_TEX = getTexture("media/textures/InventoryTetris/ItemBg.png")

local BROKEN_TEXTURE = getTexture("media/textures/InventoryTetris/Broken.png")
local HIDDEN_ITEM = getTexture("media/textures/InventoryTetris/Hidden.png")
local SQUISHED_TEXTURE = getTexture("media/textures/InventoryTetris/Squished.png")

---@param draggedStack ItemStack
---@param hoveredStack ItemStack
---@param dragInv ItemContainer
---@param hoverInv ItemContainer
---@param playerNum integer
---@return number, number, number
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

---@alias ColorProviderFunction fun(draggedStack: ItemStack, hoveredStack: ItemStack, dragInv: ItemContainer, hoverInv: ItemContainer, playerNum: integer): number, number, number

---@type table<TetrisItemCategory|string, table<TetrisItemCategory, ColorArray|ColorProviderFunction>>
local StackHoverColorsByCategories = {
    ["any"] = {
        [TetrisItemCategory.CONTAINER] = determineContainerHoverColor
    }
}

---@param dragCategory TetrisItemCategory
---@param hoverCategory TetrisItemCategory
---@param color number[]|ColorProviderFunction
function ItemGridUI.registerItemHoverColor(dragCategory, hoverCategory, color)
    if not StackHoverColorsByCategories[dragCategory] then
        StackHoverColorsByCategories[dragCategory] = {}
    end

    StackHoverColorsByCategories[dragCategory][hoverCategory] = color
end

---@param draggedStack ItemStack
---@param hoveredStack ItemStack
---@param dragInv ItemContainer
---@param hoverInv ItemContainer
---@return number, number, number
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
        return invalidItemHoverColor[1], invalidItemHoverColor[2], invalidItemHoverColor[3]
    end

    if type(colorProvider) == "function" then
        ---@cast colorProvider ColorProviderFunction
        return colorProvider(draggedStack, hoveredStack, dragInv, hoverInv, self.playerNum)
    else
        ---@cast colorProvider ColorArray
        return colorProvider[1], colorProvider[2], colorProvider[3]
    end
end

---@param scale number
function ItemGridUI:onApplyScale(scale)
    self:setWidth(self:calculateWidth())
    self:setHeight(self:calculateHeight())
end

---@return integer
function ItemGridUI:calculateWidth()
    return self.grid.width * OPT.CELL_SIZE - self.grid.width + 1
end

---@return integer
function ItemGridUI:calculateHeight()
    return self.grid.height * OPT.CELL_SIZE - self.grid.height + 1
end

---@param mouseX number
---@param mouseY number
---@return ItemStack?
function ItemGridUI:findGridStackUnderMouse(mouseX, mouseY)
    local effectiveCellSize = OPT.CELL_SIZE - 1
    local gridX = math.floor(mouseX / effectiveCellSize)
    local gridY = math.floor(mouseY / effectiveCellSize)
    return self.grid:getStack(gridX, gridY, self.playerNum)
end

function ItemGridUI:render()
    ItemGridUI.lineHeight = getTextManager():getFontHeight(UIFont.Small)
    self.itemTransferData = GridTransferQueueData.build(self.playerNum)

    self:renderBackGrid()

    if self.grid:isUnsearched(self.playerNum) then
        local searchSession = self.grid:getSearchSession(self.playerNum)
        if searchSession and searchSession.isGridRevealed then
            self:renderGridItems(searchSession)
        else
            self:renderUnsearched()
        end
    else
        self:renderGridItems()
    end

    self:renderIncomingTransfers()
    self:renderDragItemPreview()
    self:renderMultiDrag()
end

function ItemGridUI:renderUnsearched()
    self:drawRect(1, 1, self:getWidth()-2, self:getHeight()-2, 0.8, 0.2, 0.2, 0.2)
    self:drawTextCentre("?", self:getWidth()/2, self:getHeight()/2 - ItemGridUI.lineHeight, 1, 1, 1, 1, UIFont.Large)
end

function ItemGridUI:renderBackGrid()
    local width = self.grid.width
    local height = self.grid.height

    local totalWidth = OPT.CELL_SIZE * width - width + 1
    local totalHeight = OPT.CELL_SIZE * height - height + 1

    local bgTex = GridBackgroundTexturesByScale[OPT.SCALE] or GridBackgroundTexturesByScale[1]
    local background = 0.62
    self.javaObject:DrawTextureTiled(bgTex, 1, 1, totalWidth-1, totalHeight-1, background, background, background, 0.75)

    local lineTex = GridLineTexturesByScale[OPT.SCALE] or GridLineTexturesByScale[1]
    local gridLines = 0.5
    self.javaObject:DrawTextureTiled(lineTex, 0, 0, totalWidth, totalHeight, gridLines, gridLines, gridLines, 1)
end

---@return Texture
function ItemGridUI.getGridBackgroundTexture()
    return GridBackgroundTexturesByScale[OPT.SCALE] or GridBackgroundTexturesByScale[1]
end

function ItemGridUI:renderIncomingTransfers()
    local incomingActions = self.itemTransferData:getIncomingActions(self.grid.inventory, self.grid.gridKey)
    local playerObj = self.playerObj

    for item, action in pairs(incomingActions) do
        local stack = ItemStack.createTempStack(action.item)
        if action.gridX and action.gridY then
            local x = action.gridX * OPT.CELL_SIZE - action.gridX
            local y = action.gridY * OPT.CELL_SIZE - action.gridY
            local w, h = getItemSize(item, action.isRotated)
            ItemGridUI._renderSingleGridStack(self, playerObj, stack, item, x, y, w, h, 0.5, action.isRotated)
        end
    end
end

---@param searchSession ItemGridSearchSession?
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

function ItemGridUI:renderMultiDrag()
    if not self.isMultiDragging then return end

    local startX = self.multiDragStartMouseX
    local startY = self.multiDragStartMouseY
    local endX = self:getMouseX()
    local endY = self:getMouseY()

    local x1 = math.min(startX, endX)
    local y1 = math.min(startY, endY)
    local x2 = math.max(startX, endX)
    local y2 = math.max(startY, endY)

    self:drawRectBorder(x1, y1, x2-x1, y2-y1, 0.5, 0.2, 1, 1)
end

---@type TetrisRenderInstruction[]
local instructionBuffer = table.newarray()

---@param inventory ItemContainer
---@param stacks ItemStack[]
---@param alphaMult number
---@param searchSession ItemGridSearchSession?
function ItemGridUI:renderStackLoop(inventory, stacks, alphaMult, searchSession)
    local CELL_SIZE = OPT.CELL_SIZE
    local isJoypad = JoypadState.players[self.playerNum+1]
    local draggedItem = isJoypad and ControllerDragAndDrop.getDraggedItem(self.playerNum) or DragAndDrop.getDraggedItem()
    local playerObj = self.playerObj

    local outgoingQueueData = self.itemTransferData:getOutgoingActions(inventory)

    local yCorrection = 0.0
    local yCullBottom = 0.0
    local yCullTop = 9999.9

    local isNotPopup = not self.containerUi.isPopup
    if isNotPopup then
        local invPane = self.inventoryPane
        local yScroll = invPane:getYScroll()
        yCorrection = self:getAbsoluteY() - invPane:getAbsoluteY() - yScroll
        yCullBottom = -yScroll - yCorrection
        yCullTop = yCullBottom + invPane.height
    end

    local bgTex = ITEM_BG_TEXTURE[OPT.SCALE] or SEAMLESS_ITEM_BG_TEX

    local itemData = TetrisItemData._itemData
    local devItemData = TetrisItemData._devItemData

    local selectedStacks = self._selectedStacks or {}
    local pendingSelection = self.activeMultiDragStacks or {}

    local instructionCount = 0
    for i=1, #stacks do
        local stack = stacks[i]
        local item = stack._frontItem or ItemStack.getFrontItem(stack, inventory)
        local itemId = stack._frontItemId

        if item then
            local x, y = stack.x, stack.y
            if x and y then
                local itemType = stack.itemType
                local category = stack.category

                local isSquished = false
                if category == TetrisItemCategory.CONTAINER then
                    ---@cast item InventoryContainer
                    local container = item:getItemContainer()
                    local isSquishable = not TetrisContainerData.getContainerDefinition(container).isRigid
                    isSquished = isSquishable and container:isEmpty()
                end
                ---@cast item InventoryItem

                local fType = not isSquished and itemType or TetrisItemData._squishedIdCache[itemType] or TetrisItemData._getSquishedId(itemType)

                local data = devItemData[fType] or itemData[fType] or TetrisItemData._getItemDataByFullType(item, fType, isSquished)

                local w, h = data.width, data.height
                if stack.isRotated then
                    w, h = h, w
                end

                local uiX = x * CELL_SIZE - x
                local uiY = y * CELL_SIZE - y

                local shouldCull = isNotPopup and (uiY + h * CELL_SIZE - h < yCullBottom or uiY > yCullTop)
                if not shouldCull then
                    -- Only update the first item in the stack, ISInventoryTransferAction handles the rest JIT style
                    item:updateAge()
                    if category == TetrisItemCategory.CLOTHING then
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
                    instruction[11] = isSquished
                    instruction[12] = selectedStacks[stack] or pendingSelection[stack]

                    ---@cast instruction TetrisRenderInstruction
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
    local sameOwner = DragAndDrop.isDragOwner(self)

    local item = isJoyPad and ControllerDragAndDrop.getDraggedItem(self.playerNum) or DragAndDrop.getDraggedItem()
    if not item or noMouse or noController then
        return
    end

    local hoveredStack = isJoyPad and self.grid:getStack(self.selectedX, self.selectedY, self.playerNum) or self:findGridStackUnderMouse(self:getMouseX(), self:getMouseY())
    local hoveredItem = hoveredStack and ItemStack.getFrontItem(hoveredStack, self.grid.inventory) or nil

    local draggedStacks = DragAndDrop.getDraggedStacks()
    if draggedStacks and #draggedStacks > 1 then
        if hoveredStack and hoveredItem and hoveredItem:IsInventoryContainer() then
            local x = hoveredStack.x * OPT.CELL_SIZE - hoveredStack.x
            local y = hoveredStack.y * OPT.CELL_SIZE - hoveredStack.y
            local w, h = getItemSize(hoveredItem, hoveredStack.isRotated)
            self:drawRect(x, y, w * OPT.CELL_SIZE - w, h * OPT.CELL_SIZE - h, 0.5, 0.2, 1, 1)
            return
        end

        if not sameOwner then
            self:drawRect(0, 0, self:getWidth(), self:getHeight(), 0.5, 0.2, 1, 1)
        end
        return
    end

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
        self:_renderPlacementPreview(hoveredStack.x, hoveredStack.y, w, h, stackableColor[1], stackableColor[2], stackableColor[3])
        self:_renderControllerDrag(0.8)
        return
    end

    local otherContainerGrid = ItemContainerGrid.GetOrCreate(item:getContainer(), self.playerNum)
    local draggedStack = otherContainerGrid:findGridStackByVanillaStack(DragAndDrop.getDraggedStack()) or ItemStack.createTempStack(item)

    -- Container hover
    self:_renderPlacementPreview(hoveredStack.x, hoveredStack.y, w, h, self:getColorForStackHover(draggedStack, hoveredStack, otherContainerGrid.inventory, self.grid.inventory))
    self:_renderControllerDrag(0.8)
end

---@param opacity number
function ItemGridUI:_renderControllerDrag(opacity)
    if ControllerDragAndDrop.isDragging(self.playerNum) then
        local item = ControllerDragAndDrop.getDraggedItem(self.playerNum)
        local stack = ControllerDragAndDrop.getDraggedTetrisStack(self.playerNum)
        local isRotated = ControllerDragAndDrop.isDraggedItemRotated(self.playerNum)
        local x = self.selectedX * OPT.CELL_SIZE - self.selectedX
        local y = self.selectedY * OPT.CELL_SIZE - self.selectedY
        local w, h = getItemSize(item, isRotated)
        self:_renderSingleGridStack(self.playerObj, stack, item, x, y, w, h, opacity, isRotated)
    end
end

---@param gridX integer
---@param gridY integer
---@param itemW integer
---@param itemH integer
---@param r number
---@param g number
---@param b number
function ItemGridUI:_renderPlacementPreview(gridX, gridY, itemW, itemH, r, g, b)
    self:drawRect(gridX * OPT.CELL_SIZE - gridX + 1, gridY * OPT.CELL_SIZE - gridY + 1, itemW * OPT.CELL_SIZE - itemW - 1, itemH * OPT.CELL_SIZE - itemH - 1, 0.55, r, g, b)
end

---@param item InventoryItem
function ItemGridUI.getItemColor(item)
    if not item or item:getTextureColorMask() then
        return 1,1,1
    end

    local r = item:getR()
    local g = item:getG()
    local b = item:getB()

    return r,g,b
end

ItemGridUI.doLiteratureCheckmark = true

---@param player IsoPlayer
---@param item Literature
---@return boolean
function ItemGridUI._showLiteratureCheckmark(player, item)
    return
        ItemGridUI.doLiteratureCheckmark and
        (
            (player:isLiteratureRead(item:getModData().literatureTitle)) or
            (SkillBook[item:getSkillTrained()] ~= nil and item:getMaxLevelTrained() < player:getPerkLevel(SkillBook[item:getSkillTrained()].perk) + 1) or
            (item:getNumberOfPages() > 0 and player:getAlreadyReadPages(item:getFullType()) == item:getNumberOfPages()) or
            (item:getLearnedRecipes() ~= nil and player:getKnownRecipes():containsAll(item:getLearnedRecipes())) or
            (item:getModData().teachedRecipe ~= nil and player:getKnownRecipes():contains(item:getModData().teachedRecipe))
        )
end

-- A bit finnicky, the changes are not permanent and reset shortly after.
-- Seems to work fine during grid rendering in its current state.
local spriteRenderer = SpriteRenderer.instance

---@param texture Texture
function ItemGridUI.setTextureAsCrunchy(texture)
    local TEXTURE_2D = 3553

    -- Fixes blurry textures from other mods
    local MAG_FILTER = 10240
    --local MIN_FILTER = 10241
    local NEAREST = 9728
    spriteRenderer:glBind(texture:getID());
    spriteRenderer:glTexParameteri(TEXTURE_2D, MAG_FILTER, NEAREST);


    -- TODO: Benchmark performance impact of these fixes

    -- Fixes pixel bleeding on the edge of textures from other mods
    --local TEXTURE_WRAP_S = 10242
    --local TEXTURE_WRAP_T = 10243
    --local CLAMP_TO_EDGE = 33071
    --SpriteRenderer.instance:glTexParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE);
    --SpriteRenderer.instance:glTexParameteri(TEXTURE_2D, TEXTURE_WRAP_T, CLAMP_TO_EDGE);
end

-- Possible colors are limited to 101 total (0-100 int)
local triLerpColorCache = {}

-- TODO: Make these customizable
local goodColor = {r=0, g=1,b=1}
local midColor = {r=1,g=1,b=0}
local badColor = {r=1,g=0,b=0}

---@class ColorArray
---@field [1] number r
---@field [2] number g
---@field [3] number b

---@param value number
---@return ColorArray
local function triLerpColors(value)
    if value < 0 then value = 0; end
    if value > 100 then value = 100; end

    local key = value
    local value = value / 100.0
    local col
    if value <= 0.5 then
        value = value * 2
        col = table.newarray()
        col[1] = badColor.r + (midColor.r - badColor.r) * value
        col[2] = badColor.g + (midColor.g - badColor.g) * value
        col[3] = badColor.b + (midColor.b - badColor.b) * value
    else
        value = (value - 0.5) * 2
        col = table.newarray()
        col[1] = midColor.r + (goodColor.r - midColor.r) * value
        col[2] = midColor.g + (goodColor.g - midColor.g) * value
        col[3] = midColor.b + (goodColor.b - midColor.b) * value
    end

    triLerpColorCache[key] = col
    return col
end

-- Precache the sin and cos of 90 degree rotations
local sinTheta = math.sin(math.rad(90))
local cosTheta = math.cos(math.rad(90))

local floor = math.floor
local ceil = math.ceil

local neutralColor = 0.65

-- TODO: Make these customizable.
-- Color code the items by category
---@type table<TetrisItemCategory, ColorArray>
local colorsByCategory = {
    [TetrisItemCategory.MELEE] = {0.825, 0.1, 0.6},
    [TetrisItemCategory.RANGED] = {0.65, 0.05, 0.05},
    [TetrisItemCategory.AMMO] = {1, 1, 0.1},
    [TetrisItemCategory.MAGAZINE] = {0.85, 0.5, 0.05},
    [TetrisItemCategory.ATTACHMENT] = {0.9, 0.5, 0.3},
    [TetrisItemCategory.FOOD] = {0.05, 0.65, 0.15},
    [TetrisItemCategory.CLOTHING] = {neutralColor, neutralColor, neutralColor},
    [TetrisItemCategory.CONTAINER] = {0.65, 0.6, 0.4},
    [TetrisItemCategory.HEALING] = {0.1, 0.95, 1},
    [TetrisItemCategory.BOOK] = {0.3, 0, 0.5},
    [TetrisItemCategory.ENTERTAINMENT] = {0.3, 0, 0.5},
    [TetrisItemCategory.KEY] = {0.5, 0.5, 0.5},
    [TetrisItemCategory.MISC] = {neutralColor, neutralColor, neutralColor},
    [TetrisItemCategory.SEED] = {neutralColor, neutralColor, neutralColor},
    [TetrisItemCategory.MOVEABLE] = {0.7, 0.7, 0.7},
    [TetrisItemCategory.CORPSEANIMAL] = {0.7, 0.7, 0.7}
}

local stackFont = UIFont.Small
local postRenderGrid = TetrisEvents.OnPostRenderGrid

---@class MaskRenderData
---@field [1] boolean isActive - Whether this mask slot should be rendered
---@field [2] Texture texture - The mask texture to render
---@field [3] number percentage - Fill percentage (0-1), e.g. fluid level or full for color masks
---@field [4] number r - Red color component
---@field [5] number g - Green color component
---@field [6] number b - Blue color component
---@field [7] number a - Alpha color component

-- Slot 1: Fluid mask (for bottles/containers showing liquid fill levels)
-- Slot 2: Color mask (for items with colored overlays, e.g. dyed clothing)
-- Each slot is populated during item rendering then rendered in a loop.
---@type MaskRenderData[]
local maskQueue = table.newarray()
maskQueue[1] = table.newarray() -- Fluid mask slot
maskQueue[2] = table.newarray() -- Color mask slot

---@type table<string, ItemTypeRenderData>
local itemTypeDataCache = {}

---@class ItemTypeRenderData
---@field isFood boolean
---@field isFluidContainer boolean
---@field fluidCapacity number
---@field isDrainable boolean
---@field maxUses integer
---@field hasAmmo boolean
---@field isLiterature boolean
---@field isUninteresting boolean

---@param item InventoryItem
---@param itemType string
---@return ItemTypeRenderData
local function getItemTypeData(item, itemType)
    local isFood = item:isFood()
    local isFluidContainer = item:getFluidContainer() ~= nil
    local fluidCapacity = isFluidContainer and item:getFluidContainer():getCapacity() or -1
    local isDrainable = item:IsDrainable()
    local maxUses = isDrainable and item:getMaxUses() or -1
    local hasAmmo = item:getMaxAmmo() > 0
    local isLiterature = instanceof(item, "Literature")
    local isUninteresting = isLiterature and item:hasTag(ItemTag.UNINTERESTING) or false

    local data = {
        isFood = isFood,
        isFluidContainer = isFluidContainer,
        fluidCapacity = fluidCapacity,
        isDrainable = isDrainable,
        maxUses = maxUses,
        hasAmmo = hasAmmo,
        isLiterature = isLiterature,
        isUninteresting = isUninteresting
    }
    itemTypeDataCache[itemType] = data
    return data
end

---@type table<InventoryItem, ItemInstanceData>
local itemInstanceDataCache = {}

Events.EveryHours.Add(function()
    itemInstanceDataCache = {} -- Avoid memory bloat and stale data
end)

---@class ItemInstanceData
---@field r number
---@field g number
---@field b number
---@field colorMask Texture|nil
---@field fluidMask Texture|nil
---@field showPoison boolean

---@param item InventoryItem
---@param itemTypeData ItemTypeRenderData
---@return ItemInstanceData
local function getItemInstanceData(item, itemTypeData)
    local r,g,b = 1.0,1.0,1.0
    local colorMask = item:getTextureColorMask()
    if not colorMask then
        r = item:getR()
        g = item:getG()
        b = item:getB()
    end

    local fluidMask = item:getTextureFluidMask()
    local showPoison = item:hasTag(ItemTag.SHOW_POISON)

    local data = {
        r = r,
        g = g,
        b = b,
        colorMask = colorMask,
        fluidMask = fluidMask,
        showPoison = showPoison
    }
    itemInstanceDataCache[item] = data
    return data
end

---@type table<Texture, integer>
local textureIdCache = {}

---@param texture Texture
local function getTextureId(texture)
    local id = texture:getID()
    textureIdCache[texture] = id
    return id
end

---@class TextureData
---@field widthOrig integer
---@field heightOrig integer
---@field width integer
---@field height integer
---@field offsetX number
---@field offsetY number
---@field xStart number
---@field yStart number
---@field xEnd number
---@field yEnd number

---@type table<Texture, TextureData>
local textureDataCache = {}

---@param texture Texture
---@return TextureData
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

---@class FluidColorData
---@field r number
---@field g number
---@field b number
---@field a number

---@type table<Fluid, FluidColorData>
local fluidColorCache = {}

---@param fluid Fluid|nil
---@return FluidColorData
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

---@type table<number, string>
local numericStringCache = {}

---@param number number
---@return string
local function getNumericString(number)
    local str = tostring(number)
    numericStringCache[number] = str
    return str
end

---@param drawingContext ISUIElement
---@param playerObj IsoPlayer
---@param stack ItemStack
---@param item InventoryItem
---@param x number
---@param y number
---@param w integer
---@param h integer
---@param alphaMult number
---@param isRotated boolean
---@param itemBgTex Texture|nil
---@param doBorder boolean|nil
function ItemGridUI._renderSingleGridStack(drawingContext, playerObj, stack, item, x, y, w, h, alphaMult, isRotated, itemBgTex, doBorder)
    ---@type TetrisRenderInstruction[]
    local renderInstructions = table.newarray()
    renderInstructions[1] = {stack, item, x, y, w, h, alphaMult, isRotated, false, doBorder or false, false, false}
    ItemGridUI._bulkRenderGridStacks(drawingContext, renderInstructions, 1, playerObj, itemBgTex)
end

-- HEY MODDER!
-- Want to add something to the item rendering? Use the OnPostRenderGrid event!
-- See /client/InventoryTetris/Events.lua for more info.

---@param drawingContext ISUIElement
---@param renderInstructions TetrisRenderInstruction[]
---@param instructionCount number
---@param playerObj IsoPlayer
---@param itemBgTex Texture|nil
function ItemGridUI._bulkRenderGridStacks(drawingContext, renderInstructions, instructionCount, playerObj, itemBgTex)
    local SCALE = OPT.SCALE
    local CELL_SIZE = OPT.CELL_SIZE
    local TEXTURE_SIZE = OPT.TEXTURE_SIZE
    local TEXTURE_PAD = OPT.TEXTURE_PAD

    local javaObject = drawingContext.javaObject
    local absX = javaObject:getAbsoluteX()
    local absY = javaObject:getAbsoluteY()

    itemBgTex = itemBgTex or SEAMLESS_ITEM_BG_TEX

    local Bleach = Fluid.Bleach
    local TaintedWater = Fluid.TaintedWater

    local enableTainted = ENABLED_TAINTED

    ---@diagnostic disable-next-line: assign-type-mismatch
    ---@type Texture
    local favTex = FAVOURITE_TEXTURE[SCALE]
    local favTexW = favTex:getWidth()

    ---@diagnostic disable-next-line: assign-type-mismatch
    ---@type Texture
    local poisonTex = POISON_TEXTURE[SCALE]
    local poisonTexH = poisonTex:getHeight()

    local doShadow = OPT.DO_STACK_SHADOWS
    local shadowOffset = math.floor(OPT.SCALE + 0.5)

    ---@diagnostic disable-next-line: assign-type-mismatch
    ---@type Texture
    local NO_TEX = nil

    for r=1,instructionCount do
        ---@diagnostic disable-next-line: assign-type-mismatch
        ---@type TetrisRenderInstruction
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
        local isSquished = instruction[11]
        local isSelected = instruction[12]

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
            local itemTypeData = itemTypeDataCache[itemType] or getItemTypeData(item, itemType)
            local itemInstanceData = itemInstanceDataCache[item] or getItemInstanceData(item, itemTypeData)

            local fluidContainer = itemTypeData.isFluidContainer and item:getFluidContainer()
            local fluid = fluidContainer and fluidContainer:getPrimaryFluid() or nil
            local fluidPercent = fluidContainer and (fluidContainer:getAmount() / itemTypeData.fluidCapacity) or 0

            ---@cast item Food
            local hungerPercent = itemTypeData.isFood and (item:getHungerChange() / item:getBaseHunger()) or 1
            ---@cast item InventoryItem
            
            ---@cast item DrainableComboItem
            local drainPercent = itemTypeData.isDrainable and (item:getCurrentUses() / itemTypeData.maxUses) or 1
            ---@cast item InventoryItem

            local doVerticalBar = fluidPercent > 0 or hungerPercent < 1.0 or drainPercent < 1.0

            -- BACKGROUND EFFECTS
            if itemTypeData.isFood then
                ---@cast item Food
                local heat = item:getHeat() -- 1 = room, 0.2 = frozen, 3 = max
                if heat < 1.0 then
                    local coldPercent =  -(heat - 1.0) / 0.8
                    javaObject:DrawTextureScaledColor(NO_TEX, x, y, totalWidth, totalHeight, 0.1, 0.5, 1, alphaMult * coldPercent)
                elseif heat > 1.0 then
                    local hotPercent = (heat - 1.0) / 1.5
                    if hotPercent > 1 then hotPercent = 1 end
                    javaObject:DrawTextureScaledColor(NO_TEX, x, y, totalWidth, totalHeight, 1, 0.0, 0.0, alphaMult * hotPercent)
                end
                ---@cast item InventoryItem
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
            if isSelected then
                javaObject:DrawTextureTiled(itemBgTex, x+1, y+1, cellW - 1 - barOffset, cellH - 1, cols[1]*1.5, cols[2]*1.5, cols[3]*1.5, alphaMult)
            else
                javaObject:DrawTextureTiled(itemBgTex, x+1, y+1, cellW - 1 - barOffset, cellH - 1, cols[1], cols[2], cols[3], 0.725 * alphaMult)
            end
            if doBorder or isSelected then
                --drawingContext:drawRectBorder(x, y+1, cellW, cellH, 1, 1, 1, 1)
                local w, h = cellW+1, cellH+1
                local t = isSelected and 2 or 1
                local a = isSelected and 1 or 0.5

                javaObject:DrawTextureScaled(NO_TEX, x,     y, t, h, a);
                javaObject:DrawTextureScaled(NO_TEX, x+1,   y, w-2, t, a);
                javaObject:DrawTextureScaled(NO_TEX, x+w-t, y, t, h, a);
                javaObject:DrawTextureScaled(NO_TEX, x+t,   y+h-t, w-t-1, t, a);
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
            local colorMask = itemInstanceData.colorMask

            local r = itemInstanceData.r
            local g = itemInstanceData.g
            local b = itemInstanceData.b

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

            -- Populate mask slot 1: Fluid mask for containers with liquid
            local fluidMask = itemInstanceData.fluidMask
            if fluid and fluidPercent > 0 and fluidMask then                
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

            -- Populate mask slot 2: Color mask for tinted items (e.g. dyed clothing)
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

            -- Render all active mask slots (fluid mask and/or color mask)
            for i=1, #maskQueue do
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

                    -- No crunchy texture fix here, I'm just gonna assume the modders who are making texture masks are the type of modders who pack their textures properly
                    spriteRenderer:render(texture, maskX, maskY, w * mainTexScale, h, r, g, b, a, tlX, tlY, trX, trY, brX, brY, blX, blY)
                end
            end

            -- FOREGROUND EFFECTS

            if item:isBroken() then
                drawingContext:drawTextureScaledUniform(BROKEN_TEXTURE, x2, y2, targetScale, alphaMult * 0.5, 1, 1, 1);
            end

            local count = stack.count
            if count > 1 then
                local text = numericStringCache[count] or getNumericString(count)
                if doShadow then
                    javaObject:DrawText(stackFont, text, x+2+shadowOffset, y-1+shadowOffset, 0, 0, 0, alphaMult)
                end
                javaObject:DrawText(stackFont, text, x+2, y-1, 1, 1, 1, alphaMult)
            end

            if itemTypeData.isFood then
                if hungerPercent < 1.0 then
                    local barX = x + totalWidth - 3
                    local top = y + 1
                    local bottom = y + totalHeight
                    local missing = (bottom - top) * (1.0 - hungerPercent)

                    local colorVal = floor((hungerPercent * 100) + 0.5)
                    if colorVal > 100 then colorVal = 100 end

                    local col = triLerpColorCache[colorVal] or triLerpColors(colorVal)
                    javaObject:DrawTextureScaledColor(NO_TEX, barX, top + missing, 2, bottom - top - missing, col[1], col[2], col[3], alphaMult)
                end

                ---@cast item Food
                if item:isFrozen() then
                    --ItemGridUI.setTextureAsCrunchy(COLD_TEX) -- Just make a texture per grid scale
                    javaObject:DrawTextureScaledUniform(COLD_TEX, x+totalWidth-8*SCALE, y+totalHeight-8*SCALE, SCALE, 0.8, 0.8, 1, alphaMult)
                end

                if itemInstanceData.showPoison or playerObj:isKnownPoison(item) or (enableTainted and item:isTainted()) then
                    javaObject:DrawTextureColor(poisonTex, x+1, y+totalHeight - poisonTexH-1, 0.55, 1, 0.3, 1);
                end
                ---@cast item InventoryItem

            elseif drainPercent < 1.0 then
                local barX = x + totalWidth - 3
                local top = y + 1
                local bottom = y + totalHeight
                local missing = (bottom - top) * (1.0 - drainPercent)

                local colorVal = floor((drainPercent * 100) + 0.5)
                if colorVal > 100 then colorVal = 100 end

                local col = triLerpColorCache[colorVal] or triLerpColors(colorVal)
                javaObject:DrawTextureScaledColor(NO_TEX, barX, top + missing, 2, bottom - top - missing, col[1], col[2], col[3], alphaMult)

            elseif fluid and fluidPercent > 0 then
                local color = fluidColorCache[fluid] or getFluidColor(fluid)

                local barX = x + totalWidth - 3
                local top = y + 1
                local bottom = y + totalHeight - 1
                local missing = (bottom - top) * (1.0 - fluidPercent)
                javaObject:DrawTextureScaledColor(NO_TEX, barX, top + missing, 2, bottom - top - missing, color.r, color.g, color.b, alphaMult)

                ---@diagnostic disable-next-line: need-check-nil
                if fluid == Bleach or (enableTainted and fluid == TaintedWater and fluidContainer:getPoisonRatio() > 0.1) then
                    javaObject:DrawTextureColor(poisonTex, x+1, y+totalHeight - poisonTexH-1, 0.55, 1, 0.3, 1);
                end

            elseif stack.category == TetrisItemCategory.CONTAINER then
                if isSquished then
                    local x2 = x + CELL_SIZE*w - w - 16
                    local y2 = y + 1
                    javaObject:DrawTextureColor(SQUISHED_TEXTURE, x2, y2, 1, 1, 1, alphaMult);
                end

            elseif itemTypeData.hasAmmo then
                local ammo = item:getCurrentAmmoCount()
                local text = numericStringCache[ammo] or getNumericString(ammo)
                local brX = x + CELL_SIZE*w - w - 2
                local brY = y + CELL_SIZE*h - h - ItemGridUI.lineHeight - 1
                if doShadow then
                    javaObject:DrawTextRight(stackFont, text, brX+shadowOffset, brY+shadowOffset, 0, 0, 0, alphaMult)
                end
                javaObject:DrawTextRight(stackFont, text, brX, brY, 1, 1, 1, alphaMult)

            elseif itemTypeData.isLiterature and not itemTypeData.isUninteresting and ItemGridUI._showLiteratureCheckmark(playerObj, item) then
                -- bottom right
                local x2 = x + CELL_SIZE*w - w - 16
                local y2 = y + CELL_SIZE*h - h - 16
                javaObject:DrawTextureColor(MEDIA_CHECKMARK_TEX, x2, y2, 1, 1, 1, 1);
            end

            if item:isFavorite() then
                javaObject:DrawTextureColor(favTex, x + totalWidth - favTexW, y, 1, 1, 1, alphaMult)
            end
        end
    end

    postRenderGrid:trigger(drawingContext, renderInstructions, instructionCount, playerObj)
end

---@param drawingContext ISUIElement
---@param playerObj IsoPlayer
---@param stack ItemStack
---@param item InventoryItem
---@param x number
---@param y number
---@param w integer
---@param h integer
---@param alphaMult number
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

Events.OnGameStart.Add(function()
    ---@diagnostic disable-next-line: undefined-field
    ENABLED_TAINTED = getSandboxOptions():getOptionByName("EnableTaintedWaterText"):getValue()
end)

return ItemGridUI
