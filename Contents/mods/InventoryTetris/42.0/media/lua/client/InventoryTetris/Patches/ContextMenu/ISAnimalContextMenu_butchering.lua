Events.OnGameBoot.Add(function()
    local og_onButcherAnimalFromInv = AnimalContextMenu.onButcherAnimalFromInv
    AnimalContextMenu.onButcherAnimalFromInv = function(body, chr, knife)
        og_onButcherAnimalFromInv(body, chr, knife)

        -- Remove the body from the container it's in.
        -- Vanilla only handles the player's main inventory.
        local inv = body:getContainer()
        if inv then
            inv:Remove(body)
        end
    end
end)
