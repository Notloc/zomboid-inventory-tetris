require "IS/UI/ISPanel"

EquipmentSlot = ISPanel:derive("EquipmentSlot");

function EquipmentSlot:new(x, y, bodyLocation, inventoryPane, playerNum)
	local o = {}
	o = ISPanel:new(x, y, 34, 34);
	setmetatable(o, self)
    self.__index = self
	o.x = x;
	o.y = y;

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.95};

    o.bodyLocation = bodyLocation;
    o.inventoryPane = inventoryPane;
    o.playerNum = playerNum;
    
    o.bodyLocationGroup = getSpecificPlayer(playerNum):getWornItems():getBodyLocationGroup();

	return o;
end

function EquipmentSlot:initialise()
    ISPanel.initialise(self);
end

function EquipmentSlot:setItem(item)
    self.item = item;
end

function EquipmentSlot:clearItem()
    self.item = nil;
end

function EquipmentSlot:prerender()
    ISPanel.prerender(self);
    
    local dragItem = TetrisDragUtil.getDraggedItem();
    if dragItem and dragItem ~= self.item then
        local bodyLocation = TetrisEquipmentUtil.getBodyLocationFromItem(dragItem);
        local conflicts = self.bodyLocationGroup:isExclusive(bodyLocation, self.bodyLocation)
        if conflicts then
            self:drawRect(1, 1, self.width-2, self.height-2, 0.5, 1, 0, 0);
        end
    end

end

function EquipmentSlot:render()
    if not self.item then
        return
    end
    
    local alpha = 1
    if self.item == TetrisDragUtil.getDraggedItem() then
        alpha = 0.5
    end

    self:drawTexture(self.item:getTex(), 1, 1, alpha, self.getItemColor(self.item));
    if self:isMouseOver() then
        self.inventoryPane:doTooltipForItem(self.item);
    end
end

function EquipmentSlot.getItemColor(item)
    if not item or not item:allowRandomTint() then
        return 1,1,1
    end

    local colorInfo = item:getColorInfo()
    local r = colorInfo:getR()
    local g = colorInfo:getG()
    local b = colorInfo:getB()
    
    -- Limit how dark the item can appear if all colors are close to 0
    local limit = 0.2
    while r < limit and g < limit and b < limit do
        r = r + limit / 4
        g = g + limit / 4
        b = b + limit / 4
    end
    return r,g,b
end

function EquipmentSlot:onRightMouseUp(x, y)
    if self.item then
        TetrisUiUtil.openItemContextMenu(self, x, y, self.item, self.playerNum);
    end
end

function EquipmentSlot:onMouseDown(x, y)
    if self.item then
        TetrisDragUtil.prepareDrag(self, ItemGridUtil.itemToNewStack(self.item), x, y);
    end
end

function EquipmentSlot:onMouseMove(dx, dy)
    TetrisDragUtil.startDrag(self);
end

function EquipmentSlot:onMouseMoveOutside(dx, dy)
    TetrisDragUtil.startDrag(self);
end

function EquipmentSlot:onMouseUp(x, y)
    TetrisDragUtil.endDrag();
end

function EquipmentSlot:onMouseUpOutside(x, y)
    TetrisDragUtil.cancelDrag(self);
end