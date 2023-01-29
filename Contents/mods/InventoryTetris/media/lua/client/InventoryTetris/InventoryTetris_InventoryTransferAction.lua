require "TimedActions/ISInventoryTransferAction"

local og_new = ISInventoryTransferAction.new
function ISInventoryTransferAction:new (character, item, srcContainer, destContainer, time)
	local o = og_new(self, character, item, srcContainer, destContainer, time)

    -- Make the transfers instant
    -- The user's personal time spent arranging items in the grid "replaces" the time spent moving the items
    o.maxTime = 0
    return o
end

local og_start = ISInventoryTransferAction.start
function ISInventoryTransferAction:start()
    og_start(self)
	self.maxTime = 0
	self.action:setTime(0)
end

local og_isValid = ISInventoryTransferAction.isValid
function ISInventoryTransferAction:isValid()
    local valid = og_isValid(self)
    if not valid then
        return valid
    end
    
    valid = false
    local grids = ItemGrid.CreateGrids(self.destContainer, self.character:getPlayerNum())
    for _, grid in ipairs(grids) do
        if grid:canAddItem(self.item) then
            valid = true
            break
        end
    end

    return valid
end

local og_transferItem = ISInventoryTransferAction.transferItem
function ISInventoryTransferAction:transferItem(item)
    og_transferItem(self, item)

    -- The Item made it to the destination container
    if self:isAlreadyTransferred(item) then
        ItemGridUtil.clearItemPosition(item)
        
        local grids = ItemGrid.CreateGrids(self.destContainer, self.character:getPlayerNum())
        for _, grid in ipairs(grids) do
            if grid:attemptToInsertItemIntoGrid(item) then
                return
            end
        end

        -- Force the item into the first grid if something went wrong
        grids[1]:insertItemIntoGrid(item, 0, 0)
    end
end

