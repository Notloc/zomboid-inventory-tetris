require "IS/UI/ISPanel"

EquipmentSlot = ISPanel:derive("EquipmentSlot");

function EquipmentSlot:new (x, y, bodyLocation, playerNum)
	local o = {}
	o = ISPanel:new(x, y, 34, 34);
	setmetatable(o, self)
    self.__index = self
	o.x = x;
	o.y = y;

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.95};

    o.bodyLocation = bodyLocation;
    o.playerNum = playerNum;

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
end

function EquipmentSlot:render()
    if not self.item then
        return
    end
    
    -- draw the item texture

    self:drawTexture(self.item:getTex(), 1, 1, 1, self.getItemColor(self.item));

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