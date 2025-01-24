-- Based on ISItemsListTable

require("ISUI/ISPanel")

TetrisItemsListTable = ISPanel:derive("TetrisItemsListTable");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6

function TetrisItemsListTable:initialise()
    ISPanel.initialise(self);
end


function TetrisItemsListTable:render()
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

function TetrisItemsListTable:new (x, y, width, height, viewer)
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
    TetrisItemsListTable.instance = o;
    return o;
end

function TetrisItemsListTable:createChildren()
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
    self.datas:addColumn("Category", 450+(getCore():getOptionFontSizeReal()*40));
    self.datas:addColumn("DisplayCategory", 650+(getCore():getOptionFontSizeReal()*40))
    self.datas:addColumn("LootCategory", 850+(getCore():getOptionFontSizeReal()*50))

    local tX = 1050

    self.datas:addColumn("Auto", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 65

    self.datas:addColumn("X/Y", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("Size", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("Density", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("Stack", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:addColumn("StackDensity", tX+(getCore():getOptionFontSizeReal()*40));
    tX = tX + 100

    self.datas:setOnMouseDoubleClick(self, TetrisItemsListTable.addItem);
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
        if column.name == "Category" then
            local combo = ISComboBox:new(x, entryY, size, LABEL_HGT)
            combo.font = UIFont.Medium
            combo:initialise()
            combo:instantiate()
            combo.columnName = column.name
            combo.target = combo
            combo.onChange = self.onFilterChange
            combo.itemsListFilter = self.filterCategory
            self:addChild(combo)
            table.insert(self.filterWidgets, combo)
            self.filterWidgetMap[column.name] = combo
        elseif column.name == "DisplayCategory" then
            local combo = ISComboBox:new(x, entryY, size, LABEL_HGT)
            combo.font = UIFont.Medium
            combo:initialise()
            combo:instantiate()
            combo.columnName = column.name
            combo.target = combo
            combo.onChange = self.onFilterChange
            combo.itemsListFilter = self.filterDisplayCategory
            self:addChild(combo)
            table.insert(self.filterWidgets, combo)
            self.filterWidgetMap[column.name] = combo
        elseif column.name == "LootCategory" then
            local combo = ISComboBox:new(x, entryY, size, LABEL_HGT)
            combo.font = UIFont.Medium
            combo:initialise()
            combo:instantiate()
            combo.columnName = column.name
            combo.target = combo
            combo.onChange = self.onFilterChange
            combo.itemsListFilter = self.filterLootCategory
            self:addChild(combo)
            table.insert(self.filterWidgets, combo)
            self.filterWidgetMap[column.name] = combo
        elseif column.name == "X/Y" then
            local entry = ISTextEntryBox:new("", x, entryY, size, LABEL_HGT);
            entry.font = UIFont.Medium
            entry:initialise();
            entry:instantiate();
            entry.columnName = column.name;
            entry.itemsListFilter = self.filterDimensions;
            entry.onTextChange = TetrisItemsListTable.onFilterChange;
            entry.onOtherKey = function(entry, key) TetrisItemsListTable.onOtherKey(entry, key) end
            entry.target = self;
            entry:setClearButton(true)
            self:addChild(entry);
            table.insert(self.filterWidgets, entry);
            self.filterWidgetMap[column.name] = entry
        else
            local entry = ISTextEntryBox:new("", x, entryY, size, LABEL_HGT);
            entry.font = UIFont.Medium
            entry:initialise();
            entry:instantiate();
            entry.columnName = column.name;
            entry.itemsListFilter = self['filter'..column.name]
            entry.onTextChange = TetrisItemsListTable.onFilterChange;
            entry.onOtherKey = function(entry, key) TetrisItemsListTable.onOtherKey(entry, key) end
            entry.target = self;
            entry:setClearButton(true)
            self:addChild(entry);
            table.insert(self.filterWidgets, entry);
            self.filterWidgetMap[column.name] = entry
        end
        x = x + size;
    end
end

function TetrisItemsListTable:initList(moduleItems)
    self.totalResult = 0;
    local categoryNames = {}
    local displayCategoryNames = {}
    local lootCategoryNames = {}
    local categoryMap = {}
    local displayCategoryMap = {}
    local lootCategoryMap = {}
    for _, item in ipairs(moduleItems) do
        self.datas:addItem(item:getDisplayName(), item);
        if not categoryMap[item:getTypeString()] then
            categoryMap[item:getTypeString()] = true
            table.insert(categoryNames, item:getTypeString())
        end
        if not displayCategoryMap[item:getDisplayCategory()] then
            displayCategoryMap[item:getDisplayCategory()] = true
            table.insert(displayCategoryNames, item:getDisplayCategory())
        end
        if not lootCategoryMap[getText("Sandbox_" .. item:getLootType().. "LootNew")] then
            lootCategoryMap[getText("Sandbox_" .. item:getLootType() .. "LootNew")] = true
            table.insert(lootCategoryNames, getText("Sandbox_" .. item:getLootType() .. "LootNew"))
        end
        self.totalResult = self.totalResult + 1;
    end
    table.sort(self.datas.items, function(a,b) return not string.sort(a.item:getDisplayName(), b.item:getDisplayName()); end);

    local combo = self.filterWidgetMap.Category
    table.sort(categoryNames, function(a,b) return not string.sort(a, b) end)
    combo:addOption("<Any>")
    for _,categoryName in ipairs(categoryNames) do
        combo:addOption(categoryName)
    end

    local combo = self.filterWidgetMap.DisplayCategory
    table.sort(displayCategoryNames, function(a,b) return not string.sort(a, b) end)
    combo:addOption("<Any>")
    combo:addOption("<No category set>")
    for _,displayCategoryName in ipairs(displayCategoryNames) do
        combo:addOption(displayCategoryName)
    end

    local combo = self.filterWidgetMap.LootCategory
    table.sort(lootCategoryNames, function(a,b) return not string.sort(a, b) end)
    combo:addOption("<Any>")
    for _,lootCategoryName in ipairs(lootCategoryNames) do
        combo:addOption(lootCategoryName)
    end
end

function TetrisItemsListTable:update()
    self.datas.doDrawItem = self.drawDatas;

    if self.needsFilterRefresh then
        self:resumeFilterRefresh()
    end
end

function TetrisItemsListTable:resumeFilterRefresh()
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

function TetrisItemsListTable.filterDisplayCategory(widget, scriptItem)
    if widget.selected == 1 then return true end -- Any category
    if widget.selected == 2 then return scriptItem:getDisplayCategory() == nil end
    return scriptItem:getDisplayCategory() == widget:getOptionText(widget.selected)
end

function TetrisItemsListTable.filterCategory(widget, scriptItem)
    if widget.selected == 1 then return true end -- Any category
    return scriptItem:getTypeString() == widget:getOptionText(widget.selected)
end

function TetrisItemsListTable.filterName(widget, scriptItem)
    return TetrisItemsListTable.doTextFilter(widget, scriptItem:getDisplayName())
end

function TetrisItemsListTable.filterType(widget, scriptItem)
    return TetrisItemsListTable.doTextFilter(widget, scriptItem:getName())
end

function TetrisItemsListTable.filterLootCategory(widget, scriptItem)
    if widget.selected == 1 then return true end -- Any category
    return getText("Sandbox_" .. scriptItem:getLootType() .. "LootNew") == widget:getOptionText(widget.selected)
end

function TetrisItemsListTable.filterAuto(widget, scriptItem)
    return TetrisItemsListTable.doTextFilter(widget, tostring(TetrisItemInfo.isAutoCalculated(scriptItem)))
end

function TetrisItemsListTable.filterDimensions(widget, scriptItem)
    local itemSize = TetrisItemInfo.getItemDimensions(scriptItem)
    return TetrisItemsListTable.doTextFilter(widget, itemSize)
end

function TetrisItemsListTable.filterSize(widget, scriptItem)
    local itemSize = TetrisItemInfo.getItemSize(scriptItem)
    return TetrisItemsListTable.doNumericFilter(widget, itemSize)
end

function TetrisItemsListTable.filterStack(widget, scriptItem)
    local stackSize = TetrisItemInfo.getMaxStackSize(scriptItem)
    return TetrisItemsListTable.doNumericFilter(widget, stackSize)
end

function TetrisItemsListTable.filterDensity(widget, scriptItem)
    local density = TetrisItemInfo.getItemDensity(scriptItem)
    return TetrisItemsListTable.doNumericFilter(widget, density)
end

function TetrisItemsListTable.filterStackDensity(widget, scriptItem)
    local stackDensity = TetrisItemInfo.getStackDensity(scriptItem)
    return TetrisItemsListTable.doNumericFilter(widget, stackDensity)
end

function TetrisItemsListTable.doTextFilter(widget, textToCheck)
    local txtToCheck = string.lower(textToCheck)
    local filterTxt = string.lower(widget:getInternalText())
    return TetrisItemsListTable._doTextFilter(txtToCheck, filterTxt)
end

local function split(input, delimiter)
    local result = {}
    for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Didn't write this pretty, but it lets me filter strings with OR(||), AND(&&) and NOT(!!) operators
function TetrisItemsListTable._doTextFilter(txtToCheck, filterTxt)
    if string.match(filterTxt, "&&") then
        local filters = split(filterTxt, "&&")
        for _,filter in ipairs(filters) do
            if filter then
                local check = TetrisItemsListTable._doTextFilter(txtToCheck, filter)
                if not check then return false end
            end
        end
        return true
    end

    if string.match(filterTxt, "||") then
        local filters = split(filterTxt, "||")
        for _,filter in ipairs(filters) do
            if filter then
                local check = TetrisItemsListTable._doTextFilter(txtToCheck, filter)
                if check then
                    return true
                end
            end
        end
        return false
    end

    if string.len(filterTxt) >= 2 and string.sub(filterTxt, 1, 2) == "!!" then
        return not TetrisItemsListTable._doTextFilter(txtToCheck, string.sub(filterTxt, 3))
    end
    return checkStringPattern(filterTxt) and string.match(txtToCheck, filterTxt)
end

function TetrisItemsListTable.doNumericFilter(widget, numberToCheck)
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

TetrisItemsListTable.onFilterChange = function(widget)
    local datas = widget.parent.datas;
    if not datas.fullList then datas.fullList = datas.items; end
    datas:clear();

    widget.parent.totalResult = 0;
    widget.parent.needsFilterRefresh = true;
    widget.parent.filterRefreshIndex = 1;
end

function TetrisItemsListTable:onOtherKey(key)
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

function TetrisItemsListTable:drawDatas(y, item, alt)
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

    clipX = self.columns[3].size
    clipX2 = self.columns[4].size
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item:getTypeString(), self.columns[3].size + xoffset, y + 3, 1, 1, 1, a, self.font);
    self:clearStencilRect()


    if item.item:getDisplayCategory() ~= nil then
        self:drawText(getText("IGUI_ItemCat_" .. item.item:getDisplayCategory()), self.columns[4].size + xoffset, y + 4, 1, 1, 1, a, self.font);
    else
        self:drawText("Error: No category set", self.columns[4].size + xoffset, y + 3, 1, 1, 1, a, self.font);
    end

    if item.item:getLootType() ~= nil then
        self:drawText(getText("Sandbox_" .. item.item:getLootType() .. "LootNew"), self.columns[5].size + xoffset, y + 3, 1, 1, 1, a, self.font);
    end


    local tetrixIdx = 6

    local auto = TetrisItemInfo.isAutoCalculated(item.item)
    self:drawText(tostring(auto), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local itemDimensions = TetrisItemInfo.getItemDimensions(item.item)
    self:drawText(itemDimensions, self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local itemSize = TetrisItemInfo.getItemSize(item.item) or "-"
    self:drawText(tostring(itemSize), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local density = TetrisItemInfo.getItemDensity(item.item)
    self:drawText(formatNumber(density, 4), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local stackSize = TetrisItemInfo.getMaxStackSize(item.item) or "-"
    self:drawText(tostring(stackSize), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

    tetrixIdx = tetrixIdx + 1

    local stackDensity = TetrisItemInfo.getStackDensity(item.item)
    self:drawText(formatNumber(stackDensity, 4), self.columns[tetrixIdx].size + xoffset, y + 3, 1, 1, 1, a, self.font);

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

function TetrisItemsListTable:addItem(item)
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



