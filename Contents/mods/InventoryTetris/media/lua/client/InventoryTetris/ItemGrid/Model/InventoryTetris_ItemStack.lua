ItemStack = {}

function ItemStack:new(item, x, y, gridIndex)
    o = {}
    setmetatable(o, self)
    self.__index = self

    ItemGridUtil.setItemPosition(item, x, y, gridIndex)
    o.items = {item, item} 
    o.count = 1

    return o
end

function ItemStack:containsItem(item)
    for _, stackItem in ipairs(self.items) do
        if stackItem == item then
            return true
        end
    end
    return false
end

function ItemStack:canAddToStack(item)
    if self.items[1]:getFullType() ~= item:getFullType() then return false end
    if self:containsItem(item) then return false end
    if self.count >= ItemGridUtil.getMaxStackSize(item) then return false end
    return true
end

function ItemStack:addItem(item)
    table.insert(self.items, item)
    ItemGridUtil.setItemRotation(item, self:isRotated())
    ItemGridUtil.setItemPosition(item, ItemGridUtil.getItemPosition(self.items[1]))
    self.count = self.count + 1
end

function ItemStack:removeItem(item)
    for i, stackItem in ipairs(self.items) do
        if stackItem == item then
            table.remove(self.items, i)
            if i == 1 and self.count > 2 then
                table.remove(self.items, 1)
            end
            self.count = self.count - 1
            return
        end
    end
end

function ItemStack:isRotated()
    return ItemGridUtil.isItemRotated(self.items[1])
end

