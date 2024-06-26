Events.OnGameBoot.Add(function ()

    local og_create = campingCampfire.create -- TODO: Dirty override, original function is not called

    ---@diagnostic disable-next-line: duplicate-set-field
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

    local og_isValid = campingCampfire.isValid
    ---@diagnostic disable-next-line: duplicate-set-field
    function campingCampfire:isValid(square, north)
        return og_isValid(self, square, north) or
            (self:isSquareFree(square) and self.character:getInventory():getFirstTypeRecurse("CampfireKit"));
    end
end)