---@diagnostic disable: duplicate-set-field

require "TimedActions/ISInventoryTransferAction"
require "Notloc/NotUtil"

-- We really need to be the last one to load for this one
Events.OnGameBoot.Add(function()
    ISInventoryTransferAction.globalTetrisRules = false

    local og_new = ISInventoryTransferAction.new
    function ISInventoryTransferAction:new (character, item, srcContainer, destContainer, time, ...)
        local o = og_new(self, character, item, srcContainer, destContainer, time, ...)

        o.stopOnRun = false
        o.stopOnWalk = false

        if not SandboxVars.InventoryTetris.UseItemTransferTime then
            o.maxTime = 0
        else
            o.maxTime = o.maxTime / SandboxVars.InventoryTetris.ItemTransferSpeedMultiplier
        end

        if ISInventoryTransferAction.globalTetrisRules then
            o.enforceTetrisRules = true
        end

        return o
    end

    function ISInventoryTransferAction:setTetrisTarget(x, y, i, r, secondaryTarget)
        self.gridX = x
        self.gridY = y
        self.gridIndex = i
        self.isRotated = r
        self.tetrisSecondary = secondaryTarget
        self.enforceTetrisRules = true
    end

    local og_start = ISInventoryTransferAction.start
    function ISInventoryTransferAction:start()
        og_start(self)
        if not SandboxVars.InventoryTetris.UseItemTransferTime then
            self.maxTime = 0
            self.action:setTime(0)
        end
    end

    local og_canMergeAction = ISInventoryTransferAction.canMergeAction
    function ISInventoryTransferAction:canMergeAction(action)
        local canMerge = og_canMergeAction(self, action)
        if not canMerge then return false end

        local tetrisCanMerge = self.gridX == action.gridX
        tetrisCanMerge = tetrisCanMerge and self.gridY == action.gridY
        tetrisCanMerge = tetrisCanMerge and self.gridIndex == action.gridIndex
        tetrisCanMerge = tetrisCanMerge and self.isRotated == action.isRotated
        return tetrisCanMerge
    end

    local og_isValid = ISInventoryTransferAction.isValid
    function ISInventoryTransferAction:isValid()
        local valid = og_isValid(self)
        if not valid or not self.enforceTetrisRules then
            return valid
        end

        return self:validateTetrisRules()
    end

    function ISInventoryTransferAction:validateTetrisRules()
        if not self:validateTetrisSquishable(self.destContainer, self.item) then
            return false
        end

        local containerGrid = ItemContainerGrid.Create(self.destContainer, self.character:getPlayerNum())
        if self.gridX and self.gridY and self.gridIndex then
            local doesFit = containerGrid:doesItemFit(self.item, self.gridX, self.gridY, self.gridIndex, self.isRotated, self.tetrisSecondary) or containerGrid:canItemBeStacked(self.item, self.gridX, self.gridY, self.gridIndex, self.tetrisSecondary)
            if not doesFit then
                return false
            end
        end

        if self.destContainer:getType() == "floor" then
            return true
        else
            return containerGrid:canAddItem(self.item)
        end
    end

    function ISInventoryTransferAction:validateTetrisSquishable(destContainer, item)
        local containerDef = TetrisContainerData.getContainerDefinition(destContainer)
        -- Container is not squishable, so the size will not change
        if not containerDef.isSquishable then
            return true
        end

        -- Container already contains items, so the size will not change
        if not destContainer:isEmpty() then return true end

        local itemContainer = self.destContainer:getContainingItem()

        -- No need to validate if the destContainer is equipped, it doesn't need space
        if itemContainer and itemContainer:isEquipped() then
            return true
        end

        if itemContainer then
            local parentInventory = itemContainer:getContainer()
            if parentInventory then
                if parentInventory:getType() == "floor" then
                    return true
                end

                local equippedContainers = NotUtil.getAllEquippedContainers(self.character)
                for _, container in ipairs(equippedContainers) do
                    if container == destContainer then
                        --return true -- The container will self correct
                        -- DISABLED
                        -- The item gets dropped or repositioned in the inventory
                        -- But users keep thinking the item is getting deleted
                    end
                end

                local w, h = TetrisItemData.getItemSizeUnsquished(itemContainer)
                local parentContainerGrid = ItemContainerGrid.Create(parentInventory, self.character:getPlayerNum())
                return parentContainerGrid:doesItemFitAnywhere(itemContainer, w, h, {itemContainer, item})
            end
        end
        return true
    end

    local og_transferItem = ISInventoryTransferAction.transferItem
    function ISInventoryTransferAction:transferItem(item)
        local originalItemCount = self.destContainer:getItems():size()
        local wasAlreadyTransferred = self:isAlreadyTransferred(item)

        og_transferItem(self, item)

        -- The Item made it to the destination container
        if not wasAlreadyTransferred and self:isAlreadyTransferred(item) then
            -- Only need to remove the item from the source grid if it's actively displayed in the UI
            local oldContainerGrid = ItemContainerGrid.FindInstance(self.srcContainer, self.character:getPlayerNum())
            if oldContainerGrid then
                oldContainerGrid:removeItem(item)
            end

            local destContainerGrid = ItemContainerGrid.Create(self.destContainer, self.character:getPlayerNum())
            if self.gridX and self.gridY and self.gridIndex then
                destContainerGrid:insertItem(item, self.gridX, self.gridY, self.gridIndex, self.isRotated, self.tetrisSecondary)
            else
                local organized = self.character:HasTrait("Organized")
                local disorganized = self.character:HasTrait("Disorganized")
                destContainerGrid:attemptToInsertItem(item, self.isRotated, organized, disorganized)
            end

            -- Handle squishable items changing size
            local newItemCount = self.destContainer:getItems():size()
            if originalItemCount == 0 and newItemCount > 0 or newItemCount == 0 and originalItemCount > 0 then
                local itemContainer = self.destContainer:getContainingItem()
                if itemContainer then
                    local parentInventory = itemContainer:getContainer()
                    if parentInventory and TetrisItemData.isSquishable(itemContainer) then
                        local parentContainerGrid = ItemContainerGrid.Create(parentInventory, self.character:getPlayerNum())
                        local stack, grid = parentContainerGrid:findStackByItem(itemContainer)
                        parentContainerGrid:removeItem(itemContainer)
                        if not stack or (grid and not parentContainerGrid:insertItem(itemContainer, stack.x, stack.y, grid.gridIndex, stack.isRotated, grid.secondaryTarget)) then
                            parentContainerGrid:attemptToInsertItem(itemContainer, self.isRotated, true, false)
                        end
                        parentInventory:setDrawDirty(true)
                    end
                end
            end
        end
    end

end)
