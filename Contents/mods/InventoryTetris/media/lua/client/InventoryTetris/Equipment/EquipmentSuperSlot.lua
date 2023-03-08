require "IS/UI/ISPanel"
local c = require "InventoryTetris/Equipment/EquipmentConstants"
local BG_TEXTURE = getTexture("media/textures/InventoryTetris/ItemSlot.png")
local SUB_ITEM_WIDTH = 12

local MAX_COLUMN = 3
local MINI_ICON_SCALE = 0.375
local MINI_ICON_SIZE = 32 * MINI_ICON_SCALE

EquipmentSuperSlot = ISPanel:derive("EquipmentSuperSlot");

function EquipmentSuperSlot:new(slotDefinition, inventoryPane, playerNum)
	local o = ISPanel:new(50, 50, c.SUPER_SLOT_SIZE + SUB_ITEM_WIDTH, c.SUPER_SLOT_SIZE);
	setmetatable(o, self)
    self.__index = self

    if slotDefinition.position then
        o:setX(slotDefinition.position.x);
        o:setY(slotDefinition.position.y);
    end

    o.slotDefinition = slotDefinition;
    o.inventoryPane = inventoryPane;
    o.playerNum = playerNum;
	o.moveWithMouse = true;

    o.slots = {}
    o.mouseDownX = 0;
    o.mouseDownY = 0;

    o.bodyLocationGroup = getSpecificPlayer(playerNum):getWornItems():getBodyLocationGroup();

	return o;
end

function EquipmentSuperSlot:initialise()
    ISPanel.initialise(self);
end

function EquipmentSuperSlot:createChildren()
    for _, bodyLocation in ipairs(self.slotDefinition.bodyLocations) do
        local slot = EquipmentSlot:new(0, 0, bodyLocation, self.inventoryPane, self.playerNum);
        slot:initialise();
        slot:setVisible(false);
        self:addChild(slot);
        self.slots[bodyLocation] = slot;
    end
end

function EquipmentSuperSlot:setItem(item, bodyLocation)
    if self.slots[bodyLocation] then
        self.slots[bodyLocation]:setItem(item);
    end
end

function EquipmentSuperSlot:clearItem()
    for _, slot in pairs(self.slots) do
        slot:clearItem();
    end
end

function EquipmentSuperSlot:hasItem()
    return self:getTopItem() ~= nil
end

function EquipmentSuperSlot:getTopItem()
    for _, slot in pairs(self.slots) do
        if slot.item then
            return slot.item;
        end
    end
    return nil;
end

function EquipmentSuperSlot:getNthItem(index)
    local count = 0;
    for _, slot in pairs(self.slots) do
        if slot.item then
            count = count + 1;
            if count == index then
                return slot.item;
            end
        end
    end
    return nil;
end

function EquipmentSuperSlot:getItemCount()
    local count = 0
    for _, slot in pairs(self.slots) do
        if slot.item then
            count = count + 1;
        end
    end
    return count
end

function EquipmentSuperSlot:doesItemConflict(item)
    local bodyLocation = TetrisEquipmentUtil.getBodyLocationFromItem(item);
    if not bodyLocation or bodyLocation == '' then return false end

    for _, slot in pairs(self.slots) do
        if slot.item and slot.item ~= item and self.bodyLocationGroup:isExclusive(bodyLocation, slot.bodyLocation) then
            return true
        end
    end
    return false
end

function EquipmentSuperSlot:draggingMyItem()
    local dragItem = TetrisDragUtil.getDraggedItem();
    if dragItem then
        for _, slot in pairs(self.slots) do
            if slot.item == dragItem then
                return true;
            end
        end
    end
    return false;
end

