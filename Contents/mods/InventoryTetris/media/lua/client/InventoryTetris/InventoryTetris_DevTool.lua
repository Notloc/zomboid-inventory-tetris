TetrisDevTool = {}

TetrisDevTool.itemEdits = {}

function TetrisDevTool.insertEditItemOption(menu, item)
    menu:addOptionOnTop("Edit Tetris", item, TetrisDevTool.openEditItem);
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
    

    local currentX, currentY = ItemGridUtil.getItemSize(item)
    if ItemGridUtil.isItemRotated(item) then
        currentX, currentY = currentY, currentX
    end

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

    editWindow.widthInput = widthInput;
    editWindow.heightInput = heightInput;
    editWindow.item = item;

    local okButton = ISButton:new(10, 110, 100, 20, "OK", editWindow);
    okButton:setOnClick(TetrisDevTool.onEditItem, okButton);
    okButton:initialise();
    okButton:instantiate();
    okButton:setAnchorLeft(true);
    okButton:setAnchorRight(false);
    okButton:setAnchorTop(true);
    okButton:setAnchorBottom(false);
    okButton.internal = "OK";
    editWindow:addChild(okButton);

    local cancelButton = ISButton:new(10, 140, 100, 20, "Cancel", editWindow);
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
        if x and y and x > 0 and y > 0 then
            TetrisDevTool.setItemSize(self.item, x, y);
        end
    end
    self:removeFromUIManager();
end

function TetrisDevTool.setItemSize(item, x, y)
    TetrisDevTool.itemEdits[item:getFullType()] = {x=x, y=y};
    TetrisDevTool.writeItemEdits();
end

function TetrisDevTool.writeItemEdits()
    local file = getFileWriter("tetris_itemEdits.txt", true, false);
    for k,v in pairs(TetrisDevTool.itemEdits) do
        local line = string.format("[\"%s\"] = {x=%d, y=%d},\r\n", k, v.x, v.y);
        file:write(line);
    end
    file:close();
end
