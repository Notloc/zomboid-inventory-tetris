require("InventoryTetris/Data/TetrisItemData")
require("InventoryTetris/Data/TetrisContainerData")

-- Pack #1
local itemPack = {
	["Base.CeramicCrucibleSmall"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CeramicCrucibleSmallUnfired"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CeramicCrucibleWithGlass"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.CeramicCrucibleUnfired"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.CeramicCrucible"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookAimingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookMetalWeldingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookTrappingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookTrackingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookTailoringSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookReloadingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookPotterySet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookBlacksmithSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookMechanicsSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookMasonrySet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookLongBladeSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookFlintKnappingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookGlassmakingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookForagingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookFishingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookFirstAidSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookFarmingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookElectricianSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookCookingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookCarvingSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookCarpentrySet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookButcheringSet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BookHusbandrySet"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.Whisk"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.ToiletBrush"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Spatula"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.SmallSaw"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Ladle"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.KitchenTongs"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.TinOpener"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.CakeRaw"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CakePrep"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.BastingBrush"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Extinguisher"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.BakingPan"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.BakingTray"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CookiesChocolateDough"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CookiesOatmealDough"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CookiesShortbreadDough"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CookiesSugarDough"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CookieChocolateChipDough"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PotOfSoupRecipe"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PotOfSoup"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PotOfStew"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WaterPotRice"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PotForged"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WaterPotPasta"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Pot"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CannedPotato"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.CannedPotato_Open"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.ClayPot"] = {
		["maxStackSize"] = 3,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.GuitarAcoustic"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 2,
	},
	["Base.BadmintonRacket"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.Banjo"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.BaseballBat"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BareHands"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_Can"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_ScrapSheet"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_GardenForkHead"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_Nails"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_RailSpike"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_RakeHead"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_Sawblade"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_Spiked"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.Spear_Bone"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_Metal"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_Metal_Bolts"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.BaseballBat_Metal_Sawblade"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.ShortBat"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ShortBat_Can"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ShortBat_Nails"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ShortBat_RailSpike"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ShortBat_RakeHead"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ShortBat_Sawblade"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.SpikedShortBat"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.CrudeSword"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.CrudeShortSword"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.FireplacePoker"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.FishingRod"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.FishingRodBreak"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.Flute"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 3,
	},
	["Base.Pan"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PanForged"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Gaffhook"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.GardenForkHead_Forged"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.GardenForkHead"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.ScrapWeaponGardenFork"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.GardenHoeForged"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.GardenHoe"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.SpearGlass"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.Golfclub"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.GridlePan"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.HandScythe"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.HandScytheForged"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.IceHockeyStick"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.IceHockeyStick_BarbedWire"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.FieldHockeyStick"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.FieldHockeyStick_Nails"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.FieldHockeyStick_Sawblade"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.MetalPipe"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.MetalPipe_Railspike"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.IronRod"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.Katana"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.Keytar"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.LaCrosseStick"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.LargeAnimalBone"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.LargeBranch"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.LargeHook"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.LeadPipe"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.LeafRake"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.LongHandle_Brake"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.LongHandle_Nails"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.LongHandle_Can"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.SharpBone_Long"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.PickAxeForged"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.PickAxe"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.PipeWrench"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.Plank"] = {
		["maxStackSize"] = 3,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.Plank_Brake"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.Plank_Sawblade"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.Spear_Plunger"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.Plunger"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.Plunger_BarbedWire"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.Poolcue"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.RailroadSpikePuller"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.RailroadSpikePullerOld"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 1,
	},
	["Base.Rake"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.Saucepan"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.SaucepanCopper"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WaterSaucepanPasta"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WaterSaucepanPastaCopper"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WaterSaucepanRiceCopper"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WaterSaucepanRice"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WaterRationCan_Box"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WateredCan"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Trumpet"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 3,
	},
	["Base.CheckerBoard"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WatermelonSliced"] = {
		["maxStackSize"] = 2,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Watermelon"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.MilkBottle"] = {
		["maxStackSize"] = 9,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.JuiceFruitpunch"] = {
		["maxStackSize"] = 9,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.BeerBottle"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Disinfectant"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.MayonnaiseEmpty"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Baguette"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.BaguetteDough"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Baloney"] = {
		["maxStackSize"] = 4,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Banana"] = {
		["maxStackSize"] = 4,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.BBQStarterFluid"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.BBQSauce"] = {
		["maxStackSize"] = 4,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.BathTowel"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.BathTowelWet"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.BorisBadger"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Gloves_BoxingRed"] = {
		["maxStackSize"] = 8,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Gloves_BoxingBlue"] = {
		["maxStackSize"] = 8,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CigarettePack"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.CigaretteSingle"] = {
		["maxStackSize"] = 5,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Corn"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Corndog"] = {
		["maxStackSize"] = 9,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Cucumber"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Daikon"] = {
		["maxStackSize"] = 4,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.FreddyFox"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.FurbertSquirrel"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Gravy"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.GrillBrush"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Hairspray2"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Headphones"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.HolsterDouble"] = {
		["maxStackSize"] = 2,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.JacquesBeaver"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Lettuce"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Mustard"] = {
		["maxStackSize"] = 4,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.PiePrep"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PieDough"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PieWholeRawSweet"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PieWholeRaw"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Pineapple"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Spiffo"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.x8Scope"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.x4Scope"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Doll"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Goblet"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Goblet_Gold"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.PancakeHedgehog"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PanchoDog"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Goblet_Silver"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.ToyCar"] = {
		["maxStackSize"] = 8,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.TrophyGold"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.TrophyBronze"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.TrophySilver"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Goblet_Wood"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Nails"] = {
		["maxStackSize"] = 30,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.NailsBox"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.NailsCarton"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 4,
	},
}
TetrisItemData.registerItemDefinitions(itemPack)

