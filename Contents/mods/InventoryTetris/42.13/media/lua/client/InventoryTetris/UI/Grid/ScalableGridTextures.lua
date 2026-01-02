--- EmmyLua can't parse the float keys
---@diagnostic disable: duplicate-index

local ScalableGridTextures = {}

ScalableGridTextures.GridBackgroundTexturesByScale = {
    [0.5] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX0.5.png"),
    [0.75] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX0.75.png"),
    [1] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX1.png"),
    [1.5] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX1.5.png"),
    [2] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX2.png"),
    [3] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX3.png"),
    [4] = getTexture("media/textures/InventoryTetris/Grid/GridSlotX4.png")
}

ScalableGridTextures.GridLineTexturesByScale = {
    [0.5] = getTexture("media/textures/InventoryTetris/Grid/GridLineX0.5.png"),
    [0.75] = getTexture("media/textures/InventoryTetris/Grid/GridLineX0.75.png"),
    [1] = getTexture("media/textures/InventoryTetris/Grid/GridLineX1.png"),
    [1.5] = getTexture("media/textures/InventoryTetris/Grid/GridLineX1.5.png"),
    [2] = getTexture("media/textures/InventoryTetris/Grid/GridLineX2.png"),
    [3] = getTexture("media/textures/InventoryTetris/Grid/GridLineX3.png"),
    [4] = getTexture("media/textures/InventoryTetris/Grid/GridLineX4.png")
}

ScalableGridTextures.ITEM_BG_TEXTURE = {
    [0.5] = getTexture("media/textures/InventoryTetris/0.5x/ItemBg.png"),
    [0.75] = getTexture("media/textures/InventoryTetris/0.75x/ItemBg.png"),
    [1] = getTexture("media/textures/InventoryTetris/1x/ItemBg.png"),
    [1.5] = getTexture("media/textures/InventoryTetris/1.5x/ItemBg.png"),
    [2] = getTexture("media/textures/InventoryTetris/2x/ItemBg.png"),
    [3] = getTexture("media/textures/InventoryTetris/3x/ItemBg.png"),
    [4] = getTexture("media/textures/InventoryTetris/4x/ItemBg.png")
}

ScalableGridTextures.FAVOURITE_TEXTURE = {
    [0.5] =   getTexture("media/textures/InventoryTetris/0.5x/Favourite.png"),
    [0.75] =  getTexture("media/textures/InventoryTetris/0.5x/Favourite.png"),
    [1] =     getTexture("media/textures/InventoryTetris/1x/Favourite.png"),
    [1.5] =   getTexture("media/textures/InventoryTetris/1x/Favourite.png"),
    [2] =     getTexture("media/textures/InventoryTetris/2x/Favourite.png"),
    [3] =     getTexture("media/textures/InventoryTetris/3x/Favourite.png"),
    [4] =     getTexture("media/textures/InventoryTetris/4x/Favourite.png")
}

ScalableGridTextures.POISON_TEXTURE = {
    [0.5] =   getTexture("media/textures/InventoryTetris/0.5x/Poison.png"),
    [0.75] =  getTexture("media/textures/InventoryTetris/0.5x/Poison.png"),
    [1] =     getTexture("media/textures/InventoryTetris/1x/Poison.png"),
    [1.5] =   getTexture("media/textures/InventoryTetris/1x/Poison.png"),
    [2] =     getTexture("media/textures/InventoryTetris/2x/Poison.png"),
    [3] =     getTexture("media/textures/InventoryTetris/3x/Poison.png"),
    [4] =     getTexture("media/textures/InventoryTetris/4x/Poison.png")
}

return ScalableGridTextures