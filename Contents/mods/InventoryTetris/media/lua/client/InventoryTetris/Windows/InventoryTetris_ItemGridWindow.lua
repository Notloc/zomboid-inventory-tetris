require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"
require "defines"

ItemGridWindow = ISPanel:derive("ItemGridWindow");

ItemGridWindow._globalInstances = {};

ItemGridWindow.getTopWindow = function()
    return ItemGridWindow._globalInstances[#ItemGridWindow._globalInstances];
end

function ItemGridWindow:new (x, y, inventory, inventoryPane, playerNum)
	local o = ISPanel:new(x, y, 100, 100);
    setmetatable(o, self)
    self.__index = self

	o.x = x;
	o.y = y;
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.width = 100;
	o.height = 100;
	o.anchorLeft = true;

	o.inventory = inventory;
    o.inventoryPane = inventoryPane;
    o.playerNum = playerNum;
    o.player = playerNum;

    o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");
    o.infoBtn = getTexture("media/ui/Panel_info_button.png");
    o.statusbarbkg = getTexture("media/ui/Panel_StatusBar.png");
    o.resizeimage = getTexture("media/ui/Panel_StatusBar_Resize.png");
    o.invbasic = getTexture("media/ui/Icon_InventoryBasic.png");
    o.closebutton = getTexture("media/ui/Dialog_Titlebar_CloseIcon.png");
    o.collapsebutton = getTexture("media/ui/Panel_Icon_Collapse.png");
    o.pinbutton = getTexture("media/ui/Panel_Icon_Pin.png");

    o.conDefault = getTexture("media/ui/Container_Shelf.png");
    o.highlightColors = {r=0.98,g=0.56,b=0.11};

    o.containerIconMaps = ContainerButtonIcons
    o.capacity = inventory:getCapacity();

    o.pin = true;
    o.isCollapsed = false;
    o.collapseCounter = 0;
	o.title = inventory:getContainingItem():getName();
	o.titleFont = UIFont.Small
	o.titleFontHgt = getTextManager():getFontHeight(o.titleFont)
	local sizes = { 32, 40, 48 }
	o.buttonSize = sizes[getCore():getOptionInventoryContainerSize()]

    table.insert(ItemGridWindow._globalInstances, o)

   return o
end

function ItemGridWindow:initialise()
	ISPanel.initialise(self);
end

function ItemGridWindow:titleBarHeight(selected)
	return math.max(16, self.titleFontHgt + 1)
end

function ItemGridWindow:createChildren()
    self.minimumHeight = 50;
    self.minimumWidth = 50 + self.buttonSize;

    local titleBarHeight = self:titleBarHeight()
    local closeBtnSize = titleBarHeight
    local lootButtonHeight = titleBarHeight

    local gridContainerUi = ItemGridContainerUI:new(self.inventory, self.inventoryPane, self.playerNum)
    gridContainerUi.showTitle = false
    gridContainerUi:initialise()
    gridContainerUi:setY(titleBarHeight)
    self:addChild(gridContainerUi)
    self.gridContainerUi = gridContainerUi

    self:setWidth(gridContainerUi:getWidth())
    self:setHeight(gridContainerUi:getHeight() + 10 + titleBarHeight)

    local textWid = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_invpage_Transfer_all"))
    local weightWid = getTextManager():MeasureStringX(UIFont.Small, "99.99 / 99")
    self.transferAll = ISButton:new(self.width - 3 - closeBtnSize - math.max(90, weightWid + 10) - textWid, 0, textWid, lootButtonHeight, getText("IGUI_invpage_Transfer_all"), self, ISInventoryPage.transferAll);
    self.transferAll:initialise();
    self.transferAll.borderColor.a = 0.0;
    self.transferAll.backgroundColor.a = 0.0;
    self.transferAll.backgroundColorMouseOver.a = 0.7;
    self:addChild(self.transferAll);
    self.transferAll:setVisible(false);

    if not self.onCharacter then
        self.lootAll = ISButton:new(3 + closeBtnSize * 2 + 1, 0, 50, lootButtonHeight, getText("IGUI_invpage_Loot_all"), self, ItemGridWindow.lootAll);
        self.lootAll:initialise();
        self.lootAll.borderColor.a = 0.0;
        self.lootAll.backgroundColor.a = 0.0;
        self.lootAll.backgroundColorMouseOver.a = 0.7;
        self:addChild(self.lootAll);
        self.lootAll:setVisible(false);
        
        self.removeAll = ISButton:new(self.lootAll:getRight() + 16, 0, 50, lootButtonHeight, getText("IGUI_invpage_RemoveAll"), self, ItemGridWindow.removeAll);
        self.removeAll:initialise();
        self.removeAll.borderColor.a = 0.0;
        self.removeAll.backgroundColor.a = 0.0;
        self.removeAll.backgroundColorMouseOver.a = 0.7;
        self:addChild(self.removeAll);
        self.removeAll:setVisible(false);
    end

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

    self.closeButton = ISButton:new(3, 0, closeBtnSize, closeBtnSize, "", self, ItemGridWindow.onCloseButton);
    self.closeButton:initialise();
    self.closeButton.borderColor.a = 0.0;
    self.closeButton.backgroundColor.a = 0;
    self.closeButton.backgroundColorMouseOver.a = 0;
    self.closeButton:setImage(self.closebutton);
    self:addChild(self.closeButton);

    self.pinButton = ISButton:new(self.width - closeBtnSize - 3, 0, closeBtnSize, closeBtnSize, "", self, ItemGridWindow.setPinned);
    self.pinButton.anchorRight = true;
    self.pinButton.anchorLeft = false;

    self.pinButton:initialise();
    self.pinButton.borderColor.a = 0.0;
    self.pinButton.backgroundColor.a = 0;
    self.pinButton.backgroundColorMouseOver.a = 0;

	self.totalWeight =  ISInventoryPage.loadWeight(self.inventory);
end

function ItemGridWindow:onApplyGridScale(scale)
    self.gridContainerUi:onApplyGridScale(scale)
    self:setWidth(self.gridContainerUi:getWidth())
    self:setHeight(self.gridContainerUi:getHeight() + 10 + self:titleBarHeight())
end

function ItemGridWindow:onApplyContainerInfoScale(scale)
    self.gridContainerUi:onApplyContainerInfoScale(scale)
    self:setWidth(self.gridContainerUi:getWidth())
    self:setHeight(self.gridContainerUi:getHeight() + 10 + self:titleBarHeight())
end

function ItemGridWindow:prerender()
    local titleBarHeight = self:titleBarHeight()
    
    self:setWidth(self.gridContainerUi:getWidth())
    self:setHeight(self.gridContainerUi:getHeight() + 10 + titleBarHeight)

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
    
	local weightWid = 5
    self.transferAll:setX(self.pinButton:getX() - weightWid - getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_invpage_Transfer_all")));
    if not self.onCharacter or self.width < 370 then
        self.transferAll:setVisible(false)
    elseif not "Tutorial" == getCore():getGameMode() then
        self.transferAll:setVisible(true)
    end
    
    -- self:drawRectBorder(self:getWidth()-32, 15, 32, self:getHeight()-16-6, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:setStencilRect(0,0,self.width+1, height);
end

function ItemGridWindow:onCloseButton()
    self:close()
end

function ItemGridWindow:close()
	ISPanel.close(self)
	if JoypadState.players[self.player+1] then
		setJoypadFocus(self.player, nil)
		local playerObj = getSpecificPlayer(self.player)
		playerObj:setBannedAttacking(false)
	end
end

function ItemGridWindow:render()
	local titleBarHeight = self:titleBarHeight()
    local height = self:getHeight();
    if self.isCollapsed then
        height = titleBarHeight
    end
    -- Draw backpack border over backpacks....
    if not self.isCollapsed then
        self:drawRectBorder(0, height-9, self:getWidth(), 9, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
        self:drawTextureScaled(self.statusbarbkg, 2,  height-7, self:getWidth() - 4, 6, 1, 1, 1, 1);
        self:drawTexture(self.resizeimage, self:getWidth()-9, height-8, 1, 1, 1, 1);
    end

    self:clearStencilRect();
    self:drawRectBorder(0, 0, self:getWidth(), height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
end

function ItemGridWindow:onMouseMove(dx, dy)
	self.mouseOver = true;
	if self.moving then
		self:setX(self.x + dx);
		self:setY(self.y + dy);
    end
end

function ItemGridWindow:onMouseMoveOutside(dx, dy)
	self.mouseOver = false;
	if self.moving then
		self:setX(self.x + dx);
		self:setY(self.y + dy);
    end
end

function ItemGridWindow:onMouseUp(x, y)
	self.moving = false;
	self:setCapture(false);
end

function ItemGridWindow:onMouseDown(x, y)
	getSpecificPlayer(self.player):nullifyAiming();

	self.downX = self:getMouseX();
	self.downY = self:getMouseY();
	self.moving = true;
	self:setCapture(true);
end

function ItemGridWindow:onMouseUpOutside(x, y)
	self.moving = false;
	self:setCapture(false);
end

local og_removeFromUIManager = ISPanel.removeFromUIManager
function ItemGridWindow:removeFromUIManager()
    og_removeFromUIManager(self)

    for i,v in ipairs(ItemGridWindow._globalInstances) do
        if v == self then
            table.remove(ItemGridWindow._globalInstances, i)
            break
        end
    end
end

local og_bringToTop = ISPanel.bringToTop
function ItemGridWindow:bringToTop()
    og_bringToTop(self)

    for i,v in ipairs(ItemGridWindow._globalInstances) do
        if v == self then
            table.remove(ItemGridWindow._globalInstances, i)
            break
        end
    end
    table.insert(ItemGridWindow._globalInstances, self)
end
