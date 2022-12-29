local TETRIS = require "InventoryTetris/Constants"

local X_POS = TETRIS.X_POS
local Y_POS = TETRIS.Y_POS
local IS_ROTATED = TETRIS.IS_ROTATED
local GRID_INDEX = TETRIS.GRID_INDEX

local CELL_SIZE = TETRIS.CELL_SIZE
local TEXTURE_SIZE = TETRIS.TEXTURE_SIZE
local TEXTURE_PAD = TETRIS.TEXTURE_PAD



ItemGridUtil = {}

ItemGridUtil.itemSizes = {}
ItemGridUtil.isStackable = {}

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
    if not ItemGridUtil.itemSizes[item:getFullType()] then
        ItemGridUtil.calculateAndCacheItemInfo(item)
    end
    
    local sizeData = ItemGridUtil.itemSizes[item:getFullType()]
    if item:getModData()[IS_ROTATED] then
        return sizeData.y, sizeData.x
    else
        return sizeData.x, sizeData.y
    end
end

ItemGridUtil.calculateAndCacheItemInfo = function(item)
    ItemGridUtil.calculateItemSize(item)
    ItemGridUtil.calculateItemStackability(item)
end

-- Programatically determine the size of an item
-- I'll manually override the sizes of some items later via a config file or something
ItemGridUtil.calculateItemSize = function(item)
    local category = item:getDisplayCategory()
    if category == "Ammo" then
        -- determine if its ammo or a magazine by stackability
        if item:CanStack(item) then
            ItemGridUtil.calculateItemSizeMagazine(item)
        else
            ItemGridUtil.calculateItemSizeAmmo(item)
        end
    elseif category == "Weapon" then
        ItemGridUtil.calculateItemSizeWeapon(item)
    elseif category == "Clothing" then
        ItemGridUtil.calculateItemSizeClothing(item)
    elseif category == "Food" then
        ItemGridUtil.calculateItemSizeWeightBased(item)
    elseif category == "FirstAid" then
        ItemGridUtil.calculateItemSizeWeightBased(item)
    elseif category == "Container" then
        ItemGridUtil.calculateItemSizeContainer(item)
    elseif category == "Book" then
        ItemGridUtil.calculateItemSizeWeightBased(item)
    elseif category == "Key" then
        ItemGridUtil.calculateItemSizeKey(item)
    elseif category == "Junk" then
        ItemGridUtil.calculateItemSizeWeightBased(item)
    else
        ItemGridUtil.calculateItemSizeWeightBased(item)
    end
end

ItemGridUtil.calculateItemSizeMagazine = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 0.25 then
        height = 2
    end

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.calculateItemSizeAmmo = function(item)
    ItemGridUtil.itemSizes[item:getFullType()] = {x = 1, y = 1}
end

ItemGridUtil.calculateItemSizeWeapon = function(item)
    local width = 2
    local height = 1

    local weight = item:getActualWeight()

    if weight >= 3 then
        width = 4
        height = 2
    elseif weight >= 2.5 then
        width = 3
        height = 2
    elseif weight >= 2 then
        width = 3
        height = 1
    elseif weight <= 0.4 then
        width = 1
        height = 1
    end

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.calculateItemSizeClothing = function(item)
    local width = 2
    local height = 2

    -- This shouldn't happen, but just in case a mod does something weird
    if item:IsClothing() == false then
        ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
        return
    end

    local bulletDef = item:getBulletDefense()
    if bulletDef >= 50 then
        width = 3
        height = 3
    else
        local weight = item:getActualWeight()
        if weight >= 3.0 then
            width = 3
            height = 3
        elseif weight < 0.5 then
            width = 1
            height = 1
        elseif weight <= 1.0 then
            width = 2
            height = 1
        end
    end

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.calculateItemSizeWeightBased = function(item)
    local width = 1
    local height = 1

    local weight = item:getActualWeight()
    if weight >= 10 then
        width = 4
        height = 4
    elseif weight >= 5 then
        width = 3
        height = 3
    elseif weight >= 2 then
        width = 2
        height = 2
    elseif weight >= 1 then
        width = 2
        height = 1
    end

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.calculateItemSizeKey = function(item)
    ItemGridUtil.itemSizes[item:getFullType()] = {x = 1, y = 1}
end

ItemGridUtil.calculateItemStackability = function(item)
    local stackable = item:CanStack(item)
    ItemGridUtil.isStackable[item:getFullType()] = stackable
end

ItemGridUtil.calculateItemSizeContainer = function(item)
    local width = 1
    local height = 1

    -- TODO: Should match the internal size of said container

    ItemGridUtil.itemSizes[item:getFullType()] = {x = width, y = height}
end

ItemGridUtil.findGridUnderMouse = function(inventoryPane, x, y)
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
ItemGridUtil.findGridPositionOfMouse = function(grid, item)
    local xOff = 0
    local yOff = 0

    if item then
        local w, h = ItemGridUtil.getItemSize(item)
        xOff = CELL_SIZE * w / 2 - CELL_SIZE / 2
        yOff = CELL_SIZE * h / 2 - CELL_SIZE / 2
    end

    return ItemGridUtil.mousePositionToGridPosition(grid:getMouseX() - xOff, grid:getMouseY() - yOff)
end

-- Rounds a mouse position to the nearest grid position, for the top left corner of the item
ItemGridUtil.mousePositionToGridPosition = function(x, y)
    local gridX = math.floor(x / CELL_SIZE)
    local gridY = math.floor(y / CELL_SIZE)
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