--***********************************************************
--**               LEMMY/ROBERT JOHNSON                    **
--***********************************************************

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISMouseDrag"
require "TimedActions/ISTimedActionQueue"
require "TimedActions/ISEatFoodAction"



TestPanel = ISPanel:derive("TestPanel");

TestPanel.MAX_ITEMS_IN_STACK_TO_RENDER = 50

function TestPanel:render()
    ISPanel.render(self)
    self:drawRect(self:getWidth() - 12, 0, 12, 12, 0.5, 1, 1, 1);


end

function TestPanel:initialise()
	ISPanel.initialise(self);
end

function TestPanel:new (x, y, width, height, inventory, zoom)
	local o = ISPanel:new(x, y, width, height);
	setmetatable(o, self)
    self.__index = self

	o.x = x;
	o.y = y;
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.5};
	o.width = width;
	o.height = height;

	o.inventory = inventory;
    o.zoom = zoom;
    return o
end
