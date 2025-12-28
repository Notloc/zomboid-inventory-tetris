-- Parses the player's action queue into data that summarizes item transfer information for use in renderering.
-- Allows us to show previews of in-progress and upcoming item transfers.

local GridTransferQueueData = {}

function GridTransferQueueData.build(playerNum)
    local data = {}
    setmetatable(data, { __index = GridTransferQueueData })

    data.incoming = {}
    data.outgoing = {}

    local player = getSpecificPlayer(playerNum)
    local queueObj = ISTimedActionQueue.getTimedActionQueue(player)

    for _, action in ipairs(queueObj.queue) do
        data:processAction(action)
    end

    if queueObj.current then
        data:processAction(queueObj.current)
    end

    return data
end

function GridTransferQueueData:processAction(action)
    if action.Type == "ISInventoryTransferAction" then
        local item = action.item
        local targetInv = action.destContainer
        local sourceInv = action.srcContainer

        if not targetInv or not sourceInv then
            return
        end

        if not self.outgoing[sourceInv] then
            self.outgoing[sourceInv] = {}
        end
        if not self.outgoing[sourceInv] then
            self.outgoing[sourceInv] = {}
        end
        self.outgoing[sourceInv][item] = action

        local tetrisAware = action.gridIndex
        local gridKey = (action.gridIndex or "") .. (action.tetrisSecondary and tostring(action.tetrisSecondary) or "")
        if tetrisAware then
            if not self.incoming[targetInv] then
                self.incoming[targetInv] = {}
            end
            if not self.incoming[targetInv][gridKey] then
                self.incoming[targetInv][gridKey] = {}
            end
            self.incoming[targetInv][gridKey][item] = action
        end

        if #action.queueList > 0 then
            for _, queueData in ipairs(action.queueList) do
                for _, item in ipairs(queueData.items) do
                    self.outgoing[sourceInv][item] = action
                    if tetrisAware then
                        self.incoming[targetInv][gridKey][item] = action
                    end
                end
            end
        end
    end
end

function GridTransferQueueData:getOutgoingActions(container)
    return self.outgoing[container] and self.outgoing[container] or {}
end

function GridTransferQueueData:getIncomingActions(container, gridKey)
    return self.incoming[container] and self.incoming[container][gridKey] or {}
end

return GridTransferQueueData
