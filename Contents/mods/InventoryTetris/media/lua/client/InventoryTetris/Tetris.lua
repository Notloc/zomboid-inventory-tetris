local CompatibilityPopupWindow = require "Notloc/Versioning/CompatibilityPopupWindow"
local Version = require "Notloc/Versioning/Version"

local TETRIS_IMG = getTexture("media/textures/Compatibility/tetris.png")
local EQUIPMENT_IMG = getTexture("media/textures/Compatibility/equipment_ui.png")

InventoryTetris = {
    version = Version:new(6, 0, 0, "beta"),
}

local function showCompatibilityIssues()
    if not EquipmentUI or Version.isBelow(EquipmentUI.version, 2) then
        local cpw = CompatibilityPopupWindow:new(100, 100, TETRIS_IMG, InventoryTetris.version, EQUIPMENT_IMG, EquipmentUI and EquipmentUI.version, Version:new(2,0,0))
        cpw:initialise()
        cpw:addToUIManager()
    end

    local incompatibilityPopup = CompatibilityPopupWindow:new(200, 200, TETRIS_IMG, InventoryTetris.version)
    incompatibilityPopup:initialise()

    -- Known incompatibilities, I will only list things here that I believe will never be fixed
    -- and are not worth the effort to work around
    if getActivatedMods():contains("BetterSortCC") then
        incompatibilityPopup:addModIncompatibility("Better Sorting", "BetterSortCC")
    end

    if #incompatibilityPopup.incompatibleMods > 0 then
        incompatibilityPopup:addToUIManager()
    end
end

Events.OnGameStart.Add(function()
    showCompatibilityIssues()
end)
