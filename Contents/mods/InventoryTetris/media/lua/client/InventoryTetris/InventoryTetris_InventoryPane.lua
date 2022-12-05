require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISMouseDrag"
require "TimedActions/ISTimedActionQueue"
require "TimedActions/ISEatFoodAction"

require "ISUI/ISInventoryPane"

ISInventoryPane.MAX_ITEMS_IN_STACK_TO_RENDER = 50

function ISInventoryPane:initialise()
    ISPanel.initialise(self);
end

function ISInventoryPane:createChildren()
    local fontHgtSmall = getTextManager():getFontHeight(UIFont.Small)

    self.minimumHeight = 50;
    self.minimumWidth = 256;

    self.expandAll = ISButton:new(0, 0, 15, 17, "", self, ISInventoryPane.expandAll);
    self.expandAll:initialise();
    self.expandAll.borderColor.a = 0.0;
  --  self.expandAll.backgroundColorMouseOver.a = 0;
    self.expandAll:setImage(self.expandicon);

    self:addChild(self.expandAll);

    self.column2 = 48; --math.ceil(self.column2*self.zoom);
    self.column3 = math.ceil(self.column3*self.zoom);
    self.column3 = self.column3 + 100;

    local categoryWid = math.max(100,self.column4-self.column3-1)
    if self.column3 - 1 + categoryWid > self.width then
        self.column3 = self.width - categoryWid + 1
    end

    self.collapseAll = ISButton:new(15, 0, 15, 17, "", self, ISInventoryPane.collapseAll);
    self.collapseAll:initialise();
    self.collapseAll.borderColor.a = 0.0;
   -- self.collapseAll.backgroundColorMouseOver.a = 0;
    self.collapseAll:setImage(self.collapseicon);
    self:addChild(self.collapseAll);

    self.filterMenu = ISButton:new(30, 0, 15, 17, "", self, ISInventoryPane.onFilterMenu);
    self.filterMenu:initialise();
    self.filterMenu.borderColor.a = 0.0;
    -- self.collapseAll.backgroundColorMouseOver.a = 0;
    self.filterMenu:setImage(self.filtericon);
    self:addChild(self.filterMenu);

    self.headerHgt = fontHgtSmall + 1

    self.nameHeader = ISResizableButton:new(self.column2, 0, (self.column3 - self.column2), self.headerHgt, getText("IGUI_invpanel_Type"), self, ISInventoryPane.sortByName);
    self.nameHeader:initialise();
    self.nameHeader.borderColor.a = 0.2;
    self.nameHeader.minimumWidth = 100
    self.nameHeader.onresize = { ISInventoryPane.onResizeColumn, self, self.nameHeader }
    self:addChild(self.nameHeader);

    self.typeHeader = ISResizableButton:new(self.column3-1, 0, self.column4 - self.column3 + 1, self.headerHgt, getText("IGUI_invpanel_Category"), self, ISInventoryPane.sortByType);
    self.typeHeader.borderColor.a = 0.2;
    self.typeHeader.anchorRight = true;
    self.typeHeader.minimumWidth = 100
    self.typeHeader.resizeLeft = true
    self.typeHeader.onresize = { ISInventoryPane.onResizeColumn, self, self.typeHeader }
    self.typeHeader:initialise();
    self:addChild(self.typeHeader);

    local btnWid = 10 -- proper width set by setWidthToTitle() later
    local btnHgt = self.itemHgt
    self.contextButton1 = ISButton:new(0, 0, btnWid, btnHgt, getText("ContextMenu_Grab"), self, ISInventoryPane.onContext);
    self.contextButton1:initialise();
    self:addChild(self.contextButton1);
    self.contextButton1:setFont(self.font)
    self.contextButton1:setVisible(false);
    self.contextButton1.borderColor.a = 0.3;

    self.contextButton2 = ISButton:new(0, 0, btnWid, btnHgt, getText("IGUI_invpanel_Pack"), self, ISInventoryPane.onContext);
    self.contextButton2:initialise();
    self:addChild(self.contextButton2);
    self.contextButton2:setFont(self.font)
    self.contextButton2:setVisible(false);
    self.contextButton2.borderColor.a = 0.3;

    self.contextButton3 = ISButton:new(0, 0, btnWid, btnHgt, getText("IGUI_invpanel_Pack"), self, ISInventoryPane.onContext);
    self.contextButton3:initialise();
    self:addChild(self.contextButton3);
    self.contextButton3:setFont(self.font)
    self.contextButton3:setVisible(false);
    self.contextButton3.borderColor.a = 0.3;


    self:addScrollBars();
end

function ISInventoryPane:onResize()
    ISPanel.onResize(self)
    if self.typeHeader:getWidth() == self.typeHeader.minimumWidth then
        self.column3 = self.width - self.typeHeader:getWidth() + 1
        self.nameHeader:setWidth(self.column3 - self.column2)
        self.typeHeader:setX(self.column3 - 1)
    end
    self.column4 = self.width
end

