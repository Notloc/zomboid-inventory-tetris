local BaseScope = require("Notloc/ModScope/BaseScope")
local ContainerAvailableScope = BaseScope:new()
ContainerAvailableScope.containers = {}

---@param callback function
---@param containers InventoryContainer[]
function ContainerAvailableScope:execute(callback, containers)
    -- Check which containers need to be added
    local addMap = {}
    for i=1, #containers do
        addMap[i] = containers[i] and ContainerAvailableScope.containers[containers[i]] == nil
    end

    -- Add them
    for i=1, #containers do
        if addMap[i] then
            ContainerAvailableScope.containers[containers[i]] = true
        end
    end

    local values = BaseScope.execute(self, callback)

    -- Remove containers that were added
    for i=1, #containers do
        if addMap[i] then
            ContainerAvailableScope.containers[containers[i]] = nil
        end
    end

    return unpack(values)
end

Events.OnGameStart.Add(function()
    local og_getContainers = ISInventoryPaneContextMenu.getContainers

    ---@param character IsoPlayer
    ---@return ArrayList|nil
    ---@diagnostic disable-next-line: duplicate-set-field
    ISInventoryPaneContextMenu.getContainers = function(character)
        local containerList = og_getContainers(character)
        if not containerList then
            return nil
        end

        if ContainerAvailableScope:isActive() then
            for container, _ in pairs(ContainerAvailableScope.containers) do
                if not containerList:contains(container) then
                    containerList:add(container)
                end
            end
        end

        return containerList
    end
end)

return ContainerAvailableScope