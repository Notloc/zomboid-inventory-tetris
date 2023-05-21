local OPT = require "InventoryTetris/Settings"

if not INVENTORY_TETRIS_MOD_OPTIONS then
    INVENTORY_TETRIS_MOD_OPTIONS = {
        options = {
            TETRIS_GRID_SCALE_INDEX = 3,
        },
        names = {
            TETRIS_GRID_SCALE_INDEX = "UI_equipment_options_scale",
        },
        mod_id = "INVENTORY_TETRIS",
        mod_shortname = getText("UI_optionscreen_binding_EquipmentUI"),
    }
end

local gridScaleIndexToScale = {
    0.5, -- 16px
    0.75, -- 24px
    1, -- 32px
    1.25, -- 40px
    1.5, -- 48px
    2, -- 64px
    2.5, -- 80px
    3, -- 96px
    4 -- 128px
}


if ModOptions and ModOptions.getInstance then
    local settings = ModOptions:getInstance(INVENTORY_TETRIS_MOD_OPTIONS)
    ModOptions:loadFile() -- Load the mod options file right away
    
    local gridScale = settings:getData("TETRIS_GRID_SCALE_INDEX")
    for i, scale in ipairs(gridScaleIndexToScale) do
        gridScale[i] = tostring(scale).."x"
    end

    function gridScale:OnApplyInGame(val)
        INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_GRID_SCALE_INDEX = val
        local scale = gridScaleIndexToScale[val]
        OPT:applyScale(scale)
    end

    OPT:applyScale(gridScaleIndexToScale[INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_GRID_SCALE_INDEX])
end