---@diagnostic disable-next-line: undefined-global
local NotlocControllerNode = require("EquipmentUI/UI/NotlocControllerNode") or NotlocControllerNode -- Temporary until EquipmentUI removes its globals

function NotlocControllerNode.ensureVisible(uiElement)
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

function NotlocControllerNode.ensureVisibleXY(uiElement, screenX, screenY)
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

return NotlocControllerNode
