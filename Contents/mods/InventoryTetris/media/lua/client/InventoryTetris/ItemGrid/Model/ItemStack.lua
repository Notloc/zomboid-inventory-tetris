-- Purely static code as these need to be serialized into modData
-- TODO: see if we can remove the rep later once things are more stable

ItemStack = {}

ItemStack.create = function(x, y, isRotated, itemFullType, category)
    local stack = {}
    stack.itemIDs = {}
    stack.count = 0
    stack.x = x
    stack.y = y
    stack.isRotated = isRotated and true or false
    stack.itemType = itemFullType
    stack.category = category
    return stack
end

ItemStack.copyWithoutItems = function(stack)
    return ItemStack.create(stack.x, stack.y, stack.isRotated, stack.itemType, stack.category)
end

ItemStack.createTempStack = function(item)
    local stack = ItemStack.create(0, 0, false, item:getFullType(), TetrisItemCategory.getCategory(item))
    ItemStack.addItem(stack, item)
    return stack
end

ItemStack.getFrontItem = function(stack, inventory)
    for itemID, _ in pairs(stack.itemIDs) do
        local item = inventory:getItemById(itemID)
        if item then return item end
    end
    return nil
end

ItemStack.addItem = function(stack, item)
    if stack.itemIDs[item:getID()] then
        return -- Already in stack
    end
    stack.itemIDs[item:getID()] = true
    stack.count = stack.count + 1
end

ItemStack.removeItem = function(stack, item)
    if not stack.itemIDs[item:getID()] then
        return -- Not in stack
    end
    stack.itemIDs[item:getID()] = nil
    stack.count = stack.count - 1
end

ItemStack.containsItem = function(stack, item)
    return stack.itemIDs[item:getID()] ~= nil
end

ItemStack.canAddItem = function(stack, item)
    if stack.count == 0 then return true end
    
    if not ItemStack.isSameType(stack, item) then return false end
    if stack.count >= TetrisItemData.getMaxStackSize(item) then return false end
    
    return true
end

ItemStack.isSameType = function(stack, item)
    return stack.itemType == item:getFullType()
end

ItemStack.getAllItems = function(stack, inventory)
    local items = {}

    for itemID, _ in pairs(stack.itemIDs) do
        local item = inventory:getItemById(itemID)
        if item then table.insert(items, item) end
    end

    return items
end

ItemStack.convertToVanillaStacks = function(stack, inventory, inventoryPane)
    local items = ItemStack.getAllItems(stack, inventory)
    local vanillaStacks = ItemStack.createVanillaStacksFromItems(items, inventoryPane)
    vanillaStacks[1].isRotated = stack.isRotated
    return vanillaStacks
end

ItemStack.createVanillaStacksFromItem = function(item, inventoryPane)
    return ItemStack.createVanillaStacksFromItems({item}, inventoryPane)
end

-- Assumes all items are the same type
ItemStack.createVanillaStacksFromItems = function(items, inventoryPane)
    local vanillaStack = {}
    vanillaStack.items = {}
    vanillaStack.invPanel = inventoryPane

    if items[1] then
        vanillaStack.name = items[1]:getName()
        vanillaStack.cat = items[1]:getDisplayCategory() or items[1]:getCategory();
    end

    local weight = 0
    table.insert(vanillaStack.items, items[1])
    for _, item in ipairs(items) do
        table.insert(vanillaStack.items, item)
        weight = weight + item:getUnequippedWeight()
    end
    vanillaStack.weight = weight
    vanillaStack.count = #items + 1 -- Vanilla stacks count as 1 over their actual count

    return {vanillaStack}
end
