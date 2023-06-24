if not INVENTORY_TETRIS_SETTINGS then
    local EasySettings = require("Notloc/EasySettings")

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
    }

    local SETTING_DEFINITIONS = {
        SCALE = EasySettings.defineDropdown(1.0, gridScaleOptions, "UI_tetris_options_grid_scale"),
        TEXTURE_SIZE = EasySettings.defineHidden(32),
        TEXTURE_PAD = EasySettings.defineHidden(2),
        CELL_SIZE = EasySettings.defineHidden(35),
        CONTAINER_INFO_SCALE = EasySettings.defineDropdown(1.0, containerInfoScaleOptions, "UI_tetris_options_container_info_scale"),
        DOUBLE_CLICK_ACTION = EasySettings.defineDropdown("interact", clickDropdownOptions, "UI_tetris_options_double_click_action"),
        CTRL_CLICK_ACTION = EasySettings.defineDropdown("move", clickDropdownOptions, "UI_tetris_options_ctrl_click_action"),
        ALT_CLICK_ACTION = EasySettings.defineDropdown("equip", clickDropdownOptions, "UI_tetris_options_alt_click_action"),
        SHIFT_CLICK_ACTION = EasySettings.defineDropdown("drop", clickDropdownOptions, "UI_tetris_options_shift_click_action"),
    }

    local SETTINGS = EasySettings.build(SETTING_DEFINITIONS, "INVENTORY_TETRIS", getText("UI_optionscreen_binding_InventoryTetris"))
    SETTINGS.OnValueChanged.SCALE:add(function(scale)
        SETTINGS.TEXTURE_SIZE = 32 * scale
        SETTINGS.TEXTURE_PAD = 2 * scale
        SETTINGS.CELL_SIZE = SETTINGS.TEXTURE_SIZE + SETTINGS.TEXTURE_PAD * 2 + 1
    end)

    INVENTORY_TETRIS_SETTINGS = SETTINGS
end

return INVENTORY_TETRIS_SETTINGS
