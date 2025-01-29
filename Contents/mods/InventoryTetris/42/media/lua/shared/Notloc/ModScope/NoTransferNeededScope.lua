local BaseScope = require("Notloc/ModScope/BaseScope")
local NoTransferNeededScope = BaseScope:new()

function NoTransferNeededScope:execute(callback)
    return unpack(BaseScope.execute(self, callback))
end

Events.OnGameBoot.Add(function()
    local og_haveToBeTransfered = luautils.haveToBeTransfered
    ---@diagnostic disable-next-line: duplicate-set-field
    function luautils.haveToBeTransfered(...)
        if NoTransferNeededScope:isActive() then
            return false
        end
        return og_haveToBeTransfered(...)
    end
end)


return NoTransferNeededScope
