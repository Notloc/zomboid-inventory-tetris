-- This file will interact with other mods, so unknown globals are expected
---@diagnostic disable: undefined-global

local TetrisModCompatibility = {}

---@param container ItemContainer
function TetrisModCompatibility.getModContainerKey(container)
    -- Handles KnoxEventExpanded
	if not container then
        return nil
    end
    if instanceof(container:getParent(), "IsoNpcPlayer") then
        return "npcKEE"
    end
end

---@param item InventoryItem
---@param srcContainer ItemContainer
function TetrisModCompatibility.KnoxEventExpanded_HandleNpcItemTransfer(item, srcContainer)
    if instanceof(srcContainer:getParent(), "IsoNpcPlayer") then
        -- Copied from KnoxEventExpanded
        -- Ensures that any item transfers out of an NPC's inventory are handled correctly
        if NpcInventoryUI.npcObj ~= nil then
            if item:isEquipped() then
                local npc = NpcInventoryUI.npcObj;
                npc:removeWornItem(item);
                if item == npc:getPrimaryHandItem() then
                    if (item:isTwoHandWeapon() or item:isRequiresEquippedBothHands()) and item == npc:getSecondaryHandItem() then
                        npc:setSecondaryHandItem(nil);
                    end
                    npc:setPrimaryHandItem(nil);
                end
                if item == npc:getSecondaryHandItem() then
                    if (item:isTwoHandWeapon() or item:isRequiresEquippedBothHands()) and item == npc:getPrimaryHandItem() then
                        npc:setPrimaryHandItem(nil);
                    end
                    npc:setSecondaryHandItem(nil);
                end
            end
        end
    end
end

return TetrisModCompatibility
