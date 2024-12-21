Events.OnGameBoot.Add(function ()
    local og_complete = ISWearClothing.complete

    -- Currently the event is triggered before the new clothing is actually equipped.
    -- This is a temporary fix to trigger the event after the clothing is equipped.
    ISWearClothing.complete = function(self)
        og_complete(self)
        triggerEvent("OnClothingUpdated", self.character)
    end
end)