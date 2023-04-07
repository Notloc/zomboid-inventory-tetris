require "TimedActions/ISInventoryTransferAction"

local og_new = ISInventoryTransferAction.new
function ISInventoryTransferAction:new (character, item, srcContainer, destContainer, time, gridX, gridY, gridIndex, rotate)
	local o = og_new(self, character, item, srcContainer, destContainer, time)

    o.gridX = gridX
    o.gridY = gridY
    o.gridIndex = gridIndex
    o.rotate = rotate

    o.stopOnRun = false
    o.stopOnWalk = false

    -- Make the transfers instant
    -- The user's personal time spent arranging items in the grid "replaces" the time spent moving the items
    o.maxTime = 0
    return o
end

local og_start = ISInventoryTransferAction.start
function ISInventoryTransferAction:start()
    og_start(self)
	self.maxTime = 0
	self.action:setTime(0)
end

local og_isValid = ISInventoryTransferAction.isValid
function ISInventoryTransferAction:isValid()
    local valid = og_isValid(self)
    if not valid and (self.srcContainer ~= self.destContainer or not self.gridX or not self.gridY or not self.gridIndex) then
        return valid
    end

    if TimedActionSnooper.findUpcomingActionThatHandlesItem(self.character, self.item, self) then
        return true
    end

    local containerGrid = ItemContainerGrid.Create(self.destContainer, self.character:getPlayerNum())
    if self.gridX and self.gridY and self.gridIndex then
        return containerGrid:doesItemFit(self.item, self.gridX, self.gridY, self.gridIndex, self.rotate) or containerGrid:canItemBeStacked(self.item, self.gridX, self.gridY, self.gridIndex)
    elseif self.destContainer:getType() == "floor" then
        return true
    else
        self.rotate = false
        return containerGrid:canAddItem(self.item)
    end
end

local og_transferItem = ISInventoryTransferAction.transferItem
function ISInventoryTransferAction:transferItem(item)
    og_transferItem(self, item)

    -- The Item made it to the destination container
    if self:isAlreadyTransferred(item) then

        -- Only need to remove the item from the source container if it's actively displayed in the UI
        local oldContainerGrid = ItemContainerGrid.FindInstance(self.srcContainer, self.character:getPlayerNum())
        if oldContainerGrid then
            oldContainerGrid:removeItem(item)
        end

        if self.rotate then
            ItemGridUtil.rotateItem(item)
        end

        ItemGridUtil.clearItemPosition(item)

        local destContainerGrid = ItemContainerGrid.Create(self.destContainer, self.character:getPlayerNum())
        if self.gridX and self.gridY and self.gridIndex then
            destContainerGrid:insertItem(item, self.gridX, self.gridY, self.gridIndex)
        else
            destContainerGrid:attemptToInsertItem(item)
        end
    end
end

