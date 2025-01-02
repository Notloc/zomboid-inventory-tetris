local CompatibilityPopupWindow = require("InventoryTetris/UI/Windows/CompatibilityPopupWindow")
local Version = require("Notloc/Versioning/Version")

local TETRIS_IMG = getTexture("media/textures/Compatibility/tetris.png")
local EQUIPMENT_IMG = getTexture("media/textures/Compatibility/equipment_ui.png")

InventoryTetrisIncompatibleModWarningSystem = {}

-- Handle the prepended slash bug
local function isModActive(modID)
    return getActivatedMods():contains(modID) or getActivatedMods():contains("\\"..modID)
end

function InventoryTetrisIncompatibleModWarningSystem.showCompatibilityIssues()
    if not EquipmentUI or Version.isBelow(EquipmentUI.version, 2, 1) then
        local cpw = CompatibilityPopupWindow:new(100, 100, TETRIS_IMG, InventoryTetris.version, EQUIPMENT_IMG, EquipmentUI and EquipmentUI.version, Version:new(2,1,0))
        cpw:initialise()
        cpw:addToUIManager()
    end

    local modDat = ModData.getOrCreate("tetris_compat_popup")
    if modDat["doNotShowAgain"] then return end

    local incompatibilityPopup = CompatibilityPopupWindow:new(200, 200, TETRIS_IMG, InventoryTetris.version)
    incompatibilityPopup:setModData(modDat)
    incompatibilityPopup:initialise()

    InventoryTetrisIncompatibleModWarningSystem.handleItemCategoryMods(incompatibilityPopup)

    -- Not really an incompatibility, but I'm very tired of people blaming Tetris for this one
    if isModActive("PLLootF") and not InventoryTetris.hasPawLowLootFantasyPatch() then
        incompatibilityPopup:addModIncompatibility("Paw Low Loot - Fantasy Pack", "PLLootF", "MAJOR BUG:\nCauses items dropped to the floor to be deleted.\nDo not use without a community patch, i.e. Yet Another Paw Low Patch ( PLLootF_Patch )")
    end

    if #incompatibilityPopup.incompatibleMods > 0 then
        incompatibilityPopup:addToUIManager()
    end
end

function InventoryTetrisIncompatibleModWarningSystem.handleItemCategoryMods(incompatibilityPopup)
    local explaination = "INCOMPATIBLE:\nBreaks item classifications and auto-balancing systems.\nMany items will be the wrong size and stack incorrectly."

    local foundIncompatibility = false

    if isModActive("BetterSortCC") then
        incompatibilityPopup:addModIncompatibility("Better Sorting", "BetterSortCC", explaination)
        foundIncompatibility = true
    end
    if isModActive("organizedCategories_core") then
        incompatibilityPopup:addModIncompatibility("organizedCategories: Core", "organizedCategories_core", explaination)
        foundIncompatibility = true
    end

    if foundIncompatibility then return end

    local failingItems = InventoryTetrisIncompatibleModWarningSystem.spotCheckItemCategories()
    if failingItems > 0 then
        incompatibilityPopup:addModIncompatibility(
            "Item Category Mod Detected!", 
            "Unknown Mod", 
            "An unknown mod appears to be changing item categories.\n"..
            tostring(failingItems).."/9 of the tested items failed category validation.\n"..explaination
        )
    end
end

function InventoryTetrisIncompatibleModWarningSystem.spotCheckItemCategories()
    -- We spot check the categories on a few items to see if there are any issues
    -- If so, we assume the player has a mod that changes item categories and warn them

    local expectedItemCategoryPairs = {
        {"Base.ShotgunShells", TetrisItemCategory.AMMO},
        {"Base.Laser", TetrisItemCategory.ATTACHMENT},
        {"Base.BaseballBat", TetrisItemCategory.MELEE},
        {"Base.Book", TetrisItemCategory.BOOK},
        {"Base.Socks_Ankle", TetrisItemCategory.CLOTHING},
        {"Base.Bandage", TetrisItemCategory.HEALING},
        {"Base.Scalpel", TetrisItemCategory.HEALING},
        {"Base.CarrotSeed", TetrisItemCategory.SEED},
        {"Base.AssaultRifle", TetrisItemCategory.RANGED},
    }

    local failCount = 0
    for _, pair in ipairs(expectedItemCategoryPairs) do
        local item = instanceItem(pair[1])
        if item then
            local category = TetrisItemCategory.getCategory(item)
            if category ~= pair[2] then
                failCount = failCount + 1
            end
        end
    end
    return failCount
end

-- Really not a fan of this, but I don't want to annoy people with this popup if they're using a patch, but I don't know if other patches exist...
-- So I made this function easy to override if needed
function InventoryTetrisIncompatibleModWarningSystem.hasPawLowLootFantasyPatch()
    return isModActive("PLLootF_Patch")
end

Events.OnGameStart.Add(function()
    InventoryTetrisIncompatibleModWarningSystem.showCompatibilityIssues()
end)