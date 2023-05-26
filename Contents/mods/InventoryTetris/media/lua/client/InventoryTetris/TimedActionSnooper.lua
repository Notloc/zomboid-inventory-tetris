TimedActionSnooper = {}

TimedActionSnooper.findUpcomingActionThatHandlesItem = function(playerObj, item, contextAction)
    local queueObj = ISTimedActionQueue.getTimedActionQueue(playerObj)
    local queue = queueObj.queue
    for _, action in ipairs(queue) do
        if action and action ~= contextAction then
            -- Generic handling for actions, only requires a field called "item"
            if action.item == item then
                return action
            end

            -- Screw it, just check every field. Modders gonna mod and I can't guess what they'll do.
            for _, data in pairs(action) do
                if data == item then
                    return action
                end
            end
        elseif action and action == contextAction then
            -- Special handling for ISInventoryTransferAction, it batches multiple actions into one
            if action.queueList then
                for _, data in pairs(action.queueList) do
                    if data.items and data.items[1] == item then
                        return action
                    end
                end
            end
        end
    end

    return nil
end
