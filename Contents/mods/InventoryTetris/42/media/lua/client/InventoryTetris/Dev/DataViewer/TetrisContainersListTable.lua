-- Based on ISItemsListTable

require("ISUI/ISPanel")

TetrisContainersListTable = ISPanel:derive("TetrisContainersListTable");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6

function TetrisContainersListTable:initialise()
    ISPanel.initialise(self);
end


function TetrisContainersListTable:render()
    ISPanel.render(self);
    
    local filterInProgress = self.needsFilterRefresh and "..." or ""

    local y = self.datas.y + self.datas.height + UI_BORDER_SPACING + 3
    self:drawText(getText("IGUI_DbViewer_TotalResult") .. self.totalResult .. filterInProgress, 0, y, 1,1,1,1,UIFont.Small)
    self:drawText(getText("IGUI_ItemList_Info"), 0, y + BUTTON_HGT, 1,1,1,1,UIFont.Small)
    self:drawText(getText("IGUI_ItemList_Info2"), 0, y + BUTTON_HGT*2, 1,1,1,1,UIFont.Small)

    y = self.filters:getBottom()
    
    self:drawRectBorder(self.datas.x, y, self.datas:getWidth(), BUTTON_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawRect(self.datas.x, y, self.datas:getWidth(), BUTTON_HGT, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);

    local x = 0;
    for i,v in ipairs(self.datas.columns) do
        local size;
        if i == #self.datas.columns then
            size = self.datas.width - x
        else
            size = self.datas.columns[i+1].size - self.datas.columns[i].size
        end
--        print(v.name, x, v.size)
        self:drawText(v.name, x+UI_BORDER_SPACING+1, y+3, 1,1,1,1,UIFont.Small);
        self:drawRectBorder(self.datas.x + x, y, 1, BUTTON_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
        x = x + size;
    end
end

function TetrisContainersListTable:new (x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.listHeaderColor = {r=0.4, g=0.4, b=0.4, a=0.3};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0};
    o.backgroundColor = {r=0, g=0, b=0, a=1};
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.totalResult = 0;
    o.filterWidgets = {};
    o.filterWidgetMap = {}
    o.viewer = viewer
    TetrisContainersListTable.instance = o;
    return o;
end

function TetrisContainersListTable:createChildren()
    ISPanel.createChildren(self);
    
    local btnWid = 100
    local bottomHgt = BUTTON_HGT*6 + UI_BORDER_SPACING*3 + LABEL_HGT -2
    --local bottomHgt = 5 + FONT_HGT_SMALL * 2 + 5 + BUTTON_HGT + 20 + FONT_HGT_LARGE + LABEL_HGT + LABEL_HGT

    self.datas = ISScrollingListBox:new(0, BUTTON_HGT, self.width, self.height - bottomHgt - LABEL_HGT);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = BUTTON_HGT
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;

    self.datas:addColumn("Type", 0);
    self.datas:addColumn("Name", 200+(getCore():getOptionFontSizeReal()*20));

    local tX = 450

    self.datas:addColumn("Auto", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 65

    self.datas:addColumn("ItemSize", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("Slots", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("Tardis", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("Fragile", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("Capacity", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("SlotDensity", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 125

    self.datas:addColumn("Squishable", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("SquishedSize", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 140

    self.datas:setOnMouseDoubleClick(self, TetrisContainersListTable.addItem);
    self:addChild(self.datas);

    local btnY = self.datas.y + self.datas.height + UI_BORDER_SPACING*2 + BUTTON_HGT*3

    self.filters = ISLabel:new(0, btnY, LABEL_HGT, getText("IGUI_DbViewer_Filters"), 1, 1, 1, 1, UIFont.Large, true)
    self.filters:initialise()
    self.filters:instantiate()
    self:addChild(self.filters)

    local x = 0;
    local entryY = self.filters:getBottom() + BUTTON_HGT
    for i,column in ipairs(self.datas.columns) do
        local size;
        if i == #self.datas.columns then -- last column take all the remaining width
            size = self.datas:getWidth() - x;
        else
            size = self.datas.columns[i+1].size - self.datas.columns[i].size
        end

        local entry = ISTextEntryBox:new("", x, entryY, size, LABEL_HGT);
        entry.font = UIFont.Medium
        entry:initialise();
        entry:instantiate();
        entry.columnName = column.name;
        entry.itemsListFilter = self['filter'..column.name]
        entry.onTextChange = TetrisContainersListTable.onFilterChange;
        entry.onOtherKey = function(entry, key) TetrisContainersListTable.onOtherKey(entry, key) end
        entry.target = self;
        entry:setClearButton(true)
        self:addChild(entry);
        table.insert(self.filterWidgets, entry);
        self.filterWidgetMap[column.name] = entry

        x = x + size;
    end
end

function TetrisContainersListTable:initList(moduleItems)
    self.totalResult = 0;

    for _, item in ipairs(moduleItems) do
        self.datas:addItem(item:getDisplayName(), item);

        self.totalResult = self.totalResult + 1;
    end
    table.sort(self.datas.items, function(a,b) return not string.sort(a.item:getDisplayName(), b.item:getDisplayName()); end);
end

function TetrisContainersListTable:update()
    self.datas.doDrawItem = self.drawDatas;

    if self.needsFilterRefresh then
        self:resumeFilterRefresh()
    end
end

function TetrisContainersListTable:resumeFilterRefresh()
    local PER_FRAME = 500

    local datas = self.datas
    local total = #datas.fullList

    local max = math.min(self.filterRefreshIndex + PER_FRAME, total)

    for i = self.filterRefreshIndex, max do
        local itemData = datas.fullList[i]
        local add = true;
        for _,widget in ipairs(self.filterWidgets) do
            if not widget.itemsListFilter(widget, itemData.item) then
                add = false
                break
            end
        end
        if add then
            datas:addItem(i, itemData.item);
            self.totalResult = self.totalResult + 1;
        end
    end

    if max == total then
        self.needsFilterRefresh = false
    else
        self.filterRefreshIndex = max + 1
    end
end

-- FILTERS
function TetrisContainersListTable.filterName(widget, scriptItem)
    local displayName = scriptItem:getDisplayName()
    return TetrisContainersListTable.doTextFilter(widget, displayName)
end

function TetrisContainersListTable.filterType(widget, scriptItem)
    local typeName = scriptItem:getName()
    return TetrisContainersListTable.doTextFilter(widget, typeName)
end

function TetrisContainersListTable.filterAuto(widget, scriptItem)
    return TetrisContainersListTable.doTextFilter(widget, tostring(TetrisContainerInfo.isAutoCalculated(scriptItem)))
end

function TetrisContainersListTable.filterItemSize(widget, scriptItem)
    local itemSize = TetrisItemInfo.getItemSize(scriptItem)
    return TetrisContainersListTable.doNumericFilter(widget, itemSize)
end

function TetrisContainersListTable.filterSlots(widget, scriptItem)
    local slotCount = TetrisContainerInfo.getSlotCount(scriptItem)
    return TetrisContainersListTable.doNumericFilter(widget, slotCount)
end

function TetrisContainersListTable.filterFragile(widget, scriptItem)
    local isFragile = TetrisContainerInfo.isFragile(scriptItem)
    return TetrisContainersListTable.doTextFilter(widget, isFragile)
end

function TetrisContainersListTable.filterCapacity(widget, scriptItem)
    local stackSize = TetrisContainerInfo.getCapacity(scriptItem)
    return TetrisContainersListTable.doNumericFilter(widget, stackSize)
end

function TetrisContainersListTable.filterSlotDensity(widget, scriptItem)
    local density = TetrisContainerInfo.getSlotDensity(scriptItem)
    return TetrisContainersListTable.doNumericFilter(widget, density)
end

function TetrisContainersListTable.filterSquishable(widget, scriptItem)
    local stackDensity = TetrisContainerInfo.isSquishable(scriptItem)
    return TetrisContainersListTable.doTextFilter(widget, stackDensity)
end

function TetrisContainersListTable.filterSquishedSize(widget, scriptItem)
    local stackDensity = TetrisContainerInfo.getSquishedSize(scriptItem)
    return TetrisContainersListTable.doNumericFilter(widget, stackDensity)
end

function TetrisContainersListTable.filterTardis(widget, scriptItem)
    local stackDensity = TetrisContainerInfo.isTardis(scriptItem)
    return TetrisContainersListTable.doTextFilter(widget, stackDensity)
end

-- END FILTERS

function TetrisContainersListTable.doTextFilter(widget, textToCheck)
    local txtToCheck = string.lower(tostring(textToCheck))
    local filterTxt = string.lower(widget:getInternalText())
    return TetrisContainersListTable._doTextFilter(txtToCheck, filterTxt)
end

local function split(input, delimiter)
    local result = {}
    for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Didn't write this pretty, but it lets me filter strings with OR(||), AND(&&) and NOT(!!) operators
function TetrisContainersListTable._doTextFilter(txtToCheck, filterTxt)
    if string.match(filterTxt, "&&") then
        local filters = split(filterTxt, "&&")
        for _,filter in ipairs(filters) do
            if filter then
                local check = TetrisContainersListTable._doTextFilter(txtToCheck, filter)
                if not check then return false end
            end
        end
        return true
    end

    if string.match(filterTxt, "||") then
        local filters = split(filterTxt, "||")
        for _,filter in ipairs(filters) do
            if filter then
                local check = TetrisContainersListTable._doTextFilter(txtToCheck, filter)
                if check then
                    return true
                end
            end
        end
        return false
    end

    if string.len(filterTxt) >= 2 and string.sub(filterTxt, 1, 2) == "!!" then
        return not TetrisContainersListTable._doTextFilter(txtToCheck, string.sub(filterTxt, 3))
    end
    return checkStringPattern(filterTxt) and string.match(txtToCheck, filterTxt)
end

function TetrisContainersListTable.doNumericFilter(widget, numberToCheck)
    local text = widget:getInternalText()
    local operator = string.match(text, "[<>=]+")
    local number = tonumber(string.match(text, "[0-9]+"))
    if not number then return true end

    if not operator then return numberToCheck == number end
    if operator == ">" then return numberToCheck > number end
    if operator == "<" then return numberToCheck < number end
    if operator == ">=" then return numberToCheck >= number end
    if operator == "<=" then return numberToCheck <= number end
end

TetrisContainersListTable.onFilterChange = function(widget)
    local datas = widget.parent.datas;
    if not datas.fullList then datas.fullList = datas.items; end
    datas:clear();

    widget.parent.totalResult = 0;
    widget.parent.needsFilterRefresh = true;
    widget.parent.filterRefreshIndex = 1;
end

function TetrisContainersListTable:onOtherKey(key)
    if key == Keyboard.KEY_TAB then
        Core.UnfocusActiveTextEntryBox()
        if self.columnName == "Type" then
            self.parent.filterWidgetMap.Name:focus()
        else
            self.parent.filterWidgetMap.Type:focus()
        end
    end
end

local function formatNumber(num, decimalPlaces)
    if not num then return "-" end
    return string.format("%." .. decimalPlaces .. "f", num)
end

function TetrisContainersListTable:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = UI_BORDER_SPACING;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item:getName(), xoffset, y + 3, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    clipX = self.columns[2].size
    clipX2 = self.columns[3].size
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item:getDisplayName(), self.columns[2].size + iconX + iconSize + 4, y + 3, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local tetrixIdx = 3

    local auto = TetrisContainerInfo.isAutoCalculated(item.item)
    self:drawText(tostring(auto), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local itemSize = TetrisItemInfo.getItemSize(item.item)
    self:drawText(tostring(itemSize), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local slotCount = TetrisContainerInfo.getSlotCount(item.item)
    self:drawText(tostring(slotCount), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local tardis = TetrisContainerInfo.isTardis(item.item)
    self:drawText(tostring(tardis), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local fragile = TetrisContainerInfo.isFragile(item.item)
    self:drawText(tostring(fragile), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local capacity = TetrisContainerInfo.getCapacity(item.item)
    self:drawText(tostring(capacity), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local density = TetrisContainerInfo.getSlotDensity(item.item) or "-"
    self:drawText(formatNumber(density, 4), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local squishy = TetrisContainerInfo.isSquishable(item.item)
    self:drawText(tostring(squishy), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local squishedSize = squishy and TetrisContainerInfo.getSquishedSize(item.item) or "-"
    self:drawText(tostring(squishedSize), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    self:repaintStencilRect(0, clipY, self.width, clipY2 - clipY)

    local icon = item.item:getIcon()
    if item.item:getIconsForTexture() and not item.item:getIconsForTexture():isEmpty() then
        icon = item.item:getIconsForTexture():get(0)
    end
    if icon then
        local texture = tryGetTexture("Item_" .. icon)
        if texture then
            self:drawTextureScaledAspect2(texture, self.columns[2].size + iconX, y + (self.itemheight - iconSize) / 2, iconSize, iconSize,  1, 1, 1, 1);
        end
    end

    return y + self.itemheight;
end

function TetrisContainersListTable:addItem(item)
    local playerNum = self.viewer.playerSelect.selected - 1
    local playerObj = getSpecificPlayer(playerNum)
    if not playerObj or playerObj:isDead() then return end
    if isClient() then
        SendCommandToServer("/additem \"" .. playerObj:getDisplayName() .. "\" \"" .. luautils.trim(item:getFullName()) .. "\"")
    else
        local item = instanceItem(item:getFullName())
        if item:getType() == "CorpseAnimal" then
            ---@diagnostic disable-next-line: param-type-mismatch
            item:createAndStoreDefaultDeadBody(nil) -- Vanilla code
        end
        playerObj:getInventory():AddItem(item);
    end
end



