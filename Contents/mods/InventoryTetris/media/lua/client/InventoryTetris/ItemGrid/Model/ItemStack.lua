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

ItemStack.convertToVanillaStack = function(stack, inventory)
    local vanillaStack = {}
    vanillaStack.items = {}
    vanillaStack.count = stack.count
    vanillaStack.isRotated = stack.isRotated

    if stack.count == 0 then return vanillaStack end

    table.insert(vanillaStack.items, ItemStack.getFrontItem(stack, inventory))
    for itemId, _ in pairs(stack.itemIDs) do
        local item = inventory:getItemById(itemId)
        table.insert(vanillaStack.items, item)
        table.insert(vanillaStack, item)
    end

    return {vanillaStack}
end

ItemStack.createVanillaStackFromItem = function(item)
    return ItemStack.createVanillaStackFromItems({item})
end

ItemStack.createVanillaStackFromItems = function(items)
    local vanillaStack = {}
    vanillaStack.items = {}

    table.insert(vanillaStack.items, items[1])
    for _, item in ipairs(items) do
        table.insert(vanillaStack.items, item)
    end

    return {vanillaStack}
end
