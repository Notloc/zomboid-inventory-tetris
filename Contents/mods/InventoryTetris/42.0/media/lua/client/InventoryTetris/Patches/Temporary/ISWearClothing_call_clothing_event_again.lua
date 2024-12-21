Events.OnGameBoot.Add(function ()
    local og_complete = ISWearClothing.complete

    ISWearClothing.complete = function(self)
        og_complete(self)
        triggerEvent("OnClothingUpdated", self.character)
    end
end)