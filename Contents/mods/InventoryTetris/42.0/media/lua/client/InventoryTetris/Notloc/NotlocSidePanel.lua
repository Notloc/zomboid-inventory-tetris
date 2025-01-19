local SETTINGS = require("InventoryTetris/Settings")

local POPOUT_TEX = getTexture("media/textures/InventoryTetris/SidePanel/popout.png")
local ATTACH_TEX = getTexture("media/textures/InventoryTetris/SidePanel/attach.png")
local CLOSE_TEX = getTexture("media/textures/InventoryTetris/SidePanel/close.png")
local COLLAPSE_TEX = getTexture("media/ui/Panel_Icon_Collapse.png");
local PIN_TEX = getTexture("media/ui/Panel_Icon_Pin.png");

local function getLayoutModData(layoutId, playerObj, isController)
    local postfix = isController and "_controller" or ""
    local modData = playerObj:getModData()[layoutId..postfix];
    if not modData then
        modData = {
            isDocked = true,
            isClosed = false
        };
        playerObj:getModData()[layoutId..postfix] = modData;
    end
    return modData;
end

NotlocSidePanel = ISPanel:derive("NotlocSidePanel");

function NotlocSidePanel:new(title, layoutId, width, inventoryPane, playerNum)
	local o = {};
	o = ISPanel:new(0, 0, width, inventoryPane.parent:getHeight());
	setmetatable(o, self);
    self.__index = self;

    o.title = title;
    o.layoutId = layoutId;
    o.inventoryPane = inventoryPane
    o.playerNum = playerNum

	o.char = getSpecificPlayer(playerNum);
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};

    o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");

    local modData = getLayoutModData(layoutId, o.char, o:isController());
    o.isDocked = modData.isDocked;
    o.isClosed = modData.isClosed;

    o.isCollapsed = false;
    o.collapseCounter = 0;
    o.pin = true;

    o.defaultWidth = width;

    return o;
end

function NotlocSidePanel:isController()
    return JoypadState.players[self.playerNum + 1] and JoypadState.players[self.playerNum + 1].isActive
end

function NotlocSidePanel:createChildren()
    ISPanel.createChildren(self);

    local titleBarHeight = self.inventoryPane.parent:titleBarHeight()

    self.popoutButton = ISButton:new(self:getWidth() - 24, 1, 20, titleBarHeight - 2, "", self, self.onPopoutOrAttach);
    self.popoutButton.internal = "POP";
    self.popoutButton.borderColor = {r=0, g=0, b=0, a=0};
    self.popoutButton.backgroundColor = {r=0, g=0, b=0, a=0};
    self.popoutButton:initialise();
    self.popoutButton:instantiate();
    self.popoutButton:setImage(self.isDocked and POPOUT_TEX or ATTACH_TEX);
    self.popoutButton:setAnchorRight(true);
    self.popoutButton:setAnchorTop(true);
    self.popoutButton:setAnchorLeft(false);
    self:addChild(self.popoutButton);

    self.closeButton = ISButton:new(2, 1, 20, titleBarHeight - 2, "", self, self.onClose);
    self.closeButton.internal = "CLOSE";
    self.closeButton.borderColor = {r=0, g=0, b=0, a=0};
    self.closeButton.backgroundColor = {r=0, g=0, b=0, a=0};
    self.closeButton:initialise();
    self.closeButton:instantiate();
    self.closeButton:setImage(CLOSE_TEX);
    self.closeButton:setAnchorRight(false);
    self.closeButton:setAnchorTop(true);
    self.closeButton:setAnchorLeft(true);
    self:addChild(self.closeButton);
    self.closeButton:setVisible(not self.isDocked);

    self.pinButton = ISButton:new(self.width - 42, 0, titleBarHeight, titleBarHeight, "", self, NotlocSidePanel.doPin);
    self.pinButton.anchorRight = true;
    self.pinButton.anchorLeft = false;
    self.pinButton:initialise();
    self.pinButton.borderColor.a = 0;
    self.pinButton.backgroundColor.a = 0;
    self.pinButton.backgroundColorMouseOver.a = 0;
    self.pinButton:setImage(PIN_TEX);
    self:addChild(self.pinButton);
    self.pinButton:setVisible(false);

    self.collapseButton = ISButton:new(self.pinButton:getX(), 0, titleBarHeight, titleBarHeight, "", self, NotlocSidePanel.doCollapse);
    self.collapseButton.anchorRight = true;
    self.collapseButton.anchorLeft = false;
    self.collapseButton:initialise();
    self.collapseButton.borderColor.a = 0;
    self.collapseButton.backgroundColor.a = 0;
    self.collapseButton.backgroundColorMouseOver.a = 0;
    self.collapseButton:setImage(COLLAPSE_TEX);
    self:addChild(self.collapseButton);
    self.collapseButton:setVisible(false);

    if self.playerNum == 0 then
        local postfix = self:isController() and "_controller" or ""
		ISLayoutManager.RegisterWindow(self.layoutId .. postfix, NotlocSidePanel, self)
	end

    --NotlocControllerNode
     --   :injectControllerNode(self, true)
     --   :setChildrenNodeProvider(self.equipmentUi.getControllerNodes, self.equipmentUi)
