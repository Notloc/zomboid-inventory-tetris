require("ISUI/ISPanel")
require("ISUI/ISButton")
require("ISUI/ISInventoryPane")
require("ISUI/ISResizeWidget")
require("ISUI/ISMouseDrag")
require("ISUI/ISLayoutManager")
require("defines")

---@class Window : ISPanel
local Window =  ISPanel:derive("Window");

function Window:new(x, y, width, height, title, playerNum)
	local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self

    o.player = playerNum or 0;
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.anchorLeft = true;

    o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");
    o.infoBtn = getTexture("media/ui/Panel_info_button.png");
    o.statusbarbkg = getTexture("media/ui/Panel_StatusBar.png");
    o.resizeimage = getTexture("media/ui/Panel_StatusBar_Resize.png");
    o.invbasic = getTexture("media/ui/Icon_InventoryBasic.png");
    o.closebutton = getTexture("media/ui/Dialog_Titlebar_CloseIcon.png");
    o.collapsebutton = getTexture("media/ui/Panel_Icon_Collapse.png");
    o.pinbutton = getTexture("media/ui/Panel_Icon_Pin.png");

    o.highlightColors = {r=0.98,g=0.56,b=0.11};

    o.pin = true;
    o.isCollapsed = false;
    o.collapseCounter = 0;
	o.title = title
	o.titleFont = UIFont.Small
	o.titleFontHgt = getTextManager():getFontHeight(o.titleFont)
   return o
end

function Window:initialise()
	ISPanel.initialise(self);
end

function Window:titleBarHeight(selected)
	return math.max(16, self.titleFontHgt + 1)
end

function Window:createChildren()
    self.minimumHeight = 50;
    self.minimumWidth = 50

    local titleBarHeight = self:titleBarHeight()
    local closeBtnSize = titleBarHeight

    -- Do corner x + y widget
	local resizeWidget = ISResizeWidget:new(self.width-10, self.height-10, 10, 10, self);
	resizeWidget:initialise();
	self:addChild(resizeWidget);

	self.resizeWidget = resizeWidget;

    -- Do bottom y widget
    resizeWidget = ISResizeWidget:new(0, self.height-10, self.width-10, 10, self, true);
    resizeWidget.anchorLeft = true;
    resizeWidget.anchorRight = true;
    resizeWidget:initialise();
    self:addChild(resizeWidget);

    self.resizeWidget2 = resizeWidget;

    self.closeButton = ISButton:new(3, 0, closeBtnSize, closeBtnSize, "", self, Window.onCloseButton);
    self.closeButton:initialise();
    self.closeButton.borderColor.a = 0.0;
    self.closeButton.backgroundColor.a = 0;
    self.closeButton.backgroundColorMouseOver.a = 0;
    self.closeButton:setImage(self.closebutton);
    self:addChild(self.closeButton);

    self.pinButton = ISButton:new(self.width - closeBtnSize - 3, 0, closeBtnSize, closeBtnSize, "", self, Window.setPinned);
    self.pinButton.anchorRight = true;
    self.pinButton.anchorLeft = false;

    self.pinButton:initialise();
    self.pinButton.borderColor.a = 0.0;
    self.pinButton.backgroundColor.a = 0;
    self.pinButton.backgroundColorMouseOver.a = 0;
end

function Window:prerender()
    local titleBarHeight = self:titleBarHeight()

    local height = self:getHeight();
    if self.isCollapsed then
        height = titleBarHeight;
    end

	self:drawRect(0, 0, self:getWidth(), height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, titleBarHeight - 2, 1, 1, 1, 1);
    self:drawRectBorder(0, 0, self:getWidth(), titleBarHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.title then
        self:drawText(self.title, self.closeButton:getRight() + 1, 0, 1,1,1,1);
    end
end

function Window:onCloseButton()
    self:close()
end

function Window:close()
	ISPanel.close(self)
	if JoypadState.players[self.player+1] then
		setJoypadFocus(self.player, nil)
		local playerObj = getSpecificPlayer(self.player)
		playerObj:setBannedAttacking(false)
	end
end

function Window:render()
	local titleBarHeight = self:titleBarHeight()
    local height = self:getHeight();
    if self.isCollapsed then
        height = titleBarHeight
    end

    self:drawRectBorder(0, 0, self:getWidth(), height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
end

function Window:onMouseMove(dx, dy)
	self.mouseOver = true;
	if self.moving then
		self:setX(self.x + dx);
		self:setY(self.y + dy);
    end
end

function Window:onMouseMoveOutside(dx, dy)
	self.mouseOver = false;
	if self.moving then
		self:setX(self.x + dx);
		self:setY(self.y + dy);
    end
end

function Window:onMouseUp(x, y)
	self.moving = false;
	self:setCapture(false);
end

function Window:onMouseDown(x, y)
	getSpecificPlayer(self.player):nullifyAiming();

	self.downX = self:getMouseX();
	self.downY = self:getMouseY();
	self.moving = true;
	self:setCapture(true);
end

function Window:onMouseUpOutside(x, y)
	self.moving = false;
	self:setCapture(false);
end

return Window
