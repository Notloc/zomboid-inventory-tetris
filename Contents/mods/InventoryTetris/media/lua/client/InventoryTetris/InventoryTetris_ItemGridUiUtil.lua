require "InventoryTetris/ItemGridDataDefinitions"
local TETRIS = require "InventoryTetris/Constants"

local CELL_SIZE = TETRIS.CELL_SIZE
local TEXTURE_SIZE = TETRIS.TEXTURE_SIZE
local TEXTURE_PAD = TETRIS.TEXTURE_PAD

ItemGridUiUtil = {}

ItemGridUiUtil.findGridUiUnderMouse = function(gridUis)
    local x = getMouseX()
    local y = getMouseY()
    for _, gridUi in pairs(gridUis) do
        if gridUi:isMouseOver(x, y) then
            return gridUi
        end
    end
    return nil
end

ItemGridUiUtil.findItemUnderMouse = function(gridUis, x, y)
    local gridUi = ItemGridUiUtil.findGridUiUnderMouse(gridUis, x, y)
    return ItemGridUiUtil.findItemUnderMouseGrid(gridUi)
end

ItemGridUiUtil.findItemUnderMouseGrid = function(gridUi)
    if not gridUi then 
        return nil 
    end

    local x = gridUi:getMouseX()
    local y = gridUi:getMouseY()

    local inventory = gridUi.grid.inventory
    for i = 1, inventory:getItems():size() do
        local item = inventory:getItems():get(i - 1)
        local gridIndex = ItemGridUtil.getItemGridIndex(item)
        if gridIndex == gridUi.grid.gridIndex and ItemGridUiUtil.isMouseOverItem(item, x, y) then
            return item
        end
    end
    return nil
end

ItemGridUiUtil.isMouseOverItem = function(item, mouseX, mouseY)
    local itemX, itemY = ItemGridUtil.getItemPosition(item)
    local itemWidth, itemHeight = ItemGridUtil.getItemSize(item)

    local x1 = itemX * CELL_SIZE
    local y1 = itemY * CELL_SIZE
    local x2 = x1 + (itemWidth * CELL_SIZE)
    local y2 = y1 + (itemHeight * CELL_SIZE)

    if mouseX >= x1 and mouseX <= x2 and mouseY >= y1 and mouseY <= y2 then
        return true
    end
    return false
end

-- Get the mouse position relative to the top left corner of the item being dragged
ItemGridUiUtil.findGridPositionOfMouse = function(gridUi, item, rotate)
    local xOff = 0
    local yOff = 0

    if item then
        local w, h = ItemGridUtil.getItemSize(item)
        if rotate then
            w, h = h, w
        end

        xOff = CELL_SIZE * w / 2 - CELL_SIZE / 2
        yOff = CELL_SIZE * h / 2 - CELL_SIZE / 2
    end

    return ItemGridUiUtil.mousePositionToGridPosition(gridUi:getMouseX() - xOff, gridUi:getMouseY() - yOff)
end

-- Rounds a mouse position to the nearest grid position, for the top left corner of the item
ItemGridUiUtil.mousePositionToGridPosition = function(x, y)
    local effectiveCellSize = CELL_SIZE - 1
    local gridX = math.floor(x / effectiveCellSize)
    local gridY = math.floor(y / effectiveCellSize)
    return gridX, gridY
end
