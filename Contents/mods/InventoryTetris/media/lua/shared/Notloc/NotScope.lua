-- Experimenting with calling functions inside of behavior modified scopes
-- The goal is to piggyback off of as much vanilla code as possible while still achieving desired behaviors
NotScope = {};

NotScope._returnActions = {}
NotScope._validReturnItems = {}

function NotScope.withItemReturns(playerObj, returnableItems, callback)
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

function NotScope._createReturnAction(playerObj, action)
    if not NotScope._validReturnItems[action.item] then
        return
    end

    local returnAction = ISInventoryTransferAction:newReturnAction(playerObj, action.item, action.destContainer, action.srcContainer)
    NotScope._registerReturnAction(playerObj, returnAction)
end

function NotScope._registerReturnAction(playerObj, action)
    if not NotScope._returnActions[playerObj] then
        NotScope._returnActions[playerObj] = {}
    end
    table.insert(NotScope._returnActions[playerObj], action)
end

function NotScope._popReturnActions(playerObj)
    local returnActions = NotScope._returnActions[playerObj]
    NotScope._returnActions[playerObj] = {}
    return returnActions or {}
end

Events.OnGameBoot.Add(function()
    local og_new = ISInventoryTransferAction.new
    ---@diagnostic disable-next-line: duplicate-set-field
    function ISInventoryTransferAction.new(self, character, ...)
        local o = og_new(self, character, ...)
        if ISInventoryTransferAction.NotScope_enableReturnActions then
            NotScope._createReturnAction(character, o)
        end
        return o
    end

    function ISInventoryTransferAction.newReturnAction(self, character, ...)
        return og_new(self, character, ...)
    end
end)
