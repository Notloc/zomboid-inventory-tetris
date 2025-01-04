-- Adjustments to the InventoryTransferAction to support the new rules for item transfers under the grid system and avoid illegal item placements.
---@diagnostic disable: duplicate-set-field

require("TimedActions/ISInventoryTransferAction")
local ItemUtil = require("Notloc/ItemUtil")


local function getOutermostContainer(container)
    if not container:getContainingItem() then
        return container
    end
    return container:getContainingItem():getOutermostContainer()
end

-- We REALLY need to be the last one to load here
Events.OnGameBoot.Add(function()
    ISInventoryTransferAction.globalTetrisRules = false

    local og_new = ISInventoryTransferAction.new
    function ISInventoryTransferAction:new (character, item, srcContainer, destContainer, time, ...)
        local o = og_new(self, character, item, srcContainer, destContainer, time, ...)

        if not SandboxVars.InventoryTetris.UseItemTransferTime then
            o.maxTime = 0
            o.stopOnRun = false
            o.stopOnWalk = false
        else
            o.maxTime = o.maxTime / SandboxVars.InventoryTetris.ItemTransferSpeedMultiplier

            local inv = character:getInventory()
            local srcRoot = getOutermostContainer(srcContainer)
            local destRoot = getOutermostContainer(destContainer)

            local destDef = TetrisContainerData.getContainerDefinition(destContainer)

            local isInInventory = inv == srcRoot and inv == destRoot
            local isDroppingToFloor = inv == srcRoot and destDef.trueType == "floor"
            o.stopOnWalk = not (isInInventory or isDroppingToFloor)

            o.isDroppingToFloor = isDroppingToFloor
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
        if self.preventMerge or action.preventMerge then return false end

        local canMerge = og_canMergeAction(self, action)
        if not canMerge then return false end

        -- Cannot merge tetris actions without explicit grid targets
        if self.enforceTetrisRules and self.gridX == nil then
            return false
        end

        local tetrisCanMerge = self.gridX == action.gridX
        tetrisCanMerge = tetrisCanMerge and self.gridY == action.gridY
        tetrisCanMerge = tetrisCanMerge and self.gridIndex == action.gridIndex
        tetrisCanMerge = tetrisCanMerge and self.isRotated == action.isRotated
        return tetrisCanMerge
    end

  

    -- Temp overrides instanceof to ensure instanceof never reports a Moveable as such
    -- At what point should I just dirty patch a method instead... this is kinda gross
    local function moveablesArentRealScope(callback, ...)
        local real_instanceof = instanceof
        local fake_instanceof = function(obj, class)
            if class == "Moveable" then return false end
            return real_instanceof(obj, class)
        end

        instanceof = fake_instanceof
        local results = {pcall(callback, ...)}
        instanceof = real_instanceof

        if results[1] then
            return unpack(results, 2)
        else
            error(results[2])
        end
    end

    local og_isValid = ISInventoryTransferAction.isValid
    function ISInventoryTransferAction:isValid()
        local destDef = TetrisContainerData.getContainerDefinition(self.destContainer)
        local destType = destDef.trueType

        local valid;
        -- If we are moving a Moveable to anywhere but the floor, ensure it does NOT appear to be a Moveable
        if destType ~= "floor" and instanceof(self.item, "Moveable") then
            valid = moveablesArentRealScope(og_isValid, self)
        else
            valid = og_isValid(self)
        end

        if not valid or not self.enforceTetrisRules then
            return valid
        end
        return self:validateTetrisRules()
    end

    local og_doActionAnim = ISInventoryTransferAction.doActionAnim
    function ISInventoryTransferAction:doActionAnim(...)
        og_doActionAnim(self, ...)

        -- Player gets stuck crouched when dropping to the floor unless we force them to use the standing version
        if self.isDroppingToFloor then
            self:setActionAnim("DropWhileMoving");
        end
    end

    function ISInventoryTransferAction:validateTetrisRules()
        if not self:validateTetrisSquishable(self.destContainer, self.item) then
            return false
        end

        local containerGrid = ItemContainerGrid.GetOrCreate(self.destContainer, self.character:getPlayerNum())
        if self.gridX and self.gridY and self.gridIndex then
            local doesFit = containerGrid:doesItemFit(self.item, self.gridX, self.gridY, self.gridIndex, self.isRotated, self.tetrisSecondary) or containerGrid:canItemBeStacked(self.item, self.gridX, self.gridY, self.gridIndex, self.tetrisSecondary)
            if not doesFit then
                return false
            end
        end

        if containerGrid.isFloor then
            return true
        else
            return containerGrid:canAddItem(self.item)
        end
    end

    function ISInventoryTransferAction:validateTetrisSquishable(destContainer, item)
        local containerDef = TetrisContainerData.getContainerDefinition(destContainer)
        -- Container is not squishable, so the size will not change
        if containerDef.isRigid then
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

                local equippedContainers = ItemUtil.getAllEquippedContainers(self.character)
                for _, container in ipairs(equippedContainers) do
                    if container == destContainer then
                        --return true -- The container will self correct
                        -- DISABLED
                        -- The item gets dropped or repositioned in the inventory
                        -- But users keep thinking the item is getting deleted
                    end
                end

                local w, h = TetrisItemData.getItemSizeUnsquished(itemContainer)
                local parentContainerGrid = ItemContainerGrid.GetOrCreate(parentInventory, self.character:getPlayerNum())
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

            local destContainerGrid = ItemContainerGrid.GetOrCreate(self.destContainer, self.character:getPlayerNum())
            if self.gridX and self.gridY and self.gridIndex then
                destContainerGrid:insertItem(item, self.gridX, self.gridY, self.gridIndex, self.isRotated, self.tetrisSecondary)
            else
                local disorganized = self.character:HasTrait("Disorganized")
                destContainerGrid:attemptToInsertItem(item, self.isRotated, disorganized)
            end

            -- Handle squishable items changing size
            local newItemCount = self.destContainer:getItems():size()
            if originalItemCount == 0 and newItemCount > 0 or newItemCount == 0 and originalItemCount > 0 then
                local itemContainer = self.destContainer:getContainingItem()
                if itemContainer then
                    local parentInventory = itemContainer:getContainer()
                    if parentInventory and TetrisItemData.isSquishable(itemContainer) then
                        local parentContainerGrid = ItemContainerGrid.GetOrCreate(parentInventory, self.character:getPlayerNum())
                        local stack, grid = parentContainerGrid:findStackByItem(itemContainer)
                        parentContainerGrid:removeItem(itemContainer)
                        if not stack or (grid and not parentContainerGrid:insertItem(itemContainer, stack.x, stack.y, grid.gridIndex, stack.isRotated, grid.secondaryTarget)) then
                            parentContainerGrid:attemptToInsertItem(itemContainer, self.isRotated, false)
                        end
                        parentInventory:setDrawDirty(true)
                    end
                end
            end
        end
    end

end)
