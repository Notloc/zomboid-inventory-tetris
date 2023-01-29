TetrisWindowManager = {}

function TetrisWindowManager:new(parent)
    o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.parent = parent
    o.childWindows = {}
  
    return o
end

function TetrisWindowManager:addChildWindow(window)
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
    window.onMouseDown = function(window, x, y)
        self:onChildWindowMouseDown(window, x, y)
        window:onMouseDown_preWindowManager(x, y)
    end
end

function TetrisWindowManager:addRemoveOnClose(window)
    -- Incase the window is being pooled/reused
    if not window.onClose_preWindowManager then
        window.onClose_preWindowManager = window.onClose
    end
    -- Remove the window from the stack when it is closed
    window.onClose = function(window)
        self:removeChildWindow(window)
        window:onClose_preWindowManager()
    end
end

function TetrisWindowManager:removeChildWindow(window)
    if self.childWindows then
        for i, child in ipairs(self.childWindows) do
            if child == window then
                table.remove(self.childWindows, i)
                window:removeFromUIManager()
                break
            end
        end
    end
end

function TetrisWindowManager:onChildWindowMouseDown(window, x, y)
    -- bring the window to the top of the stack
    --window:removeFromUIManager()
    --window:addToUIManager()
    window:bringToTop()
end

function TetrisWindowManager:keepChildWindowsOnTop()
    for _, child in ipairs(self.childWindows) do
        child:bringToTop()
    end
end

function TetrisWindowManager:closeAll()
    for _, child in ipairs(self.childWindows) do
        child:removeFromUIManager()
    end
    self.childWindows = {}
end