end

function NotlocSidePanel:prerender()
    -- Side panels have a fixed width
    self:setWidth(self.defaultWidth * SETTINGS.SCALE);

    if self.isDocked and not self.inventoryPane.parent:isVisible() then
        self:setVisible(false);
        return;
    end

    if self.pin or DragAndDrop.isDragging()then
        self:uncollapseWindow();
    end

    local invPage = self.inventoryPane.parent
    if self.isDocked then
        self:setHeight(invPage:getHeight());
        self:setX(invPage:getX() - self:getWidth() + 1);
        self:setY(invPage:getY());
    end
    
    if not self.isCollapsed then
	    ISPanel.prerender(self)
    end

    local titleBarHeight = self.inventoryPane.parent:titleBarHeight()
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, titleBarHeight - 2, 1, 1, 1, 1);
    self:drawRectBorder(0, 0, self:getWidth(), titleBarHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    
    self:drawText(self.title, 24, 0, 1, 1, 1, 1, UIFont.Small);

    if not self.isCollapsed then
        self:drawTextureScaled(self.titlebarbkg, 2, self:getHeight() - 9, self:getWidth() - 4, 9, 1, 1, 1, 1);
        self:drawRectBorder(0, self:getHeight() - 9, self:getWidth(), 9, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    end
end

function NotlocSidePanel:render()
    ISPanel.render(self)
    if self.joyfocus then
        self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
        self:drawRectBorder(1, 1, self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
    end
end

function NotlocSidePanel:onInventoryVisibilityChanged(isVisible)
    if not self.isDocked and not self:isController() then return; end
    self:setVisible(isVisible and not self.isClosed);
end

function NotlocSidePanel:onPopoutOrAttach()
    self.isDocked = not self.isDocked;
    self.popoutButton:setImage(self.isDocked and POPOUT_TEX or ATTACH_TEX);
    if not self.isDocked then
        self:setX(self:getX() - 8);
    else
        self:setVisible(self.inventoryPane.parent:isVisible());
    end

    self.closeButton:setVisible(not self.isDocked);

    if self.isDocked then
        self:doPin();
        self.pinButton:setVisible(false);
        self.collapseButton:setVisible(false);
    else
        self.pinButton:setVisible(not self.pin);
        self.collapseButton:setVisible(self.pin);
    end

    local modData = getLayoutModData(self.layoutId, self.char, self:isController());
    modData.isDocked = self.isDocked;
end

function NotlocSidePanel:onClose()
    self.isClosed = true;
    self:setVisible(false);

    local modData = getLayoutModData(self.layoutId, self.char, self:isController());
    modData.isClosed = true;

    self.inventoryPane.parent:bringToTop();
end

function NotlocSidePanel:toggleWindow()
    if self.isClosed or not self:isVisible() then
        self.isClosed = false;
        if self.isDocked or self:isController() then
            self:setVisible(self.inventoryPane.parent:isVisible());
            if self.inventoryPane.parent:isVisible() then
                self.inventoryPane.parent:uncollapse();
            end
        else
            self:setVisible(true);
        end
    else
        self:onClose();
    end

    local modData = getLayoutModData(self.layoutId, self.char, self:isController());
    modData.isClosed = self.isClosed;
end

function NotlocSidePanel:onMouseDown(x, y)
    if self.isDocked then return; end

    -- if over the title bar, then drag the window
    local titleBarHeight = self.inventoryPane.parent:titleBarHeight()
    if y < titleBarHeight then
        self.dragging = true;
        self.dragX = x;
        self.dragY = y;
        return true
    end

    -- if over the bottom bar, and not docked, then resize the window
    if y > self:getHeight() - 9 then
        self.resizing = true;
        self.dragX = x;
        self.dragY = y;
        return true
    end
end

function NotlocSidePanel:onMouseDownOutside(x, y)
    -- check if the mouse is over this window
    if self:isMouseOver() then return; end


    if self.isDocked then
        if self.inventoryPane.parent:isMouseOver() then
            self:uncollapseWindow();
            return
        end
    end
    self:collapseWindow();
end

function NotlocSidePanel:onRightMouseDownOutside(x, y)
    self:onMouseDownOutside(x, y)    
end

function NotlocSidePanel:onMouseUp(x, y)
    self.dragging = false;
    self.resizing = false;
end

function NotlocSidePanel:onMouseUpOutside(x, y)
    self.dragging = false;
    self.resizing = false;
end

function NotlocSidePanel:onMouseMove(dx, dy)
    local player = getSpecificPlayer(self.playerNum)
    if player:isAiming() then return; end

    if not isMouseButtonDown(0) and not isMouseButtonDown(1) and not isMouseButtonDown(2) then
        self:uncollapseWindow();
    end

    local panCameraKey = getCore():getKey("PanCamera")
    if self.isCollapsed and panCameraKey ~= 0 and isKeyDown(panCameraKey) then
        return
    end

    self.toggleElement:bringToTop();

    if self.dragging then
        self:setX(self:getX() + dx);
        self:setY(self:getY() + dy);
        return true
    end

    if self.resizing then
        local newHeight = self:getHeight() + dy
        if newHeight < 100 then newHeight = 100; end
        self:setHeight(newHeight);
        return true
    end
end

function NotlocSidePanel:onMouseMoveOutside(dx, dy)
    if not DragAndDrop.isDragging() and not self.pin then
        self.collapseCounter = self.collapseCounter + getGameTime():getMultiplier() / 0.8;

        local playerObj = getSpecificPlayer(self.playerNum)
        if playerObj and playerObj:isAiming() then
            self.collapseCounter = 1000
        end

        if self.collapseCounter > 120 and not self.isCollapsed then
            self:collapseWindow();
        end
    end

    if self.dragging then
        self:setX(self:getX() + dx);
        self:setY(self:getY() + dy);
        return true
    end

    if self.resizing then
        local newHeight = self:getHeight() + dy
        if newHeight < 100 then newHeight = 100; end
        self:setHeight(newHeight);
        return true
    end
end

function NotlocSidePanel:collapseWindow()
    self.isCollapsed = true;
    self:setMaxDrawHeight(self.inventoryPane.parent:titleBarHeight());
end

function NotlocSidePanel:uncollapseWindow()
    self.isCollapsed = false;
    self:clearMaxDrawHeight();
    self.collapseCounter = 0;
end

function NotlocSidePanel:doPin()
    self.pin = true

    if not self.isDocked then
        self.pinButton:setVisible(false)
        self.collapseButton:setVisible(true)
    end
end

function NotlocSidePanel:doCollapse()
    if self.isDocked then return; end

    self.pin = false
    self.pinButton:setVisible(true)
    self.collapseButton:setVisible(false)
end

function NotlocSidePanel:RestoreLayout(name, layout)
    ISLayoutManager.DefaultRestoreWindow(self, layout)
    if layout.pin == 'true' or layout.pin == nil then
        self:doPin()
    else
        self:doCollapse()
        self:collapseWindow()
    end
end

function NotlocSidePanel:SaveLayout(name, layout)
    if self.pin then layout.pin = 'true' else layout.pin = 'false' end
    ISLayoutManager.DefaultSaveWindow(self, layout)
end

-- Controller Window focus handling
function NotlocSidePanel:onJoypadDirLeft(joypadData)
    setJoypadFocus(self.playerNum, getPlayerLoot(self.playerNum));
end

function NotlocSidePanel:onJoypadDirRight(joypadData)
    setJoypadFocus(self.playerNum, getPlayerInventory(self.playerNum));
end

function NotlocSidePanel:onJoypadDown(button)


end


function NotlocSidePanel:addToInventoryPage(inventoryPage)
    local sidePanelButtons = inventoryPage.notlocSidePanelButtons or {}
    local last = sidePanelButtons[#sidePanelButtons] or {}
    local y = (last.offsetY or inventoryPage:titleBarHeight()) + inventoryPage:titleBarHeight()

    local toggleButton = NotlocSidePanelToggle:new(y, self, self.buttonTexture, self.inventoryPane)
    toggleButton:initialise()
    toggleButton:addToUIManager()

    self:initialise()
    self:addToUIManager()

    inventoryPage.notlocSidePanelButtons = sidePanelButtons
end
