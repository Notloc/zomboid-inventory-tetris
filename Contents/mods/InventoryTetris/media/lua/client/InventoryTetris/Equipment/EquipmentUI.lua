require "ISUI/ISPanelJoypad"
local c = require "InventoryTetris/Equipment/EquipmentConstants"

EquipmentUI = ISPanelJoypad:derive("EquipmentUI");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

-- Order is important here, the first slot appears on top of the others in the ui
-- It looks nicer to have the outermost layer of clothing on top
local SUPER_SLOT_DEFS = {
    {
        name = "Head",
        position = { x = 54, y = 18 },
        bodyLocations = { "FullTop", "FullHat", "Hat", "FullHelmet", "Head", "Wig", "Scarf", "Neck"}
    },
    {
        name = "Face",
        position = { x = 110, y = 26 },
        bodyLocations = { "SpecialMask", "MaskFull", "MaskEyes", "Mask", "Pupils", "Eyes", "RightEye", "LeftEye"}
    },
    {
        name = "Torso",
        position = { x = 54, y = 68 },
        bodyLocations = { "FullSuit", "FullSuitHead", "JacketSuit", "Jacket_Down", "JacketHat_Bulky", "Jacket_Bulky", "JacketHat", "Jacket", "BathRobe", "Boilersuit", "SweaterHat", "Sweater", "Dress", "Shirt", "ShortSleeveShirt", "Tshirt", "TankTop", "UnderwearTop", "Underwear"}
    },
    {
        name = "Vest",
        position = { x = 116, y = 76 },
        bodyLocations = { "SMUIJumpsuitPlus", "SMUITorsoRigPlus", "SMUIWebbingPlus", "TorsoRigPlus2", "TorsoRig", "TorsoRig2", "TorsoExtraVest", "TorsoExtraPlus1", "RifleSling", "AmmoStrap", "TorsoExtra"}
    },
    {
        name = "Back",
        position = { x = 188, y = 22 },
        bodyLocations = {"Back"}
    },
    {
        name = "Waist",
        position = { x = 54, y = 138 },
        bodyLocations = { "waistbagsComplete", "waistbags", "waistbagsf", "FannyPackBack", "FannyPackFront", "SpecialBelt", "BeltExtraHL", "BeltExtra", "Belt420", "Belt419", "Belt", "Tail"}
    },
    {
        name = "Hands",
        position = { x = 110, y = 146 },
        bodyLocations = { "Hands", "SMUIGlovesPlus", "RightWrist", "LeftWrist" }
    },
    {
        name = "Jewelry",
        position = { x = 116, y = 220 },
        bodyLocations = { "Necklace", "Necklace_Long", "BellyButton", "Right_RingFinger", "Left_RingFinger", "Right_MiddleFinger",  "Left_MiddleFinger", "Nose", "Ears", "EarTop" }
    },
    {
        name = "Legs",
        position = { x = 54, y = 212 },
        bodyLocations = { "Kneepads", "ShinPlateRight", "ShinPlateLeft", "ThighRight" ,"ThighLeft", "Pants", "Skirt", "Legs1", "LowerBody", "UnderwearExtra2", "UnderwearExtra1", "UnderwearBottom"}
    },
    {
        name = "Feet",
        position = { x = 54, y = 282 },
        bodyLocations = { "Shoes", "SMUIBootsPlus", "Socks"}
    }
}

function EquipmentUI:new(x, y, width, height, playerNum)
	local o = {};
	o = ISPanelJoypad:new(x, y, width, height);
	o:noBackground();
	setmetatable(o, self);
    self.__index = self;
    o.playerNum = playerNum
	o.char = getSpecificPlayer(playerNum);
	o.bFemale = o.char:isFemale()
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.8};
	o.bodyOutline = getTexture("media/ui/defense/" .. (o.char:isFemale() and "female" or "male") .. "_base.png")
   return o;
end

function EquipmentUI:createChildren()
    ISPanelJoypad.createChildren(self);
    self:createSlots();
end

function EquipmentUI:createSlots()
    self.dynamicSlotPool = {}
    self.dynamicSlots = {};
    self.superSlots = {};

    for _, superSlotDef in pairs(SUPER_SLOT_DEFS) do
        local superslot = EquipmentSuperSlot:new(superSlotDef, self.playerNum);
        superslot:initialise();

        if superSlotDef.position then
            superslot.moveWithMouse = false
            self:addChild(superslot);
        else
            superslot.parentX = self;
            superslot:addToUIManager();
        end

        for _, bodyLocation in pairs(superslot.slotDefinition.bodyLocations) do
            self.superSlots[bodyLocation] = superslot;
        end
    end

    self:updateDynamicSlots()
    Events.OnClothingUpdated.Add(function(character) 
        if character:isLocalPlayer() and character:getPlayerNum() == self.playerNum then
            self:updateDynamicSlots()
        end
    end)
end

function EquipmentUI:updateDynamicSlots()
    for key, slot in pairs(self.dynamicSlots) do
        slot:setVisible(false)
        table.insert(self.dynamicSlotPool, slot)
        self.dynamicSlots[key] = nil
    end
 
    local player = getSpecificPlayer(self.playerNum)
    local wornItems = player:getWornItems()

    local MAX_COLUMN = 5

    local column = 0
    local row = 0
    for i = 1, wornItems:size() do
        local item = wornItems:get(i-1)
        local bodyLocation = item:getLocation()

        if not self.superSlots[bodyLocation] then
            local slot = self:createDynamicSlot(bodyLocation)
            slot:setX(16 + (column * (c.SLOT_SIZE + 4)));
            slot:setY(330 + (row * c.SLOT_SIZE));
            slot:setItem(item:getItem())
            self.dynamicSlots[bodyLocation] = slot

            column = column + 1
            if column >= MAX_COLUMN then
                column = 0
                row = row + 1
            end
        end
    end

end

function EquipmentUI:createDynamicSlot(bodyLocation)
    if #self.dynamicSlotPool > 0 then
        local slot = self.dynamicSlotPool[#self.dynamicSlotPool]
        table.remove(self.dynamicSlotPool, #self.dynamicSlotPool)

        slot.bodyLocation = bodyLocation
        slot:setVisible(true)
        slot:setItem(nil)
        return slot
    end

    local slot = EquipmentSlot:new(50, 50, bodyLocation, self.playerNum);
    slot:initialise();
    self:addChild(slot);
    return slot
end


function EquipmentUI:setVisible(visible)
    self.javaObject:setVisible(visible);
end

function EquipmentUI:prerender()
	ISPanelJoypad.prerender(self)

    self:drawTexture(self.bodyOutline, 10, 10, 1, 1, 1, 1, 1, 1);

    self:updateSlots();
    self:drawRectBorder(self:getWidth() - 16, 0, 0, self:getHeight(), 1,0.5,0.5,0.5);

end

function EquipmentUI:updateSlots()
    for _, slot in pairs(self.dynamicSlots) do
        slot:clearItem();
    end

    for _, slot in pairs(self.superSlots) do
        slot:clearItem();
    end

    local wornItems = self.char:getWornItems()
    for i=1,wornItems:size() do
        local wornItem = wornItems:get(i-1)
        local bodyLocation = wornItem:getLocation()
        if self.superSlots[bodyLocation] then
            self.superSlots[bodyLocation]:setItem(wornItem:getItem(), bodyLocation)
        end

        if self.dynamicSlots[bodyLocation] then
            self.dynamicSlots[bodyLocation]:setItem(wornItem:getItem())
        end
    end
end
