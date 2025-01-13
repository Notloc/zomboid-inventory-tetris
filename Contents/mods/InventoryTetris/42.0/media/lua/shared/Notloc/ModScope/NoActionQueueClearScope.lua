if not __GLOBAL_NO_ACTION_QUEUE_CLEAR_SCOPE then

    local BaseScope = require("Notloc/ModScope/BaseScope")
    local NoActionQueueClearScope = BaseScope:new()
    __GLOBAL_NO_ACTION_QUEUE_CLEAR_SCOPE = NoActionQueueClearScope

    function NoActionQueueClearScope:execute(callback)
        return unpack(BaseScope.execute(self, callback))
    end

    Events.OnGameBoot.Add(function()
        local og_clear = ISTimedActionQueue.clear

        ---@diagnostic disable-next-line: duplicate-set-field
        function ISTimedActionQueue.clear(...)
            if NoActionQueueClearScope:isActive() then
                return
            end
            return og_clear(...)
        end
    end)
end

return __GLOBAL_NO_ACTION_QUEUE_CLEAR_SCOPE
