local CompatibilityPopupWindow = require("InventoryTetris/UI/Windows/CompatibilityPopupWindow")
local Version = require("Notloc/Versioning/Version")

local TETRIS_IMG = getTexture("media/textures/Compatibility/tetris.png")
local EQUIPMENT_IMG = getTexture("media/textures/Compatibility/equipment_ui.png")

InventoryTetris = {
    version = Version:new(6, 1, 0, "beta"),
}

-- Handle the prepended slash bug
local function isModActive(modID)
    return getActivatedMods():contains(modID) or getActivatedMods():contains("\\"..modID)
end

local function showCompatibilityIssues()
    if not EquipmentUI or Version.isBelow(EquipmentUI.version, 2, 1) then
        local cpw = CompatibilityPopupWindow:new(100, 100, TETRIS_IMG, InventoryTetris.version, EQUIPMENT_IMG, EquipmentUI and EquipmentUI.version, Version:new(2,1,0))
        cpw:initialise()
        cpw:addToUIManager()
    end

    local incompatibilityPopup = CompatibilityPopupWindow:new(200, 200, TETRIS_IMG, InventoryTetris.version)
    incompatibilityPopup:initialise()

    -- Known incompatibilities, I will only list things here that I cannot or will not fix

    if isModActive("BetterSortCC") then
        incompatibilityPopup:addModIncompatibility("Better Sorting", "BetterSortCC", "INCOMPATIBLE:\nBreaks item classifications and auto-balancing systems.\nMany items will be the wrong size and stack incorrectly.")
    end

    -- Not really an incompatibility, but I'm tired of people blaming Tetris for this one
    if isModActive("PLLootF") and not InventoryTetris.hasPawLowLootFantasyPatch() then
        incompatibilityPopup:addModIncompatibility("Paw Low Loot - Fantasy Pack", "PLLootF", "MAJOR BUG:\nCauses items dropped to the floor to be deleted.\nDo not use without a community patch, i.e. Yet Another Paw Low Patch ( PLLootF_Patch )")
    end

    if #incompatibilityPopup.incompatibleMods > 0 then
        incompatibilityPopup:addToUIManager()
    end
end

-- Really not a fan of this, but I don't want to annoy people with this popup if they're using a patch, but I don't know if other patches exist...
-- So I made this function easy to override if needed
function InventoryTetris.hasPawLowLootFantasyPatch()
    return isModActive("PLLootF_Patch")
end

Events.OnGameStart.Add(function()
    showCompatibilityIssues()
end)