function EquipmentSuperSlot:prerender()
    local itemCount = self:getItemCount();
    if itemCount > 0 then
        local slotWidth = itemCount > 1 and c.SUPER_SLOT_SIZE + SUB_ITEM_WIDTH or c.SUPER_SLOT_SIZE;
        self:drawRect(0, 0, slotWidth, c.SUPER_SLOT_SIZE, 0.85, 0, 0, 0);
        self:drawTextureScaled(BG_TEXTURE, 0, 0, slotWidth, c.SUPER_SLOT_SIZE, 1, 0.4, 0.4, 0.4);
        self:drawRectBorder(0, 0, slotWidth, c.SUPER_SLOT_SIZE, 1, 1, 1, 1);
    else
        self:drawRect(0, 0, c.SUPER_SLOT_SIZE, c.SUPER_SLOT_SIZE, 0.65, 0, 0, 0);
        self:drawTextureScaled(BG_TEXTURE, 0, 0, c.SUPER_SLOT_SIZE, c.SUPER_SLOT_SIZE, 1, 0.4, 0.4, 0.4);
        self:drawRectBorder(0, 0, c.SUPER_SLOT_SIZE, c.SUPER_SLOT_SIZE, 1, 1, 1, 1);
    end
    
    local dragItem = TetrisDragUtil.getDraggedItem();
    if dragItem then
        local bodyLocation = TetrisEquipmentUtil.getBodyLocationFromItem(dragItem);
        local canAcceptItem = self.slots[bodyLocation] and self.slots[bodyLocation].item ~= dragItem
        local hasConflictingItems = self:doesItemConflict(dragItem)

        local r = hasConflictingItems and 1 or 0
        local g = canAcceptItem and 1 or 0
        if canAcceptItem or hasConflictingItems then
            self:drawRect(1, 1, c.SUPER_SLOT_SIZE-2, c.SUPER_SLOT_SIZE-2, 0.5, r, g, 0);
        end
    end

    if self.expanded and itemCount < 2 then
        self:toggleExpanded();
    end

    if self.expanded then
        self:layoutSlots();

        local slotCount = self.visibleSlots
        local xCount = math.min(slotCount, 3);
        local yCount = math.ceil(slotCount / 3);
        if self.expanded then
            self:suspendStencil();
            self:drawRect(0, c.SUPER_SLOT_SIZE + c.SUPER_SLOT_VERTICAL_OFFSET, c.SLOT_SIZE * xCount + 5 - xCount, yCount * c.SLOT_SIZE + 5 - yCount, 0.9, 0, 0, 0);
            self:drawRectBorder(0, c.SUPER_SLOT_SIZE + c.SUPER_SLOT_VERTICAL_OFFSET, c.SLOT_SIZE * xCount + 5 - xCount, yCount * c.SLOT_SIZE + 5 - yCount, 0.8, 1, 1, 1);
            self:resumeStencil();
        end
    end
end

function EquipmentSuperSlot:layoutSlots()
    self.visibleSlots = 0;
    local column = 0;
    local row = 0;

    if not self.expanded then
        for _, slot in pairs(self.slots) do
            slot:setVisible(self.expanded);
        end
        return
    end

    for _, slot in pairs(self.slots) do
        if slot.item then
            slot:setVisible(true);
            slot:setX(column * c.SLOT_SIZE + 2 - column);
            slot:setY(c.SUPER_SLOT_SIZE + c.SUPER_SLOT_VERTICAL_OFFSET + 2 + row * c.SLOT_SIZE - row);
            
            self.visibleSlots = self.visibleSlots + 1;
            column = column + 1;
            
            if column >= 3 then
                column = 0;
                row = row + 1;
            end
        else
            slot:setVisible(false);
        end
    end
end

function EquipmentSuperSlot:render()
    --if the mouse is over the super slot, draw the name of the slot
    if self:isMouseOver() then
        local width = getTextManager():MeasureStringX(UIFont.Small, self.slotDefinition.name);
        local height = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight();
        self:drawRect      (c.SUPER_SLOT_SIZE / 2 - width / 2 - 3, -height - 4, width + 8, height + 4, 0.9, 0, 0, 0);
        self:drawRectBorder(c.SUPER_SLOT_SIZE / 2 - width / 2 - 3, -height - 4, width + 8, height + 4, 1, 1, 1, 1);
        self:drawTextCentre(self.slotDefinition.name, c.SUPER_SLOT_SIZE / 2, -height - 2, 1, 1, 1, 1, UIFont.Small);
    end

    local itemsToDraw = {};
    
    local index = 1;
    for _, bodyLocation in ipairs(self.slotDefinition.bodyLocations) do
        local slot = self.slots[bodyLocation];
        if slot.item and index <= 4 then
            itemsToDraw[index] = slot.item;
            index = index + 1;
        end
    end

    local count = index - 1

    if count == 0 then
        return
    end

    local xOff = (c.SUPER_SLOT_SIZE - c.TEXTURE_SIZE) / 2;
    local yOff = (c.SUPER_SLOT_SIZE - c.TEXTURE_SIZE) / 2;
    local mainAlpha = 1;
    if itemsToDraw[1] == TetrisDragUtil.getDraggedItem() then
        mainAlpha = 0.5;
    end
    self:drawTexture(itemsToDraw[1]:getTex(), xOff, yOff, mainAlpha, EquipmentSlot.getItemColor(itemsToDraw[1]));
  
    if count > 1 then
        local slotSize = c.SUPER_SLOT_SIZE + SUB_ITEM_WIDTH
        local scaledSize = MINI_ICON_SIZE
        for i = 2, count do
            self:drawRect(slotSize - scaledSize - 1, (scaledSize * (i - 2)), scaledSize+1, scaledSize+1, 0.7, 0, 0, 0);
            self:drawRectBorder(slotSize - scaledSize - 1, (scaledSize * (i - 2)), scaledSize+1, scaledSize+1, 0.4, 1, 1, 1);
            self:drawTextureScaledUniform(itemsToDraw[i]:getTex(), slotSize - scaledSize, yOff + (scaledSize * (i - 2)) - 1, MINI_ICON_SCALE, 1, EquipmentSlot.getItemColor(itemsToDraw[i]));
        end

        self:drawRectBorder(c.SUPER_SLOT_SIZE-1, 0, SUB_ITEM_WIDTH+1, c.SUPER_SLOT_SIZE, 1, 1, 1, 1);
    end

    if not TetrisDragUtil.isDragging() and self:isMouseOver() then
        local x = self:getMouseX();
        local y = self:getMouseY();
        local index = self:mousePositionToSlotIndex(x, y);
        if index ~= -1 and index <= count then
            self.inventoryPane:doTooltipForItem(itemsToDraw[index]);
        end
    end
