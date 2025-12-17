local BaseScope = require("Notloc/ModScope/BaseScope")
local LuaUtilsKeepActionScope = BaseScope:new()

function LuaUtilsKeepActionScope:execute(callback)
    return unpack(BaseScope.execute(self, callback))
end

Events.OnGameBoot.Add(function()
    local og_walkAdj = luautils.walkAdj
    ---@diagnostic disable-next-line: duplicate-set-field
    function luautils.walkAdj(playerObj, square, keepActions)
        if LuaUtilsKeepActionScope:isActive() then
            return og_walkAdj(playerObj, square, true)
        end
        return og_walkAdj(playerObj, square, keepActions)
    end
end)

return LuaUtilsKeepActionScope