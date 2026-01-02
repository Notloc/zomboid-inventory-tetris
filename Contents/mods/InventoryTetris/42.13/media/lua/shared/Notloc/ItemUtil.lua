local ItemUtil = {}

---@param item InventoryItem
---@param playerObj IsoPlayer
---@return boolean
function ItemUtil.canBeRead(item, playerObj)
    if not instanceof(item, "Literature") then
        return false
    end

    ---@cast item Literature

    -- Not a book
    if item:canBeWrite() then
        return false
    end
    
    -- Character can't read
    if playerObj:hasTrait(CharacterTrait.ILLITERATE) then
        return false
    end

    -- No skill required
    local skillLvlTrained = item:getLvlSkillTrained()
    if skillLvlTrained == -1 then
        return true
    end

    local skillTrained = item:getSkillTrained()

    -- Skill too low
    local perk = SkillBook[skillTrained].perk
    if perk and	skillLvlTrained > playerObj:getPerkLevel(perk) + 1 then   
        return false
    end

    return true
end

---@param item InventoryItem
---@return boolean
function ItemUtil.canEat(item)
    return item:getCategory() == "Food" and not item:getScriptItem():isCantEat()
end

---@param item InventoryItem
---@return boolean
function ItemUtil.canEquipItem(item)
    return not ItemUtil.canEat(item) and not item:IsClothing() and not item:isBroken()
end

---@param playerObj IsoPlayer
---@param callbackFunc fun(item: InventoryItem, container: ItemContainer)
---@param ignoreMainInventory boolean?
function ItemUtil.forEachItemOnPlayer(playerObj, callbackFunc, ignoreMainInventory)
    local containers = ItemUtil.getAllEquippedContainers(playerObj, ignoreMainInventory)
    for _, container in ipairs(containers) do
        local _items = container:getItems()
        local _itemCount = container:getItems():size() - 1
        for i = 0, _itemCount do
            callbackFunc(_items:get(i), container)
        end
    end
end


-- TODO: Remove this, there is a vanilla function that does the same thing
---@param playerObj IsoPlayer
---@param ignoreMainInventory boolean?
---@return ItemContainer[]
function ItemUtil.getAllEquippedContainers(playerObj, ignoreMainInventory)
    local containers = {}
    local mainInv = playerObj:getInventory()

    local inventoryPage = getPlayerInventory(playerObj:getPlayerNum())
    if not inventoryPage then
        return containers
    end

    local selectedContainer = inventoryPage.inventory
    if not ignoreMainInventory or selectedContainer ~= mainInv then
        table.insert(containers, selectedContainer)
    end

    for _, button in ipairs(inventoryPage.backpacks) do
        ---@diagnostic disable-next-line: undefined-field
        local inv = button.inventory

        if inv ~= selectedContainer and (not ignoreMainInventory or inv ~= mainInv) then
            table.insert(containers, inv)
        end
    end
    return containers
end

---@param item InventoryItem
---@param sourceContainer ItemContainer
---@param destinationContainer ItemContainer
---@param playerObj IsoPlayer
---@return ISInventoryTransferAction, ISInventoryTransferAction
function ItemUtil.createTransferActionWithReturn(item, sourceContainer, destinationContainer, playerObj)
    local transferActions, returnActions = ItemUtil.createTransferActionsWithReturns({item}, sourceContainer, destinationContainer, playerObj)
    ---@diagnostic disable-next-line: return-type-mismatch
    return transferActions[1], returnActions[1]
end

---@param items InventoryItem[]
---@param sourceContainer ItemContainer
---@param destinationContainer ItemContainer
---@param playerObj IsoPlayer
---@return ISInventoryTransferAction[], ISInventoryTransferAction[]
function ItemUtil.createTransferActionsWithReturns(items, sourceContainer, destinationContainer, playerObj)
    local transferActions = {}
    local returnActions = {}
    for _, item in ipairs(items) do
        local action = ISInventoryTransferAction:new(playerObj, item, sourceContainer, destinationContainer)
        table.insert(transferActions, action)

        local returnAction = ISInventoryTransferAction:new(playerObj, item, destinationContainer, sourceContainer)
        table.insert(returnActions, returnAction)
    end
    return transferActions, returnActions
end

---@param playerNum integer
---@param itemType string
---@param count integer
---@return boolean
function ItemUtil.canGatherItems(playerNum, itemType, count)
    local playerObj = getSpecificPlayer(playerNum)
    local containers = ItemUtil.getAllEquippedContainers(playerObj)
    local gatheredItems = 0

    for _, container in ipairs(containers) do
        local items = container:getItems()
        local itemCount = items:size() - 1
        for i = 0, itemCount do
            local item = items:get(i)
            if item:getFullType() == itemType then
                gatheredItems = gatheredItems + 1
                if gatheredItems >= count then
                    return true
                end
            end
        end
    end

    local groundContainer = ISInventoryPage.GetFloorContainer(playerNum)
    local items = groundContainer:getItems()
    local itemCount = items:size() - 1
    for i = 0, itemCount do
        local item = items:get(i)
        if item:getFullType() == itemType then
            gatheredItems = gatheredItems + 1
            if gatheredItems >= count then
                return true
            end
        end
    end

    return false
end

---@param playerNum integer
---@param itemType string
---@param count integer
---@return boolean
function ItemUtil.gatherItems(playerNum, itemType, count)
    local playerObj = getSpecificPlayer(playerNum)
    local containers = ItemUtil.getAllEquippedContainers(playerObj)

    local gatheredItems = 0
    local itemAndSourcePairs = {}

    local playerInv = playerObj:getInventory()
    for _, container in ipairs(containers) do
        local items = container:getItems()
        local itemCount = items:size() - 1
        for i = 0, itemCount do
            local item = items:get(i)
            if item:getFullType() == itemType then
                gatheredItems = gatheredItems + 1

                if container ~= playerInv then
                    table.insert(itemAndSourcePairs, {item, container})
                end
                if gatheredItems >= count then
                    break
                end
            end
        end
    end

    -- Search the floor
    if gatheredItems < count then
        local groundContainer = ISInventoryPage.GetFloorContainer(playerNum)
        local items = groundContainer:getItems()
        local itemCount = items:size() - 1
        for i = 0, itemCount do
            local item = items:get(i)
            if item:getFullType() == itemType then
                gatheredItems = gatheredItems + 1
                table.insert(itemAndSourcePairs, {item, groundContainer})
                if gatheredItems >= count then
                    break
                end
            end
        end
    end

    -- Could not gather enough items
    if gatheredItems < count then
        return false
    end

    -- Transfer the gathered items to the player's main inventory
    for i, itemAndSource in ipairs(itemAndSourcePairs) do
        local item = itemAndSource[1]
        local sourceContainer = itemAndSource[2]
        local destinationContainer = playerInv
        local transferAction = ISInventoryTransferAction:new(playerObj, item, sourceContainer, destinationContainer)
        transferAction.preventMerge = true
        ISTimedActionQueue.add(transferAction)
    end
    return true
end

return ItemUtil
