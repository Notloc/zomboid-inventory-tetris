local TetrisPocketData = require("InventoryTetris/Data/TetrisPocketData")

local pocketPack = {
    ["Base.PonchoYellow"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 2,
                    ["height"] = 1,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 2,
                    ["height"] = 1,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 1,
                    ["height"] = 1,
                },
                ["position"] = {
                    ["x"] = 2,
                    ["y"] = 0,
                },
            },
            [4] = {
                ["size"] = {
                    ["width"] = 1,
                    ["height"] = 1,
                },
                ["position"] = {
                    ["x"] = 3,
                    ["y"] = 0,
                },
            },
        },
    },
}

TetrisPocketData.registerPocketDefinitions(pocketPack)
