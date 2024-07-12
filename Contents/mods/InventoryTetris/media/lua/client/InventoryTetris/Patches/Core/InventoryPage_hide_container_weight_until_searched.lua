---@diagnostic disable: duplicate-set-field

Events.OnGameStart.Add(function()
    local og_round = round
    local function lenientRound(num, numDecimalPlaces)
        if num == nil then return "?" end
        return og_round(num, numDecimalPlaces)
    end

    local og_loadWeight = ISInventoryPage.loadWeight
    function ISInventoryPage.loadWeight(container)
        if SandboxVars.InventoryTetris.EnableSearch and container then
            local containerGrid = ItemContainerGrid.Create(container, 0)
            if containerGrid:areAnyUnsearched() then
                return nil
            end
        end
        return og_loadWeight(container)
    end

    local og_prerender = ISInventoryPage.prerender
    function ISInventoryPage:prerender()
        round = lenientRound
        og_prerender(self)
        round = og_round
    end
end)
