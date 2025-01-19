require("ISUI/ISUIElement")

NotlocSidePanelToggle = ISUIElement:derive("NotlocSidePanelToggle");

function NotlocSidePanelToggle:new(yOffset, notlocSidePanel, texture, inventoryPane)
	local o = {};
	o = ISUIElement:new(0, 0, 16, 20);
	setmetatable(o, self);
    self.__index = self;

    o.yOffset = yOffset
    o.texture = texture
    o.notlocSidePanel = notlocSidePanel
    o.inventoryPane = inventoryPane

    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}

    notlocSidePanel.toggleElement = o

    return o;
end

function NotlocSidePanelToggle:createChildren()
    ISUIElement.createChildren(self);

    self.toggleButton = ISButton:new(0, 0, self.width, self.height, "", self, self.onToggleEquipmentUiWindow)
    self.toggleButton:initialise()
    self.toggleButton.image = self.texture

    self.toggleButton:setAnchorLeft(true)
    self.toggleButton:setAnchorRight(true)
    self.toggleButton:setAnchorTop(true)
    self.toggleButton:setAnchorBottom(true)
    self.toggleButton:setImage(self.texture)
    self.toggleButton.borderColor = {r=0, g=0, b=0, a=0}
    self.toggleButton.backgroundColor = {r=0, g=0, b=0, a=0}

    self.toggleButton:forceImageSize(16, 20)

    self:addChild(self.toggleButton)
    self.toggleButton:bringToTop()
end

function NotlocSidePanelToggle:onToggleEquipmentUiWindow()
	local state = not self.notlocSidePanel:isVisible()
	self.notlocSidePanel:setVisible(state)
    self.notlocSidePanel.isClosed = not state

    if not state then
        self.inventoryPane.parent:bringToTop()
    end
end

function NotlocSidePanelToggle:prerender()
    local invPage = self.inventoryPane.parent

    local targetX = invPage:getX()
    local targetY = invPage:getY() + self.yOffset

    local dockedAndVisible = self.notlocSidePanel.isDocked and self.notlocSidePanel:isVisible()

    if dockedAndVisible or math.abs(getMouseX() - targetX) + math.abs(getMouseY() - targetY) < 38 then
        self:setWidth(16)
    else
        self:setWidth(6)
    end

    self:setHeight(16);
    self:setX(targetX - self:getWidth());
    self:setY(targetY);

    local invIsVisible = self.inventoryPane.parent:isVisible() and not self.inventoryPane.parent.isCollapsed
    local undockedAndOpen = not self.notlocSidePanel.isDocked and self.notlocSidePanel:isVisible()
    self.toggleButton:setVisible(invIsVisible and not undockedAndOpen)
end
