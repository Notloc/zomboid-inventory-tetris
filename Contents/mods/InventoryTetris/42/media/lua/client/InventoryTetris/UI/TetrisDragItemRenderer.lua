require("ISUI/ISUIElement")
local TetrisItemData = require("InventoryTetris/Data/TetrisItemData")
local OPT = require("InventoryTetris/Settings")

local BG_TEXTURE = getTexture("media/textures/InventoryTetris/ItemSlot.png")

DragItemRenderer = ISUIElement:derive("DragItemRenderer")

function DragItemRenderer:new(equipmentUi, playerNum)
    local o = ISUIElement:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index = self

    o.equipmentUi = equipmentUi
    o.playerNum = playerNum
    return o
end

function DragItemRenderer:prerender()
    self:bringToTop()
end

function DragItemRenderer:render() 
    local stacks = DragAndDrop.getDraggedStacks()
    local item = DragAndDrop.getDraggedItem()
    if not item then
        return
    end

    local x = self:getMouseX()
    local y = self:getMouseY()

    local itemW, itemH = 1, 1

    local force1x1 = self.equipmentUi:isMouseOver()
    if not force1x1 then
        itemW, itemH = TetrisItemData.getItemSize(item, DragAndDrop.isDraggedItemRotated())
    end

    local xPos = x - itemW * OPT.CELL_SIZE / 2
    local yPos = y - itemH * OPT.CELL_SIZE / 2

    local playerObj = getSpecificPlayer(self.playerNum)
    if playerObj:isDead() then
        DragAndDrop.endDrag()
        return
    end

    local stack = ItemStack.createTempStack(item)
    local vanillaStack = DragAndDrop.getDraggedStack()

    stack.count = vanillaStack and vanillaStack.count or 2
    stack.count = stack.count - 1

    self:suspendStencil()
    ItemGridUI._renderGridStack(self, playerObj, stack, item, xPos, yPos, itemW, itemH, 1, DragAndDrop.isDraggedItemRotated(), nil, true)

    if stacks and #stacks > 1 then
        self:drawText("+"..tostring(#stacks - 1), xPos + itemW * OPT.CELL_SIZE, yPos, 1, 1, 1, 1, UIFont.Small, true)
    end

    self:resumeStencil()
end