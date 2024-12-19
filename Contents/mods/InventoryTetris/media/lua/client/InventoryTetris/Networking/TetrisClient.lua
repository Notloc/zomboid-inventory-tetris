-- Keep these synced with the ones in TetrisServer.lua
local TETRIS_UUID = "TetrisUUID"

local WORLD_ITEM_DATA = "INVENTORYTETRIS_WorldItemData"
local WORLD_ITEM_PARTIAL = "INVENTORYTETRIS_WorldItemPartial"

local VEHICLE_ITEM_DATA = "INVENTORYTETRIS_VehicleItemData"
local VEHICLE_ITEM_PARTIAL = "INVENTORYTETRIS_VehicleItemPartial"

TetrisClient = {}
TetrisClient._modDataSyncQueue = {}

TetrisClient.queueModDataSync = function(obj)
    TetrisClient._modDataSyncQueue[obj] = true
end


TetrisClient.getMostRecentModData = function(isoModData, isoKey, worldModData, worldKey)
    local worldData = worldModData[worldKey]
    if not worldData then
        return isoModData
    end

    local isoData = isoModData[isoKey]
    if not isoData then
        isoModData[isoKey] = worldData
    else
        local isoTime = isoData.lastServerTime or 0
        local worldTime = worldData.lastServerTime or 0
        if worldTime > isoTime then
            isoModData[isoKey] = worldData
        end
    end

    return isoModData
end

TetrisClient.getInventoryContainerModData = function(item)
    return TetrisClient.getMostRecentModData(item:getModData(), "gridContainers", ModData.getOrCreate(WORLD_ITEM_DATA), item:getID()), item:getWorldItem()
end

TetrisClient.getVehicleModData = function(vehicle)
    return TetrisClient.getMostRecentModData(vehicle:getModData(), "gridContainers", ModData.getOrCreate(VEHICLE_ITEM_DATA), vehicle:getKeyId()), vehicle
end


TetrisClient.transmitPartialData = function(fullKey, partialKey, data)
    local fullData = ModData.getOrCreate(fullKey)
    fullData[data[TETRIS_UUID]] = data

    ModData.add(partialKey, data)
    ModData.transmit(partialKey)
end

TetrisClient.transmitWorldInventoryObjectData = function(worldInvObject)
    local item = worldInvObject:getItem();
    local gridData = item and item:getModData().gridContainers;
    if not gridData then return end

    gridData[TETRIS_UUID] = item:getID()
    TetrisClient.transmitPartialData(WORLD_ITEM_DATA, WORLD_ITEM_PARTIAL, gridData)
end

TetrisClient.transmitVehicleInventoryData = function(vehicleObj)
    local gridData = vehicleObj:getModData().gridContainers;
    if not gridData then return end

    gridData[TETRIS_UUID] = vehicleObj:getKeyId()
    TetrisClient.transmitPartialData(VEHICLE_ITEM_DATA, VEHICLE_ITEM_PARTIAL, gridData)
end

if isClient() then
    Events.OnTick.Add(function()
        for obj,_ in pairs(TetrisClient._modDataSyncQueue) do  
            if instanceof(obj, "IsoWorldInventoryObject") then
                TetrisClient.transmitWorldInventoryObjectData(obj)

            elseif instanceof(obj, "BaseVehicle") then
                TetrisClient.transmitVehicleInventoryData(obj)

            elseif obj.transmitModData then
                obj:transmitModData()
            end
        end
        table.wipe(TetrisClient._modDataSyncQueue)
    end)
end

Events.OnLoad.Add(function()
    ModData.request(WORLD_ITEM_DATA)
    ModData.request(VEHICLE_ITEM_DATA)
end);

Events.OnReceiveGlobalModData.Add(function(key, data)
    if isServer() or not data then return end

    if key == WORLD_ITEM_DATA then
        ModData.add(WORLD_ITEM_DATA, data)
        return
    end

    if key == VEHICLE_ITEM_DATA then
        ModData.add(VEHICLE_ITEM_DATA, data)
        return
    end

    if key == WORLD_ITEM_PARTIAL then
        local worldItemData = ModData.getOrCreate(WORLD_ITEM_DATA)
        worldItemData[data[TETRIS_UUID]] = data
        return
    end

    if key == VEHICLE_ITEM_PARTIAL then
        local vehicleItemData = ModData.getOrCreate(VEHICLE_ITEM_DATA)
        vehicleItemData[data[TETRIS_UUID]] = data
        return
    end
end);