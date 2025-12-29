local TetrisItemData = require("InventoryTetris/Data/TetrisItemData")
local TetrisItemCategory = require("InventoryTetris/Data/TetrisItemCategory")

-- Keeps track of a stack of items in the item grid, holding the id of each item in the stack as well as position and rotation
-- Purely static code as these need to be serialized into modData

---@class ItemStack
---@field public itemIDs table<integer, boolean>
---@field public count number
---@field public x number
---@field public y number
---@field public isRotated boolean
---@field public itemType string
---@field public category string
---@field public _frontItem InventoryItem|nil
---@field public _frontItemId integer|nil

local ItemStackService = {}

---@return ItemStack
function ItemStackService.create(x, y, isRotated, itemFullType, category)
    ---@type ItemStack
    local stack = {
        itemIDs = {},
        count = 0,
        x = x,
        y = y,
        isRotated = isRotated and true or false,
        itemType = itemFullType,
        category = category,
        _frontItem = nil,
        _frontItemId = nil,
    }
    return stack
end

function ItemStackService.copyWithoutItems(stack)
    return ItemStackService.create(stack.x, stack.y, stack.isRotated, stack.itemType, stack.category)
end

function ItemStackService.createTempStack(item)
    local stack = ItemStackService.create(0, 0, false, item:getFullType(), TetrisItemCategory.getCategory(item))
    ItemStackService.addItem(stack, item)
    return stack
end

---comment
---@param stack ItemStack
---@param inventory ItemContainer
---@return InventoryItem
function ItemStackService.getFrontItem(stack, inventory)
    if stack._frontItem and stack._frontItem:getContainer() == inventory then
        return stack._frontItem
    end

    for itemID, _ in pairs(stack.itemIDs) do
        local item = inventory:getItemWithID(itemID)
        if item then
            stack._frontItem = item
            stack._frontItemId = itemID
            return item
        end
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return nil
end

function ItemStackService.addItem(stack, item)
    if stack.itemIDs[item:getID()] then
        return -- Already in stack
    end
    stack.itemIDs[item:getID()] = true
    stack.count = stack.count + 1
end

function ItemStackService.removeItem(stack, item)
    local itemId = item:getID()
    if not stack.itemIDs[item:getID()] then
        return -- Not in stack
    end
    stack.itemIDs[item:getID()] = nil
    stack.count = stack.count - 1

    if stack._frontItem and stack._frontItem:getID() == itemId then
        stack._frontItem = nil
        stack._frontItemId = nil
    end
end

function ItemStackService.containsItem(stack, item)
    return stack.itemIDs[item:getID()] ~= nil
end

function ItemStackService.canAddItem(stack, item)
    if stack.count == 0 then return true end

    if not ItemStackService.isSameType(stack, item) then return false end
    if stack.count >= TetrisItemData.getMaxStackSize(item) then return false end

    return true
end

function ItemStackService.isSameType(stack, item)
    return stack.itemType == item:getFullType()
end

function ItemStackService.getAllItems(stack, inventory)
    local items = {}

    for itemID, _ in pairs(stack.itemIDs) do
        local item = inventory:getItemWithID(itemID)
        if item then table.insert(items, item) end
    end

    return items
end

---@param stack ItemStack
---@param inventory ItemContainer
---@param inventoryPane ISInventoryPane
function ItemStackService.convertStackToVanillaStackList(stack, inventory, inventoryPane)
    return ItemStackService.convertStacksToVanillaStackList({stack}, inventory, inventoryPane)
end

---@param stacks ItemStack[]
---@param inventory ItemContainer
---@param inventoryPane ISInventoryPane
---@return VanillaStack[]
function ItemStackService.convertStacksToVanillaStackList(stacks, inventory, inventoryPane)
    if #stacks == 0 then return {} end
    local vanillaStacks = {}
    for _, stack in ipairs(stacks) do
        local items = ItemStackService.getAllItems(stack, inventory)
        local vanillaStack = ItemStackService._createVanillaStackFromItems(items, inventoryPane)
        vanillaStack.isRotated = stack.isRotated
        table.insert(vanillaStacks, vanillaStack)
    end
    return vanillaStacks
end

function ItemStackService.createVanillaStackListFromItem(item, inventoryPane)
    return {ItemStackService._createVanillaStackFromItems({item}, inventoryPane)}
end

-- Assumes all items are the same type
function ItemStackService.createVanillaStackListFromItems(items, inventoryPane)
    return {ItemStackService._createVanillaStackFromItems(items, inventoryPane)}
end

-- Assumes all items are the same type
---@param items InventoryItem[]
---@param inventoryPane ISInventoryPane
---@return VanillaStack
function ItemStackService._createVanillaStackFromItems(items, inventoryPane)
    local referenceItem = items[1]

    -- Copy the list
    local weight = 0.0
    local itemList = {referenceItem} -- The reference item is always in the list twice
    for _, item in ipairs(items) do
        table.insert(itemList, item)
        weight = weight + item:getUnequippedWeight()
    end

    local vanillaStack = {
        items = itemList,
        invPanel = inventoryPane,
        name = referenceItem and referenceItem:getName() or "",
        cat = referenceItem and (referenceItem:getDisplayCategory() or referenceItem:getCategory()) or "",
        weight = weight,
        count = #items + 1, -- Vanilla stacks count as 1 over their actual
        equipped = false, -- TODO: Determine if the item is equipped
        inHotbar = false, -- TODO: Determine if the item is in the hotbar
    }

    return vanillaStack
end

return ItemStackService
