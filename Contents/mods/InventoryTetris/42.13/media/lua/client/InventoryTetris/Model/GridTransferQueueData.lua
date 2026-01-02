-- Parses the player's action queue into data that summarizes item transfer information for use in renderering.
-- Allows us to show previews of in-progress and upcoming item transfers.

---@class GridTransferQueueData
---@field incoming table<ItemContainer, table<string, table<InventoryItem, ISInventoryTransferAction>>>
---@field outgoing table<ItemContainer, table<InventoryItem, ISInventoryTransferAction>>
local GridTransferQueueData = {}
GridTransferQueueData.__index = GridTransferQueueData

---@param playerNum integer
---@return GridTransferQueueData
function GridTransferQueueData.build(playerNum)
    local data = setmetatable({}, GridTransferQueueData)

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

---@param action ISBaseTimedAction
function GridTransferQueueData:processAction(action)
    if action.Type == "ISInventoryTransferAction" then
        ---@cast action ISInventoryTransferAction
        local item = action.item
        local targetInv = action.destContainer
        local sourceInv = action.srcContainer

        if not item or not targetInv or not sourceInv then
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
                        ---@diagnostic disable-next-line: need-check-nil Its not nil
                        self.incoming[targetInv][gridKey][item] = action
                    end
                end
            end
        end
    end
end

---@param container ItemContainer
---@return table<InventoryItem, ISInventoryTransferAction>
function GridTransferQueueData:getOutgoingActions(container)
    return self.outgoing[container] and self.outgoing[container] or {}
end

---@param container ItemContainer
---@param gridKey string
---@return table<InventoryItem, ISInventoryTransferAction>
function GridTransferQueueData:getIncomingActions(container, gridKey)
    return self.incoming[container] and self.incoming[container][gridKey] or {}
end

return GridTransferQueueData
