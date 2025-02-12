local BaseScope = require("Notloc/ModScope/BaseScope")
local InstanceofExclusionsScope = BaseScope:new()
InstanceofExclusionsScope.exclusions = {}

---@param callback function
---@param exclusion string
function InstanceofExclusionsScope:execute(callback, exclusion)
    local doAdd = self.exclusions[exclusion] == nil
    if doAdd then
        self.exclusions[exclusion] = true
    end

    local values = BaseScope.execute(self, callback)

    if doAdd then
        self.exclusions[exclusion] = nil
    end
    return unpack(values)
end

Events.OnGameStart.Add(function() 
    local og_instanceof = instanceof

    function instanceof(obj, className)
        if InstanceofExclusionsScope:isActive() and InstanceofExclusionsScope.exclusions[className] then
            return false
        end
        return og_instanceof(obj, className)
    end
end)

return InstanceofExclusionsScope
