require "ISUI/ISCollapsableWindow"

ItemGridStackSplitWindow = ISCollapsableWindow:derive("ItemGridStackSplitWindow");

function ItemGridStackSplitWindow:new(grid, vanillaStack, x, y, r, playerNum)
    local o = ISCollapsableWindow:new(0, 0, 200, 100)
    setmetatable(o, self)
    self.__index = self

    o.grid = grid
    o.vanillaStack = vanillaStack
    o.targetX = x
    o.targetY = y
    o.isRotated = r
    o.playerNum = playerNum

    return o
end

function ItemGridStackSplitWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.max = #self.vanillaStack.items - 1 -- minus 1 because the first item is fake
    local half = math.floor(self.max / 2)

    self.countLabel = ISLabel:new(100, 20, 20, tostring(half) .. " / "..tostring(self.max), 1, 1, 1, 1, UIFont.Small, true)
    self.countLabel:initialise()
    self.countLabel:instantiate()
    self.countLabel.center = true
    self:addChild(self.countLabel)

    self.splitSlider = ISSliderPanel:new(20, 40, 160, 20, self, self.onSplitSliderChange)
    self.splitSlider:initialise()
    self.splitSlider:instantiate()
    self:addChild(self.splitSlider)
    self.splitSlider:setValues(1, self.max, 1, 0)
    self.splitSlider:setCurrentValue(half)

    self.ok = ISButton:new(80, 65, 40, 20, "OK", self, self.onOK)
    self.ok:initialise()
    self.ok:instantiate()
    self:addChild(self.ok)
end

function ItemGridStackSplitWindow:onSplitSliderChange()
    self.countLabel:setName(tostring(self.splitSlider:getCurrentValue()) .. " / "..tostring(self.max))
end

function ItemGridStackSplitWindow:onOK()
    local vanillaStack = self.vanillaStack
    local targetX = self.targetX
    local targetY = self.targetY
    local isRotated = self.isRotated

    local dragInventory = vanillaStack.items[1]:getContainer()
    local isSameInventory = self.grid.inventory == dragInventory
    if isSameInventory then
        local gridStack = self.grid:findStackByItem(vanillaStack.items[1])
        if gridStack and self.grid:willStackOverlapSelf(gridStack, targetX, targetY, isRotated) then
            self:close()
            return
        end
    end

    local playerObj = getSpecificPlayer(self.playerNum)

    local count = self.splitSlider:getCurrentValue()

    if isSameInventory then
        local containerGrid = ItemContainerGrid.Create(self.grid.inventory, self.playerNum)
        for i=2, count+1 do
            local item = vanillaStack.items[i]
            if self.grid:canAddItemAt(item, targetX, targetY, isRotated) and containerGrid:removeItem(item) then
                self.grid:insertItem(item, targetX, targetY, isRotated)
            else
                break
            end
        end
    else
        for i=2, count+1 do
            local action = ISInventoryTransferAction:new(playerObj, vanillaStack.items[i], dragInventory, self.grid.inventory, 1)
            action:setTetrisTarget(targetX, targetY, self.grid.gridIndex, isRotated)
            ISTimedActionQueue.add(action)
        end
    end

    self:close()
end