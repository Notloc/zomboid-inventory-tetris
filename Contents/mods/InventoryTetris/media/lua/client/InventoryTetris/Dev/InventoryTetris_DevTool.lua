local JSON = require "InventoryTetris/Dev/JSON.lua"

local function readJsonFile(fileName)
    local reader = getFileReader(fileName, false);
    if reader then
        local allLines = "";

        local line = reader:readLine()
        while line do
            allLines = allLines .. line .. "\r\n";
            line = reader:readLine()
        end    
        
        reader:close();
        if allLines == "" then
            return nil;
        end

        return JSON.parse(allLines);
    end
    return nil;
end

local function writeJsonFile(fileName, json)
    local createFile = true
    local appendToFile = false
    local writer = getFileWriter(fileName, createFile, appendToFile);

    if type(json) ~= "string" then
        json = JSON.stringify(json);
    end

    writer:write(json);
    writer:close();
end





TetrisDevTool = {}

local FILENAME = "InventoryTetris_ItemData.json"
local FORMATED_FILENAME = "InventoryTetris_ItemData_Formated.txt"
TetrisDevTool.itemEdits = readJsonFile(FILENAME) or {}

function TetrisDevTool.insertDebugOptions(menu, item)
    if not isDebugEnabled() then
        return;
    end

    menu:addOptionOnTop("Edit Item Data", item, TetrisDevTool.openEditItem);
    menu:addOptionOnTop("Recalculate Item Data", item, TetrisDevTool.recalculateItemData);
end

function TetrisDevTool.insertContainerDebugOptions(menu, containerGrid)
    if not isDebugEnabled() then
        return;
    end

    menu:addOptionOnTop("Recalculate Container Data", containerGrid, TetrisDevTool.recalculateContainerData);
end

function TetrisDevTool.openEditItem(item)
    -- create a new window with 2 number inputs for width and height
    -- and a button to save the changes or cancel

    local editWindow = ISPanel:new(getMouseX(), getMouseY(), 300, 200);
    editWindow:initialise();
    editWindow:addToUIManager();

    -- Item name
    local nameLabel = ISLabel:new(10, 10, 10, item:getName(), 1, 1, 1, 1, UIFont.Small, true);
    nameLabel:initialise();
    nameLabel:instantiate();
    nameLabel:setAnchorLeft(true);
    nameLabel:setAnchorRight(false);
    nameLabel:setAnchorTop(true);
    nameLabel:setAnchorBottom(false);
    editWindow:addChild(nameLabel);
    

    local currentX, currentY = TetrisItemData.getItemSize(item, false)
    local maxStackSize = TetrisItemData.getMaxStackSize(item)

    local widthLabel = ISLabel:new(10, 25, 10, "X:", 1, 1, 1, 1, UIFont.Small, true);
    widthLabel:initialise();
    widthLabel:instantiate();
    widthLabel:setAnchorLeft(true);
    widthLabel:setAnchorRight(false);
    widthLabel:setAnchorTop(true);
    widthLabel:setAnchorBottom(false);
    editWindow:addChild(widthLabel);
    
    local widthInput = ISTextEntryBox:new("", 30, 25, 100, 20);
    widthInput:initialise();
    widthInput:instantiate();
    widthInput:setAnchorLeft(true);
    widthInput:setAnchorRight(false);
    widthInput:setAnchorTop(true);
    widthInput:setAnchorBottom(false);
    widthInput:setOnlyNumbers(true);
    widthInput:setMaxTextLength(2);
    widthInput:setText(tostring(currentX));
    editWindow:addChild(widthInput);

    local heightLabel = ISLabel:new(10, 60, 10, "Y:", 1, 1, 1, 1, UIFont.Small, true);
    heightLabel:initialise();
    heightLabel:instantiate();
    heightLabel:setAnchorLeft(true);
    heightLabel:setAnchorRight(false);
    heightLabel:setAnchorTop(true);
    heightLabel:setAnchorBottom(false);
    editWindow:addChild(heightLabel);

    local heightInput = ISTextEntryBox:new("", 30, 60, 100, 20);
    heightInput:initialise();
    heightInput:instantiate();
    heightInput:setAnchorLeft(true);
    heightInput:setAnchorRight(false);
    heightInput:setAnchorTop(true);
    heightInput:setAnchorBottom(false);
    heightInput:setOnlyNumbers(true);
    heightInput:setMaxTextLength(2);
    heightInput:setText(tostring(currentY));
    editWindow:addChild(heightInput);

    local maxStackLabel = ISLabel:new(10, 95, 10, "Max Stack:", 1, 1, 1, 1, UIFont.Small, true);
    maxStackLabel:initialise();
    maxStackLabel:instantiate();
    maxStackLabel:setAnchorLeft(true);
    maxStackLabel:setAnchorRight(false);
    maxStackLabel:setAnchorTop(true);
    maxStackLabel:setAnchorBottom(false);
    editWindow:addChild(maxStackLabel);

    local maxStackInput = ISTextEntryBox:new("", 80, 95, 50, 20);
    maxStackInput:initialise();
    maxStackInput:instantiate();
    maxStackInput:setAnchorLeft(true);
    maxStackInput:setAnchorRight(false);
    maxStackInput:setAnchorTop(true);
    maxStackInput:setAnchorBottom(false);
    maxStackInput:setOnlyNumbers(true);
    maxStackInput:setMaxTextLength(3);
    maxStackInput:setText(tostring(maxStackSize));
    editWindow:addChild(maxStackInput);

    editWindow.widthInput = widthInput;
    editWindow.heightInput = heightInput;
    editWindow.maxStackInput = maxStackInput;
    editWindow.item = item;

    local okButton = ISButton:new(10, 125, 100, 20, "OK", editWindow);
    okButton:setOnClick(TetrisDevTool.onEditItem, okButton);
    okButton:initialise();
    okButton:instantiate();
    okButton:setAnchorLeft(true);
    okButton:setAnchorRight(false);
    okButton:setAnchorTop(true);
    okButton:setAnchorBottom(false);
    okButton.internal = "OK";
    editWindow:addChild(okButton);

    local cancelButton = ISButton:new(10, 155, 100, 20, "Cancel", editWindow);
    cancelButton:setOnClick(TetrisDevTool.onEditItem, cancelButton);
    cancelButton:initialise();
    cancelButton:instantiate();
    cancelButton:setAnchorLeft(true);
    cancelButton:setAnchorRight(false);
    cancelButton:setAnchorTop(true);
    cancelButton:setAnchorBottom(false);
    cancelButton.internal = "Cancel";
    editWindow:addChild(cancelButton);
