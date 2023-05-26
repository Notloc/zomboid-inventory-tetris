require "InventoryTetris/TetrisItemData"
require "InventoryTetris/TetrisContainerData"

-- All packs except these defaults should be registered in the OnGameBoot event.
-- I go first so that you can overwrite my defaults with your own.
-- You can delay further if you want, but unless you have a reason to wait longer, you should do it in OnGameBoot.

local defaultItemPack = {
    --item:getFullType()    x/y size         maxStackSize=1 if not specified
    ["Base.KeyRing"] = { width=1, height=1, maxStackSize=1 },
    ["Base.Pan"] = {height=2, width=2, maxStackSize=1},
    ["Base.BakingTray"] = {height=2, width=2, maxStackSize=1},
    ["Base.CuttingBoardPlastic"] = {height=2, width=2, maxStackSize=5},
    ["Base.TinOpener"] = {height=1, width=2, maxStackSize=1},
    ["Base.Nails"] = {height=1, width=1, maxStackSize=50},
    ["Base.HandTorch"] = {height=1, width=2, maxStackSize=1},
    ["Base.Peas"] = {height=2, width=1, maxStackSize=1},
    ["Base.Spatula"] = {height=1, width=2, maxStackSize=1},
    ["Base.TunaTin"] = {height=1, width=1, maxStackSize=3},
    ["Base.RedPen"] = {height=1, width=1, maxStackSize=5},
    ["Base.Pen"] = {height=1, width=1, maxStackSize=5},
    ["Base.SheetPaper2"] = {height=1, width=2, maxStackSize=10},
    ["Base.BluePen"] = {height=1, width=1, maxStackSize=5},
    ["Base.Plank"] = {height=1, width=4, maxStackSize=2},
    ["Base.EmptyPetrolCan"] = {height=2, width=2, maxStackSize=1},
    ["Base.Pencil"] = {height=1, width=1, maxStackSize=5},
    ["Base.WaterBottleFull"] = {height=1, width=2, maxStackSize=1},
    ["Base.WaterBottleEmpty"] = {height=1, width=2, maxStackSize=1},
    ["Base.Money"] = {height=1, width=1, maxStackSize=100},
    ["Moveables.location_shop_greenes_01_37"] = {height=3, width=3, maxStackSize=1},
    ["Base.Saucepan"] = {height=2, width=2, maxStackSize=2},
    ["Base.KitchenTongs"] = {height=1, width=2, maxStackSize=1},
    ["Base.BakingPan"] = {height=2, width=2, maxStackSize=4},
    ["Base.Kettle"] = {height=2, width=2, maxStackSize=1},
    ["Base.MuffinTray"] = {height=2, width=2, maxStackSize=4},
    ["Base.Bowl"] = {height=1, width=1, maxStackSize=3},
    ["Base.OvenMitt"] = {height=1, width=2, maxStackSize=2},
    ["Base.Shovel"] = {height=1, width=4, maxStackSize=1},
    ["Base.CordlessPhone"] = {height=1, width=2, maxStackSize=1},
    ["Base.ElectronicsScrap"] = {height=1, width=1, maxStackSize=2},
    ["Base.Cereal"] = {height=2, width=2, maxStackSize=1},
    ["Base.OilOlive"] = {height=1, width=2, maxStackSize=1},
    ["Base.Peppermint"] = {height=1, width=1, maxStackSize=5},
    ["Base.Flour"] = {height=2, width=2, maxStackSize=1},
    ["Base.PopBottle"] = {height=1, width=2, maxStackSize=1},
    ["Base.GuitarAcoustic"] = {height=2, width=5, maxStackSize=1},
    ["Base.GridlePan"] = {height=2, width=2, maxStackSize=1},
    ["Base.Plunger"] = {height=1, width=3, maxStackSize=1},
    ["Base.Sheet"] = {height=2, width=1, maxStackSize=2},
    ["Base.Drumstick"] = {height=1, width=2, maxStackSize=1},
    ["Base.Trumpet"] = {height=3, width=2, maxStackSize=1},
    ["Base.Headphones"] = {height=2, width=2, maxStackSize=4},
    ["Base.RoastingPan"] = {height=2, width=2, maxStackSize=3},
    ["Base.Disinfectant"] = {height=1, width=2, maxStackSize=1},
    ["Radio.ElectricWire"] = {height=2, width=2, maxStackSize=5},
    ["Base.GardenSaw"] = {height=2, width=1, maxStackSize=2},
    ["Base.HandAxe"] = {height=1, width=2, maxStackSize=1},
    ["Base.Rope"] = {height=2, width=2, maxStackSize=3},
    ["Base.Gravelbag"] = {height=2, width=3, maxStackSize=2},
    ["Base.FishingRod"] = {height=1, width=4, maxStackSize=1},
    ["Base.PropaneTank"] = {height=3, width=4, maxStackSize=2},
    ["Base.CarBattery3"] = {height=3, width=2, maxStackSize=2},
    ["Base.WineEmpty"] = {height=1, width=2, maxStackSize=3},
    ["Base.Broom"] = {height=1, width=4, maxStackSize=1},
    ["Base.Tarp"] = {height=2, width=2, maxStackSize=2},
    ["Base.Mop"] = {height=1, width=4, maxStackSize=4},
    ["Base.Bleach"] = {height=1, width=2, maxStackSize=2},
    ["Base.BeerEmpty"] = {height=1, width=2, maxStackSize=4},
    ["Base.GlassWine"] = {height=1, width=1, maxStackSize=1},
    ["Base.VHS_Retail"] = {height=2, width=1, maxStackSize=1},
    ["Base.Aluminum"] = {height=2, width=1, maxStackSize=2},
    ["Base.Pot"] = {height=2, width=2, maxStackSize=1},
    ["Base.KitchenKnife"] = {height=1, width=2, maxStackSize=1},
    ["Base.CannedSardines"] = {height=1, width=1, maxStackSize=3},
    ["Base.GuitarElectricBlue"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricRed"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricBlack"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricBassBlue"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricBassRed"] = {height=2, width=5, maxStackSize=1},
    ["Base.GuitarElectricBassBlack"] = {height=2, width=5, maxStackSize=1},
    ["Base.AmmoStraps"] = {height=2, width=1, maxStackSize=2},
    ["Base.Amplifier"] = {height=1, width=1, maxStackSize=1},
    ["Base.Saw"] = {height=2, width=1, maxStackSize=2},
    ["Base.Wire"] = {height=2, width=2, maxStackSize=4},
    ["Base.FirstAidKit"] = {height=2, width=2, maxStackSize=1}
}

local defaultContainerPack = {
    -- Example
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

    -- Player Inv
    ["none"] = {
        centerMode = "vertical",
        gridDefinitions = {
            {
                size = {width=1, height=2},
                position = {x=1, y=1},
            },
            {
                size = {width=1, height=2},
                position = {x=2, y=1},
            },
            {
                size = {width=1, height=2},
                position = {x=3, y=1},
            },
            {
                size = {width=1, height=2},
                position = {x=4, y=1},
            },
            {
                size = {width=1, height=1},
                position = {x=5, y=1},
            },
        },
        isOrganized = true,
    },

    ["floor_50"] = {
        gridDefinitions = {
            {
                size = {width=10, height=10},
                position = {x=1, y=1},
            }
        },
        isOrganized = false,
    },
    ["Bag_DoctorBag_8"] = {
        gridDefinitions = {
            {
                size = {width=5, height=5},
                position = {x=1, y=1},
            }
        },
        validCategories = {TetrisItemCategory.HEALING},
    }
}

TetrisItemData.registerItemDefinitions(defaultItemPack)
TetrisContainerData.registerContainerDefinitions(defaultContainerPack)
