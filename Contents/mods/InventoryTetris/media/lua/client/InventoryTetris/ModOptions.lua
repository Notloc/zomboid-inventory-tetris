local OPT = require "InventoryTetris/Settings"

if not INVENTORY_TETRIS_MOD_OPTIONS then
    INVENTORY_TETRIS_MOD_OPTIONS = {
        options = {
            TETRIS_GRID_SCALE_INDEX = 3,
            TETRIS_CONTAINER_INFO_SCALE_INDEX = 2,

            TETRIS_DOUBLE_CLICK_ACTION_INDEX = 2,
            TETRIS_CTRL_CLICK_ACTION_INDEX = 3,
            TETRIS_ALT_CLICK_ACTION_INDEX = 4,
            TETRIS_SHIFT_CLICK_ACTION_INDEX = 2,
        },
        names = {
            TETRIS_GRID_SCALE_INDEX = "UI_tetris_options_grid_scale",
            TETRIS_CONTAINER_INFO_SCALE_INDEX = "UI_tetris_options_container_info_scale",

            TETRIS_DOUBLE_CLICK_ACTION_INDEX = "UI_tetris_options_double_click_action",
            TETRIS_CTRL_CLICK_ACTION_INDEX = "UI_tetris_options_ctrl_click_action",
            TETRIS_ALT_CLICK_ACTION_INDEX = "UI_tetris_options_alt_click_action",
            TETRIS_SHIFT_CLICK_ACTION_INDEX = "UI_tetris_options_shift_click_action",
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

local actionNamesByIndex = {
    "UI_tetris_options_do_nothing",
    "UI_tetris_options_do_interact",
    "UI_tetris_options_do_move",
    "UI_tetris_options_do_equip",
    "UI_tetris_options_do_drop",
}

local actionsByIndex = {
    "none",
    "interact",
    "move",
    "equip",
    "drop",
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


    local doubleClickAction = settings:getData("TETRIS_DOUBLE_CLICK_ACTION_INDEX")
    for i, action in ipairs(actionNamesByIndex) do
        doubleClickAction[i] = getText(action)
    end
    function doubleClickAction:OnApplyInGame(val)
        INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_DOUBLE_CLICK_ACTION_INDEX = val
        local action = actionsByIndex[val]
        OPT:applyDoubleClickAction(action)
    end
    doubleClickAction:OnApplyInGame(INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_DOUBLE_CLICK_ACTION_INDEX)


    local ctrlClickAction = settings:getData("TETRIS_CTRL_CLICK_ACTION_INDEX")
    for i, action in ipairs(actionNamesByIndex) do
        ctrlClickAction[i] = getText(action)
    end
    function ctrlClickAction:OnApplyInGame(val)
        INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_CTRL_CLICK_ACTION_INDEX = val
        local action = actionsByIndex[val]
        OPT:applyCtrlClickAction(action)
    end
    ctrlClickAction:OnApplyInGame(INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_CTRL_CLICK_ACTION_INDEX)


    local altClickAction = settings:getData("TETRIS_ALT_CLICK_ACTION_INDEX")
    for i, action in ipairs(actionNamesByIndex) do
        altClickAction[i] = getText(action)
    end
    function altClickAction:OnApplyInGame(val)
        INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_ALT_CLICK_ACTION_INDEX = val
        local action = actionsByIndex[val]
        OPT:applyAltClickAction(action)
    end
    altClickAction:OnApplyInGame(INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_ALT_CLICK_ACTION_INDEX)


    local shiftClickAction = settings:getData("TETRIS_SHIFT_CLICK_ACTION_INDEX")
    for i, action in ipairs(actionNamesByIndex) do
        shiftClickAction[i] = getText(action)
    end
    function shiftClickAction:OnApplyInGame(val)
        INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_SHIFT_CLICK_ACTION_INDEX = val
        local action = actionsByIndex[val]
        OPT:applyShiftClickAction(action)
    end
    shiftClickAction:OnApplyInGame(INVENTORY_TETRIS_MOD_OPTIONS.options.TETRIS_SHIFT_CLICK_ACTION_INDEX)

end