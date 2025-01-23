TetrisEvents = {}

function TetrisEvents._genericTrigger(event, ...)
    local data = TetrisEvents.createEventData(event)
    for _, handler in ipairs(event._eventHandlers) do
        handler.call(data, ...)
    end
end

function TetrisEvents._genericConsumableTrigger(event, ...)
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

function TetrisEvents.createEvent(name, triggerFunc)
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

function TetrisEvents.createEventData(event)
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

---@deprecated - Use OnPostRenderGrid instead, this event is no longer called due to performance reasons.
TetrisEvents.OnPostRenderGridItem = TetrisEvents.createEvent("OnPostRenderGridItem", function(self, drawingContext, item, gridStack, x, y, width, height, playerObj)
    TetrisEvents._genericTrigger(self, drawingContext, item, gridStack, x, y, width, height, playerObj)
end)


---@class TetrisRenderInstruction
---@field [1] ItemStack stack
---@field [2] InventoryItem item
---@field [3] number x
---@field [4] number y
---@field [5] number w (in grid cells)
---@field [6] number h (in grid cells)
---@field [7] number alphaMult
---@field [8] boolean isRotated
---@field [9] boolean isHidden
---@field [10] boolean doBorder

--- This event is called once an entire item grid has finished rendering.<br>
--- This event is performance CRITICAL! Please write highly efficient code and avoid all unnecessary work.<br>
--- For tips on performance optimization in lua, see this wiki page: https://pzwiki.net/wiki/Mod_optimization
--- Also feel free to contact me on Discord[notloc] if you want help or feedback on your render code.
---
--- For an example of how to use this event, see /client/InventoryTetris/EventHandlers/KnownAndCollectedRenderHandler.lua
---
---@param drawingContext ISUIElement - The UI element that is rendering. Not guaranteed to be an ItemGridUI.
---@param renderInstructions TetrisRenderInstruction[] - An array of render instructions that were used to render the grid. This is a buffer, do not modify it.
---@param instructionCount number - The number of valid instructions in the renderInstructions buffer. Going beyond this number may contain old data.
---@param playerObj IsoPlayer - The player that the grid is being rendered for.
TetrisEvents.OnPostRenderGrid = TetrisEvents.createEvent("OnPostRenderGrid", function(self, drawingContext, renderInstructions, instructionCount, playerObj)
    TetrisEvents._genericTrigger(self, drawingContext, renderInstructions, instructionCount, playerObj)
end)