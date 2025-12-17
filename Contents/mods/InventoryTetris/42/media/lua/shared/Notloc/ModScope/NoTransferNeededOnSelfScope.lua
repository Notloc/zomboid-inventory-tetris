local BaseScope = require("Notloc/ModScope/BaseScope")
local NoTransferNeededOnSelfScope = BaseScope:new()

function NoTransferNeededOnSelfScope:execute(callback)
    return unpack(BaseScope.execute(self, callback))
end

Events.OnGameBoot.Add(function()
    local og_haveToBeTransfered = luautils.haveToBeTransfered
    ---@diagnostic disable-next-line: duplicate-set-field
    function luautils.haveToBeTransfered(player, item, dontWalk)
        if NoTransferNeededOnSelfScope:isActive() then
            if player:getInventory() == item:getOutermostContainer() then
                return false
            end
        end
        return og_haveToBeTransfered(player, item, dontWalk)
    end
end)


return NoTransferNeededOnSelfScope
