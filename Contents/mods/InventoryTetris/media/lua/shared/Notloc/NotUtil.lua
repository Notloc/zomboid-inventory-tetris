if not NotUtil then
    NotUtil = {}
end

function NotUtil.forEachItemOnPlayer(playerObj, callbackFunc)
    local containers = NotUtil.getAllEquippedContainers(playerObj)
    for _, container in ipairs(containers) do
        local _items = container:getItems()
        local _itemCount = container:getItems():size() - 1
        for i = 0, _itemCount do
            callbackFunc(_items:get(i), container)
        end
    end
end

function NotUtil.getAllEquippedContainers(playerObj)
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

function NotUtil.createTransferActionWithReturn(item, sourceContainer, destinationContainer, playerObj)
    local transferActions, returnActions = NotUtil.createTransferActionsWithReturns({item}, sourceContainer, destinationContainer, playerObj)
    return transferActions[1], returnActions[1]
end

function NotUtil.createTransferActionsWithReturns(items, sourceContainer, destinationContainer, playerObj)
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


function NotUtil.slice(tbl, start, stop)
    local sliced = {}
    for i = start, stop do
        table.insert(sliced, tbl[i])
    end
    return sliced
end

function NotUtil.toTruthMap(tbl)
    local truthMap = {}
    for _, value in pairs(tbl) do
        truthMap[value] = true
    end
    return truthMap
end

---@class SimpleEvent
---@field add fun(self:SimpleEvent, listener: function)
---@field remove fun(self:SimpleEvent, listener: function)
---@field trigger function
---@field private _listeners function[]

---@return SimpleEvent
function NotUtil.createSimpleEvent()
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

---@param x number
---@param y number
---@param localSpace ISUIElement
---@param targetSpace ISUIElement
---@return number
---@return number
function NotUtil.Ui.convertCoordinates(x, y, localSpace, targetSpace)
    local x2 = x + localSpace:getAbsoluteX()
    local y2 = y + localSpace:getAbsoluteY()
    x2 = x2 - targetSpace:getAbsoluteX()
    y2 = y2 - targetSpace:getAbsoluteY()
    return x2, y2
end
