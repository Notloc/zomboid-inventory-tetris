
require "ISUI/ISUIElement"
require "Notloc/NotUtil"

local OPT = require "InventoryTetris/Settings"
local OVERFLOW_MARGIN = 3
local OVERFLOW_RENDERER_SPACING = 8

GridOverflowRenderer = ISUIElement:derive("GridOverflowRenderer")

function GridOverflowRenderer:new(x,y, containerGridUi)
    local o = ISUIElement:new(x, y, 0, 0)
    setmetatable(o, self)
    self.__index = self
    o.containerGridUi = containerGridUi
    o.containerGrid = containerGridUi.containerGrid
    o.gridUi = o.containerGridUi.gridUis[1]
    return o
end

function GridOverflowRenderer:getYPositionsForOverflow()    
    local height = self.containerGridUi.gridRenderer:getHeight()
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

function GridOverflowRenderer:render()
    local inventory = self.containerGridUi.inventory
    local overflow = self.containerGrid.overflow
    
    local gridRenderer = self.containerGridUi.gridRenderer
    self:setX(gridRenderer:getX() + gridRenderer:getWidth() + OVERFLOW_RENDERER_SPACING)
    self:setY(gridRenderer:getY())
    self:setWidth(self:calculateOverflowColumnWidth(#overflow))
    self:setHeight(gridRenderer:getHeight())
    
    if #overflow == 0 then return end
    
    local playerObj = getSpecificPlayer(self.containerGridUi.playerNum)
    local yPositions = self:getYPositionsForOverflow()
    local xPos = 0
    local yi = 1

    for _, stack in ipairs(overflow) do
        local item = ItemStack.getFrontItem(stack, inventory)
        if item then
            updateItem(item);

            local yPos = yPositions[yi]

            if true then --or not isUnsearched or (searchSession and searchSession.searchedStackIDs[item:getID()]) then
                ItemGridUI._renderGridStack(self, playerObj, stack, item, xPos, yPos, 1, true)
            else
                ItemGridUI._renderHiddenStack(self, playerObj, stack, item, xPos, yPos, 1, true)
            end

            yi = yi + 1
            if yi > #yPositions then
                yi = 1
                xPos = xPos + OPT.CELL_SIZE + OVERFLOW_MARGIN
            end
        end
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