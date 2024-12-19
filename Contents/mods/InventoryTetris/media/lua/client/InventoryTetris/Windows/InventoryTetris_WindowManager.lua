TetrisWindowManager = {}

function TetrisWindowManager:new(parent)
    o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.parent = parent
    o.childWindows = {}
  
    return o
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

function TetrisWindowManager:addBaseChildWindow(window)
    table.insert(self.childWindows, window)

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

function TetrisWindowManager:removeChildWindow(window)
    for i, child in ipairs(self.childWindows) do
        if child == window then
            table.remove(self.childWindows, i)
            window:removeFromUIManager()
            break
        end
    end
end

function TetrisWindowManager:keepChildWindowsOnTop()
    for _, child in ipairs(self.childWindows) do
        child:bringToTop()
    end
end

function TetrisWindowManager:openContainerPopup(item, playerNum, invPane)
    if not item or not item:getContainer() then return end
    
    if isClient() then -- Prevent multiplayer dupe glitch
        local playerObj = getSpecificPlayer(playerNum)
        local outerContainer = item:getOutermostContainer()
        if outerContainer ~= playerObj:getInventory() and outerContainer ~= nil then
            return
        end
    end

    local itemGridWindow = ItemGridWindow:new(getMouseX(), getMouseY(), item:getInventory(), invPane, playerNum)
    itemGridWindow:initialise()
    itemGridWindow:addToUIManager()
    itemGridWindow:bringToTop()
    itemGridWindow.childWindows = {}
    itemGridWindow.parentInventory = item:getContainer()
    itemGridWindow.item = item

    local parentWindow = self:findWindowByInventory(item:getContainer())
    if parentWindow then
        table.insert(parentWindow.childWindows, itemGridWindow)
    else
        self:addBaseChildWindow(itemGridWindow)
    end
end

function TetrisWindowManager:closeIfNotInMap(validInventoryMap)    
    -- Loop backwards so we can remove items from the list
    for i = #self.childWindows, 1, -1 do
        local child = self.childWindows[i]
        local inv = child.parentInventory
        
        if not validInventoryMap[inv] or not inv:contains(child.item) then
            child:removeFromUIManager()
            table.remove(self.childWindows, i)
            self:closeChildWindowsRecursive(child)
        end
    end

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
            self:closeChildWindowsRecursive(child)
        else
            self:closeIfMovedRecursive(child)
        end
    end
end

function TetrisWindowManager:closeChildWindowsRecursive(window)
    for _, child in ipairs(window.childWindows) do
        child:removeFromUIManager()
        self:closeChildWindowsRecursive(child)
    end
end

function TetrisWindowManager:closeAll()
    for _, child in ipairs(self.childWindows) do
        child:removeFromUIManager()
    end
    self.childWindows = {}
end

function TetrisWindowManager:closeTopWindow()
    local window = ItemGridWindow.getTopWindow()
    if not window then return false end
    window:close()
    return true
end