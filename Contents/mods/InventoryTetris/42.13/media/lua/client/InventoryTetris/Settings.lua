local EasyOptionsBuilder = require("Notloc/EasyOptions/EasyOptionsBuilder")

local gridScaleOptions = {
    {value=0.5,  name="0.5x"},
    {value=0.75, name="0.75x"},
    {value=1.0,  name="1x"},
    {value=1.5,  name="1.5x"},
    {value=2.0,  name="2x"},
    {value=3.0,  name="3x"},
    {value=4.0,  name="4x"},
}

local containerInfoScaleOptions = {
    {value=0.75, name="0.75x"},
    {value=1.0,  name="1x"},
    {value=1.5,  name="1.5x"},
    {value=2.0,  name="2x"},
    {value=3.0,  name="3x"},
    {value=4.0,  name="4x"},
}

local clickDropdownOptions = {
    {value="none",     name="UI_tetris_options_do_nothing"},
    {value="interact", name="UI_tetris_options_do_interact"},
    {value="move",     name="UI_tetris_options_do_move"},
    {value="equip",    name="UI_tetris_options_do_equip"},
    {value="drop",     name="UI_tetris_options_do_drop"},
    {value="multi",    name="UI_tetris_options_do_multi"},
}

-- Define the options
local optionDefinitions = {
    EasyOptionsBuilder.defineTitle("UI_tetris_scale_options"),
    EasyOptionsBuilder.defineDropdown("SCALE", 1.0, gridScaleOptions, "UI_tetris_options_grid_scale"),
    EasyOptionsBuilder.defineDropdown("CONTAINER_INFO_SCALE", 1.0, containerInfoScaleOptions, "UI_tetris_options_container_info_scale"),
    EasyOptionsBuilder.defineHidden("TEXTURE_SIZE", 32),
    EasyOptionsBuilder.defineHidden("TEXTURE_PAD", 2),
    EasyOptionsBuilder.defineHidden("CELL_SIZE", 35),

    EasyOptionsBuilder.defineTitle("UI_tetris_control_options"),
    EasyOptionsBuilder.defineDropdown("DOUBLE_CLICK_ACTION", "interact", clickDropdownOptions, "UI_tetris_options_double_click_action"),
    EasyOptionsBuilder.defineDropdown("CTRL_CLICK_ACTION", "move", clickDropdownOptions, "UI_tetris_options_ctrl_click_action"),
    EasyOptionsBuilder.defineDropdown("ALT_CLICK_ACTION", "equip", clickDropdownOptions, "UI_tetris_options_alt_click_action"),
    EasyOptionsBuilder.defineDropdown("SHIFT_CLICK_ACTION", "multi", clickDropdownOptions, "UI_tetris_options_shift_click_action"),

    EasyOptionsBuilder.defineTitle("UI_tetris_performance_options"),
    EasyOptionsBuilder.defineCheckbox("DO_STACK_SHADOWS", true, "UI_tetris_options_do_stack_shadows", "UI_tetris_options_do_stack_shadows_desc"),
}

---@class InventoryTetrisOptions : EasyOptions
---@field SCALE number
---@field TEXTURE_SIZE integer
---@field TEXTURE_PAD integer
---@field CELL_SIZE integer
---@field CONTAINER_INFO_SCALE number
---@field DOUBLE_CLICK_ACTION string
---@field CTRL_CLICK_ACTION string
---@field ALT_CLICK_ACTION string
---@field SHIFT_CLICK_ACTION string
---@field DO_STACK_SHADOWS boolean
local INVENTORY_TETRIS_OPTIONS = EasyOptionsBuilder.build(optionDefinitions, "INVENTORY_TETRIS", "UI_optionscreen_binding_InventoryTetris")

-- Register a callback for when the scale changes and apply it immediately
INVENTORY_TETRIS_OPTIONS.OnValueChanged.SCALE:addAndApply(function(scale)
    INVENTORY_TETRIS_OPTIONS.TEXTURE_SIZE = 32 * scale
    INVENTORY_TETRIS_OPTIONS.TEXTURE_PAD = 2 * scale
    INVENTORY_TETRIS_OPTIONS.CELL_SIZE = INVENTORY_TETRIS_OPTIONS.TEXTURE_SIZE + INVENTORY_TETRIS_OPTIONS.TEXTURE_PAD * 2 + 1
end)

return INVENTORY_TETRIS_OPTIONS