function ISInventoryPane:onContext(button)

    local playerObj = getSpecificPlayer(self.player)
    local playerInv = playerObj:getInventory();
    local lootInv = getPlayerLoot(self.player).inventory;


    if button.mode == "unpack" then
        local k = self.items[self.buttonOption];
        local items = ISInventoryPane.getActualItems({k})
        ISInventoryPaneContextMenu.onMoveItemsTo(items, playerInv, self.player)
    end
    if button.mode == "grab" then
        local k = self.items[self.buttonOption];
        local items = ISInventoryPane.getActualItems({k})
        if isForceDropHeavyItem(items[1]) then
            ISInventoryPaneContextMenu.equipHeavyItem(playerObj, items[1])
            return
        end
        ISInventoryPaneContextMenu.onGrabItems(items, self.player)
    end
    if button.mode == "grab1" then
        local k = self.items[self.buttonOption];
        local items = ISInventoryPane.getActualItems({k})
        ISInventoryPaneContextMenu.onGrabOneItems(items, self.player)
    end
    if button.mode == "drop" then
        local k = self.items[self.buttonOption];
        local items = ISInventoryPane.getActualItems({k})
        ISInventoryPaneContextMenu.onDropItems(items, self.player)
    end
    if button.mode == "drop1" then
        local k = self.items[self.buttonOption];
        local items = ISInventoryPane.getActualItems({k})
        ISInventoryPaneContextMenu.onDropItems({items[1]}, self.player)
    end
    if button.mode == "place" then
        local k = self.items[self.buttonOption];
        local items = ISInventoryPane.getActualItems({k})
        local mo = ISMoveableCursor:new(getSpecificPlayer(self.player))
        getCell():setDrag(mo, mo.player)
        mo:setMoveableMode("place")
        mo:tryInitialItem(items[1])
    end

    getPlayerLoot(self.player).inventoryPane.selected = {};
    getPlayerInventory(self.player).inventoryPane.selected = {};
end


function ISInventoryPane:prerender()
    local mouseY = self:getMouseY()
    self:updateSmoothScrolling()
    if mouseY ~= self:getMouseY() and self:isMouseOver() then
        self:onMouseMove(0, self:getMouseY() - mouseY)
    end

    self.nameHeader.maximumWidth = self.width - self.typeHeader.minimumWidth - self.column2
    self.typeHeader.maximumWidth = self.width - self.nameHeader.minimumWidth - self.column2 + 1
    --self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
--  self:drawRectStatic(0, 0, self.width, 1, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
--  self:drawRectStatic(0, self.height-1, self.width, 1, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
--  self:drawRectStatic(0, 0, 1, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
--  self:drawRectStatic(0+self.width-1, 0, 1, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:setStencilRect(0,0,self.width-1, self.height-1);

    self:renderGrid();

    self:updateScrollbars();

end

function ISInventoryPane:render()
    if self.mode == "icons" then
        self:rendericons();
    elseif self.mode == "details" then
        self:renderdetails(true);
    end

    self:clearStencilRect();

    --self:clearStencilRect();

    local resize = self.nameHeader.resizing or self.nameHeader.mouseOverResize
    if not resize then
        resize = self.typeHeader.resizing or self.typeHeader.mouseOverResize
    end
    if resize then
        self:repaintStencilRect(self.nameHeader:getRight() - 1, self.nameHeader.y, 2, self.height)
        self:drawRectStatic(self.nameHeader:getRight() - 1, self.nameHeader.y, 2, self.height, 0.5, 1, 1, 1)
    end
end

local cellSize = 48
local width = 8
local height = 8

function ISInventoryPane:renderGrid()
    for y = 0,height-1 do
        for x = 0,width-1 do
            self:drawRectBorder(cellSize * x, cellSize * y, cellSize, cellSize, 0.5, 1, 1, 1)
        end
    end
    self:drawText(tostring(self.inventory["ID"]), 20, 20, 1, 1, 1, 0.5, UIFont.Small);
end

ISInventoryPaneX = {}
function ISInventoryPaneX:new (x, y, width, height, inventory, zoom)
    local o = {}
    --o.data = {}
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.x = x;
    o.y = y;
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.5};
    o.width = width;
    o.height = height;
    o.anchorLeft = true;
    o.anchorRight = false;
    o.anchorTop = true;
    o.anchorBottom = false;
    o.inventory = inventory;
    o.zoom = zoom;
    o.mode = "details";
    o.column2 = 30;
    o.column3 = 140;
    o.column4 = o.width;
    o.items = {}
    o.selected = {}
    o.previousMouseUp = nil;
    local font = getCore():getOptionInventoryFont()
    if font == "Large" then
        o.font = UIFont.Large
    elseif font == "Small" then
        o.font = UIFont.Small
    else
        o.font = UIFont.Medium
    end
    if zoom > 1.5 then
        o.font = UIFont.Large;
    end
    o.fontHgt = getTextManager():getFontFromEnum(o.font):getLineHeight()
    o.itemHgt = math.ceil(math.max(18, o.fontHgt) * o.zoom)
    o.texScale = math.min(32, (o.itemHgt - 2)) / 32
    o.draggedItems = DraggedItems:new(o)

    o.treeexpicon = getTexture("media/ui/TreeExpanded.png");
    o.treecolicon = getTexture("media/ui/TreeCollapsed.png");
    o.expandicon = getTexture("media/ui/TreeExpandAll.png");
    o.filtericon = getTexture("media/ui/TreeFilter.png");
    o.collapseicon = getTexture("media/ui/TreeCollapseAll.png");
    o.equippedItemIcon = getTexture("media/ui/icon.png");
    o.equippedInHotbar = getTexture("media/ui/iconInHotbar.png");
    o.brokenItemIcon = getTexture("media/ui/icon_broken.png");
    o.frozenItemIcon = getTexture("media/ui/icon_frozen.png");
    o.poisonIcon = getTexture("media/ui/SkullPoison.png");
    o.itemSortFunc = ISInventoryPane.itemSortByNameInc; -- how to sort the items...
    o.favoriteStar = getTexture("media/ui/FavoriteStar.png");
   return o
end
