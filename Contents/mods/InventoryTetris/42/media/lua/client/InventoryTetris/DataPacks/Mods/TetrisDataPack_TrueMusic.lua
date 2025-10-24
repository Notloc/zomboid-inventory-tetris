local TetrisItemData = require("InventoryTetris/Data/TetrisItemData")
local TetrisContainerData = require("InventoryTetris/Data/TetrisContainerData")

local itemPack = {
    ["Tsarcraft.TCWalkman"] = {
        ["maxStackSize"] = 1,
        ["height"] = 1,
        ["width"] = 1,
    },
    ["Tsarcraft.TCBoombox"] = {
        ["width"] = 1,
        ["height"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Tsarcraft.TCVinylplayer"] = {
        ["maxStackSize"] = 1,
        ["height"] = 3,
        ["width"] = 3,
    },
}

local containerPack = {
    ["tcmusic_1"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 10,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["validCategories"] = {
            ["ENTERTAINMENT"] = true,
        },
    },
}

TetrisItemData.registerItemDefinitions(itemPack)
TetrisContainerData.registerContainerDefinitions(containerPack)