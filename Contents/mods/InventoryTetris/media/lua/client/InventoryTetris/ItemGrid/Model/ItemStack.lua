-- Purely static code as these need to be serialized into modData
-- TODO: see if we can remove the rep later once things are more stable

ItemStack = {}

ItemStack.create = function(x, y, isRotated, inventory)
    local stack = {}
    stack.itemIDs = {}
    stack.count = 0
    stack.x = x
    stack.y = y
    stack.isRotated = isRotated and true or false
    stack.inventory = inventory -- Does not get serialized
    return stack
end

ItemStack.copyWithoutItems = function(stack, inventory)
    local newStack = ItemStack.create(stack.x, stack.y, stack.isRotated, inventory)
    return newStack
end

ItemStack.getFrontItem = function(stack)
    for itemID, _ in pairs(stack.itemIDs) do
        local item = stack.inventory:getItemById(itemID)
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
    
    local frontItem = ItemStack.getFrontItem(stack)
    if frontItem:getFullType() ~= item:getFullType() then return false end
    if stack.count >= GridItemManager.getMaxStackSize(item) then return false end
    
    return true
end

ItemStack.isSameType = function(stack, item)
    if stack.count == 0 then return false end
    local frontItem = ItemStack.getFrontItem(stack)
    local fullType = item:getFullType()
    local fullType2 = frontItem:getFullType()
    return fullType == fullType2
end

ItemStack.isRotated = function(stack)
    return stack.isRotated
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
    end

    return vanillaStack
end
