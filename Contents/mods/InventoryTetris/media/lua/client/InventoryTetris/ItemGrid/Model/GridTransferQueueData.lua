-- TODO: Maintain this via events instead of polling?
GridTransferQueueData = {}

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

        if not self.outgoing[sourceInv] then
            self.outgoing[sourceInv] = {}
        end
        if not self.outgoing[sourceInv] then
            self.outgoing[sourceInv] = {}
        end
        self.outgoing[sourceInv][item] = action

        local tetrisAware = action.gridIndex
        local gridIndex = action.gridIndex
        if tetrisAware then
            if not self.incoming[targetInv] then
                self.incoming[targetInv] = {}
            end
            if not self.incoming[targetInv][gridIndex] then
                self.incoming[targetInv][gridIndex] = {}
            end
            self.incoming[targetInv][gridIndex][item] = action
        end

        if #action.queueList > 0 then
            for _, queueData in ipairs(action.queueList) do
                for _, item in ipairs(queueData.items) do
                    self.outgoing[sourceInv][item] = action
                    if tetrisAware then
                        self.incoming[targetInv][gridIndex][item] = action
                    end
                end
            end
        end
    end
end

function GridTransferQueueData:getOutgoingActions(container)
    return self.outgoing[container] and self.outgoing[container] or {}
end

function GridTransferQueueData:getIncomingActions(container, gridIndex)
    return self.incoming[container] and self.incoming[container][gridIndex] or {}
end
