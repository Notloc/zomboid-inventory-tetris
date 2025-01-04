require("EquipmentUI/UI/NotlocScrollView")

function NotlocScrollView:scrollToPositionX(screenXPos)
    local xPos = screenXPos - self:getAbsoluteX()

    local scrollX = self:getXScroll()
    local newScroll = scrollX - xPos
    if newScroll > 0 then
        newScroll = 0
    end
    self:setXScroll(newScroll)
    self:updateScroll()
end

function NotlocScrollView:scrollToPositionY(screenYPos)
    local yPos = screenYPos - self:getAbsoluteY()

    local scrollY = self:getYScroll()
    local newScroll = scrollY - yPos
    if newScroll > 0 then
        newScroll = 0
    end
    self:setYScroll(newScroll)
    self:updateScroll()
end
