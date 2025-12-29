---@diagnostic disable: redundant-return-value
local ItemReturnScope = require("Notloc/ModScope/ItemReturnScope")
local NoTransferNeededScope = require("Notloc/ModScope/NoTransferNeededScope")
local NoTransferNeededOnSelfScope = require("Notloc/ModScope/NoTransferNeededOnSelfScope")
local LuaUtilsKeepActionScope = require("Notloc/ModScope/LuaUtilsKeepActionScope")
local NoActionQueueClearScope = require("Notloc/ModScope/NoActionQueueClearScope")
local InstanceofExclusionsScope = require("Notloc/ModScope/InstanceofExclusionsScope")
local ContainerAvailableScope = require("Notloc/ModScope/ContainerAvailableScope")

-- An experiment with calling functions inside of behavior modified scopes
-- The goal is to piggyback off of as much vanilla code as possible while still achieving desired behaviors
-- While also avoiding lasting side effects when errors occur
---@class ModScope
---@field withItemReturnActions fun(playerObj: IsoPlayer, returnableItems: table<string, boolean>, callback: function)
---@field withoutTransferNeeded fun(callback: function)
---@field withoutTransferNeededOnSelf fun(callback: function)
---@field withKeepActions fun(callback: function)
---@field withNoActionQueueClear fun(callback: function)
---@field withInstanceofExclusion fun(callback: function, exclusion: string)
---@field withContainersAvailable fun(callback: function, containers: InventoryContainer[])
local ModScope = {};

---Reverse item transfers will be created after the callback for all items in the returnableItems table
---@param playerObj IsoPlayer
---@param returnableItems table<string, boolean>
---@param callback function
function ModScope.withItemReturnActions(playerObj, returnableItems, callback)
    return ItemReturnScope:execute(playerObj, returnableItems, callback)
end

---Checks to luautils.haveToBeTransfered() will return false inside of the callback
function ModScope.withoutTransferNeeded(callback)
    return NoTransferNeededScope:execute(callback)
end

---Checks to luautils.haveToBeTransfered() will return false if the item is somewhere on the player's body
function ModScope.withoutTransferNeededOnSelf(callback)
    return NoTransferNeededOnSelfScope:execute(callback)
end

---Checks to luautils.walkAdj() will always keep the action queue
function ModScope.withKeepActions(callback)
    return LuaUtilsKeepActionScope:execute(callback)
end

---Calls to clear the player's action queue will be ignored
function ModScope.withNoActionQueueClear(callback)
    return NoActionQueueClearScope:execute(callback)
end

---Calls to instanceof() will return false for the specified class name
function ModScope.withInstanceofExclusion(callback, exclusion)
    return InstanceofExclusionsScope:execute(callback, exclusion)
end

---Ensures the given containers are considered available to the player during the callback
function ModScope.withContainersAvailable(callback, containers)
    return ContainerAvailableScope:execute(callback, containers)
end

return ModScope
