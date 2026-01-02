require("ISUI/ISUIElement")
local OPT = require("InventoryTetris/Settings")
local ItemStack = require("InventoryTetris/Model/ItemStack")
local ControllerDragAndDrop = require("InventoryTetris/System/ControllerDragAndDrop")
local ControllerNode = require("InventoryTetris/UI/ControllerNode")
local ItemGridUI = require("InventoryTetris/UI/Grid/ItemGridUI")

local OVERFLOW_MARGIN = 3
local OVERFLOW_RENDERER_SPACING = 8

---@class GridOverflowRenderer : ISUIElement
---@field public containerGridUi ItemGridContainerUI
---@field public containerGrid ItemContainerGrid
---@field public gridUi ItemGridUI
---@field public inventory ItemContainer
---@field public inventoryPane ISInventoryPane
---@field public playerNum integer
---@field public controllerNode ControllerNode
local GridOverflowRenderer = ISUIElement:derive("GridOverflowRenderer")

---@param x number
---@param y number
---@param containerGridUi ItemGridContainerUI
---@param gridUi ItemGridUI
---@param inventory ItemContainer
---@param inventoryPane ISInventoryPane
---@param playerNum integer
function GridOverflowRenderer:new(x,y, containerGridUi, gridUi, inventory, inventoryPane, playerNum)
    ---@type GridOverflowRenderer
    local o = ISUIElement:new(x, y, 0, 0)
    setmetatable(o, self)
    self.__index = self
    o.containerGridUi = containerGridUi
    o.containerGrid = containerGridUi.containerGrid
    o.gridUi = gridUi
    o.inventory = inventory
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum
    o.controllerSelection = 1
    return o
end

function GridOverflowRenderer:initialise()
    ISUIElement.initialise(self)
    ControllerNode
        :injectControllerNode(self)
        :setJoypadDirHandler(self.controllerNodeOnJoypadDir)
        :setJoypadDownHandler(self.controllerNodeOnJoypadDown)
end

---@return number[]
function GridOverflowRenderer:getYPositionsForOverflow()    
    local height = self.containerGridUi.multiGridRenderer:getHeight()
    if self.lastHeight == height then
        return self.lastYPositions
    end

    local y = 0.0
    local yPositions = {}
    while height > (OPT.CELL_SIZE + OVERFLOW_MARGIN * 0.8) do
        table.insert(yPositions, y)
        y = y + OPT.CELL_SIZE + OVERFLOW_MARGIN
        height = height - OPT.CELL_SIZE - OVERFLOW_MARGIN
    end

    self.lastHeight = self:getHeight()
    self.lastYPositions = yPositions

    return yPositions
end

