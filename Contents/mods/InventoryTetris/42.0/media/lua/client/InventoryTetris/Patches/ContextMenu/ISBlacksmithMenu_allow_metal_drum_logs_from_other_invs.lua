-- Fixes the inability to add logs to a metal drum from other inventories.
-- Vanilla expects all items to be in the player's main inventory
require("client/Blacksmith/ISUI/ISBlacksmithMenu")
local ItemUtil = require("Notloc/ItemUtil")
local ModScope = require("Notloc/ModScope/ModScope")

Events.OnGameStart.Add(function()
    Events.OnFillWorldObjectContextMenu.Add(function (playerNum, context, worldobjects, test)
        local drumMenu = nil

        -- Find the Metal Drum option
        local targetOptionName = getText("ContextMenu_Metal_Drum")
        for _, option in ipairs(context.options) do
            if option.name == targetOptionName then
                drumMenu = option
                break
            end
        end
        if not drumMenu then return end

        -- Find the Add Logs option
        local subMenu = context:getSubMenu(drumMenu.subOption)
        local addLogsOption = nil
        targetOptionName = getText("ContextMenu_Add_Logs")
        for _, option in ipairs(subMenu.options) do
            if option.name == targetOptionName then
                addLogsOption = option
                break
            end
        end

        if not addLogsOption or not addLogsOption.notAvailable then return end

        -- TODO: Alert the player about carry weight restrictions somehow, as picking up logs can be very heavy (40+ kg) and cause the action to fail mid-way due to exceeding 50kg

        -- Check if the player has the required items in the vicinity and modify the action to work with InventoryTetris
        if ItemUtil.canGatherItems(playerNum, "Base.Log", 5) then
            local og_onSelect = addLogsOption.onSelect
            addLogsOption.onSelect = function (...)
                local vargs = {...}
                ModScope.withKeepActions(function()
                    if (ItemUtil.gatherItems(playerNum, "Base.Log", 5)) then
                        og_onSelect(unpack(vargs))
                        local playerObj = getSpecificPlayer(playerNum)
                        local postDelay = TetrisLambdaAction:new(playerObj, nil, 1000)
                        postDelay.stopOnRun = false
                        postDelay.stopOnWalk = false
                        ISTimedActionQueue.add(postDelay) -- HACK: Jams the auto-drop system for a moment so the server has time to send the removal commands
                    end
                end)
            end
            addLogsOption.notAvailable = false
        end
    end)
end)
