require("ISUI/ISCollapsableWindow")
local ItemContainerGrid = require("InventoryTetris/Model/ItemContainerGrid")
local OPT = require("InventoryTetris/Settings")

---@class ItemGridStackSplitWindow : ISCollapsableWindow
---@field public grid ItemGrid
---@field public vanillaStack VanillaStack
---@field public targetX integer
---@field public targetY integer
---@field public isRotated boolean
---@field public playerNum integer
local ItemGridStackSplitWindow = ISCollapsableWindow:derive("ItemGridStackSplitWindow");
ItemGridStackSplitWindow.__index = ItemGridStackSplitWindow

---@param grid ItemGrid
---@param vanillaStack VanillaStack
---@param x integer
---@param y integer
---@param r boolean
---@param playerNum integer
function ItemGridStackSplitWindow:new(grid, vanillaStack, x, y, r, playerNum)
    local scale = OPT.SCALE
    if scale < 1 then
        scale = 1
    end

    ---@type ItemGridStackSplitWindow
    local o = ISCollapsableWindow:new(0, 0, 275 * scale, 75 + 50 * scale)
    setmetatable(o, self)

    o.grid = grid
    o.vanillaStack = vanillaStack
    o.targetX = x
    o.targetY = y
    o.isRotated = r
    o.playerNum = playerNum

    o.title = "Split Stack"

    return o
end

function ItemGridStackSplitWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    local scale = OPT.SCALE
    if scale < 1 then
        scale = 1
    end

    self.max = #self.vanillaStack.items - 1 -- minus 1 because the first item is fake
    local half = math.floor(self.max / 2)

    local width = self.width
    local height = self.height

    local yPadding = 10 + 5 * scale

    self.countLabel = ISLabel:new(width/2, yPadding, 40, tostring(half) .. " / "..tostring(self.max), 1, 1, 1, 1, UIFont.Medium, true)
    self.countLabel:initialise()
    self.countLabel:instantiate()
    self.countLabel.center = true
    self:addChild(self.countLabel)


    local sliderHeight = 20 * scale
    local xPadding = 15 * scale
    yPadding = height/2 - sliderHeight/2 + 4
    

    self.splitSlider = ISSliderPanel:new(xPadding, yPadding, width - 2*xPadding, sliderHeight, self, self.onSplitSliderChange)
    self.splitSlider:initialise()
    self.splitSlider:instantiate()
    self:addChild(self.splitSlider)
    self.splitSlider:setValues(1, self.max, 1, 0)
    self.splitSlider:setCurrentValue(half)

    local buttonW = 30 * scale
    yPadding = 12 + 20 * scale

    self.ok = ISButton:new(width/2 - buttonW/2, height - yPadding, buttonW, 20, "OK", self, self.onOK)
    self.ok:initialise()
    self.ok:instantiate()
    self.ok.font = UIFont.Medium
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

    local frontItem = vanillaStack.items[1]
    if not frontItem then
        self:close()
        return
    end

    local dragInventory = frontItem:getContainer()
    local isSameInventory = self.grid.inventory == dragInventory
    if isSameInventory then
        local gridStack = self.grid:findStackByItem(frontItem)
        if gridStack and self.grid:willStackOverlapSelf(gridStack, targetX, targetY, isRotated) then
            self:close()
            return
        end
    end

    local playerObj = getSpecificPlayer(self.playerNum)

    local count = self.splitSlider:getCurrentValue()

    if isSameInventory then
        local containerGrid = ItemContainerGrid.GetOrCreate(self.grid.inventory, self.playerNum)
        for i=2, count+1 do
            local item = vanillaStack.items[i]
            if item and self.grid:canAddItemAt(item, targetX, targetY, isRotated) and containerGrid:removeItem(item) then
                self.grid:insertItem(item, targetX, targetY, isRotated)
            else
                break
            end
        end
    else
        for i=2, count+1 do
            local item = vanillaStack.items[i]
            if item then
                local action = ISInventoryTransferAction:new(playerObj, item, dragInventory, self.grid.inventory)
                action:setTetrisTarget(targetX, targetY, self.grid.gridIndex, isRotated, self.grid.secondaryTarget)
                ISTimedActionQueue.add(action)
            end
        end
    end

    self:close()
end

return ItemGridStackSplitWindow
