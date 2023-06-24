local OPT = require "InventoryTetris/Settings"

ItemGridUiUtil = {}

function ItemGridUiUtil.findGridUiUnderMouse(gridUis, x, y)
    for _, gridUi in pairs(gridUis) do
        if gridUi:isMouseOver(x, y) then
            return gridUi
        end
    end
    return nil
end

function ItemGridUiUtil.findGridStackUnderMouse(gridUis, x, y)
    local gridUi = ItemGridUiUtil.findGridUiUnderMouse(gridUis, x, y)
    if gridUi then
        return gridUi:findGridStackUnderMouse()
    end
    return nil
end

-- Get the mouse position relative to the top left corner of the item being dragged
function ItemGridUiUtil.findGridPositionOfMouse(gridUi, item, isRotated)
    local xOff = 0
    local yOff = 0

    if item then
        local w, h = TetrisItemData.getItemSize(item, isRotated)
        xOff = OPT.CELL_SIZE * w / 2 - OPT.CELL_SIZE / 2
        yOff = OPT.CELL_SIZE * h / 2 - OPT.CELL_SIZE / 2
    end

    return ItemGridUiUtil.mousePositionToGridPosition(gridUi:getMouseX() - xOff, gridUi:getMouseY() - yOff)
end

-- Rounds a mouse position to the nearest grid position, for the top left corner of the item
function ItemGridUiUtil.mousePositionToGridPosition(x, y)
    local effectiveCellSize = OPT.CELL_SIZE - 1
    local gridX = math.floor(x / effectiveCellSize)
    local gridY = math.floor(y / effectiveCellSize)
    return gridX, gridY
end


function ItemGridUiUtil.getOrderedBackpacks(inventoryPage)
    local orderedBackpacks = {}

    local selectedBackpack = inventoryPage.inventory
    if selectedBackpack then
        table.insert(orderedBackpacks, selectedBackpack)
    end

    local sortedButtons = {}
    for _, button in ipairs(inventoryPage.backpacks) do
        table.insert(sortedButtons, button)
    end
    table.sort(sortedButtons, function(a, b) return a:getY() < b:getY() end)

    for _, button in ipairs(sortedButtons) do
        if button.inventory ~= selectedBackpack then
            table.insert(orderedBackpacks, button.inventory)
        end
    end

    return orderedBackpacks
end
