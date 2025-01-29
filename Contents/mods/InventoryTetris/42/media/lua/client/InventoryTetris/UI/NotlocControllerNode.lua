---@diagnostic disable-next-line: undefined-global
local NotlocControllerNode = require("EquipmentUI/UI/NotlocControllerNode") or NotlocControllerNode -- Temporary until EquipmentUI removes its globals

function NotlocControllerNode.ensureVisible(uiElement)
    local current = uiElement.parent
    while current do
        if current.Type == "NotlocScrollView" then
            current:ensureChildIsVisible(uiElement, 50)
            current:scrollToPositionX(uiElement:getAbsoluteX() - 10)
            return
        end
        current = current.parent
    end
end

function NotlocControllerNode.ensureVisibleXY(uiElement, screenX, screenY)
    local current = uiElement.parent
    while current do
        if current.Type == "NotlocScrollView" then
            current:scrollToPositionX(screenX - 50)
            current:scrollToPositionY(screenY - 50)
            return
        end
        current = current.parent
    end
end

return NotlocControllerNode
