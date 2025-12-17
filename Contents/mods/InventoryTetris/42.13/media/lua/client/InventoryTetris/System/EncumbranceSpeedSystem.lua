Events.OnGameStart.Add(function()
    if not SandboxVars.InventoryTetris.EncumbranceSlow then
        return
    end

    -- If the player is overencumbered, slow them down based on how much they're carrying
    Events.OnPlayerUpdate.Add(function(playerObj)
        local inventory = playerObj:getInventory()
        local encumbrance = inventory:getCapacityWeight()

        if encumbrance > 50 then
            local currentSlow = playerObj:getSlowFactor()

            local baseSlowCap = 0.5
            local baseMaxLoad = 50

            local slowFactor = ((encumbrance - 50) / baseMaxLoad) * baseSlowCap
            if slowFactor > baseSlowCap then
                slowFactor = baseSlowCap

                local extraSlowCap = 1.0 - baseSlowCap
                local extraMaxLoad = 250

                local extraSlow = ((encumbrance - 50 - baseMaxLoad) / extraMaxLoad) * extraSlowCap
                if extraSlow > extraSlowCap then
                    extraSlow = extraSlowCap
                end

                slowFactor = slowFactor + extraSlow
            end

            if slowFactor > currentSlow then
                playerObj:setSlowTimer(1)
                playerObj:setSlowFactor(slowFactor)
            end
        end
    end)
end)
