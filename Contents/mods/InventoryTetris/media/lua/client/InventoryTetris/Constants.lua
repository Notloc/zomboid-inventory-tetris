InventoryTetris = {}

local constants = {}

constants.SCALE = 1

constants.TEXTURE_SIZE = 32 * constants.SCALE;
constants.TEXTURE_PAD = 3 * constants.SCALE;
constants.CELL_SIZE = constants.TEXTURE_SIZE + constants.TEXTURE_PAD * 2 + 1
constants.ICON_SCALE = constants.TEXTURE_SIZE / 32

return constants