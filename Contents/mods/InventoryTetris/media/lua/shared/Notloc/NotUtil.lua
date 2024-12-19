if not NotUtil then
    NotUtil = {}
end

NotUtil.forEachItemOnPlayer = function(playerObj, callbackFunc)
    local containers = NotUtil.getAllEquippedContainers(playerObj)
    for _, container in ipairs(containers) do
        local _items = container:getItems()
        local _itemCount = container:getItems():size() - 1
        for i = 0, _itemCount do
            callbackFunc(_items:get(i), container)
        end
    end
end

NotUtil.getAllEquippedContainers = function(playerObj)
    local playerInv = getPlayerInventory(playerObj:getPlayerNum())
    local selectedContainer = playerInv.inventory
    local containers = {selectedContainer}
    
    for _, button in ipairs(playerInv.backpacks) do
        if button.inventory ~= selectedContainer then
            table.insert(containers, button.inventory)
        end
    end
    return containers
end

NotUtil.createTransferActionWithReturn = function(item, sourceContainer, destinationContainer, playerObj)
    local transferActions, returnActions = NotUtil.createTransferActionsWithReturns({item}, sourceContainer, destinationContainer, playerObj)
    return transferActions[1], returnActions[1]
end

NotUtil.createTransferActionsWithReturns = function(items, sourceContainer, destinationContainer, playerObj)
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


NotUtil.slice = function(tbl, start, stop)
    local sliced = {}
    for i = start, stop do
        table.insert(sliced, tbl[i])
    end
    return sliced
end

NotUtil.createSimpleEvent = function()
    local event = {}
    event._listeners = {}
    function event:add(func)
        table.insert(self._listeners, func)
    end
    function event:remove(func)
        table.remove(self._listeners, func)
    end
    function event:trigger(...)
        for _, func in ipairs(self._listeners) do
            func(...)
        end
    end
    return event
end

NotUtil.Ui = {}

NotUtil.Ui.convertCoordinates = function(x, y, localSpace, targetSpace)
    local x = x + localSpace:getAbsoluteX()
    local y = y + localSpace:getAbsoluteY()
    x = x - targetSpace:getAbsoluteX()
    y = y - targetSpace:getAbsoluteY()
    return x, y
end
