ItemGridUtil = {}

ItemGridUtil.itemSizes = {}
ItemGridUtil.isStackable = {}

ItemGridUtil.getItemPosition = function(item)
    local modData = item:getModData()
    return modData[X_POS], modData[Y_POS]
end

ItemGridUtil.setItemPosition = function(item, x, y)
    local modData = item:getModData()
    modData[X_POS] = x
    modData[Y_POS] = y
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

ItemGridUtil.findItemUnderMouse = function(inventory, x, y)
    for i = 1, inventory:getItems():size() do
        local item = inventory:getItems():get(i - 1)
        if ItemGridUtil.isMouseOverItem(item, x, y) then
            return item
        end
    end
    return nil
end

ItemGridUtil.isMouseOverItem = function(item, mouseX, mouseY)
    local itemX, itemY = ItemGridUtil.getItemPosition(item)
    local itemWidth, itemHeight = ItemGridUtil.getItemSize(item)

    local x1 = itemX * cellSize
    local y1 = itemY * cellSize
    local x2 = x1 + (itemWidth * cellSize)
    local y2 = y1 + (itemHeight * cellSize)

    if mouseX >= x1 and mouseX <= x2 and mouseY >= y1 and mouseY <= y2 then
        return true
    end
    return false
end

-- Rounds a mouse position to the nearest grid position, for the top left corner of the item
ItemGridUtil.mousePositionToGridPosition = function(x, y)
    local gridX = math.floor((x + cellSize / 2) / cellSize)
    local gridY = math.floor((y + cellSize / 2) / cellSize)
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
