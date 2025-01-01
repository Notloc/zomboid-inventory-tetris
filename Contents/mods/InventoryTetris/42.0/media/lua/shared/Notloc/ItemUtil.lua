local ItemUtil = {}

function ItemUtil.canBeRead(item, playerObj)
    -- Not a book
    if not item or item:getCategory() ~= "Literature" or item:canBeWrite() then
        return false
    end
    
    -- Character can't read
    if playerObj:getTraits():isIlliterate() then
        return false
    end

    -- No skill required
    local skillLvlTrained = item:getLvlSkillTrained()
    if skillLvlTrained == -1 then
        return true
    end

    -- Skill too low
    local perk = SkillBook[skillLvlTrained].perk
    if perk and	skillLvlTrained > playerObj:getPerkLevel(perk) + 1 then   
        return false
    end

    return true
end

function ItemUtil.canEat(item)
    return item:getCategory() == "Food" and not item:getScriptItem():isCantEat()
end

function ItemUtil.canEquipItem(item)
    return not ItemUtil.canEat(item) and not item:IsClothing() and not item:isBroken()
end

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

function ItemUtil.getAllEquippedContainers(playerObj, ignoreMainInventory)
    local containers = {}
    local mainInv = playerObj:getInventory()

    local inventoryPage = getPlayerInventory(playerObj:getPlayerNum())
    local selectedContainer = inventoryPage.inventory
    if not ignoreMainInventory or selectedContainer ~= mainInv then
        table.insert(containers, selectedContainer)
    end

    for _, button in ipairs(inventoryPage.backpacks) do
        if button.inventory ~= selectedContainer and (not ignoreMainInventory or button.inventory ~= mainInv) then
            table.insert(containers, button.inventory)
        end
    end
    return containers
end

function ItemUtil.createTransferActionWithReturn(item, sourceContainer, destinationContainer, playerObj)
    local transferActions, returnActions = ItemUtil.createTransferActionsWithReturns({item}, sourceContainer, destinationContainer, playerObj)
    return transferActions[1], returnActions[1]
end

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

    if gatheredItems < count then
        return false
    end

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
