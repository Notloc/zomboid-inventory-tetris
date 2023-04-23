-- Purely static code as these need to be serialized into modData

ItemStackNew = {}

ItemStackNew.create = function(x, y, isRotated)
    local stack = {}
    stack.items = {}
    stack.count = 0
    stack.x = x
    stack.y = y
    stack.isRotated = isRotated and true or false
end

ItemStackNew.copyWithoutItems = function(stack)
    local newStack = ItemStackNew.create(stack.x, stack.y, stack.isRotated)
    return newStack
end

ItemStackNew.getFrontItem = function(stack)
    for itemID, _ in pairs(stack.items) do
        return itemID
    end
    return nil
end

ItemStackNew.addItem = function(stack, item)
    if stack.items[item:getID()] then
        return -- Already in stack
    end
    stack.items[item:getID()] = true
    stack.count = stack.count + 1
end

ItemStackNew.removeItem = function(stack, item)
    if not stack.items[item:getID()] then
        return -- Not in stack
    end
    stack.items[item:getID()] = nil
    stack.count = stack.count - 1
end

ItemStackNew.containsItem = function(stack, item)
    return stack.items[item:getID()] ~= nil
end

ItemStackNew.canAddToStack = function(stack, item)
    if stack.count == 0 then return true end
    
    local frontItem = ItemStackNew.getFrontItem(stack)
    if frontItem:getFullType() ~= item:getFullType() then return false end
    if stack.count >= ItemGridUtil.getMaxStackSize(item) then return false end
    
    return true
end

ItemStackNew.isRotated = function(stack)
    return stack.isRotated
end
