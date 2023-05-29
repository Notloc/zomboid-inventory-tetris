
require "ISUI/ISUIElement"
local OPT = require "InventoryTetris/Settings"
local OVERFLOW_MARGIN = 3


GridOverflowRenderer = ISUIElement:derive("GridOverflowRenderer")

function GridOverflowRenderer:new(x,y, containerGridUi)
    local o = ISUIElement:new(x, y, 0, 0)
    setmetatable(o, self)
    self.__index = self
    o.containerGridUi = containerGridUi
    return o
end

function GridOverflowRenderer:getOverflowStackData()
    local overflowStackData = {}
    
    for _, gridUi in ipairs(self.containerGridUi.gridUis) do
        local data = {}
        data.gridUi = gridUi
        data.stacks = gridUi.grid.overflow
        table.insert(overflowStackData, data)
    end

    return overflowStackData
end

function GridOverflowRenderer:getYPositionsForOverflow()    
    local height = self.containerGridUi.gridRenderer:getHeight()
    if self.lastHeight == height then
        return self.lastYPositions
    end
    
    local y = 0
    local yPositions = {}
    while height > 0 do
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
    local overflowData = self:getOverflowStackData()
    
    local count = 0
    for _, data in ipairs(overflowData) do
        count = count + #data.stacks
    end
    
    local gridRenderer = self.containerGridUi.gridRenderer
    self:setX(gridRenderer:getX() + gridRenderer:getWidth() + 10)
    self:setY(gridRenderer:getY())
    self:setWidth(self:calculateOverflowColumnWidth(count))
    self:setHeight(gridRenderer:getHeight())

    if count == 0 then return end

    local yPositions = self:getYPositionsForOverflow()
    local xPos = 0
    local yi = 1

    for _, data in ipairs(overflowData) do
        local gridUi = data.gridUi
        local stacks = data.stacks
        local isUnsearched = gridUi.grid:isUnsearched(gridUi.playerNum)
        local searchSession = gridUi.grid:getSearchSession(gridUi.playerNum)

        local doNotShowOverflow = isUnsearched and (not searchSession or not searchSession.isGridRevealed)
        if not doNotShowOverflow then
            for _, stack in ipairs(stacks) do
                local item = ItemStack.getFrontItem(stack, inventory)
                if item then
                    updateItem(item);

                    local yPos = yPositions[yi]

                    if not isUnsearched or (searchSession and searchSession.searchedStackIDs[item:getID()]) then
                        ItemGridUI._renderGridStack(self, stack, item, xPos, yPos, 1, true)
                    else
                        ItemGridUI._renderHiddenStack(self, stack, item, xPos, yPos, 1, true)
                    end

                    yi = yi + 1
                    if yi > #yPositions then
                        yi = 1
                        xPos = xPos + OPT.CELL_SIZE + OVERFLOW_MARGIN
                    end
                end
            end
        end
    end
end

function GridOverflowRenderer:findStackDataUnderMouse(x, y)
    local overflowData = self:getOverflowStackData()

    local count = 0
    for _, data in ipairs(overflowData) do
        count = count + #data.stacks
    end
    if count == 0 then return end

    local yPositions = self:getYPositionsForOverflow()
    local xPos = 0
    local yi = 1

    for _, data in ipairs(overflowData) do
        local gridUi = data.gridUi
        local stacks = data.stacks
        for _, stack in ipairs(stacks) do
            local yPos = yPositions[yi]
            if x >= xPos and x < xPos + OPT.CELL_SIZE and y >= yPos and y < yPos + OPT.CELL_SIZE then
                return stack, data
            end
            
            yi = yi + 1
            if yi > #yPositions then
                yi = 1
                xPos = xPos + OPT.CELL_SIZE + OVERFLOW_MARGIN
            end
        end
    end
end

function GridOverflowRenderer:onMouseDown(x, y)
	local stack, data = self:findStackDataUnderMouse(x, y)
    if stack then
        return data.gridUi:onMouseDown(x, y, stack)
    end
end