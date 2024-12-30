local ItemUtil = require("Notloc/ItemUtil")

Events.OnGameBoot.Add(function()
    local og_findInInventory = ISMoveableSpriteProps.findInInventory

    ---@diagnostic disable-next-line: duplicate-set-field
    function ISMoveableSpriteProps:findInInventory(playerObj, _origSpriteName)
        local item = og_findInInventory(self, playerObj, _origSpriteName)
        if item then return item end

        local containers = ItemUtil.getAllEquippedContainers(playerObj, false)
        for _, container in ipairs(containers) do
            local items = container:getItems()
            local itemCount = container:getItems():size() - 1
            for i = 0, itemCount do
                local item = items:get(i)
                if instanceof(item, "Moveable") and item:getWorldSprite() == _origSpriteName then
                    return item
                end
            end
        end
    end
end)