-- Keeps track of a stack of items in the item grid, holding the id of each item in the stack as well as position and rotation
-- Purely static code as these need to be serialized into modData

---@class ItemStack
---@field public itemIDs table<number, boolean>
---@field public count number
---@field public x number
---@field public y number
---@field public isRotated boolean
---@field public itemType string
---@field public category string

ItemStack = {}

---@return ItemStack
function ItemStack.create(x, y, isRotated, itemFullType, category)
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

function ItemStack.copyWithoutItems(stack)
    return ItemStack.create(stack.x, stack.y, stack.isRotated, stack.itemType, stack.category)
end

function ItemStack.createTempStack(item)
    local stack = ItemStack.create(0, 0, false, item:getFullType(), TetrisItemCategory.getCategory(item))
    ItemStack.addItem(stack, item)
    return stack
end

function ItemStack.getFrontItem(stack, inventory)
    for itemID, _ in pairs(stack.itemIDs) do
        local item = inventory:getItemById(itemID)
        if item then return item end
    end
    return nil
end

function ItemStack.addItem(stack, item)
    if stack.itemIDs[item:getID()] then
        return -- Already in stack
    end
    stack.itemIDs[item:getID()] = true
    stack.count = stack.count + 1
end

function ItemStack.removeItem(stack, item)
    if not stack.itemIDs[item:getID()] then
        return -- Not in stack
    end
    stack.itemIDs[item:getID()] = nil
    stack.count = stack.count - 1
end

function ItemStack.containsItem(stack, item)
    return stack.itemIDs[item:getID()] ~= nil
end

function ItemStack.canAddItem(stack, item)
    if stack.count == 0 then return true end

    if not ItemStack.isSameType(stack, item) then return false end
    if stack.count >= TetrisItemData.getMaxStackSize(item) then return false end

    return true
end

function ItemStack.isSameType(stack, item)
    return stack.itemType == item:getFullType()
end

function ItemStack.getAllItems(stack, inventory)
    local items = {}

    for itemID, _ in pairs(stack.itemIDs) do
        local item = inventory:getItemById(itemID)
        if item then table.insert(items, item) end
    end

    return items
end

function ItemStack.convertToVanillaStacks(stack, inventory, inventoryPane)
    local items = ItemStack.getAllItems(stack, inventory)
    local vanillaStacks = ItemStack.createVanillaStacksFromItems(items, inventoryPane)
    vanillaStacks[1].isRotated = stack.isRotated
    return vanillaStacks
end

function ItemStack.createVanillaStacksFromItem(item, inventoryPane)
    return ItemStack.createVanillaStacksFromItems({item}, inventoryPane)
end

-- Assumes all items are the same type
function ItemStack.createVanillaStacksFromItems(items, inventoryPane)
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
