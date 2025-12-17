local ItemUtil = require("Notloc/ItemUtil")

-- Allows ISMoveableSpriteProps to find items in the player's hands and equipped bags when building the ISMoveablesAction
-- Transfer and unequipping of the item is handled by the ISMoveablesAction_JitTransferItems patch

Events.OnGameBoot.Add(function()
    local og_findInInventory = ISMoveableSpriteProps.findInInventory

    ---@diagnostic disable-next-line: duplicate-set-field
    function ISMoveableSpriteProps:findInInventory(playerObj, _spriteName)
        local item = og_findInInventory(self, playerObj, _spriteName)
        if item then return item end

        local containers = ItemUtil.getAllEquippedContainers(playerObj, false)
        for _, container in ipairs(containers) do
            local items = container:getItems()
            local itemCount = container:getItems():size() - 1
            for i = 0, itemCount do
                local item = items:get(i)
                if instanceof(item, "Moveable") and item:getWorldSprite() then
                    if (item:getWorldSprite() == _spriteName) then
                        return item;
                    else
                        local worldSprite = getSprite(item:getWorldSprite());
                        if worldSprite and worldSprite:getSpriteGrid() and worldSprite:getSpriteGrid():getAnchorSprite() and worldSprite:getSpriteGrid():getAnchorSprite():getName() == _spriteName then
                            return item;
                        end
                    end
                end
            end
        end
    end
end)