function GridOverflowRenderer:calculateOverflowColumnWidth(stackCount)
    local yPositions = self:getYPositionsForOverflow()
    local columns = math.ceil(stackCount / #yPositions)
    return columns * OPT.CELL_SIZE + OVERFLOW_MARGIN * columns - OVERFLOW_MARGIN + 4 
end

function GridOverflowRenderer:isEmpty()
    return #self.containerGrid.overflow == 0
end

function GridOverflowRenderer:render()
    local inventory = self.containerGridUi.inventory
    local overflow = self.containerGrid.overflow
    
    local gridRenderer = self.containerGridUi.multiGridRenderer
    self:setX(gridRenderer:getX() + gridRenderer:getWidth() + OVERFLOW_RENDERER_SPACING)
    self:setY(gridRenderer:getY())
    self:setWidth(self:calculateOverflowColumnWidth(#overflow))
    self:setHeight(gridRenderer:getHeight())
    
    if #overflow == 0 then return end
    if self.controllerSelection > #overflow then self.controllerSelection = #overflow end

    local playerObj = getSpecificPlayer(self.containerGridUi.playerNum)
    local yPositions = self:getYPositionsForOverflow()
    local xPos = 0
    local yi = 1

    local renderInstructions = table.newarray()

    local controllerSelectionFound = false
    local controllerX = 0.0
    local controllerY = 0.0

    local i = 1
    for _, stack in ipairs(overflow) do
        local item = ItemStack.getFrontItem(stack, inventory)
        if item then
            local yPos = yPositions[yi]

            local instruction = table.newarray()
            instruction[1] = stack
            instruction[2] = item
            instruction[3] = xPos
            instruction[4] = yPos
            instruction[5] = 1
            instruction[6] = 1
            instruction[7] = 1
            instruction[8] = false
            instruction[9] = false
            instruction[10] = true
            table.insert(renderInstructions, instruction)

            if self.controllerNode.isFocused and self.controllerSelection == i then
                controllerSelectionFound = true
                controllerX = xPos
                controllerY = yPos
            end

            yi = yi + 1
            if yi > #yPositions then
                yi = 1
                xPos = xPos + OPT.CELL_SIZE + OVERFLOW_MARGIN
            end
        end
        i = i + 1
    end

    local instructionCount = #renderInstructions
    ItemGridUI._bulkRenderGridStacks(self, renderInstructions, instructionCount, playerObj)

    if controllerSelectionFound then
        self:drawRectBorder(controllerX, controllerY, OPT.CELL_SIZE, OPT.CELL_SIZE, 0.3, ControllerNode.FOCUS_COLOR.r, ControllerNode.FOCUS_COLOR.g, ControllerNode.FOCUS_COLOR.b)
    end
end

function GridOverflowRenderer:findStackDataUnderMouse(x, y)
    local overflow = self.containerGrid.overflow
    if #overflow == 0 then return end

    local yPositions = self:getYPositionsForOverflow()
    local xPos = 0
    local yi = 1

    for _, stack in ipairs(overflow) do
        local yPos = yPositions[yi]
        if x >= xPos and x < xPos + OPT.CELL_SIZE and y >= yPos and y < yPos + OPT.CELL_SIZE then
            return stack
        end

        yi = yi + 1
        if yi > #yPositions then
            yi = 1
            xPos = xPos + OPT.CELL_SIZE + OVERFLOW_MARGIN
        end
    end

    return nil
end

---@param x number
---@param y number
---@param localSpace ISUIElement
---@param targetSpace ISUIElement
---@return number
---@return number
local function convertCoordinates(x, y, localSpace, targetSpace)
    local x2 = x + localSpace:getAbsoluteX()
    local y2 = y + localSpace:getAbsoluteY()
    x2 = x2 - targetSpace:getAbsoluteX()
    y2 = y2 - targetSpace:getAbsoluteY()
    return x2, y2
end

function GridOverflowRenderer:onMouseDown(x, y)
	local stack = self:findStackDataUnderMouse(x, y)
    if stack then
        x, y = convertCoordinates(x, y, self, self.gridUi)
        return self.gridUi:onMouseDown(x, y, stack)
    end
end

function GridOverflowRenderer:onMouseUp(x, y)
	local stack = self:findStackDataUnderMouse(x, y)
    if stack then
        x, y = convertCoordinates(x, y, self, self.gridUi)
        return self.gridUi:onMouseUp(x, y, stack)
    end
end

function GridOverflowRenderer:onRightMouseUp(x, y)
	local stack = self:findStackDataUnderMouse(x, y)
    if stack then
        x, y = convertCoordinates(x, y, self, self.gridUi)
        return self.gridUi:onRightMouseUp(x, y, stack)
    end
end

function GridOverflowRenderer:onMouseDoubleClick(x, y)
    local stack = self:findStackDataUnderMouse(x, y)
    if stack then
        x, y = convertCoordinates(x, y, self, self.gridUi)
        return self.gridUi:handleDoubleClick(x, y, stack)
    end
end

function GridOverflowRenderer:controllerNodeOnJoypadDir(dx, dy, joypadData)
    local yCount = #self:getYPositionsForOverflow()

    if dy == -1 then
        if self.controllerSelection % yCount ~= 1 then
            self.controllerSelection = self.controllerSelection - 1
            return true
        end
    end

    if dy == 1 then
        if self.controllerSelection % yCount ~= 0 then
            self.controllerSelection = self.controllerSelection + 1
            return true
        end
    end

    if dx == -1 then
        if self.controllerSelection > yCount then
            self.controllerSelection = self.controllerSelection - yCount
            return true
        end
    end

    if dx == 1 then
        local columns = math.ceil(#self.containerGrid.overflow / yCount)
        local currentColumn = math.ceil(self.controllerSelection / yCount)
        if currentColumn < columns then
            self.controllerSelection = math.min(self.controllerSelection + yCount, #self.containerGrid.overflow)
            return true
        end
    end

    return false
end

function GridOverflowRenderer:controllerNodeOnJoypadDown(button)
    if ControllerDragAndDrop.isDragging(self.playerNum) then
        -- Rotate item
        if button == Joypad.AButton then
            ControllerDragAndDrop.rotateDraggedItem(self.playerNum)
            return true
        end
 
        -- Eat the input, but do nothing
        if button == Joypad.BButton then
            return true
        end

        -- Cancel drag without moving item
        if button == Joypad.YButton then
            ControllerDragAndDrop.endDrag(self.playerNum)
            return true
        end

    else
        -- Open item context menu
        if button == Joypad.AButton then
            local stack = self.containerGrid.overflow[self.controllerSelection]
            if stack then
                local yPositions = self:getYPositionsForOverflow()
                local yCount = #yPositions
                local currentColumn = math.ceil(self.controllerSelection / yCount)
                local yIndex = self.controllerSelection % yCount

                local x = currentColumn * (OPT.CELL_SIZE + OVERFLOW_MARGIN) 
                local y = yPositions[yIndex]

                ItemGridUI.openStackContextMenu(self, x - 16, y + 16, stack, self.inventory, self.inventoryPane, self.playerNum)
            end
            return true
        end

        -- Pick up item
        if button == Joypad.BButton then
            local stack = self.containerGrid.overflow[self.controllerSelection]
            if stack then
                local vanillaStack = ItemStack.convertStackToVanillaStackList(stack, self.inventory, self.inventoryPane)[1]
                ControllerDragAndDrop.startDrag(self.playerNum, self, stack, vanillaStack)
            end
            return true
        end

        -- Quick move item
        if button == Joypad.XButton then
            local stack = self.containerGrid.overflow[self.controllerSelection]
            if stack then
                self.gridUi:doAction(stack, "move")
            end
            return true
        end

    end

    return false
end

return GridOverflowRenderer
