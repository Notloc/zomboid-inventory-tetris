require("InventoryTetris/Data/TetrisItemData")
require("InventoryTetris/Data/TetrisContainerData")

local itemPack = {
	["Base.Bag_AmmoBox_ShotgunShells"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox_Mixed"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox_308"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox_223"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox_Hunting"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox_45"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox_9mm"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox_44"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_AmmoBox_38"] = {
		["maxStackSize"] = 1,
		["height"] = 3,
		["width"] = 4,
	},
	["Base.Bag_DoctorBag"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 5,
	},
	["Base.Bag_DoctorBag__squished"] = {
		["width"] = 2,
		["height"] = 2,
		["maxStackSize"] = 1,
	},
	["Base.FirstAidKit_Military"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.FirstAidKit"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.FirstAidKit_New"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.FirstAidKit_NewPro"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.FirstAidKit_Camping"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 2,
	},
	["Base.FirstAidKit_Camping__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.PencilCase"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 2,
	},
	["Base.PencilCase__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.Bag_SaxophoneCase"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 2,
	},
	["Base.Bag_TrashBag__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.Garbagebag__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.HolsterShoulder__squished"] = {
		["width"] = 1,
		["height"] = 2,
		["maxStackSize"] = 1,
	},
	["Base.KeyRing"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_CarDealer"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_EagleFlag"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Bass"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_BlueFox"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Bug"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_EightBall"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Clover"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Kitty"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Large"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Nolans"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Panther"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_PineTree"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_PrayingHands"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Hotdog"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_RabbitFoot"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_RainbowStar"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_RubberDuck"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Sexy"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_Spiffos"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_StinkyFace"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_WestMaple"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Plasticbag__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.GroceryBag3__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.GroceryBag4__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.GroceryBag5__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.GroceryBag1__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.GroceryBag2__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.Plasticbag_Bags__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.GroceryBagGourmet__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.Plasticbag_Clothing__squished"] = {
		["width"] = 1,
		["height"] = 1,
		["maxStackSize"] = 1,
	},
	["Base.SeedBag_Farming"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.SeedBag"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.DiceBag"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.GemBag"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.KeyRing_SecurityPass"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.SewingKit"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 3,
	},
	["Base.ToolRoll_Fabric"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 3,
	},
	["Base.ToolRoll_Leather"] = {
		["maxStackSize"] = 1,
		["height"] = 2,
		["width"] = 3,
	},
	["Base.Toolbox_Fishing"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 5,
	},
	["Base.Bag_JanitorToolbox"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 5,
	},
	["Base.Toolbox_Mechanic"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 5,
	},
	["Base.Toolbox_Gardening"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 5,
	},
	["Base.Toolbox_Farming"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 5,
	},
	["Base.Toolbox"] = {
		["maxStackSize"] = 1,
		["height"] = 4,
		["width"] = 5,
	},
	["Base.Wallet_Female"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Wallet_Male"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
	["Base.Wallet"] = {
		["maxStackSize"] = 1,
		["height"] = 1,
		["width"] = 1,
	},
}

local containerPack = {
	["none"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 1,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 1,
				},
				["position"] = {
					["x"] = 1,
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
        ["isOrganized"] = true,
    },
	["Bag_AmmoBox_ShotgunShells_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_Mixed_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_308_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_223_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_Hunting_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_45_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_9mm_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_44_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_AmmoBox_38_6"] = {
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
		["validCategories"] = {
			["AMMO"] = true,
		},
		["isRigid"] = true,
	},
	["Bag_BirthdayBasket_6"] = {
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
		["isRigid"] = true,
	},
	["HollowBook_Handgun_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["HollowBook_Kids_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["HollowBook_Valuables_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["HollowBook_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["HollowBook_Whiskey_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["HollowBook_Prison_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Bag_BowlingBallBag_6"] = {
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
	},
	["Bag_ProtectiveCaseBulkyHazard_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_44_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_38_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_223_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_556_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_9mm_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_Hunting_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_308_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_45_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_ShotgunShells_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulky_HAMRadio1_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulky_SCBA_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulky_Audio_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulky_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyMilitary_HAMRadio2_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyMilitary_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulky_Survivalist_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseBulkyAmmo_16"] = {
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
		["isFragile"] = false,
		["isRigid"] = true,
	},
	["AmmoStrap_Bullets_1"] = {
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
					["width"] = 2,
					["height"] = 1,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
		},
		["validCategories"] = {
			["AMMO"] = true,
		},
	},
	["AmmoStrap_Bullets_308_1"] = {
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
					["width"] = 2,
					["height"] = 1,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
		},
		["validCategories"] = {
			["AMMO"] = true,
		},
	},
	["AmmoStrap_Bullets_223_1"] = {
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
					["width"] = 2,
					["height"] = 1,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
		},
		["validCategories"] = {
			["AMMO"] = true,
		},
	},
	["Briefcase_8"] = {
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
		["isRigid"] = true,
	},
	["Briefcase_Money_8"] = {
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
		["isRigid"] = true,
	},
	["Cashbox_2"] = {
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
		["isRigid"] = true,
	},
	["TakeoutBox_Chinese_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["CigarBox_2"] = {
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
		["isRigid"] = true,
	},
	["CigarBox_Gaming_2"] = {
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
		["isRigid"] = true,
	},
	["CigarBox_Kids_2"] = {
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
		["isRigid"] = true,
	},
	["CigarBox_Keepsakes_2"] = {
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
		["isRigid"] = true,
	},
	["Bag_RifleCaseClothCamo_7"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
	},
	["Bag_ShotgunCaseCloth_7"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
	},
	["Bag_RifleCaseCloth2_7"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
	},
	["Bag_RifleCaseCloth_7"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
	},
	["Bag_ShotgunCaseCloth2_7"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
	},
	["CookieJar_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["CookieJar_Bear_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Cooler_Meat_12"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 4,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Cooler_12"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 4,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Cooler_Beer_12"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 4,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Cooler_Seafood_12"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 4,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Cooler_Soda_12"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 7,
					["height"] = 4,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Bag_DoctorBag_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 8,
					["height"] = 6,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["validCategories"] = {
			["HEALING"] = true,
		},
	},
	["Bag_FannyPackBack_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
		},
	},
	["Bag_FannyPackFront_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
		},
	},
	["FirstAidKit_Military_2"] = {
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
		["isRigid"] = true,
		["validCategories"] = {
			["HEALING"] = true,
		},
	},
	["FirstAidKit_4"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 3,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
		["validCategories"] = {
			["HEALING"] = true,
		},
	},
	["FirstAidKit_New_4"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 3,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
		["validCategories"] = {
			["HEALING"] = true,
		},
	},
	["FirstAidKit_NewPro_4"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 3,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
		["validCategories"] = {
			["HEALING"] = true,
		},
	},
	["FirstAidKit_Camping_2"] = {
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
		["validCategories"] = {
			["HEALING"] = true,
		},
	},
	["Bag_FishingBasket_6"] = {
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
		["isRigid"] = true,
	},
	["Flightcase_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_FluteCase_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 1,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Guitarcase_5"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["RifleCase4_7"] = {
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
		["isRigid"] = true,
	},
	["ShotgunCase1_7"] = {
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
		["isRigid"] = true,
	},
	["ShotgunCase2_7"] = {
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
		["isRigid"] = true,
	},
	["RifleCase3_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_ShotgunCase_Police_7"] = {
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
		["isRigid"] = true,
	},
	["RifleCase2_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_RifleCase_7"] = {
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
		["isRigid"] = true,
	},
	["RifleCase1_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_RifleCase_Police3_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_RifleCase_Police2_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_RifleCase_Police_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_RifleCaseGreen_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_ShotgunCaseGreen_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_RifleCaseGreen2_7"] = {
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
		["isRigid"] = true,
	},
	["PistolCase2_4"] = {
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
		},
		["isRigid"] = true,
	},
	["PistolCase1_4"] = {
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
		},
		["isRigid"] = true,
	},
	["RevolverCase2_4"] = {
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
		},
		["isRigid"] = true,
	},
	["PistolCase3_4"] = {
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
		},
		["isRigid"] = true,
	},
	["RevolverCase3_4"] = {
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
		},
		["isRigid"] = true,
	},
	["RevolverCase1_4"] = {
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
		},
		["isRigid"] = true,
	},
	["MakeupCase_Professional_4"] = {
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
		["isRigid"] = true,
	},
	["PencilCase_1"] = {
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
		["maxSize"] = 1
	},
	["PencilCase_Gaming_1"] = {
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
		["maxSize"] = 1
	},
	["Bag_SaxophoneCase_3"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Suitcase_16"] = {
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
		["isRigid"] = true,
	},
	["Bag_ViolinCase_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Bag_TrumpetCase_1"] = {
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
		["isRigid"] = true,
	},
	["Bag_ProtectiveCase_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseMilitary_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseMilitary_Tools_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseMilitary_Medical_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_ProtectiveCase_Survivalist_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_ProtectiveCase_Tools_7"] = {
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
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Electronics_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Pistol2_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmallMilitary_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmallMilitary_WalkieTalkie_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmallMilitary_Pistol1_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmallMilitary_FirstAid_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_WalkieTalkie_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Pistol1_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Armorer_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_FirstAid_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Pistol3_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Revolver1_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Revolver2_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Survivalist_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_Revolver3_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_ProtectiveCaseSmall_WalkieTalkiePolice_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Bag_TrashBag_20"] = {
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
		["isFragile"] = true,
	},
	["Garbagebag_20"] = {
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
		["isFragile"] = true,
	},
	["Bag_GardenBasket_6"] = {
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
		["isRigid"] = true,
	},
	["Present_ExtraSmall_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Present_Large_10"] = {
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
		["isRigid"] = true,
	},
	["Present_ExtraLarge_20"] = {
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
		["isRigid"] = true,
	},
	["Present_Medium_5"] = {
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
		["isRigid"] = true,
	},
	["Present_Small_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Bag_GolfBag_Melee_18"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
			[4] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 3,
					["y"] = 0,
				},
			},
			[5] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
			[6] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 1,
				},
			},
			[7] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 4,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Bag_GolfBag_18"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
			[4] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 3,
					["y"] = 0,
				},
			},
			[5] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
			[6] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 1,
				},
			},
			[7] = {
				["size"] = {
					["width"] = 1,
					["height"] = 7,
				},
				["position"] = {
					["x"] = 4,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["HalloweenCandyBucket_2"] = {
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
		["isRigid"] = true,
	},
	["Hatbox_1"] = {
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
		["isRigid"] = true,
	},
	["Bag_FannyPackFront_Hide_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
		},
	},
	["Bag_FannyPackBack_Hide_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
		},
	},
	["HolsterShoulder_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
		},
		["validCategories"] = {
			["AMMO"] = true,
			["MAGAZINE"] = true,
			["RANGED_WEAPON"] = true,
			["MELEE_WEAPON"] = true,
			["ATTACHMENT"] = true,
		},
	},
	["Humidor_2"] = {
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
		["isRigid"] = true,
	},
	["JewelleryBox_2"] = {
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
		["isRigid"] = true,
	},
	["JewelleryBox_Fancy_2"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_CarDealer_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_EagleFlag_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Bass_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_BlueFox_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Bug_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_EightBall_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Clover_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Kitty_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Large_2"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Nolans_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Panther_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_PineTree_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_PrayingHands_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Hotdog_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_RabbitFoot_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_RainbowStar_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_RubberDuck_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Sexy_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_Spiffos_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_StinkyFace_1"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_WestMaple_1"] = {
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
		["isRigid"] = true,
	},
	["HollowFancyBook_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["PaperBag_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
	},
	["Paperbag_Spiffos_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
	},
	["Paperbag_Jays_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
	},
	["Lunchbag_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 3,
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
					["width"] = 4,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Lunchbox2_4"] = {
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
		},
		["isRigid"] = true,
	},
	["Parcel_Small_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Parcel_Medium_5"] = {
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
		["isRigid"] = true,
	},
	["Parcel_Large_10"] = {
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
		["isRigid"] = true,
	},
	["Parcel_ExtraSmall_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Parcel_ExtraLarge_20"] = {
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
		["isRigid"] = true,
	},
	["PhotoAlbum_Old_2"] = {
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
		["isRigid"] = true,
	},
	["PhotoAlbum_2"] = {
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
		["isRigid"] = true,
	},
	["Bag_PicnicBasket_6"] = {
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
		["isRigid"] = true,
	},
	["Plasticbag_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["GroceryBag3_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["GroceryBag4_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["GroceryBag5_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["GroceryBag1_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["GroceryBag2_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["Plasticbag_Bags_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["GroceryBagGourmet_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["Plasticbag_Clothing_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 4,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isFragile"] = true,
	},
	["SeedBag_Farming_1"] = {
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
		["validCategories"] = {
			["SEED"] = true,
		},
		["isRigid"] = true,
	},
	["SeedBag_1"] = {
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
		["validCategories"] = {
			["SEED"] = true,
		},
		["isRigid"] = true,
	},
	["DiceBag_1"] = {
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
		["validCategories"] = {
			["MISC"] = true,
		},
		["isFragile"] = true,
		["isRigid"] = true,
	},
	["GemBag_1"] = {
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
		["validCategories"] = {
			["MISC"] = true,
		},
		["isFragile"] = true,
		["isRigid"] = true,
	},
	["ProduceBox_Small_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["ProduceBox_Large_10"] = {
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
		["isRigid"] = true,
	},
	["ProduceBox_Medium_5"] = {
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
		["isRigid"] = true,
	},
	["ProduceBox_ExtraSmall_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["ProduceBox_ExtraLarge_20"] = {
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
		["isRigid"] = true,
	},
	["KeyRing_SecurityPass_1"] = {
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
		["isRigid"] = true,
	},
	["SewingKit_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 1,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["AmmoStrap_Shells_1"] = {
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
					["width"] = 2,
					["height"] = 1,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
		},
		["validCategories"] = {
			["AMMO"] = true,
		},
	},
	["Shoebox_1"] = {
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
		["isRigid"] = true,
		["isFragile"] = true,
	},
	["Tacklebox_6"] = {
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
		["isRigid"] = true,
	},
	["TakeoutBox_Styrofoam_2"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
		["isFragile"] = true,
	},
	["ToolRoll_Fabric_4"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
			[4] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 3,
					["y"] = 0,
				},
			},
			[5] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 4,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["ToolRoll_Leather_4"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
			[2] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 2,
					["y"] = 0,
				},
			},
			[4] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 3,
					["y"] = 0,
				},
			},
			[5] = {
				["size"] = {
					["width"] = 1,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 4,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
	},
	["Toolbox_Fishing_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
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
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 5,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
	},
	["Bag_JanitorToolbox_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
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
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 5,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
	},
	["Toolbox_Mechanic_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
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
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 5,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
	},
	["Toolbox_Gardening_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
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
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 5,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
	},
	["Toolbox_Farming_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
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
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 5,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
	},
	["Toolbox_8"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
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
					["x"] = 1,
					["y"] = 0,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 5,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
		["isRigid"] = true,
	},
	["Tote_Clothing_6"] = {
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
		["isFragile"] = true,
	},
	["Bag_Dancer_6"] = {
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
		["isFragile"] = true,
	},
	["Tote_Bags_6"] = {
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
		["isFragile"] = true,
	},
	["Tote_6"] = {
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
		["isFragile"] = true,
	},
	["Toolbox_Wooden_6"] = {
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
		["isRigid"] = true,
	},
	["Wallet_Female_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
		["validCategories"] = {
			["KEY"] = true,
			["MISC"] = true,
		},
	},
	["Wallet_Male_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
		["validCategories"] = {
			["KEY"] = true,
			["MISC"] = true,
		},
	},
	["Wallet_1"] = {
		["gridDefinitions"] = {
			[1] = {
				["size"] = {
					["width"] = 2,
					["height"] = 2,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 0,
				},
			},
		},
		["isRigid"] = true,
		["validCategories"] = {
			["KEY"] = true,
			["MISC"] = true,
		},
	},
}

TetrisItemData.registerItemDefinitions(itemPack)
TetrisContainerData.registerContainerDefinitions(containerPack)
