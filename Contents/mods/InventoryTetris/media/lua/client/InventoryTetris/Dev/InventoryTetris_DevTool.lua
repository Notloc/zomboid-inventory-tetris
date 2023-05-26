local OPT = require "InventoryTetris/Settings"
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

function TetrisDevTool.insertContainerDebugOptions(menu, containerUi)
    if not isDebugEnabled() then
        return;
    end

    menu:addOptionOnTop("Recalculate Container Data", containerUi.containerGrid, TetrisDevTool.recalculateContainerData);
    menu:addOptionOnTop("Edit Container Data", containerUi, TetrisDevTool.openContainerEdit);
end

function TetrisDevTool.openEditItem(item)
    -- create a new window with 2 number inputs for width and height
    -- and a button to save the changes or cancel

    local editWindow = ISPanel:new(getMouseX(), getMouseY(), 200, 200);
    editWindow:initialise();
    editWindow:addToUIManager();

    -- Item name
    local nameLabel = ISLabel:new(10, 10, 10, item:getName(), 1, 1, 1, 1, UIFont.Small, true);
    nameLabel:initialise();
    nameLabel:instantiate();
    editWindow:addChild(nameLabel);
    

    local currentX, currentY = TetrisItemData.getItemSize(item, false)
    local maxStackSize = TetrisItemData.getMaxStackSize(item)

    local widthLabel = ISLabel:new(10, 25, 10, "X:", 1, 1, 1, 1, UIFont.Small, true);
    widthLabel:initialise();
    widthLabel:instantiate();
    editWindow:addChild(widthLabel);
    
    local widthInput = ISTextEntryBox:new("", 30, 25, 100, 20);
    widthInput:initialise();
    widthInput:instantiate();
    widthInput:setOnlyNumbers(true);
    widthInput:setMaxTextLength(2);
    widthInput:setText(tostring(currentX));
    editWindow:addChild(widthInput);

    local heightLabel = ISLabel:new(10, 60, 10, "Y:", 1, 1, 1, 1, UIFont.Small, true);
    heightLabel:initialise();
    heightLabel:instantiate();
    editWindow:addChild(heightLabel);

    local heightInput = ISTextEntryBox:new("", 30, 60, 100, 20);
    heightInput:initialise();
    heightInput:instantiate();
    heightInput:setOnlyNumbers(true);
    heightInput:setMaxTextLength(2);
    heightInput:setText(tostring(currentY));
    editWindow:addChild(heightInput);

    local maxStackLabel = ISLabel:new(10, 95, 10, "Max Stack:", 1, 1, 1, 1, UIFont.Small, true);
    maxStackLabel:initialise();
    maxStackLabel:instantiate();
    editWindow:addChild(maxStackLabel);

    local maxStackInput = ISTextEntryBox:new("", 80, 95, 50, 20);
    maxStackInput:initialise();
    maxStackInput:instantiate();
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
    okButton.internal = "OK";
    editWindow:addChild(okButton);

    local cancelButton = ISButton:new(10, 155, 100, 20, "Cancel", editWindow);
    cancelButton:setOnClick(TetrisDevTool.onEditItem, cancelButton);
    cancelButton:initialise();
    cancelButton:instantiate();
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
    TetrisDevTool.writeLuaFormattedFile();
end


local function copyTable(from, to)
    for k,v in pairs(from) do
        if type(v) == "table" then
            to[k] = {}
            copyTable(v, to[k])
        else
            to[k] = v
        end
    end
end

local function getGridXYFromHandle(handle)
    local x = handle:getX() + OPT.CELL_SIZE / 2;
    local y = handle:getY() + OPT.CELL_SIZE / 2;

    if x < 0 then x = 0 end
    if y < 0 then y = 0 end

    return ItemGridUiUtil.mousePositionToGridPosition(x, y)
end

function createAddGridButton(context)
    local button = ISButton:new(0, 0, 20, 20, "+", context, TetrisDevTool.onAddGridButton);
    button:initialise();
    button:instantiate();
    return button;
end

function createRemoveGridButton(context)
    local button = ISButton:new(0, 0, 20, 20, "X", context, TetrisDevTool.onRemoveGridButton);
    button:initialise();
    button:instantiate();
    return button;
end

