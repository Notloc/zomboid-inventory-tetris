require("ISUI/ISUIElement")
require("Notloc/NotUtil")

local OPT = require("InventoryTetris/Settings")
local OVERFLOW_MARGIN = 3
local OVERFLOW_RENDERER_SPACING = 8

GridOverflowRenderer = ISUIElement:derive("GridOverflowRenderer")

function GridOverflowRenderer:new(x,y, containerGridUi, gridUi, inventory, inventoryPane, playerNum)
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
    NotlocControllerNode
        :injectControllerNode(self)
        :setJoypadDirHandler(self.controllerNodeOnJoypadDir)
        :setJoypadDownHandler(self.controllerNodeOnJoypadDown)
end

function GridOverflowRenderer:getYPositionsForOverflow()    
    local height = self.containerGridUi.multiGridRenderer:getHeight()
    if self.lastHeight == height then
        return self.lastYPositions
    end

    local y = 0
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

    local i = 1
    for _, stack in ipairs(overflow) do
        local item = ItemStack.getFrontItem(stack, inventory)
        if item then
            --ItemGridUI.updateItem(item);

            local yPos = yPositions[yi]
            local alpha = 1
            local w, h = 1, 1

            if true then --or not isUnsearched or (searchSession and searchSession.searchedStackIDs[item:getID()]) then
                ItemGridUI._renderGridStack(self, playerObj, stack, item, xPos, yPos, w, h, alpha, false, nil, true)
            else
                ItemGridUI._renderHiddenStack(self, playerObj, stack, item, xPos, yPos, w, h, 1)
            end

            if self.controllerNode.isFocused and self.controllerSelection == i then
                self:drawRect(xPos, yPos, OPT.CELL_SIZE, OPT.CELL_SIZE, 0.3, NotlocControllerNode.FOCUS_COLOR.r, NotlocControllerNode.FOCUS_COLOR.g, NotlocControllerNode.FOCUS_COLOR.b)
            end

            yi = yi + 1
            if yi > #yPositions then
                yi = 1
                xPos = xPos + OPT.CELL_SIZE + OVERFLOW_MARGIN
            end
        end
        i = i + 1
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

function GridOverflowRenderer:onMouseDown(x, y)
	local stack = self:findStackDataUnderMouse(x, y)
    if stack then
        x, y = NotUtil.Ui.convertCoordinates(x, y, self, self.gridUi)
        return self.gridUi:onMouseDown(x, y, stack)
    end
end

function GridOverflowRenderer:onMouseUp(x, y)
	local stack = self:findStackDataUnderMouse(x, y)
    if stack then
        x, y = NotUtil.Ui.convertCoordinates(x, y, self, self.gridUi)
        return self.gridUi:onMouseUp(x, y, stack)
    end
end

function GridOverflowRenderer:onRightMouseUp(x, y)
	local stack = self:findStackDataUnderMouse(x, y)
    if stack then
        x, y = NotUtil.Ui.convertCoordinates(x, y, self, self.gridUi)
        return self.gridUi:onRightMouseUp(x, y, stack)
    end
end

function GridOverflowRenderer:onMouseDoubleClick(x, y)
    local stack = self:findStackDataUnderMouse(x, y)
    if stack then
        x, y = NotUtil.Ui.convertCoordinates(x, y, self, self.gridUi)
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