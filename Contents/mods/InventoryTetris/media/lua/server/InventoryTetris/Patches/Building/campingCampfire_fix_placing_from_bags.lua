function campingCampfire:create(x, y, z, north, sprite)
    local fireKit = self.character:getInventory():getFirstTypeRecurse("CampfireKit")
    if not fireKit then return end

    ISInventoryPaneContextMenu.transferIfNeeded(self.character, fireKit)
    if fireKit:isEquipped() then
        ISTimedActionQueue.add(ISUnequipAction:new(self.character, fireKit, 0))
	end

	local sq = getWorld():getCell():getGridSquare(x, y, z);
	ISTimedActionQueue.add(ISPlaceCampfireAction:new(self.character, sq, fireKit, 0));
end

function campingCampfire:isValid(square, north)
	return self:isSquareFree(square) and self.character:getInventory():getFirstTypeRecurse("CampfireKit");
end