end

TetrisDevTool.onEditItem = function(self, button)
    if button.internal == "OK" then
        local x = tonumber(self.widthInput:getText());
        local y = tonumber(self.heightInput:getText());
        local maxStack = tonumber(self.maxStackInput:getText());
        if x and y and maxStack and x > 0 and y > 0 and maxStack > 0 then
            TetrisDevTool.applyEdits(self.item, x, y, maxStack);
        end
    end
    self:removeFromUIManager();
end

function TetrisDevTool.applyEdits(item, x, y, maxStack)
    local fType = item:getFullType();
    local oldData = TetrisItemData._itemData[fType] or {};

    local newData = {}
    for k,v in pairs(oldData) do
        newData[k] = v;
    end
    newData.width = x;
    newData.height = y;
    newData.maxStackSize = maxStack

    TetrisDevTool.itemEdits[fType] = newData;
    
    writeJsonFile(FILENAME, TetrisDevTool.itemEdits);
    --TetrisDevTool.writeLuaFormattedFile();
end

function TetrisDevTool.writeLuaFormattedFile()
    local file = getFileWriter(FORMATED_FILENAME, true, false);
    for k,v in pairs(TetrisDevTool.itemEdits) do
        local line = string.format("[\"%s\"] = {x=%d, y=%d},\r\n", k, v.x, v.y);
        file:write(line);
    end
    file:close();
end

function TetrisDevTool.recalculateItemData(item)
    local fType = item:getFullType();
    TetrisItemData._itemData[fType] = nil;
    TetrisDevTool.itemEdits[fType] = nil;
    writeJsonFile(FILENAME, TetrisDevTool.itemEdits);
    -- Recalculation will happen when the item is next rendered
end

function TetrisDevTool.recalculateContainerData(containerGrid)
    TetrisContainerData.recalculateContainerData(containerGrid.inventory);
    local playerNum = containerGrid.playerNum
    getPlayerInventory(playerNum).inventoryPane:refreshItemGrids(true)
    getPlayerLoot(playerNum).inventoryPane:refreshItemGrids(true)
end


local og_createMenu = ISInventoryPaneContextMenu.createMenu
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)
    local menu = og_createMenu(player, isInPlayerInventory, items, x, y, origin)
    
    
    local item = items[1]
    if not item then return end

    if items[1].items then 
        item = items[1].items[1]
    end
    if not item then return end

    print("item CLASS: " .. TetrisItemData._calculateItemClass(item))
    print("item full type: " .. item:getFullType())
    print("item weight: " .. tostring(item:getActualWeight()))

    local mediaData = item:getMediaData()
    if mediaData then
        print("mediaData: " .. mediaData:getCategory())
    end

    if item:IsInventoryContainer() then
        local container = item:getItemContainer()
        print("container type: " .. tostring(container:getType()))
    end

    local tex = item:getTex()
    if tex then
        print("Texture Width: " .. tostring(tex:getWidth()))
        print("Texture Height: " .. tostring(tex:getHeight()))
    end

    TetrisDevTool.insertDebugOptions(menu, item)

    return menu
end
