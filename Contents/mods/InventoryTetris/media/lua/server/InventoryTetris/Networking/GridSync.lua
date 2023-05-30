-- Keep these synced with the ones in ItemGrid.lua
local WORLD_ITEM_DATA = "INVENTORYTETRIS_WorldItemData"
local WORLD_ITEM_PARTIAL = "INVENTORYTETRIS_WorldItemPartial"

local function onServerReceiveGlobalModData(key, data)
    if not isServer() then
        return
    end
    
    if key == WORLD_ITEM_PARTIAL then

        for k, v in pairs(data) do
            print(k)
        end

        local serverTime = getTimestampMs()
        data.lastModified = serverTime
        
        local worldItemData = ModData.getOrCreate(WORLD_ITEM_DATA)
        worldItemData[data.id] = data
        
        ModData.add(key, data)
        ModData.transmit(key)
        --ModData.remove(key)
    end
end

Events.OnReceiveGlobalModData.Add(onServerReceiveGlobalModData);
