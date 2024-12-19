-- Experimenting with calling functions inside of behavior modified scopes
-- The goal is to piggyback off of as much vanilla code as possible while still achieving desired behaviors
NotScope = {};

NotScope._returnActions = {}
NotScope._validReturnItems = {}

NotScope.withItemReturns = function(playerObj, returnableItems, callback)
    local items = {}
    for _, item in ipairs(returnableItems) do
        items[item] = true
    end
    NotScope._validReturnItems = items

    ISInventoryTransferAction.NotScope_enableReturnActions = true
    pcall(callback)
    ISInventoryTransferAction.NotScope_enableReturnActions = false

    local returnActions = NotScope._popReturnActions(playerObj)
    for _, action in ipairs(returnActions) do
        ISTimedActionQueue.add(action)
    end
end

NotScope._createReturnAction = function(playerObj, action)
    if not NotScope._validReturnItems[action.item] then
        return
    end

    local returnAction = ISInventoryTransferAction:newReturnAction(playerObj, action.item, action.destContainer, action.srcContainer)
    NotScope._registerReturnAction(playerObj, returnAction)
end

NotScope._registerReturnAction = function(playerObj, action)
    if not NotScope._returnActions[playerObj] then
        NotScope._returnActions[playerObj] = {}
    end
    table.insert(NotScope._returnActions[playerObj], action)
end

NotScope._popReturnActions = function(playerObj)
    local returnActions = NotScope._returnActions[playerObj]
    NotScope._returnActions[playerObj] = {}
    return returnActions or {}
end

Events.OnGameBoot.Add(function()
    local og_new = ISInventoryTransferAction.new
    
    ISInventoryTransferAction.new = function(self, character, ...)
        local o = og_new(self, character, ...)
        
        if ISInventoryTransferAction.NotScope_enableReturnActions then
            NotScope._createReturnAction(character, o)
        end
        
        return o
    end

    ISInventoryTransferAction.newReturnAction = function(self, character, ...)
        return og_new(self, character, ...)
    end
end)