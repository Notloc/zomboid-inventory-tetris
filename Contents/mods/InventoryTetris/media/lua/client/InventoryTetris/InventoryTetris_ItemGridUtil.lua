require "InventoryTetris/ItemGridDataDefinitions"
local TETRIS = require "InventoryTetris/Constants"

local X_POS = TETRIS.X_POS
local Y_POS = TETRIS.Y_POS
local IS_ROTATED = TETRIS.IS_ROTATED
local GRID_INDEX = TETRIS.GRID_INDEX

local CELL_SIZE = TETRIS.CELL_SIZE
local TEXTURE_SIZE = TETRIS.TEXTURE_SIZE
local TEXTURE_PAD = TETRIS.TEXTURE_PAD

ItemGridUtil = {}

ItemGridUtil.getItemPosition = function(item)
    local modData = item:getModData()
    return modData[X_POS], modData[Y_POS], modData[GRID_INDEX]
end

ItemGridUtil.setItemPosition = function(item, x, y, index)
    local modData = item:getModData()
    modData[X_POS] = x
    modData[Y_POS] = y
    modData[GRID_INDEX] = index
end

ItemGridUtil.getItemGridIndex = function(item)
    local modData = item:getModData()
    return modData[GRID_INDEX]
end

ItemGridUtil.setItemGridIndex = function(item, index)
    local modData = item:getModData()
    modData[GRID_INDEX] = index
end

ItemGridUtil.clearItemPosition = function(item)
    local modData = item:getModData()
    modData[X_POS] = nil
    modData[Y_POS] = nil
    modData[GRID_INDEX] = nil
end

ItemGridUtil.rotateItem = function(item)
    local modData = item:getModData()
    local isRotated = modData[IS_ROTATED]
    if isRotated then
        modData[IS_ROTATED] = nil
    else
        modData[IS_ROTATED] = true
    end
end

ItemGridUtil.getItemSize = function(item)
    if not ItemGridDataDefinitions.itemSizes[item:getFullType()] then
        ItemGridDataDefinitions.calculateAndCacheItemInfo(item)
    end
    
    local sizeData = ItemGridDataDefinitions.itemSizes[item:getFullType()]
    if item:getModData()[IS_ROTATED] then
        return sizeData.y, sizeData.x
    else
        return sizeData.x, sizeData.y
    end
end

ItemGridUtil.findGridUnderMouse = function(inventoryPane)
    if not inventoryPane.grids then return nil end
    
    local x = getMouseX()
    local y = getMouseY()
    for _, grid in pairs(inventoryPane.grids) do
        if grid:isMouseOver(x, y) then
            return grid
        end
    end
    return nil
end

ItemGridUtil.findItemUnderMouse = function(inventoryPane, x, y)
    local grid = ItemGridUtil.findGridUnderMouse(inventoryPane, x, y)
    return ItemGridUtil.findItemUnderMouseGrid(grid)
end

ItemGridUtil.findItemUnderMouseGrid = function(grid)
    if not grid then 
        return nil 
    end

    local x = grid:getMouseX()
    local y = grid:getMouseY()

    local inventory = grid.inventory
    for i = 1, inventory:getItems():size() do
        local item = inventory:getItems():get(i - 1)
        local gridIndex = ItemGridUtil.getItemGridIndex(item)
        if gridIndex == grid.gridIndex and ItemGridUtil.isMouseOverItem(item, x, y) then
            return item
        end
    end
    return nil
end

ItemGridUtil.isMouseOverItem = function(item, mouseX, mouseY)
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
ItemGridUtil.findGridPositionOfMouse = function(grid, item, rotate)
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

    return ItemGridUtil.mousePositionToGridPosition(grid:getMouseX() - xOff, grid:getMouseY() - yOff)
end

-- Rounds a mouse position to the nearest grid position, for the top left corner of the item
ItemGridUtil.mousePositionToGridPosition = function(x, y)
    local effectiveCellSize = CELL_SIZE - 1
    local gridX = math.floor(x / effectiveCellSize)
    local gridY = math.floor(y / effectiveCellSize)
    return gridX, gridY
end

ItemGridUtil.convertItemStackToItem = function(items)
    if instanceof(items, "InventoryItem") then
        return items
    -- Converts a vanilla "stack" of items into a single item
    elseif items and items.items then
        return items.items[1] == items.items[2] and items.items[1] or nil
    end
    return nil
end

function ItemGridUtil.isGridPositionValid(grid, x, y)
    local width = grid.gridWidth
    local height = grid.gridHeight
    if x < 0 or y < 0 or x >= width or y >= height then
        return false
    end
    return true
end