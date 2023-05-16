NotUtil = {}

NotUtil.forEachItemOnPlayer = function(playerObj, callbackFunc)
    local containers = NotUtil.getAllEquippedContainers(playerObj)
    for _, container in ipairs(containers) do
        local _items = container:getItems()
        local _itemCount = container:getItems():size() - 1
        for i = 0, _itemCount do
            callbackFunc(_items:get(i))
        end
    end
end

NotUtil.getAllEquippedContainers = function(playerObj)
    local containers = { playerObj:getInventory() }
    local wornItems = playerObj:getWornItems()
    for i = 0, wornItems:size()-1 do
        local wornItem = wornItems:get(i):getItem()
        if wornItem:IsInventoryContainer() then
            table.insert(containers, wornItem:getInventory())
        end
    end
    return containers
end
