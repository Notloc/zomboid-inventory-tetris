---@class ControllerNode
---@field isFocused boolean
---@field injectControllerNode fun(self: ControllerNode, uiElement: ISUIElement) : ControllerNode
---@field doSimpleFocusHighlight fun(self: ControllerNode) : ControllerNode
---@field setJoypadDownHandler fun(self: ControllerNode, handler: fun(self: ISUIElement, button: integer): boolean) : ControllerNode
---@field setJoypadDirHandler fun(self: ControllerNode, handler: fun(self: ISUIElement, dx: integer, dy: integer, joypadData: JoypadData): boolean) : ControllerNode
local ControllerNode = require("Notloc/UI/ControllerNode") -- From EquipmentUI

function ControllerNode.ensureVisible(uiElement)
    local current = uiElement.parent
    while current do
        if current.Type == "ISInventoryPane" then
            current:scrollToPositionX(uiElement:getAbsoluteX() - 10)
            current:scrollToPositionY(uiElement:getAbsoluteY() + 50)
            return
        end
        current = current.parent
    end
end

function ControllerNode.ensureVisibleXY(uiElement, screenX, screenY)
    local current = uiElement.parent
    while current do
        if current.Type == "ISInventoryPane" then
            current:scrollToPositionX(screenX - 50)
            current:scrollToPositionY(screenY - 50)
            return
        end
        current = current.parent
    end
end

return ControllerNode