-- Pack #2
local itemPack2 = {
	["Base.Strainer"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Pliers"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Remote"] = {
		["maxStackSize"] = 2,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.DumbBell"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 3,
	},
	["Base.RoastingPan"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Saxophone"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.OilVegetable"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.TirePump"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.BeerPack"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 3,
	},
	["Base.Kettle"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.MuffinTray"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.NoodleSoup"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.RamenBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.BeanBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.BrainTan"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.PastaBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.RiceBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.SoupBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.StewBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.CerealBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Oatmeal"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.SeedPasteBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.PanFriedVegetablesForged"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.GriddlePanFriedVegetables"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PanFriedVegetables"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PastaPan"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PastaPanCopper"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.RicePan"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.RicePanCopper"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PanFriedVegetables2"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Pancakes"] = {
		["maxStackSize"] = 3,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.PancakesRecipe"] = {
		["maxStackSize"] = 3,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.PancakesCraft"] = {
		["maxStackSize"] = 3,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.PotatoPancakes"] = {
		["maxStackSize"] = 10,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Frozen_TatoDots"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Frozen_FrenchFries"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Frozen_FishFingers"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Frozen_ChickenNuggets"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.CornFrozen"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.WineBox"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.ChickenWhole"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CocoaPowder"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Coffee2"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.DeadRabbit"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.HalloweenPumpkin"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Muffintray_Biscuit"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.BakingTray_Muffin_Recipe"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.BakingTray_Muffin"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PizzaRecipe"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PizzaWhole"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Pumpkin"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.TurkeyWhole"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Bitters"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.GlassPanel"] = {
		["maxStackSize"] = 10,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.PropaneTank"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 4,
	},
	["Base.Plate"] = {
		["maxStackSize"] = 5,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.BeerCanPack"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Kettle_Copper"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CuttingBoardWooden"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CuttingBoardPlastic"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.OvenMitt"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.PizzaCutter"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.BoxOfJars"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 3,
	},
	["Base.EmptyJar"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Hat_DeerHeadress"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Hat_EarMuff_Protectors"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Hat_EarMuffs"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Holster_Hide"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Holster_DuctTape"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.HolsterAnkle"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.HolsterSimple_Green"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.HolsterSimple_Black"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.HolsterSimple_Brown"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.HolsterSimple"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Hat_Fedora_Delmonte"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Hat_Fedora"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Oxygen_Tank"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.FluffyfootBunny"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.WalkieTalkieMakeShift"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.WalkieTalkie3"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.WalkieTalkie4"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.WalkieTalkie1"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.WalkieTalkie5"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.WalkieTalkie2"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.PowerBar"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 3,
	},
	["Base.Speaker"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CraftedFishingRod"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.GardeningSprayEmpty"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.GardeningSprayAphids"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.GardeningSprayMilk"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.GardeningSprayCigarettes"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Scythe"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 2,
	},
	["Base.ScytheForged"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 2,
	},
	["Base.Shovel2"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.Shovel"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.SpadeForged"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.PrimitiveScythe"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CleaningLiquid2"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.MagnifyingGlass"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.ScissorsBlunt"] = {
		["maxStackSize"] = 4,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.UmbrellaBlack"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.UmbrellaRed"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.UmbrellaTINTED"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.UmbrellaBlue"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.UmbrellaWhite"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 2,
	},
	["Base.ClosedUmbrellaWhite"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ClosedUmbrellaTINTED"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ClosedUmbrellaBlue"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ClosedUmbrellaRed"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.ClosedUmbrellaBlack"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
	["Base.Broom"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.Mop"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 1,
	},
	["Base.TuningFork"] = {
		["maxStackSize"] = 4,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.GuitarElectric"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 2,
	},
	["Base.Guitarcase"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 2,
	},
	["Base.GuitarElectricBass"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 2,
	},
	["Base.BackgammonBoard"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.HolePuncher"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Money"] = {
		["maxStackSize"] = 99,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.PlasticTray"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.CardDeck"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.SpadeHead"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.BrassNameplate"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Aluminum"] = {
		["maxStackSize"] = 8,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.OldAxeHead"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.BarbedWireStack"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 4,
	},
	["Base.GlazeBowl"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.AdhesiveTapeBox"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.DuctTapeBox"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.BrassIngot"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.CopperIngot"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.GoldBar"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.ClayIngotMoldUnfired"] = {
		["maxStackSize"] = 3,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.CeramicIngotCast"] = {
		["maxStackSize"] = 3,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.ClayIngotMold"] = {
		["maxStackSize"] = 3,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.CeramicIngotCastUnfired"] = {
		["maxStackSize"] = 3,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.SilverBar"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.IronIngotMold"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.IronIngot"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.PigIronIngot"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.PiercedIronIngot"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.SmallGoldBar"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.SmallSilverBar"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.SteelIngotMold"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.SteelIngot"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.PiercedSteelIngot"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.WoodenIngotCastMold"] = {
		["maxStackSize"] = 3,
		["height"] = 1,
		["width"] = 2,
	},
}
TetrisItemData.registerItemDefinitions(itemPack2)

-- Pack #3
local itemPack3 = {
	["Base.HandScytheBlade"] = {
		["maxStackSize"] = 3,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.HacksawBlade"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Log"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 5,
	},
	["Base.LogStacks2"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 5,
	},
	["Base.LogStacks4"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 6,
	},
	["Base.LogStacks3"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 6,
	},
	["Base.Jack"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 3,
	},
	["Base.LugWrench"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.BatteryBox"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.CandleBox"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Battery"] = {
		["maxStackSize"] = 6,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Garbagebag_box"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.Bellows"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.Calipers"] = {
		["maxStackSize"] = 4,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.Saw"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.HandAxe_Old"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.HandAxeForged"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.HandAxe"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.HeavyChain"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.HeavyChain_Hook"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.Multitool"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.SnowShovel"] = {
		["maxStackSize"] = 1,
		["height"] = 5,
		["width"] = 2,
	},
	["Base.ViseGrips"] = {
		["maxStackSize"] = 2,
		["height"] = 2,
		["width"] = 1,
	},
	["Base.WeldingMask"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.GardenSaw"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.BlowTorch"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 1,
	},
}
TetrisItemData.registerItemDefinitions(itemPack3)