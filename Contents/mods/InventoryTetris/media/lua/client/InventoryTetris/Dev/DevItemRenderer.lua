OPT = require "InventoryTetris/Settings"

DevItemRenderer = ISPanel:derive("DevItemRenderer");

function DevItemRenderer:new(x, y, item, w, h)
    local o = ISPanel:new(x, y, 1, 1);
    setmetatable(o, self);
    self.__index = self;

    o.item = item;
    o.playerNum = playerNum;
    o.w = w;
    o.h = h;

    return o;
end



function DevItemRenderer:updateSize()
    self:setWidth(self.w * OPT.TEXTURE_SIZE);
    self:setHeight(self.h * OPT.TEXTURE_SIZE);
end


function DevItemRenderer:prerender()
    self:updateSize();
    ISPanel.prerender(self);

    local tex = self.item:getTex()
    self:drawTextureScaledAspect(tex, 0, 0, self:getWidth(), self:getHeight(), 1, 1, 1, 1);
end


function DevItemRenderer:render()
end