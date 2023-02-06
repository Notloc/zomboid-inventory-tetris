InventoryTetrisGridDefinitions = {
    ["default"] = {
        {
            size = {width=5, height=5},
            position = {x=0, y=0},
        }
    },

    ["floor"] = {
        {
            size = {width=8, height=8},
            position = {x=0, y=0},
        }
    },

    ["overhead"] = {
        {
            size = {width=5, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=1},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=2},
        }
    },

    ["counter"] = {
        {
            size = {width=4, height=3},
            position = {x=0, y=0},
        },
        {
            size = {width=4, height=3},
            position = {x=1, y=0},
        },
        {
            size = {width=4, height=3},
            position = {x=0, y=1},
        },
        {
            size = {width=4, height=3},
            position = {x=1, y=1},
        }
    },

    ["shelves_small"] = {
        {
            size = {width=5, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=1},
        },
    },

    ["shelves_medium"] = {
        {
            size = {width=5, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=1},
        },
        {
            size = {width=5, height=2},
            position = {x=0, y=2},
        },
    },

    -- 3 small drawers, vertical
    ["sidetable"] = {
        {
            size = {width=3, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=3, height=2},
            position = {x=0, y=1},
        },
        {
            size = {width=3, height=2},
            position = {x=0, y=2},
        },
    },

    -- 3 small drawers, vertical        
    ["dresser"] = {
        {
            size = {width=3, height=2},
            position = {x=0, y=0},
        },
        {
            size = {width=3, height=2},
            position = {x=0, y=1},
        },
        {
            size = {width=3, height=2},
            position = {x=0, y=2},
        },
    },

    ["Guitarcase"] = {
        {
            size = {width=2, height=5},
            position = {x=0, y=0},
        }
    }
}

InventoryTetrisContainerOverloads = {
    ["crate"] = {
        [40] = "crate_medium"
    },
    ["shelves"] = {
        [15] = "shelves_small",
        [30] = "shelves_medium",
    },
}