function getQuickButton(context, quickId, factory)
    if not context[quickId.."pool"] then
        context[quickId.."pool"] = {}
    end

    if not context[quickId] then
        context[quickId] = {}
    end

    local button = nil;
    if #context[quickId.."pool"] > 0 then
        button = context[quickId.."pool"][#context[quickId.."pool"]];
        table.remove(context[quickId.."pool"], #context[quickId.."pool"]);
    else
        button = factory(context)
    end

    table.insert(context[quickId], button);
    context:addChild(button);
    button:bringToTop();
    return button;
end

function clearQuickButtons(context, quickId)
    if not context[quickId] then return end

    if not context[quickId.."pool"] then
        context[quickId.."pool"] = {}
    end

    for _,button in ipairs(context[quickId]) do
        context:removeChild(button);
        table.insert(context[quickId.."pool"], button);
    end
    context[quickId] = {};
end

function TetrisDevTool.remakeContainerUi(editWindow)
    if editWindow.containerUi then
        editWindow:removeChild(editWindow.containerUi);
        editWindow.containerUi = nil;
    end

    TetrisContainerData._containerDefinitions[editWindow.containerDataKey] = editWindow.newContainerDefinition;

    local containerUi = ItemGridContainerUI:new(editWindow.inventory, editWindow.inventoryPane, 0);
    containerUi.containerGrid = ItemContainerGrid:new(editWindow.inventory, 0)
    containerUi:initialise();

    editWindow.containerUi = containerUi;

    TetrisContainerData._containerDefinitions[editWindow.containerDataKey] = editWindow.originalContainerDef;

    editWindow:addChild(containerUi);
    containerUi:setY(200);

    -- Resize handles
    for _, gridUi in pairs(containerUi.gridUis) do
        local dragHandle = TetrisDevTool.createDragHandle(gridUi, OPT.CELL_SIZE, function(handle)
            local x, y = getGridXYFromHandle(handle);

            print("Drag handle at: " .. x .. ", " .. y);

            handle:setX(x * OPT.CELL_SIZE - x);
            handle:setY(y * OPT.CELL_SIZE - y);

            local index = gridUi.grid.gridIndex

            editWindow.newContainerDefinition.gridDefinitions[index] = {
                size = {
                    width = x+1,
                    height = y+1,
                },
                position = {
                    x = editWindow.newContainerDefinition.gridDefinitions[index].position.x,
                    y = editWindow.newContainerDefinition.gridDefinitions[index].position.y,
                }
            }

            ItemContainerGrid._playerMainGrids = {}
            ItemContainerGrid._getPlayerMainGrid(0)

            getPlayerInventory(0).inventoryPane:refreshItemGrids(true)
            getPlayerLoot(0).inventoryPane:refreshItemGrids(true)

            TetrisDevTool.remakeContainerUi(editWindow);
            editWindow:reflow();
        end);

        gridUi:addChild(dragHandle);
        dragHandle:setX(gridUi:getWidth() - OPT.CELL_SIZE);
        dragHandle:setY(gridUi:getHeight() - OPT.CELL_SIZE);
    end
end

function TetrisDevTool.openContainerEdit(containerUi)
    local inventory = containerUi.inventory;
    local inventoryPane = containerUi.inventoryPane;

    local editWindow = ISPanel:new(getMouseX(), getMouseY(), 50, 50);
    editWindow:initialise();
    editWindow.inventory = inventory;
    editWindow.inventoryPane = inventoryPane;
    
    editWindow.containerDataKey = TetrisContainerData._getContainerKey(editWindow.inventory);
    editWindow.originalContainerDef = TetrisContainerData.getContainerDefinition(editWindow.inventory);
    editWindow.newContainerDefinition = {}
    copyTable(editWindow.originalContainerDef, editWindow.newContainerDefinition);

    TetrisDevTool.remakeContainerUi(editWindow);    

    editWindow.reflow = function(self)
        self.containerUi:applyScales(OPT.SCALE, OPT.CONTAINER_INFO_SCALE)
        self.containerUi.containerGrid:refresh();
        self:setWidth(self.containerUi:getWidth() + 48);
        self:setHeight(self.containerUi:getHeight() + 200 + 48);
        TetrisDevTool.writeContainerEditsToFile({[editWindow.containerDataKey] = editWindow.newContainerDefinition})
        self.quickButtonsDirty = true
    end

    editWindow:reflow();

    editWindow:setWidth(containerUi:getWidth() + 48);
    editWindow:setHeight(containerUi:getHeight() + 200 + 48);
    
    -- Create titlebar
    local titleBar = ISPanel:new(0, 0, editWindow:getWidth(), 20);
    titleBar:initialise();
    titleBar:instantiate();
    titleBar:setAnchorLeft(true);
    titleBar:setAnchorRight(true);
    titleBar:setAnchorTop(true);
    titleBar.backgroundColor = {r=0, g=0, b=0, a=0.5};
    editWindow:addChild(titleBar);
    titleBar.moveWithMouse = true;


    -- Close button, top right
    local closeButton = ISButton:new(editWindow:getWidth() - 40, 2, 16, 16, "Close", editWindow);
    closeButton:initialise();
    closeButton:instantiate();
    closeButton:setAnchorRight(true);
    closeButton:setAnchorTop(true);
    closeButton:setAnchorBottom(false);
    closeButton:setAnchorLeft(false);
    closeButton:setAlwaysOnTop(true);
    closeButton.internal = "CLOSE";
    closeButton:setOnClick(TetrisDevTool.onEditContainer, closeButton);
    
    -- Alignment Title
    local alignmentTitle = ISLabel:new(10, 25, 16, "Alignment:", 1, 1, 1, 1, UIFont.Small, true);
    alignmentTitle:initialise();
    alignmentTitle:instantiate();
    editWindow:addChild(alignmentTitle);

    -- Alignment toggle button
    local isHorizontal = editWindow.newContainerDefinition.centerMode == "horizontal" or editWindow.newContainerDefinition.centerMode == nil;
    local alignmentButton = ISButton:new(10, 42, 100, 16, isHorizontal and "Horizontal" or "Vertical", editWindow);
    alignmentButton:initialise();
    alignmentButton:instantiate();
    alignmentButton.internal = "ALIGNMENT";
    alignmentButton:setOnClick(TetrisDevTool.onEditContainer, alignmentButton);
    editWindow:addChild(alignmentButton);

    -- Organized Title
    local organizedTitle = ISLabel:new(10, 65, 16, "Organized:", 1, 1, 1, 1, UIFont.Small, true);
    organizedTitle:initialise();
    organizedTitle:instantiate();
    editWindow:addChild(organizedTitle);

    -- Organized toggle button
    local isOrganized = editWindow.newContainerDefinition.isOrganized;
    local organizedButton = ISButton:new(10, 82, 100, 16, isOrganized and "True" or "False", editWindow);
    organizedButton:initialise();
    organizedButton:instantiate();
    organizedButton.internal = "ORGANIZED";
    organizedButton:setOnClick(TetrisDevTool.onEditContainer, organizedButton);
    editWindow:addChild(organizedButton);

    editWindow.alignmentButton = alignmentButton;

    local og_prerender = editWindow.prerender
    editWindow.prerender = function(self)
        og_prerender(self);
        -- Much darker background
        self:drawRect(1, 1, self:getWidth()-2, self:getHeight()-2, 0.75, 0, 0, 0);

        -- Draw a cyan rectangle behind the container grid
        self:drawRect(0, 200, self:getWidth(), self:getHeight() - 200, 0.5, 0, 0.7, 1);

        if not self.quickButtonsDirty then
            return;
        end

        -- Find all the grids on the right and bottom edges based only on their position
        local rightGrids = {};
        local bottomGrids = {};
        for _, gridUi in pairs(self.containerUi.gridUis) do
            local gridDef = gridUi.grid.gridDefinition;
            local x = gridDef.position.x;
            local y = gridDef.position.y;

            if not rightGrids[y] or rightGrids[y].grid.gridDefinition.position.x < x then
                rightGrids[y] = gridUi;
            end

            if not bottomGrids[x] or bottomGrids[x].grid.gridDefinition.position.y < y then
                bottomGrids[x] = gridUi;
            end
        end

        --self.containerUi:backMost();

        clearQuickButtons(self, "ADD");

        local containerX = self.containerUi:getX() + self.containerUi.gridRenderer:getX();
        local containerY = self.containerUi:getY() + self.containerUi.gridRenderer:getY();

        for _, rightGrid in pairs(rightGrids) do
            local gridX = rightGrid:getX();
            local gridY = rightGrid:getY();

            local gridDef = rightGrid.grid.gridDefinition;
            local x = gridDef.position.x;
            local y = gridDef.position.y;

            local button = getQuickButton(self, "ADD", createAddGridButton);
            button:setX(containerX + gridX + rightGrid:getWidth() + button:getWidth() + 8);
            button:setY(containerY + gridY + rightGrid:getHeight() / 2 - button:getHeight() / 2);
            button.newGridPos = {x = x + 1, y = y};
        end

        for _, bottomGrid in pairs(bottomGrids) do
            local gridX = bottomGrid:getX();
            local gridY = bottomGrid:getY();

            local gridDef = bottomGrid.grid.gridDefinition;
            local x = gridDef.position.x;
            local y = gridDef.position.y;

            local button = getQuickButton(self, "ADD", createAddGridButton);
            button:setX(containerX + gridX + bottomGrid:getWidth() / 2 - button:getWidth() / 2);
            button:setY(containerY + gridY + bottomGrid:getHeight() + button:getHeight() + 8);
            button.newGridPos = {x = x, y = y + 1};
        end

        clearQuickButtons(self, "REMOVE");
        for _, gridUi in pairs(self.containerUi.gridUis) do
            local gridX = gridUi:getX();
            local gridY = gridUi:getY();

            local gridDef = gridUi.grid.gridDefinition;
            local x = gridDef.position.x;
            local y = gridDef.position.y;

            local button = getQuickButton(self, "REMOVE", createRemoveGridButton);
            button:setX(containerX + gridX)
            button:setY(containerY + gridY);
            button.grid = gridUi;
        end
    end

    local og_render = editWindow.render
    editWindow.render = function(self)
        og_render(self);
        -- Draw the size and position of each grid
        for _, gridUi in pairs(self.containerUi.gridUis) do
            local grid = gridUi.grid;
            local gridDef = grid.gridDefinition;
            local w = gridDef.size.width;
            local h = gridDef.size.height;
            local x = gridDef.position.x;
            local y = gridDef.position.y;

            if gridUi.dragHandle.moving then
                w, h = getGridXYFromHandle(gridUi.dragHandle);
                w = w + 1;
                h = h + 1;
            end

            gridUi:drawText(w .. "x" .. h, 4, 22, 1, 1, 1, 1, UIFont.Medium);
            --gridUi:drawText("Pos: " .. x .. "," .. y, 4, 20, 1, 1, 1, 1, UIFont.Medium);
        end
    end

    titleBar:addChild(closeButton);
    editWindow:addToUIManager();
end

function TetrisDevTool.onEditContainer(self, button)
    if button.internal == "CLOSE" then
        self:removeFromUIManager();
    end

    if button.internal == "ALIGNMENT" then
        if self.newContainerDefinition.centerMode == nil then
            self.newContainerDefinition.centerMode = "horizontal";
        end
        self.newContainerDefinition.centerMode = self.newContainerDefinition.centerMode == "horizontal" and "vertical" or "horizontal";
        button:setTitle(self.newContainerDefinition.centerMode == "horizontal" and "Horizontal" or "Vertical");
    end

    if button.internal == "ORGANIZED" then
        self.newContainerDefinition.isOrganized = not self.newContainerDefinition.isOrganized;
        button:setTitle(self.newContainerDefinition.isOrganized and "True" or "False");
    end

    self:reflow();
end


function TetrisDevTool.onAddGridButton(editWindow, button)
    table.insert(editWindow.newContainerDefinition.gridDefinitions, {
        size = {
            width = 2,
            height = 2,
        },
        position = {
            x = button.newGridPos.x,
            y = button.newGridPos.y,
        },
    })

    TetrisDevTool.normalizeGridPositions(editWindow.newContainerDefinition);
    TetrisDevTool.remakeContainerUi(editWindow);
    editWindow:reflow()
end

function TetrisDevTool.onRemoveGridButton(editWindow, button)
    if #editWindow.newContainerDefinition.gridDefinitions > 1 then
        for i, gridDef in ipairs(editWindow.newContainerDefinition.gridDefinitions) do
            if gridDef.position.x == button.grid.grid.gridDefinition.position.x and gridDef.position.y == button.grid.grid.gridDefinition.position.y then
                table.remove(editWindow.newContainerDefinition.gridDefinitions, i);
                break;
            end
        end
    end

    TetrisDevTool.normalizeGridPositions(editWindow.newContainerDefinition);
    TetrisDevTool.remakeContainerUi(editWindow);
    editWindow:reflow()
end

function TetrisDevTool.normalizeGridPositions(containerDefinition)
    TetrisDevTool.compressRows(containerDefinition);
    TetrisDevTool.compressColumns(containerDefinition);
end

function TetrisDevTool.compressRows(containerDefinition)
    local rows = {};
    for _, gridDef in ipairs(containerDefinition.gridDefinitions) do
        if not rows[gridDef.position.y] then
            rows[gridDef.position.y] = {};
        end
        table.insert(rows[gridDef.position.y], gridDef);
    end

    for _, row in pairs(rows) do
        table.sort(row, function(a, b) return a.position.x < b.position.x end);
        if #row > 1 then        
            for i, gridDef in ipairs(row) do
                gridDef.position.x = i - 1;
            end
        end
    end
end

function TetrisDevTool.compressColumns(containerDefinition)
    local columns = {};
    for _, gridDef in ipairs(containerDefinition.gridDefinitions) do
        if not columns[gridDef.position.x] then
            columns[gridDef.position.x] = {};
        end
        table.insert(columns[gridDef.position.x], gridDef);
    end

    for _, column in pairs(columns) do
        table.sort(column, function(a, b) return a.position.y < b.position.y end);
        if #column > 1 then
            for i, gridDef in ipairs(column) do
                gridDef.position.y = i - 1;
            end
        end
    end
end


local function onMouseMoveOutside_noParent(self, dx, dy)
    if not self.moveWithMouse then return; end
    self.mouseOver = false;

    if self.moving then

        self:setX(self.x + dx);
        self:setY(self.y + dy);
        self:bringToTop();

    end
end

local function onMouseMove_noParent(self, dx, dy)
    if not self.moveWithMouse then return; end
    self.mouseOver = true;

    if self.moving then

        self:setX(self.x + dx);
        self:setY(self.y + dy);
        self:bringToTop();

        --ISMouseDrag.dragView = self;
    end
end

local function onMouseUp_handle(self, x, y)
    if not self.moveWithMouse then return; end
    if not self:getIsVisible() then
        return;
    end

    if self.moving then
        self.onReleaseCallback(self);
    end

    self.moving = false;
    ISMouseDrag.dragView = nil;
end

local function onMouseUpOutside_handle(self, x, y)
    if not self.moveWithMouse then return; end
    if not self:getIsVisible() then
        return;
    end

    if self.moving then
        self.onReleaseCallback(self);
    end

    self.moving = false;
    ISMouseDrag.dragView = nil;
end

local function onMouseDown_handle(self, x, y)
    if not self.moveWithMouse then return true; end
    if not self:getIsVisible() then
        return;
    end
    if not self:isMouseOver() then
        return -- this happens with setCapture(true)
    end
    
    self.downX = x;
    self.downY = y;
    
    -- Snap the center to the mouse

    local xCenter = self:getWidth() / 2;
    local xDiff = x - xCenter;
    self:setX(self:getX() + xDiff);

    local yCenter = self:getHeight() / 2;
    local yDiff = y - yCenter;
    self:setY(self:getY() + yDiff);

    self.moving = true;
    self:bringToTop();
end

function TetrisDevTool.createDragHandle(gridUi, pixelIncrement, onReleaseCallback)
    local handle = ISPanel:new(0,0, pixelIncrement, pixelIncrement);
    handle:initialise();
    handle:instantiate();
    handle:setVisible(true);

    handle.onReleaseCallback = onReleaseCallback;

    -- enable drag
    handle.moveWithMouse = true;

    handle.onMouseDown = onMouseDown_handle;
    handle.onMouseMoveOutside = onMouseMoveOutside_noParent;
    handle.onMouseMove = onMouseMove_noParent;
    handle.onMouseUp = onMouseUp_handle;
    handle.onMouseUpOutside = onMouseUpOutside_handle;

    gridUi.dragHandle = handle;

    -- Draw a red square
    handle.prerender = function(self)
        self:drawRect(0, 0, self:getWidth(), self:getHeight(), 1, 1, 0, 0);
    end

    handle.render = function(self)
        if self.moving then
            -- Draw a rect from the 0,0 of the parent to the handles bottom right corner
            self:suspendStencil();

            self:drawRect(-self:getX(), -self:getY(), self:getX() + self:getWidth(), self:getY() + self:getHeight(), 1, 1, 1, 1);
        end
    end

    return handle;
end


function TetrisDevTool.writeContainerEditsToFile(containerPack)
    local file = getFileWriter(FORMATED_FILENAME.."CONTAINER", true, false);
    local text = FormattedLuaWriter.formatLocalVariable("containerPack", containerPack, 0);
    file:write(text);
    file:close();
end

function TetrisDevTool.writeLuaFormattedFile()
    local file = getFileWriter(FORMATED_FILENAME, true, false);
    for k,v in pairs(TetrisDevTool.itemEdits) do
        local line = string.format("[\"%s\"] = {height=%d, width=%d, maxStackSize=%d},\r\n", k, v.width, v.height, v.maxStackSize);
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

    print("item CLASS: " .. TetrisItemCategory.getCategory(item))
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
