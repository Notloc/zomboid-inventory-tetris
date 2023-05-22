local OPT = require "InventoryTetris/Settings"

if not INVENTORY_TETRIS_MOD_OPTIONS then
    INVENTORY_TETRIS_MOD_OPTIONS = {
        options = {
            TETRIS_GRID_SCALE_INDEX = 3,
            TETRIS_CONTAINER_INFO_SCALE_INDEX = 2,
        },
        names = {
            TETRIS_GRID_SCALE_INDEX = "UI_tetris_options_grid_scale",
            TETRIS_CONTAINER_INFO_SCALE_INDEX = "UI_tetris_options_container_info_scale",
        },
        mod_id = "INVENTORY_TETRIS",
        mod_shortname = getText("UI_optionscreen_binding_InventoryTetris"),
    }
end

local gridScaleIndexToScale = {
    0.5, -- 16px
    0.75, -- 24px
    1, -- 32px
    1.5, -- 48px
    2, -- 64px
    3, -- 96px
    4 -- 128px
}

local containerInfoScaleIndexToScale = {
    0.75,
    1,
    1.5,
    2,
    3,
    4
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
        OPT:applyGridScale(scale)
    end

    OPT:applyGridScale(gridScaleIndexToScale[INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_GRID_SCALE_INDEX])


    local containerScale = settings:getData("TETRIS_CONTAINER_INFO_SCALE_INDEX")
    for i, scale in ipairs(containerInfoScaleIndexToScale) do
        containerScale[i] = tostring(scale).."x"
    end

    function containerScale:OnApplyInGame(val)
        INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_CONTAINER_INFO_SCALE_INDEX = val
        local scale = containerInfoScaleIndexToScale[val]
        OPT:applyContainerInfoScale(scale)
    end

    OPT:applyContainerInfoScale(containerInfoScaleIndexToScale[INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_CONTAINER_INFO_SCALE_INDEX])
end