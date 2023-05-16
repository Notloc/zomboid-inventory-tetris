TimedActionSnooper = {}

TimedActionSnooper.findUpcomingActionThatHandlesItem = function(playerObj, item, contextAction)
    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queue = queueObj.queue
    for _, action in ipairs(queue) do

        -- Generic handling for actions, only requires a field called "item"
        if action ~= contextAction and action and action.item == item then
            return action
        end

        -- Special handling for ISInventoryTransferAction, it batches multiple actions into one
        if action.queueList then
            for _, data in pairs(action.queueList) do
                if data.items and data.items[1] == item then
                    return action
                end
            end
        end
    end

    return nil
end
