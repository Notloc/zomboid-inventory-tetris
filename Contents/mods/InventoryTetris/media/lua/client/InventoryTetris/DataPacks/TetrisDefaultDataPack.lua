require "InventoryTetris/TetrisItemData"
require "InventoryTetris/TetrisContainerData"

-- All packs except this default should be registered in the OnGameBoot event.
-- I go first so that you can overwrite my defaults with your own.

local itemPack = {
    ["Base.Pan"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.BakingTray"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.CuttingBoardPlastic"] = {
        ["width"] = 2,
        ["height"] = 2,
        ["maxStackSize"] = 5,
    },
    ["Base.TinOpener"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Nails"] = {
        ["width"] = 1,
        ["height"] = 1,
        ["maxStackSize"] = 25,
    },
    ["Base.HandTorch"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Peas"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Spatula"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.TunaTin"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 3,
    },
    ["Base.RedPen"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.Pen"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.SheetPaper2"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 20,
    },
    ["Base.BluePen"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.Plank"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.EmptyPetrolCan"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Pencil"] = {
        ["width"] = 1,
        ["height"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.WaterBottleFull"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Money"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 100,
    },
    ["Moveables.location_shop_greenes_01_37"] = {
        ["height"] = 3,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["Base.Saucepan"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.KitchenTongs"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.BakingPan"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 4,
    },
    ["Base.Kettle"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.MuffinTray"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 4,
    },
    ["Base.Bowl"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 3,
    },
    ["Base.OvenMitt"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.Shovel"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.CordlessPhone"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.ElectronicsScrap"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.Cereal"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.OilOlive"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Peppermint"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.Flour"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PopBottle"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.GuitarAcoustic"] = {
        ["height"] = 5,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.GridlePan"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Plunger"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Sheet"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Headphones"] = {
        ["width"] = 2,
        ["height"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.RoastingPan"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.Disinfectant"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Radio.ElectricWire"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 5,
    },
    ["Base.GardenSaw"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.HandAxe"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Rope"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.FishingRod"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.PropaneTank"] = {
        ["height"] = 4,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.WineEmpty"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Broom"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Tarp"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Mop"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.Bleach"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.BeerEmpty"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.GlassWine"] = {
        ["width"] = 1,
        ["height"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.VHS_Retail"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Aluminum"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Pot"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.KitchenKnife"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.CannedSardines"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 3,
    },
    ["Base.GuitarElectricBlue"] = {
        ["height"] = 5,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.GuitarElectricRed"] = {
        ["height"] = 5,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.GuitarElectricBlack"] = {
        ["height"] = 5,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.GuitarElectricBassBlue"] = {
        ["height"] = 5,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.GuitarElectricBassRed"] = {
        ["height"] = 5,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.GuitarElectricBassBlack"] = {
        ["height"] = 5,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.AmmoStraps"] = {
        ["width"] = 2,
        ["height"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Amplifier"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Saw"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Wire"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 4,
    },
    ["Base.BucketEmpty"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 5,
    },
    ["Base.Katana"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Radio.RadioRed"] = {
        ["width"] = 2,
        ["height"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.VideoGame"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.ClosedUmbrellaWhite"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Paperclip"] = {
        ["width"] = 1,
        ["height"] = 1,
        ["maxStackSize"] = 39,
    },
    ["Base.brokenglass_1_1"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.VHS_Home"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Hat_GasMask"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.WeldingMask"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_SPHhelmet"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Boilersuit_Flying"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.NormalCarMuffler2"] = {
        ["height"] = 2,
        ["width"] = 4,
        ["maxStackSize"] = 1,
    },
    ["Base.NormalCarMuffler1"] = {
        ["width"] = 3,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.NormalCarMuffler3"] = {
        ["width"] = 3,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.BackgammonBoard"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.Baguette"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.BaguetteDough"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.CookieChocolateChipDough"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.CookiesOatmealDough"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.CookiesShortbreadDough"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.CookiesSugarDough"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.CookiesChocolateDough"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Hat_BalaclavaFull"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.Bayonnet"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.BeerBottle"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Bellows"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.Hat_CrashHelmet"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.HolsterDouble"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 4,
    },
    ["Base.Hat_EarMuff_Protectors"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.Hat_EarMuffs"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.Hat_Fedora"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_Fireman"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Trousers_Fireman"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Hat_FootballHelmet"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_Jay"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_JockeyHelmet05"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_JockeyHelmet02"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_JockeyHelmet06"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_JockeyHelmet03"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_JockeyHelmet01"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_JockeyHelmet04"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_Army"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_CrashHelmetFULL"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_CrashHelmet_Police"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Boilersuit_Prisoner"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Boilersuit_PrisonerKhaki"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Hat_Raccoon"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_RiotHelmet"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.AmmoStrap_Shells"] = {
        ["height"] = 1,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.SpiffoSuit"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Hat_Spiffo"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.SpiffoTail"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Hat_CrashHelmet_Stars"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Jacket_Varsity"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Hat_WinterHat"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Hat_BaseballHelmet_Z"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.BathTowel"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 3,
    },
    ["Base.Battery"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.HairDyeBlonde"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.HairDyeGinger"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.HairDyeRed"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.HairDyeBlack"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.HairDyePink"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.HairDyeYellow"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.HairDyeWhite"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.HairDyeBlue"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.HairDyeLightBrown"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.HairDyeGreen"] = {
        ["width"] = 1,
        ["height"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintBlack"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.WaterPaintbucket"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintBrown"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintCyan"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintBlue"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintPurple"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintPink"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintWhite"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintLightBlue"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintGrey"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintTurquoise"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintRed"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintGreen"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintOrange"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintLightBrown"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintYellow"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.BucketConcreteFull"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.BucketWaterFull"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.BucketPlasterFull"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.WaterBowl"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.WaterBleachBottle"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.WaterBottlePetrol"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.WineWaterFull"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Hairgel"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.PetrolBleachBottle"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Trumpet"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["Base.CleaningLiquid2"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Extinguisher"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["farming.GardeningSprayFull"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.PetrolCan"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Gravelbag"] = {
        ["height"] = 4,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["farming.GardeningSprayCigarettes"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["farming.GardeningSprayMilk"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Fertilizer"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.BlowTorch"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Sandbag"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Vinegar"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["farming.WateredCanFull"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["Base.WeldingRods"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.x8Scope"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.x4Scope"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.x2Scope"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Laser"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FiberglassStock"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.ChokeTubeFull"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.IronSight"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.RedDot"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.ChokeTubeImproved"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Sling"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.GunLight"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.RecoilPad"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Chainsaw"] = {
        ["height"] = 2,
        ["width"] = 4,
        ["maxStackSize"] = 1,
    },
    ["Base.CraftedFishingRod"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FishingRodTwineLine"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.CraftedFishingRodTwineLine"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FishingRodBreak"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.DumbBell"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.SpearCrafted"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.Flute"] = {
        ["height"] = 1,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["Base.Football2"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.FlameTrapTriggered"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FlameTrapSensorV2"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FlameTrapSensorV3"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FlameTrapSensorV1"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FlameTrap"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.ClosedUmbrellaBlue"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.ClosedUmbrellaRed"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.ClosedUmbrellaBlack"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.CanoePadelX2"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.CanoePadel"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.GardenHoe"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Golfclub"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.IceHockeyStick"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Keytar"] = {
        ["height"] = 4,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.LaCrosseStick"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.LeafRake"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Molotov"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.NoiseTrapSensorV3"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.NoiseTrapSensorV1"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.NoiseTrapTriggered"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.NoiseTrapSensorV2"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.NoiseTrap"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PickAxeHandle"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.PipeBomb"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.PickAxe"] = {
        ["height"] = 4,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Poolcue"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Rake"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FlameTrapRemote"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.NoiseTrapRemote"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PipeBombRemote"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.SmokeBombRemote"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.RollingPin"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Shovel2"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.SmokeBomb"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.SmokeBombSensorV1"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.SmokeBombTriggered"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.SmokeBombSensorV2"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.SmokeBombSensorV3"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.SnowShovel"] = {
        ["height"] = 4,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.SpearHuntingKnife"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearBreadKnife"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearScalpel"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearScissors"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearButterKnife"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearFork"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearIcePick"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearHandFork"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearKnife"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearScrewdriver"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearSpoon"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearLetterOpener"] = {
        ["height"] = 5,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.SpearMachete"] = {
        ["height"] = 6,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.PickAxeHandleSpiked"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.PlankNail"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.TennisRacket"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Violin"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.WoodenLance"] = {
        ["height"] = 4,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Radio.RadioMakeShift"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Radio.WalkieTalkie3"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Radio.WalkieTalkieMakeShift"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Radio.WalkieTalkie2"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Radio.WalkieTalkie4"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Radio.WalkieTalkie5"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Radio.CDplayer"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.CuttingBoardWooden"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.Windshield2"] = {
        ["height"] = 4,
        ["width"] = 7,
        ["maxStackSize"] = 2,
    },
    ["Base.Windshield1"] = {
        ["height"] = 4,
        ["width"] = 6,
        ["maxStackSize"] = 2,
    },
    ["Base.Windshield3"] = {
        ["height"] = 4,
        ["width"] = 6,
        ["maxStackSize"] = 2,
    },
    ["Base.BathTowelWet"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.ChessWhite"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 16,
    },
    ["Base.OldTire1"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 2,
    },
    ["Base.OldTire3"] = {
        ["width"] = 4,
        ["height"] = 4,
        ["maxStackSize"] = 2,
    },
    ["Base.VHS"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.UmbrellaBlack"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.UmbrellaBlue"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.UmbrellaWhite"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.UmbrellaRed"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Twigs"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 4,
    },
    ["Base.TrunkDoor2"] = {
        ["height"] = 7,
        ["width"] = 7,
        ["maxStackSize"] = 2,
    },
    ["Base.TreeBranch"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.TirePump"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.WoodenStick"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.Staples"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 10,
    },
    ["Base.NormalTrunk2"] = {
        ["height"] = 9,
        ["width"] = 9,
        ["maxStackSize"] = 2,
    },
    ["Base.KatePic"] = {
        ["height"] = 14,
        ["width"] = 15,
        ["maxStackSize"] = 4,
    },
    ["Base.NormalCarSeat2"] = {
        ["height"] = 7,
        ["width"] = 7,
        ["maxStackSize"] = 1,
    },
    ["Base.NormalGasTank2"] = {
        ["height"] = 8,
        ["width"] = 8,
        ["maxStackSize"] = 2,
    },
    ["Base.TrunkDoor3"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 2,
    },
    ["Base.NormalTrunk3"] = {
        ["height"] = 7,
        ["width"] = 7,
        ["maxStackSize"] = 2,
    },
    ["Base.NormalCarSeat1"] = {
        ["height"] = 6,
        ["width"] = 6,
        ["maxStackSize"] = 1,
    },
    ["Base.NormalCarSeat3"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 1,
    },
    ["Base.NormalGasTank3"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 2,
    },
    ["Base.SmallTrunk3"] = {
        ["height"] = 7,
        ["width"] = 7,
        ["maxStackSize"] = 2,
    },
    ["Base.Spiffo"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Speaker"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.EngineParts"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.Screws"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 25,
    },
    ["Base.ScrewsBox"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.NormalTire3"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 2,
    },
    ["Base.NormalTire1"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 2,
    },
    ["Base.NormalTire2"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 2,
    },
    ["Base.NormalSuspension2"] = {
        ["height"] = 3,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.NormalSuspension1"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.RearWindow1"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.RearWindow2"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.RearWindow3"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.RearWindshield2"] = {
        ["height"] = 4,
        ["width"] = 5,
        ["maxStackSize"] = 2,
    },
    ["Base.RearCarDoor3"] = {
        ["height"] = 4,
        ["width"] = 5,
        ["maxStackSize"] = 2,
    },
    ["Base.RearCarDoor2"] = {
        ["height"] = 5,
        ["width"] = 6,
        ["maxStackSize"] = 2,
    },
    ["Base.PokerChips"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 10,
    },
    ["Base.PlasticTray"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 4,
    },
    ["Base.Pipe"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Pillow"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.ModernTire3"] = {
        ["height"] = 4,
        ["width"] = 4,
        ["maxStackSize"] = 2,
    },
    ["Base.ModernTire1"] = {
        ["height"] = 4,
        ["width"] = 4,
        ["maxStackSize"] = 2,
    },
    ["Base.ModernTire2"] = {
        ["height"] = 4,
        ["width"] = 4,
        ["maxStackSize"] = 2,
    },
    ["Base.ModernSuspension2"] = {
        ["height"] = 2,
        ["width"] = 4,
        ["maxStackSize"] = 2,
    },
    ["Base.ModernSuspension1"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.ModernCarMuffler2"] = {
        ["height"] = 2,
        ["width"] = 4,
        ["maxStackSize"] = 2,
    },
    ["Base.ModernCarMuffler3"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.ModernCarMuffler1"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.PancakeHedgehog"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.OldCarMuffler2"] = {
        ["height"] = 2,
        ["width"] = 4,
        ["maxStackSize"] = 2,
    },
    ["Base.OldCarMuffler1"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.OldCarMuffler3"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.PercedWood"] = {
        ["height"] = 3,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.MoleyMole"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.LugWrench"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 2,
    },
    ["Base.JacquesBeaver"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Jack"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.EngineDoor2"] = {
        ["height"] = 7,
        ["width"] = 7,
        ["maxStackSize"] = 1,
    },
    ["Base.EngineDoor3"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 1,
    },
    ["Base.EngineDoor1"] = {
        ["height"] = 6,
        ["width"] = 6,
        ["maxStackSize"] = 1,
    },
    ["Base.GrillBrush"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.GolfBall"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 2,
    },
    ["Base.FurbertSquirrel"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.FrontWindow1"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.FrontWindow2"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.FrontWindow3"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 2,
    },
    ["Base.FrontCarDoor3"] = {
        ["height"] = 4,
        ["width"] = 5,
        ["maxStackSize"] = 1,
    },
    ["Base.FrontCarDoor2"] = {
        ["height"] = 6,
        ["width"] = 6,
        ["maxStackSize"] = 1,
    },
    ["Base.FrontCarDoor1"] = {
        ["height"] = 5,
        ["width"] = 5,
        ["maxStackSize"] = 1,
    },
    ["Base.FreddyFox"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Football"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.FluffyfootBunny"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PaintbucketEmpty"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.SpiffoBig"] = {
        ["height"] = 4,
        ["width"] = 4,
        ["maxStackSize"] = 1,
    },
    ["Base.SeedBag"] = {
        ["width"] = 1,
        ["height"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.brokenglass_1_2"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 4,
    },
    ["Base.Charcoal"] = {
        ["height"] = 5,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["Base.CottonBalls"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.Guitarcase"] = {
        ["height"] = 4,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.KeyRing"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Cooler"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["Base.Bag_DoctorBag"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["Base.FirstAidKit"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Purse"] = {
        ["height"] = 3,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.SewingKit"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Drumstick"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Bag_FannyPackFront"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.Bag_FannyPackBack"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.SheetMetal"] = {
        ["height"] = 1,
        ["width"] = 2,
        ["maxStackSize"] = 3,
    },
    ["Base.SmallSheetMetal"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.SoccerBall"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.GunPowder"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.PetrolPopBottle"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.WaterBottleEmpty"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.PopBottleEmpty"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.BleachEmpty"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.WineEmpty2"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.WaterPopBottle"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["farming.WateredCan"] = {
        ["height"] = 2,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
    ["farming.GardeningSprayEmpty"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.MugWhite"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.MugRed"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Mugl"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.MugSpiffo"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.AlarmClock2"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Basketball"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.PoolBall"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Baseball"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.TennisBall"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Fork"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.BreadKnife"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.Spoon"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.ButterKnife"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 5,
    },
    ["Base.WaterPotRice"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.WaterPotPasta"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.ChessBlack"] = {
        ["height"] = 1,
        ["width"] = 1,
        ["maxStackSize"] = 16,
    },
    ["Base.CheckerBoard"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 5,
    },
    ["Radio.WalkieTalkie1"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.FullKettle"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.WaterPot"] = {
        ["height"] = 2,
        ["width"] = 2,
        ["maxStackSize"] = 1,
    },
    ["Base.BeerWaterFull"] = {
        ["height"] = 2,
        ["width"] = 1,
        ["maxStackSize"] = 1,
    },
    ["Base.Garbagebag"] = {
        ["height"] = 3,
        ["width"] = 3,
        ["maxStackSize"] = 1,
    },
}

local containerPack = {
    ["KeyRing_1"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 8,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["floor_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 12,
                    ["height"] = 12,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 1,
                },
            },
        },
        ["isOrganized"] = false,
    },
    ["Guitarcase_5"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["Toolbox_8"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["validCategories"] = {
            [1] = "MELEE_WEAPON",
            [2] = "MELEE_WEAPON",
            [3] = "RANGED_WEAPON",
            [4] = "RANGED_WEAPON",
            [5] = "AMMO",
            [6] = "AMMO",
            [7] = "MAGAZINE",
            [8] = "MAGAZINE",
            [9] = "FOOD",
            [10] = "FOOD",
            [11] = "DRINK",
            [12] = "CLOTHING",
            [13] = "CLOTHING",
            [14] = "DRINK",
            [15] = "HEALING",
            [16] = "HEALING",
            [17] = "BOOK",
            [18] = "BOOK",
            [19] = "ENTERTAINMENT",
            [20] = "ENTERTAINMENT",
            [21] = "KEY",
            [22] = "KEY",
            [23] = "MISC",
            [24] = "MISC",
            [25] = "SEED",
            [26] = "SEED",
        },
    },
    ["Bag_JanitorToolbox_8"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["validCategories"] = {
            [1] = "MELEE_WEAPON",
            [2] = "MELEE_WEAPON",
            [3] = "RANGED_WEAPON",
            [4] = "MAGAZINE",
            [5] = "AMMO",
            [6] = "AMMO",
            [7] = "RANGED_WEAPON",
            [8] = "MAGAZINE",
            [9] = "FOOD",
            [10] = "FOOD",
            [11] = "DRINK",
            [12] = "DRINK",
            [13] = "CLOTHING",
            [14] = "CLOTHING",
            [15] = "SEED",
            [16] = "SEED",
            [17] = "MISC",
            [18] = "MISC",
            [19] = "KEY",
            [20] = "KEY",
            [21] = "ENTERTAINMENT",
            [22] = "ENTERTAINMENT",
            [23] = "BOOK",
            [24] = "BOOK",
            [25] = "HEALING",
            [26] = "HEALING",
        },
    },
    ["Bag_NormalHikingBag_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 7,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["isOrganized"] = true,
    },
    ["postbox_5"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["bin_10"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["dresser_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
    },
    ["shelves_10"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["shelves_30"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
        ["isOrganized"] = true,
    },
    ["medicine_10"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
    },
    ["plankstash_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 12,
                    ["height"] = 12,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["microwave_10"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["filingcabinet_15"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
        ["isOrganized"] = true,
    },
    ["restaurantdisplay_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["barbecue_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["locker_10"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["vendingpop_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 7,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["locker_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 6,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 6,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                },
            },
        },
    },
    ["shelvesmag_15"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["isOrganized"] = true,
    },
    ["displaycase_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["isOrganized"] = true,
    },
    ["Flightcase_5"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 7,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["RevolverCase2_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["RevolverCase3_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["RevolverCase1_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["ShotgunCase1_7"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["ShotgunCase2_7"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["RifleCase2_7"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["RifleCase3_7"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["RifleCase1_7"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["PistolCase1_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["PistolCase2_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["PistolCase3_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["overhead_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                },
            },
            [4] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 1,
                },
            },
        },
    },
    ["counter_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
    },
    ["Bag_DoctorBag_8"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "RANGED_WEAPON",
            [2] = "AMMO",
            [3] = "MAGAZINE",
            [4] = "CONTAINER",
        },
    },
    ["Cooler_8"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 7,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["Bag_Military_18"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 8,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["FirstAidKit_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 6,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "RANGED_WEAPON",
            [2] = "CONTAINER",
            [3] = "MOVEABLE",
            [4] = "AMMO",
            [5] = "MAGAZINE",
        },
    },
    ["Garbagebag_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["Bag_GolfBag_18"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 8,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["Lunchbag_5"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["Lunchbox_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["Lunchbox2_4"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "CONTAINER",
        },
    },
    ["SeedBag_5"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "MISC",
            [2] = "ENTERTAINMENT",
            [3] = "BOOK",
            [4] = "HEALING",
            [5] = "CONTAINER",
            [6] = "MELEE_WEAPON",
            [7] = "RANGED_WEAPON",
            [8] = "AMMO",
            [9] = "MAGAZINE",
            [10] = "FOOD",
            [11] = "DRINK",
            [12] = "CLOTHING",
            [13] = "MOVEABLE",
            [14] = "KEY",
        },
    },
    ["SewingKit_5"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
        ["invalidCategories"] = {
            [1] = "CONTAINER",
            [2] = "FOOD",
            [3] = "DRINK",
            [4] = "MAGAZINE",
            [5] = "BOOK",
            [6] = "ENTERTAINMENT",
            [7] = "RANGED_WEAPON",
            [8] = "MELEE_WEAPON",
            [9] = "MOVEABLE",
        },
    },
    ["Bag_MedicalBag_18"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 8,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["wardrobe_25"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 7,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
    },
    ["fridge_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 7,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["fridge_40"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 7,
                    ["height"] = 11,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["freezer_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 7,
                    ["height"] = 6,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["shelves_15"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
        ["isOrganized"] = true,
    },
    ["sidetable_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
    },
    ["desk_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
    },
    ["metal_shelves_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
    },
    ["crate_10"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["clothingrack_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
        ["isOrganized"] = true,
        ["invalidCategories"] = {
            [1] = "MELEE_WEAPON",
            [2] = "RANGED_WEAPON",
            [3] = "AMMO",
            [4] = "MAGAZINE",
            [5] = "DRINK",
            [6] = "FOOD",
            [7] = "CONTAINER",
            [8] = "HEALING",
            [9] = "ENTERTAINMENT",
            [10] = "KEY",
            [11] = "SEED",
            [12] = "MISC",
            [13] = "MOVEABLE",
            [14] = "BOOK",
        },
    },
    ["shelves_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 5,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
    },
    ["shelves_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
    },
    ["displaycasebutcher_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                },
            },
            [4] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 1,
                },
            },
            [5] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 2,
                    ["y"] = 1,
                },
            },
            [6] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 2,
                    ["y"] = 0,
                },
            },
        },
    },
    ["displaycasebakery_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 1,
                },
            },
            [4] = {
                ["size"] = {
                    ["width"] = 4,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
    },
    ["grocerstand_20"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 5,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
    },
    ["fridge_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 12,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["militarylocker_50"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 10,
                    ["height"] = 8,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
    },
    ["shelves_40"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
        ["isOrganized"] = true,
    },
    ["metal_shelves_30"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 8,
                    ["height"] = 4,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
        },
        ["isOrganized"] = true,
    },
    ["clothingrack_25"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 1,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 6,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 2,
                },
            },
        },
        ["isOrganized"] = true,
        ["invalidCategories"] = {
            [1] = "MELEE_WEAPON",
            [2] = "RANGED_WEAPON",
            [3] = "AMMO",
            [4] = "DRINK",
            [5] = "FOOD",
            [6] = "MAGAZINE",
            [7] = "CONTAINER",
            [8] = "HEALING",
            [9] = "BOOK",
            [10] = "ENTERTAINMENT",
            [11] = "SEED",
            [12] = "MOVEABLE",
            [13] = "MISC",
            [14] = "KEY",
        },
    },
    ["Bag_FannyPackBack_1"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["Bag_FannyPackFront_1"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 3,
                    ["height"] = 3,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
        },
    },
    ["none"] = {
        ["gridDefinitions"] = {
            [1] = {
                ["size"] = {
                    ["width"] = 1,
                    ["height"] = 1,
                },
                ["position"] = {
                    ["x"] = 4,
                    ["y"] = 0,
                },
            },
            [2] = {
                ["size"] = {
                    ["width"] = 1,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                },
            },
            [3] = {
                ["size"] = {
                    ["width"] = 1,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 1,
                    ["y"] = 0,
                },
            },
            [4] = {
                ["size"] = {
                    ["width"] = 1,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 2,
                    ["y"] = 0,
                },
            },
            [5] = {
                ["size"] = {
                    ["width"] = 1,
                    ["height"] = 2,
                },
                ["position"] = {
                    ["x"] = 3,
                    ["y"] = 0,
                },
            },
        },
        ["centerMode"] = "vertical",
        ["isOrganized"] = true,
    },
}

local vehicleStoragePack = {
    "TruckBed",
    "TrailerTrunk",
    "TruckBedOpen",
}

local alwaysStackOnSpawnItems = {
    "Base.Cigarettes",
}

TetrisItemData.registerItemDefinitions(itemPack)
TetrisItemData.registerAlwaysStackOnSpawnItems(alwaysStackOnSpawnItems)
TetrisContainerData.registerContainerDefinitions(containerPack)
TetrisContainerData.registerLargeVehicleStorageContainers(vehicleStoragePack)
