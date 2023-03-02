require "IS/UI/ISPanel"
local c = require "InventoryTetris/Equipment/EquipmentConstants"
local BG_TEXTURE = getTexture("media/textures/InventoryTetris/ItemSlot.png")
local SUB_ITEM_WIDTH = 12

EquipmentSuperSlot = ISPanel:derive("EquipmentSuperSlot");

function EquipmentSuperSlot:new (slotDefinition, playerNum)
	local o = ISPanel:new(50, 50, c.SUPER_SLOT_SIZE, c.SUPER_SLOT_SIZE);
	setmetatable(o, self)
    self.__index = self

    if slotDefinition.position then
        o:setX(slotDefinition.position.x);
        o:setY(slotDefinition.position.y);
    end

    o.slotDefinition = slotDefinition;
    o.playerNum = playerNum;
	o.moveWithMouse = true;

    o.slots = {}

	return o;
end

function EquipmentSuperSlot:initialise()
    ISPanel.initialise(self);
end

function EquipmentSuperSlot:createChildren()
    for _, bodyLocation in ipairs(self.slotDefinition.bodyLocations) do
        local slot = EquipmentSlot:new(0, 0, bodyLocation, self.playerNum);
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
    for _, slot in pairs(self.slots) do
        if slot.item then
            return true;
        end
    end
    return false;
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
        self:drawRect(c.SUPER_SLOT_SIZE / 2 - width / 2 - 3, -15, width + 8, 16, 0.9, 0, 0, 0);
        self:drawRectBorder(c.SUPER_SLOT_SIZE / 2 - width / 2 - 3, -15, width + 8, 16, 1, 1, 1, 1);
        self:drawTextCentre(self.slotDefinition.name, c.SUPER_SLOT_SIZE / 2, -15, 1, 1, 1, 1, UIFont.Small);
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

    local xOff = (c.SUPER_SLOT_SIZE - c.SLOT_SIZE) / 2;
    local yOff = (c.SUPER_SLOT_SIZE - c.SLOT_SIZE) / 2;
    self:drawTexture(itemsToDraw[1]:getTex(), xOff, yOff, 1, EquipmentSlot.getItemColor(itemsToDraw[1]));
  
    if count == 1 then
        return
    end

    
    local scale = 0.375;
    local slotSize = c.SUPER_SLOT_SIZE + SUB_ITEM_WIDTH
    local scaledSize = 32 * scale;
    for i = 2, count do
        self:drawRect(slotSize - scaledSize - 1, (scaledSize * (i - 2)), scaledSize+1, scaledSize+1, 0.7, 0, 0, 0);
        self:drawRectBorder(slotSize - scaledSize - 1, (scaledSize * (i - 2)), scaledSize+1, scaledSize+1, 0.4, 1, 1, 1);
        self:drawTextureScaledUniform(itemsToDraw[i]:getTex(), slotSize - scaledSize, yOff + (scaledSize * (i - 2)) - 1, scale, 1, EquipmentSlot.getItemColor(itemsToDraw[i]));
    end

    self:drawRectBorder(c.SUPER_SLOT_SIZE-1, 0, SUB_ITEM_WIDTH+1, c.SUPER_SLOT_SIZE, 1, 1, 1, 1);
end

function EquipmentSuperSlot:onMouseDown(x, y)
    self.mouseDownX = x;
    self.mouseDownY = y;
    ISPanel.onMouseDown(self, x, y);
end

function EquipmentSuperSlot:onMouseUp(x, y)
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

function EquipmentSuperSlot:onRightMouseUp(x, y)
    if x > c.SUPER_SLOT_SIZE or y > c.SUPER_SLOT_SIZE then
        return false;
    end

    -- Simulate a right click on the first found item
    for _, slot in pairs(self.slots) do
        if slot.item then
            TetrisUiUtil.openItemContextMenu(self, x, y, slot.item, self.playerNum)
            break;
        end
    end

end

function EquipmentSuperSlot:toggleExpanded()
    self.expanded = not self.expanded and self:getItemCount() > 1;
    for _, slot in pairs(self.slots) do
        slot:setVisible(self.expanded);
    end

    local count = #self.slotDefinition.bodyLocations;
    local countX = count > 3 and 3 or count;
    local countY = count > 3 and math.ceil(count / 3) or 1;

    self:setWidth(self.expanded and countX * c.SLOT_SIZE + 4 - countX or c.SUPER_SLOT_SIZE);
    self:setHeight(self.expanded and c.SUPER_SLOT_SIZE + c.SUPER_SLOT_VERTICAL_OFFSET + c.SLOT_SIZE * countY + 4 - countY or c.SUPER_SLOT_SIZE);

    if self.expanded then
        self:bringToTop();
    end
end