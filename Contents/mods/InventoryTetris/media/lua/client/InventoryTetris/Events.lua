TetrisEvents = {}

TetrisEvents._genericTrigger = function(event, ...)
    local data = TetrisEvents.createEventData(event)
    for _, handler in ipairs(event._eventHandlers) do
        handler.call(data, ...)
    end
end

TetrisEvents._genericConsumableTrigger = function(event, ...)
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

    return data.isConsumed
end

TetrisEvents.createEvent = function(name, triggerFunc)
    local event = {}
    event._name = name
    event.trigger = triggerFunc

    event._eventHandlers = {}
    function event:add(handler)
        table.insert(self._eventHandlers, handler)
    end
    function event:remove(handler)
        table.remove(self._eventHandlers, handler)
    end
    
    return event
end

TetrisEvents.createEventData = function(event)
    local data = {}
    data.name = event._name
    data.isConsumed = false
    return data
end


TetrisEvents.OnItemInteract = TetrisEvents.createEvent("OnItemInteract", function(self, itemStack, playerNum)
    TetrisEvents._genericConsumableTrigger(self, itemStack, playerNum)
end)

TetrisEvents.OnStackDroppedOnStack = TetrisEvents.createEvent("OnStackDroppedOnStack", function(self, dragStack, fromInv, targetStack, targetInv, playerNum)
    TetrisEvents._genericConsumableTrigger(self, dragStack, fromInv, targetStack, targetInv, playerNum)
end)

TetrisEvents.OnPostRenderGridItem = TetrisEvents.createEvent("OnPostRenderGridItem", function(self, drawingContext, item, gridStack, x, y, width, height, playerObj)
    TetrisEvents._genericTrigger(self, drawingContext, item, gridStack, x, y, width, height, playerObj)
end)
