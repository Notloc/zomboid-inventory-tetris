if not __GLOBAL_NO_TRANSFER_NEEDED_SCOPE then

    local BaseScope = require "Notloc/ModScope/BaseScope"
    local NoTransferNeededScope = BaseScope:new()
    __GLOBAL_NO_TRANSFER_NEEDED_SCOPE = NoTransferNeededScope

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
end

return __GLOBAL_NO_TRANSFER_NEEDED_SCOPE
