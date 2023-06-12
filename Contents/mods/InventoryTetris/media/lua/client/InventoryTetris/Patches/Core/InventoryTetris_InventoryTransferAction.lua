require "TimedActions/ISInventoryTransferAction"

-- We really need to be the last one to load for this one
Events.OnGameBoot.Add(function()
    local og_new = ISInventoryTransferAction.new
    function ISInventoryTransferAction:new (character, item, srcContainer, destContainer, time, ...)
        local o = og_new(self, character, item, srcContainer, destContainer, time, ...)

        o.stopOnRun = false
        o.stopOnWalk = false

        -- Make the transfers instant
        -- The user's personal time spent arranging items in the grid "replaces" the time spent moving the items
        o.maxTime = 0
        return o
    end

    function ISInventoryTransferAction:setTetrisTarget(x, y, i, r)
        self.gridX = x
        self.gridY = y
        self.gridIndex = i
        self.isRotated = r
    end

    local og_start = ISInventoryTransferAction.start
    function ISInventoryTransferAction:start()
        og_start(self)
        self.maxTime = 0
        self.action:setTime(0)
    end

    local og_canMergeAction = ISInventoryTransferAction.canMergeAction
    function ISInventoryTransferAction:canMergeAction(action)
        local canMerge = og_canMergeAction(self, action)
        if not canMerge then return false end

        local tetrisCanMerge = self.tetrisForceAllow == action.tetrisForceAllow
        tetrisCanMerge = tetrisCanMerge and self.gridX == action.gridX
        tetrisCanMerge = tetrisCanMerge and self.gridY == action.gridY
        tetrisCanMerge = tetrisCanMerge and self.gridIndex == action.gridIndex
        tetrisCanMerge = tetrisCanMerge and self.isRotated == action.isRotated
        return tetrisCanMerge
    end

    local og_isValid = ISInventoryTransferAction.isValid
    function ISInventoryTransferAction:isValid()
        local valid = og_isValid(self)
        if not valid and (self.srcContainer ~= self.destContainer or not self.gridX or not self.gridY or not self.gridIndex) then
            return false
        end

        if self.tetrisForceAllow or TimedActionSnooper.findUpcomingActionThatHandlesItem(self.character, self.item, self) then
            return true
        end

        local containerGrid = ItemContainerGrid.Create(self.destContainer, self.character:getPlayerNum())
        if self.gridX and self.gridY and self.gridIndex then
            return containerGrid:doesItemFit(self.item, self.gridX, self.gridY, self.gridIndex, self.isRotated) or containerGrid:canItemBeStacked(self.item, self.gridX, self.gridY, self.gridIndex)
        elseif self.destContainer:getType() == "floor" then
            return true
        else
            return containerGrid:canAddItem(self.item)
        end
    end

    local og_transferItem = ISInventoryTransferAction.transferItem
    function ISInventoryTransferAction:transferItem(item)
        og_transferItem(self, item)

        -- The Item made it to the destination container
        if self:isAlreadyTransferred(item) then
            -- Only need to remove the item from the source grid if it's actively displayed in the UI
            local oldContainerGrid = ItemContainerGrid.FindInstance(self.srcContainer, self.character:getPlayerNum())
            if oldContainerGrid then
                oldContainerGrid:removeItem(item)
            end

            local destContainerGrid = ItemContainerGrid.Create(self.destContainer, self.character:getPlayerNum())
            if self.gridX and self.gridY and self.gridIndex then
                destContainerGrid:insertItem(item, self.gridX, self.gridY, self.gridIndex, self.isRotated)
            else
                local organized = self.character:HasTrait("Organized")
                local disorganized = self.character:HasTrait("Disorganized")

                destContainerGrid:attemptToInsertItem(item, self.isRotated, organized, disorganized)
            end
        end
    end
end)