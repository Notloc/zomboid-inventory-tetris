--***********************************************************
--**                    THE INDIE STONE                    **
--**				  Author: turbotutone				   **
--***********************************************************

local function isItemInWornContainer(player, item)
    local wornItems = player:getWornItems();
    for i=0,wornItems:size()-1 do
        local containerItem = wornItems:get(i):getItem()
        if containerItem:IsInventoryContainer() then
            local inv = containerItem:getInventory()
            if inv:contains(item) then
                return true
            end
        end
    end
    return false
end

ISInventoryMenuElements = ISInventoryMenuElements or {};

function ISInventoryMenuElements.ContextMovable2()
    local self 					= ISMenuElement.new();
    self.invMenu			    = ISContextManager.getInstance().getInventoryMenu();

    function self.init()
    end

    function self.createMenu( _item )
        if instanceof(_item, "Moveable") then
            if self.invMenu.player:getPrimaryHandItem() ~= _item and self.invMenu.player:getSecondaryHandItem() ~= _item then
                if not isItemInWornContainer(self.invMenu.player, _item) then
                    return
                end
            end

            if _item:getWorldStaticItem() then
            end
            if instanceof(_item, "Radio") and _item:getWorldStaticItem() then
                return
            end
        
            self.invMenu.context:addOption(getText("IGUI_PlaceObject"), self.invMenu, self.openMovableCursor, _item );
        end
    end

    function self.openMovableCursor( _p, _item )
        local player = _p.player;

        if _item:getContainer() ~= player:getInventory() then
            local transferAction = ISInventoryTransferAction:new(player, _item, _item:getContainer(), player:getInventory())
            ISTimedActionQueue.add(transferAction)
        elseif player:isEquipped(_item) then
            local unequipAction = ISUnequipAction:new(player, _item, 1)
            ISTimedActionQueue.add(unequipAction)
        end

        local queuedItemAction = QueuedItemAction:new(player, _item, function(_character, _item)
            local mo = ISMoveableCursor:new(player);
            getCell():setDrag(mo, mo.player);
            mo:setMoveableMode("place");
            mo:tryInitialItem(_item);
        end)        
        ISTimedActionQueue.add(queuedItemAction)
    end

    return self;
end
