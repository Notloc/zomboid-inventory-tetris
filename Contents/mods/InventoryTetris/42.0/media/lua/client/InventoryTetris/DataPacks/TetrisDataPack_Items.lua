require("InventoryTetris/Data/TetrisItemData")
require("InventoryTetris/Data/TetrisContainerData")

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

local containerPack = {
}

TetrisItemData.registerItemDefinitions(itemPack)
TetrisContainerData.registerContainerDefinitions(containerPack)
