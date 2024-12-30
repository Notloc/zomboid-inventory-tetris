require("BuildingObjects/ISMoveableCursor")
local ItemUtil = require("Notloc/ItemUtil")

-- Adjusts the moveable cursor to show moveable items in the player's hands and equipped bags in addition to their main inventory
-- ISMoveableSpriteProps_allow_items_from_hands_and_bags handles finding items while building a ISMoveablesAction
-- ISMoveablesAction_JitTransferItems handles transferring and unequipping the item(s) just before the action is executed

Events.OnGameStart.Add(function()
    local og_getInventoryObjectList = ISMoveableCursor.getInventoryObjectList
    ---@diagnostic disable-next-line: duplicate-set-field
    function ISMoveableCursor:getInventoryObjectList()

        -- Call the original function incase other mods have modified it
        local otherObjects = og_getInventoryObjectList(self) or {};
        local otherMap = {};
        for i,object in ipairs(otherObjects) do
            otherMap[object.object] = true;
        end

        -- Copy the list of objects
        local objects = {};
        for i,object in ipairs(otherObjects) do
            table.insert(objects, object);
        end

        local spriteBuffer = {};

        local processItem = function(item)
            if instanceof(item, "Moveable") then
                local moveProps = ISMoveableSpriteProps.new( item:getWorldSprite() );
                if moveProps.isMoveable then
                    local ignoreMulti = false
                    if moveProps.isMultiSprite then
                        local anchorSprite = moveProps.sprite:getSpriteGrid():getAnchorSprite()
                        if spriteBuffer[anchorSprite] then
                            ignoreMulti = true
                        else
                            spriteBuffer[anchorSprite] = true
                            if moveProps.sprite ~= anchorSprite then
                                moveProps = ISMoveableSpriteProps.new(anchorSprite)
                            end
                        end
                    end
                    if not ignoreMulti and not otherMap[item] then
                        table.insert(objects, { object = item, moveProps = moveProps });
                        if self.cacheInvObjectSprite and self.cacheInvObjectSprite == item:getWorldSprite() then
                            self.objectIndex = #objects;
                        end
                    end
                end
            end
        end

        ItemUtil.forEachItemOnPlayer(self.character, processItem)

        if self.tryInitialInvItem then
            if instanceof(self.tryInitialInvItem, "Moveable") then
                --print("MovablesCursor attempting to set Initial Item: "..self.tryInitialInvItem:getWorldSprite());
                local moveProps = ISMoveableSpriteProps.new(self.tryInitialInvItem:getWorldSprite());
                local sprite = moveProps.sprite;
                if moveProps.isMultiSprite then
                    local spriteGrid = moveProps.sprite:getSpriteGrid();
                    sprite = spriteGrid:getAnchorSprite();
                end
                local spriteName = sprite:getName();
                for index,table in ipairs(objects) do
                    --print("Compare "..table.object:getWorldSprite().." "..spriteName )
                    if table.moveProps.sprite == sprite then
                        self.objectIndex = index;
                        self.cacheInvObjectSprite = spriteName;
                        break;
                    end
                end
            else
                print("MovablesCursor Initial Item is not a Movable item");
                print(self.tryInitialInvItem);
            end
            self.tryInitialInvItem = nil;
        end

        return objects;
    end
end)


