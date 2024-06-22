---@class TetrisWindowManager
---@field inventoryPane ISInventoryPane
---@field playerNum number
---@field childWindows table[]
---@field openWindows table[]
TetrisWindowManager = {}

TetrisWindowManager._instances = {}

---@param inventoryPane table
---@param playerNum number
---@return TetrisWindowManager
function TetrisWindowManager:new(inventoryPane, playerNum)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.inventoryPane = inventoryPane
    o.playerNum = playerNum
    o.childWindows = {}
    o.openWindows = {}
    o.controllerWindowIndex = 1

    TetrisWindowManager._instances[o] = true
    return o
end

function TetrisWindowManager:getInventoryPage()
    local inventoryPage = getPlayerInventory(self.playerNum)
    if inventoryPage.inventoryPane ~= self.inventoryPane then
        inventoryPage = getPlayerLoot(self.playerNum)
    end
    return inventoryPage
end

function TetrisWindowManager:hasOpenWindows()
    return #self.openWindows > 0
end

function TetrisWindowManager:focusFirstWindow()
    if #self.openWindows > 0 then
        self.openWindows[1]:bringToTop()
        self.controllerWindowIndex = 1
        setJoypadFocus(self.playerNum, self.openWindows[1])
    end
end

-- Selects the inventory page once we hit the edge of the list
function TetrisWindowManager:nextWindow()
    self.controllerWindowIndex = self.controllerWindowIndex + 1
    if self.controllerWindowIndex > #self.openWindows then
        self.controllerWindowIndex = 1
        local inventoryPage = self:getInventoryPage()
        setJoypadFocus(self.playerNum, inventoryPage)
        inventoryPage:bringToTop()
    else
        setJoypadFocus(self.playerNum, self.openWindows[self.controllerWindowIndex])
        self.openWindows[self.controllerWindowIndex]:bringToTop()
    end
end

-- Keeps windows selected even if we hit the edge of the list until empty
function TetrisWindowManager:previousWindow()
    local current = self.openWindows[self.controllerWindowIndex]

    self.controllerWindowIndex = self.controllerWindowIndex - 1
    if self.controllerWindowIndex < 1 then
        self.controllerWindowIndex = #self.openWindows
    end

    local newSelection = self.openWindows[self.controllerWindowIndex]
    if newSelection == current then
        local inventoryPage = self:getInventoryPage()
        setJoypadFocus(self.playerNum, inventoryPage)
        inventoryPage:bringToTop()
    else
        setJoypadFocus(self.playerNum, self.openWindows[self.controllerWindowIndex])
        self.openWindows[self.controllerWindowIndex]:bringToTop()
    end
end

function TetrisWindowManager:findWindowByInventory(inventory)
    return self:_findWindowByInventory(self.childWindows, inventory)
end

function TetrisWindowManager:_findWindowByInventory(childWindows, inventory)
    for _, child in ipairs(childWindows) do
        if child.inventory == inventory then
            return child
        end
        local recur = self:_findWindowByInventory(child.childWindows, inventory)
        if recur then
            return recur
        end
    end
end

function TetrisWindowManager:setupChildWindow(window)
    self:addBringToFrontOnMouseDown(window)
    self:addRemoveOnClose(window)

    if window.gridContainerUi then
        for _, gridUi in ipairs(window.gridContainerUi.gridUis) do
            self:addBringToFrontOnMouseDown(gridUi)
        end
    end
end

function TetrisWindowManager:addBringToFrontOnMouseDown(window)
    -- Incase the window is being pooled/reused
    if not window.onMouseDown_preWindowManager then
        window.onMouseDown_preWindowManager = window.onMouseDown
    end
    -- Bring the window to the top of the stack when it is clicked
    window.onMouseDown = function(window, ...)
        window:bringToTop()
        window:onMouseDown_preWindowManager(...)
    end
end

function TetrisWindowManager:addRemoveOnClose(window)
    -- Incase the window is being pooled/reused
    if not window.close_preWindowManager then
        window.close_preWindowManager = window.close
    end
    -- Remove the window from the stack when it is closed
    window.close = function(window)
        self:removeChildWindow(window)
        window:close_preWindowManager()
    end
end


local function removeFromList(list, item)
    for i, listItem in ipairs(list) do
        if listItem == item then
            table.remove(list, i)
            return
        end
    end
end

function TetrisWindowManager:removeChildWindow(window)
    window:removeFromUIManager()

    if window == self.openWindows[self.controllerWindowIndex] then
        self:previousWindow()
    end
    removeFromList(self.openWindows, window)

    local parent = window.parentWindow
    if parent then
        removeFromList(parent.childWindows, window)

        for _, child in ipairs(window.childWindows) do
            child.parentWindow = parent
            table.insert(parent.childWindows, child)
        end
    end

    window.parentWindow = nil
