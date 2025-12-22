require("Traps/ISUI/ISTrapMenu")
local ContextUtil = require("Notloc/ContextUtil")
local ItemUtil = require("Notloc/ItemUtil")

Events.OnGameStart.Add(function()
    local og_doTrapMenu = ISTrapMenu.doTrapMenu;
    Events.OnFillWorldObjectContextMenu.Remove(og_doTrapMenu);

    ---@diagnostic disable-next-line: duplicate-set-field
    ISTrapMenu.doTrapMenu = function(player, context, worldobjects, test)
        og_doTrapMenu(player, context, worldobjects, test);
        local playerObj = getSpecificPlayer(player);

        local cTrapInstance = CTrapSystem.instance;
        if not cTrapInstance then return end

        local placedTrap = nil;
        for _,v in ipairs(worldobjects) do
            placedTrap = cTrapInstance:getLuaObjectAt(v:getX(), v:getY(), v:getZ());
            if placedTrap then break end
        end

        if placedTrap then
            -- add bait
            if not placedTrap.bait and not placedTrap.animal.type then
                local alreadyAddedItems = {};
                local items = {}

                ItemUtil.forEachItemOnPlayer(playerObj, function(vItem)
                    if instanceof(vItem, "Food") and (vItem:getHungerChange() <= -0.05 or vItem:getType() == "Worm") and not vItem:isCooked() and
                            not alreadyAddedItems[vItem:getName()] and not vItem:haveExtraItems() and
                            (vItem:getCustomMenuOption() ~= "Drink") then
                        table.insert(items, vItem)
                        alreadyAddedItems[vItem:getName()] = true;
                    end
                end, true)

                if #items > 0 then
                    if test then return ISWorldObjectContextMenu.setTest() end
                    local subMenuBait = ContextUtil.getOrCreateSubMenu(context, getText("ContextMenu_Add_Bait"), worldobjects);
                    for _,vItem in ipairs(items) do
                        if not ContextUtil.getOptionByName(subMenuBait, vItem:getName()) then
                            subMenuBait:addOption(vItem:getName(), worldobjects, ISTrapMenu.onAddBait, vItem, placedTrap, playerObj);
                        end
                    end
                end
            end
        end
    end

    Events.OnFillWorldObjectContextMenu.Add(ISTrapMenu.doTrapMenu);
end)
