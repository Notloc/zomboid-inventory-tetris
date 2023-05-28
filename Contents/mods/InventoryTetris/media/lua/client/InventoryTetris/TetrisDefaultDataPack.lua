require "InventoryTetris/TetrisItemData"
require "InventoryTetris/TetrisContainerData"

-- All packs except these defaults should be registered in the OnGameBoot event.
-- I go first so that you can overwrite my defaults with your own.

local defaultItemPack = {

}

local defaultContainerPack = {
    -- Example for manual container definition
    ["a_fake_container_id_that_will_never_be_used"] = {
        -- Defines the grids inside the container
        -- In this case, 2 side-by-side grids, 3x3
        gridDefinitions = {
            {
                size = {width=3, height=3},
                position = {x=1, y=1},
            },
            {
                size = {width=3, height=3},
                position = {x=2, y=1},
            }
        },

        -- Defines if the grid is organized
        -- If true, items that are quick moved will be placed in the first available slot
        -- If false, items that are quick moved will be placed randomly and stacks will not necessarily stay together
        isOrganized = true,

        -- Defines how the grids are aligned
        -- If "vertical", the grid colums will be aligned vertically against the tallest column
        -- If "horizontal", the grid rows will be aligned horizontally against the widest row
        -- If "none", "horizontal" is used
        centerMode = "vertical",

        -- Defines the categories that can be placed in this container
        -- If nil, all categories are allowed
        -- Uses the constants from the TetrisItemCategory file, other categories will not work
        validCategories = {TetrisItemCategory.HEALING},

        -- Defines specific items that can be placed in this container
        -- If nil, all items are allowed (unless validCategories is set)
        -- These items are additive with the items from validCategories
        -- If validCategories is nil, only these items are allowed
        validItems = {"Base.Bandage", "Base.Painkillers"},

        -- If both validCategories and validItems are nil, all items are allowed, the default behavior
    },   
}

local defaultVehiclePack = {
    "TruckBed",
    "TrailerTrunk",
    "TruckBedOpen",
}

TetrisItemData.registerItemDefinitions(defaultItemPack)
TetrisContainerData.registerContainerDefinitions(defaultContainerPack)
TetrisContainerData.registerLargeVehicleStorageContainers(defaultVehiclePack)
