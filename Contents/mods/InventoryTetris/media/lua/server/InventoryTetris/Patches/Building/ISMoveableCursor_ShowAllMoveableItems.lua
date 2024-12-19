require "BuildingObjects/ISMoveableCursor"
require "Notloc/NotUtil"

-- Make all moveable items visible in the moveable cursor
-- Even if they are not in the player's main inventory

local og_getInventoryObjectList = ISMoveableCursor.getInventoryObjectList
function ISMoveableCursor:getInventoryObjectList()
    local objects = {};
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
                if not ignoreMulti then
                    table.insert(objects, { object = item, moveProps = moveProps });
                    if self.cacheInvObjectSprite and self.cacheInvObjectSprite == item:getWorldSprite() then
                        self.objectIndex = #objects;
                    end
                end
            end
        end
    end

    NotUtil.forEachItemOnPlayer(self.character, processItem)

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
