require "TimedActions/ISInventoryTransferAction"

local og_new = ISInventoryTransferAction.new
function ISInventoryTransferAction:new (character, item, srcContainer, destContainer, time)
	local o = og_new(self, character, item, srcContainer, destContainer, time)

    -- Make the transfers instant
    -- The user's personal time spent arranging items in the grid "replaces" the time spent moving the items
    if o.maxTime >= 1 then
        o.maxTime = 0
    end

    return o
end