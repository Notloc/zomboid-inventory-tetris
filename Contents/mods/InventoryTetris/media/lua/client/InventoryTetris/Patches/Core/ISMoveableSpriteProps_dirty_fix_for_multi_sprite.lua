require "Notloc/NotUtil"

-- Full override :S
function ISMoveableSpriteProps:findInInventoryMultiSprite( _character, _spriteName )
    if _character and _spriteName then

        local retItem = nil;
        local retInv = nil;
        local isDone = false;
        NotUtil.forEachItemOnPlayer(_character, function(item, inventory)
            if isDone then return end
            if instanceof(item, "Moveable") and self.customItem and (item:getFullType() == self.customItem) and (item:getName() == self.name) then
                retItem = item;
                retInv = inventory;
                isDone = true;
                return
            end
            if instanceof(item, "Moveable") and item:getCustomNameFull() then
                if item:getCustomNameFull() == _spriteName then
                    retItem = item;
                    retInv = inventory;
                    isDone = true
                    return
                end
            end
        end);

        if retItem and retInv then
            return retItem, retInv;
        end

        local radius = ISMoveableSpriteProps.multiSpriteFloorRadius;
        local square = _character:getSquare();
        if square then
            --print("try find square ".._spriteName);
            local sx,sy,sz = square:getX(), square:getY(), square:getZ();
            for x = sx-radius,sx+radius do
                for y = sy-radius,sy+radius do
                    --print(" test "..tostring(x)..":"..tostring(y)..":"..tostring(sz));
                    local sq = getCell():getGridSquare(x,y,sz);
                    if sq and sq:getWorldObjects() then
                        local items 			= sq:getWorldObjects();
                        local items_size 		= items:size();
                        for i=0,items_size-1, 1 do
                            if instanceof(items:get(i), "IsoWorldInventoryObject") then
                                local item = items:get(i):getItem();
                                if instanceof(item, "Moveable") and self.customItem and (item:getFullType() == self.customItem) and (item:getName() == self.name) then
                                    return item, "floor";
                                end
                                if item and instanceof(item, "Moveable") and item:getCustomNameFull() then
                                    if item:getCustomNameFull() == _spriteName then
                                        return item, "floor";
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end