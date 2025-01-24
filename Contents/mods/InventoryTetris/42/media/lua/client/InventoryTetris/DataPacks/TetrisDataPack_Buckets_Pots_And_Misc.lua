require("InventoryTetris/Data/TetrisItemData")
require("InventoryTetris/Data/TetrisContainerData")

local itemPack = {
	["Base.Salad"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.FruitSalad"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.BucketClayCement"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BucketConcreteFull"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BucketOfStew"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BucketWallpaperPaste"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BucketPlasterFull"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BucketEmpty"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.Bucket"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BucketWaterDebug"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BucketForged"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.BucketOfSoup"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintbucketEmpty"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintBlack"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintBlue"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintBrown"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintCyan"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintGrey"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintGreen"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintLightBlue"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintLightBrown"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintOrange"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintPink"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintPurple"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintRed"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintTurquoise"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintWhite"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PaintYellow"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 3,
	},
	["Base.PastaPot"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.RicePot"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.SugarBeetSyrupPot"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.SugarBeetPulpPot"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.SugarBeetSugarPot"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.VHS_Retail"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.VHS_Home"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
}

local containerPack = {
}

TetrisItemData.registerItemDefinitions(itemPack)
TetrisContainerData.registerContainerDefinitions(containerPack)