end

function EquipmentSuperSlot:mousePositionToSlotIndex(x, y)
    if x > 0 and y > 0 and x < c.SUPER_SLOT_SIZE and y < c.SUPER_SLOT_SIZE then
        return 1;
    end

    if x > c.SUPER_SLOT_SIZE and y > 0 and x < c.SUPER_SLOT_SIZE + SUB_ITEM_WIDTH and y < c.SUPER_SLOT_SIZE then
        return math.floor(y / MINI_ICON_SIZE) + 2;
    end

    return -1;
end

function EquipmentSuperSlot:onRightMouseUp(x, y)
    local index = self:mousePositionToSlotIndex(x, y);
    if index == -1 then
        return;
    end

    local item = self:getNthItem(index);
    if item then
        TetrisUiUtil.openItemContextMenu(self, x, y, item, self.playerNum)
        return true
    end
end

function EquipmentSuperSlot:onMouseDown(x, y)
    self.mouseDownX = x;
    self.mouseDownY = y;
    
    local item = self:getTopItem();
    if item then
        local stack = ItemGridUtil.itemToNewStack(item);
        TetrisDragUtil.prepareDrag(self, stack, x, y);
        return true;
    end

    ISPanel.onMouseDown(self, x, y);
end

function EquipmentSuperSlot:onMouseMove(dx, dy)
    if TetrisDragUtil.isDragging() and self:doesItemConflict(TetrisDragUtil.getDraggedItem()) then
        self:setExpanded(true);
    else 
        TetrisDragUtil.startDrag(self);
    end
end

function EquipmentSuperSlot:onMouseMoveOutside(x, y)
    TetrisDragUtil.startDrag(self);

    -- if the mouse is more than 10 pixels away from the edge of the super slot, close it
    if self.expanded and not self:draggingMyItem() and (math.abs(x - self.mouseDownX) > 10 or math.abs(y - self.mouseDownY) > 10) then
        self:setExpanded(false);
    end
end

function EquipmentSuperSlot:onMouseUp(x, y)
    if TetrisDragUtil.isDragging() then
        self:handleDragDrop(x, y);
    else
        self:handleSlotClick(x, y);
    end
    TetrisDragUtil.endDrag();
end

function EquipmentSuperSlot:onMouseUpOutside(x, y)
    TetrisDragUtil.cancelDrag(self);
end

function EquipmentSuperSlot:handleDragDrop(x, y)
    local item = TetrisDragUtil.getDraggedItem();
    local bodyLocation = TetrisEquipmentUtil.getBodyLocationFromItem(item)
    if bodyLocation then
        self:handleClothingDrop(item, bodyLocation);
    end

    TetrisDragUtil.endDrag();
end

function EquipmentSuperSlot:handleClothingDrop(item, bodyLocation)
    local slot = self.slots[bodyLocation];
    if slot then
        ISInventoryPaneContextMenu.onWearItems({item}, self.playerNum);
    end
end

function EquipmentSuperSlot:handleSlotClick(x, y)
    local dx = math.abs(x - self.mouseDownX);
    local dy = math.abs(y - self.mouseDownY);
    if dx < 5 and dy < 5 then
        self:toggleExpanded();
    end
    ISPanel.onMouseUp(self, x, y);
    
    if self.parentX then
        print(self:getAbsoluteX() - self.parentX:getAbsoluteX(), ", ", self:getAbsoluteY() - self.parentX:getAbsoluteY());
    end
end

function EquipmentSuperSlot:toggleExpanded()
    self:setExpanded(not self.expanded);
end

function EquipmentSuperSlot:setExpanded(expanded)
    self.expanded = expanded and self:getItemCount() > 1;
    self:layoutSlots()

    local count = self.visibleSlots;
    local countX = count > MAX_COLUMN and MAX_COLUMN or count;
    local countY = count > MAX_COLUMN and math.ceil(count / MAX_COLUMN) or 1;

    self:setWidth(self.expanded and (countX * c.SLOT_SIZE + 4 - countX) or c.SUPER_SLOT_SIZE+SUB_ITEM_WIDTH);
    if self.width < c.SUPER_SLOT_SIZE+SUB_ITEM_WIDTH then
        self:setWidth(c.SUPER_SLOT_SIZE+SUB_ITEM_WIDTH);
    end

    self:setHeight(self.expanded and c.SUPER_SLOT_SIZE + c.SUPER_SLOT_VERTICAL_OFFSET + c.SLOT_SIZE * countY + 4 - countY or c.SUPER_SLOT_SIZE);

    if self.expanded then
        self:bringToTop();
    end
end