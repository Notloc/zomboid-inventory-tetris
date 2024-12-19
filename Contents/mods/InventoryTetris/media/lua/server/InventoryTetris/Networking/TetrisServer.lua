-- Keep these synced with the ones in TetrisClient.lua
local TETRIS_UUID = "TetrisUUID"

local WORLD_ITEM_DATA = "INVENTORYTETRIS_WorldItemData"
local WORLD_ITEM_PARTIAL = "INVENTORYTETRIS_WorldItemPartial"

local VEHICLE_ITEM_DATA = "INVENTORYTETRIS_VehicleItemData"
local VEHICLE_ITEM_PARTIAL = "INVENTORYTETRIS_VehicleItemPartial"

local validKeys = {
    [WORLD_ITEM_PARTIAL] = true,
    [VEHICLE_ITEM_PARTIAL] = true,
}

TetrisServer = {}

TetrisServer.getOrCreateUuid = function(tableObj)
    local uuid = tableObj[TETRIS_UUID]
    if not uuid then
        uuid = getRandomUUID()
        tableObj[TETRIS_UUID] = uuid
    end
    return uuid
end

local validateTimestamps = function(existingData, incomingData)
    if not existingData.lastServerTime then
        return true
    end

    if not incomingData.lastServerTime then
        return false
    end

    return incomingData.lastServerTime == existingData.lastServerTime
end

local handlePartialData = function(fullKey, partialKey, incomingData)
    local uuid = TetrisServer.getOrCreateUuid(incomingData)
    local fullData = ModData.getOrCreate(fullKey)
    local existingData = fullData[uuid]
    
    -- if data already exists, validate timestamps
    if not existingData or validateTimestamps(existingData, incomingData) then
        incomingData.lastServerTime = getTimestampMs()
    else
        -- Reject incoming data, send existing data back so the client can be corrected
        incomingData = existingData
    end

    fullData[uuid] = incomingData  
    ModData.add(partialKey, incomingData)
    ModData.transmit(partialKey)
end

local onServerReceiveGlobalModData = function(key, data)
    if not isServer() or not validKeys[key] then
        return
    end
    
    if key == WORLD_ITEM_PARTIAL then
        handlePartialData(WORLD_ITEM_DATA, WORLD_ITEM_PARTIAL, data)
    end

    if key == VEHICLE_ITEM_PARTIAL then
        handlePartialData(VEHICLE_ITEM_DATA, VEHICLE_ITEM_PARTIAL, data)
    end
end

Events.OnReceiveGlobalModData.Add(onServerReceiveGlobalModData);
