Events.OnGameStart.Add(function ()
	local og_create = campingTent.create -- TODO: Dirty override, original function is not called

	---@diagnostic disable-next-line: duplicate-set-field
	function campingTent:create(x, y, z, north, sprite)
		local tent = self.character:getInventory():getFirstTypeRecurse("CampingTentKit")
		if not tent then return end

		ISInventoryPaneContextMenu.transferIfNeeded(self.character, tent)
		if tent:isEquipped() then
			ISTimedActionQueue.add(ISUnequipAction:new(self.character, tent, 0))
		end

		local sq = getWorld():getCell():getGridSquare(x, y, z);
		ISTimedActionQueue.add(ISAddTentAction:new(self.character, sq, tent, sprite, 0));
	end

	local og_isValid = campingTent.isValid

	---@diagnostic disable-next-line: duplicate-set-field
	function campingTent:isValid(square)
		if og_isValid(self, square) then
			return true
		end

		local valid = self:isSquareFree(square)
		if valid and not self.character:getInventory():getFirstTypeRecurse("CampingTentKit") then
			valid = false
		end
		local square2 = self:getSquare2(square, self.north)
		if valid and not (square2 and self:isSquareFree(square2) and not square:isSomethingTo(square2)) then
			valid = false
		end

		return valid
	end
end)