TetrisEvents = {}

TetrisEvents._genericTrigger = function(event, ...)
    local data = TetrisEvents.createEventData(event)
    for _, handler in ipairs(event._eventHandlers) do
        if handler.validate(data, ...) then
            data.isConsumed = true
            handler.call(data, ...)
        end

        if data.isConsumed then
            break
        end
    end
end

TetrisEvents.createEvent = function(name, triggerFunc)
    local event = {}
    event._name = name

    event._eventHandlers = {}
    function event:add(handler)
        table.insert(self._eventHandlers, handler)
    end
    function event:remove(handler)
        table.remove(self._eventHandlers, handler)
    end
    
    if not triggerFunc then
        triggerFunc = TetrisEvents._genericTrigger
    end
    event.trigger = triggerFunc

    return event
end

TetrisEvents.createEventData = function(event)
    local data = {}
    data.name = event._name
    data.isConsumed = false
    return data
end


-- Call Signature: (eventData, droppedStack, fromInventory, targetStack, targetInventory, playerNum)
TetrisEvents.OnStackDroppedOnStack = TetrisEvents.createEvent("OnStackDroppedOnStack", function(self, dragStack, fromInv, targetStack, targetInv, playerNum)
    if isDebugEnabled() then
        local dragClass = TetrisItemCategory.getCategory(dragStack.items[1])
        local targetClass = TetrisItemCategory.getCategory(targetStack.items[1])
        print("Firing OnStackDroppedOnStack!")
        print("Dragged: " .. dragClass)
        print("Target: " .. targetClass)
    end

    TetrisEvents._genericTrigger(self, dragStack, fromInv, targetStack, targetInv, playerNum)
end)
