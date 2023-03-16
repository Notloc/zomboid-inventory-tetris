TimedActionSnooper = {}

TimedActionSnooper.findUpcomingActionThatHandlesItem = function(playerObj, item, contextAction)
    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queue = queueObj.queue
    for _, action in ipairs(queue) do
        if action ~= contextAction and action and action.item == item then
            return action
        end
    end

    return nil
end
