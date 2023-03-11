require "InventoryTetris/ItemData"
local TETRIS = require "InventoryTetris/Constants"

local X_POS = TETRIS.X_POS
local Y_POS = TETRIS.Y_POS
local IS_ROTATED = TETRIS.IS_ROTATED
local GRID_INDEX = TETRIS.GRID_INDEX

ItemGridUtil = {}

ItemGridUtil.getItemPosition = function(item)
    if item:isEquipped() then
        return -1, -1, 0
    end

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

ItemGridUtil.isItemRotated = function(item)
    local modData = item:getModData()
    return modData[IS_ROTATED]
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

ItemGridUtil.setItemRotation = function(item, isRotated)
    local modData = item:getModData()
    if isRotated then
        modData[IS_ROTATED] = true
    else
        modData[IS_ROTATED] = nil
    end
end

ItemGridUtil.getItemSize = function(item)
    if TetrisDevTool.itemEdits and TetrisDevTool.itemEdits[item:getFullType()] then
        return TetrisDevTool.itemEdits[item:getFullType()].x, TetrisDevTool.itemEdits[item:getFullType()].y
    end

    if not ItemData.itemSizes[item:getFullType()] then
        ItemData.calculateAndCacheItemInfo(item)
    end
    
    local sizeData = ItemData.itemSizes[item:getFullType()]
    if item:getModData()[IS_ROTATED] then
        return sizeData.y, sizeData.x
    else
        return sizeData.x, sizeData.y
    end
end

ItemGridUtil.getMaxStackSize = function(item)
    local fullType = item:getFullType()
    if TetrisDevTool.itemEdits and TetrisDevTool.itemEdits[fullType] then
        return TetrisDevTool.itemEdits[fullType].maxStackSize
    end

    if not ItemData.itemSizes[fullType] then
        ItemData.calculateAndCacheItemInfo(item)
    end

    local max = ItemData.itemSizes[fullType].maxStackSize
    --return max and max or 1
    return 10
end

ItemGridUtil.canStack = function(item)
    local max = ItemGridUtil.getMaxStackSize(item) 
    return max and max > 1
end

ItemGridUtil.convertItemStackToItem = function(items)
    if instanceof(items, "InventoryItem") then
        return items
    -- Converts a vanilla "stack" of items into a single item
    elseif items and items.items then
        return items.items[1]
    end
    return nil
end

ItemGridUtil.isGridPositionValid = function(grid, x, y)
    local width = grid.width
    local height = grid.height
    if x < 0 or y < 0 or x >= width or y >= height then
        return false
    end
    return true
end

ItemGridUtil.itemToNewStack = function(item)
    local stack = {
        items = {item}, 
        count = 1,
        position = {x = -1, y = -1},
    }
    return stack
end