end

function TetrisWindowManager:keepChildWindowsOnTop()
    local isController = JoypadState.players[self.playerNum + 1] ~= nil
    if isController then return end
    
    for _, child in ipairs(self.childWindows) do
        child:bringToTop()
    end
end

---@param item InventoryContainer
function TetrisWindowManager:openContainerPopup(item)
    if not item or not item:IsInventoryContainer() then return end

    if isClient() then -- Prevent multiplayer dupe glitch
        local playerObj = getSpecificPlayer(self.playerNum)
        local outerContainer = item:getOutermostContainer()
        if outerContainer ~= playerObj:getInventory() and outerContainer ~= nil then
            return
        end
    end

    local isController = JoypadState.players[self.playerNum + 1] ~= nil
    local x = isController and self.inventoryPane:getAbsoluteX() or getMouseX()
    local y = isController and self.inventoryPane:getAbsoluteY() or getMouseY()

    local itemGridWindow = ItemGridWindow:new(x, y, item:getInventory(), self.inventoryPane, self.playerNum, self)
    itemGridWindow:initialise()
    itemGridWindow:addToUIManager()
    itemGridWindow:bringToTop()
    itemGridWindow.childWindows = {}
    itemGridWindow.parentInventory = item:getContainer()
    itemGridWindow.item = item
    self:setupChildWindow(itemGridWindow)

    local parent = self:findWindowByInventory(item:getContainer()) or self
    itemGridWindow.parentWindow = parent

    table.insert(parent.childWindows, itemGridWindow)
    table.insert(self.openWindows, itemGridWindow)

    if isController then
        setJoypadFocus(self.playerNum, itemGridWindow)
        self.controllerWindowIndex = #self.openWindows
    end
end

function TetrisWindowManager:closeIfInvalid(invPage)
    local inventoryMap = {}
    for _, backpack in ipairs(invPage.backpacks) do
        inventoryMap[backpack.inventory] = true
    end

    -- Loop backwards so we can remove items from the list
    -- Closes top level windows no longer visible from the inventory page
    for i = #self.childWindows, 1, -1 do
        local child = self.childWindows[i]
        local inv = child.parentInventory
        
        if not inventoryMap[inv] or not inv:contains(child.item) then
            child:removeFromUIManager()
            table.remove(self.childWindows, i)

            if child == self.openWindows[self.controllerWindowIndex] then
                self:previousWindow()
            end

            removeFromList(self.openWindows, child)
            self:closeChildWindowsRecursive(child)
        end
    end

    -- Handles the window tree when a container is moved to a different container
    for _, child in ipairs(self.childWindows) do
        self:closeIfMovedRecursive(child)
    end
end

function TetrisWindowManager:closeIfMovedRecursive(window)
    -- Loop backwards so we can remove items from the list
    for i = #window.childWindows, 1, -1 do
        local child = window.childWindows[i]
        local inv = child.parentInventory

        if not inv:contains(child.item) then
            child:removeFromUIManager()
            table.remove(window.childWindows, i)

            if child == self.openWindows[self.controllerWindowIndex] then
                self:previousWindow()
            end
            removeFromList(self.openWindows, child)

            self:closeChildWindowsRecursive(child)
        else
            self:closeIfMovedRecursive(child)
        end
    end
end

function TetrisWindowManager:closeChildWindowsRecursive(window)
    for _, child in ipairs(window.childWindows) do
        child:removeFromUIManager()

        if child == self.openWindows[self.controllerWindowIndex] then
            self:previousWindow()
        end
        removeFromList(self.openWindows, child)

        self:closeChildWindowsRecursive(child)
    end
end

function TetrisWindowManager:closeAll()
    for _, child in ipairs(self.childWindows) do
        self:closeChildWindowsRecursive(child)
        child:removeFromUIManager()
    end
    self.childWindows = {}
    self.openWindows = {}
end

function TetrisWindowManager:closeTopWindow()
    local window = ItemGridWindow.getTopWindow()
    if not window then return false end
    window:close()
    return true
end

---@param player IsoPlayer
function TetrisWindowManager:onPlayerDeath(player)
    if player:getPlayerNum() == self.playerNum then
        self:closeAll()
        TetrisWindowManager._instances[self] = nil
    end
end

Events.OnPlayerDeath.Add(function(player)
    local instances = TetrisWindowManager._instances
    for windowManager, _ in pairs(instances) do
        windowManager:onPlayerDeath(player)
    end
end)
