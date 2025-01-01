require("InventoryTetris/Data/TetrisItemData")
require("InventoryTetris/Data/TetrisContainerData")

local itemPack = {
}

local containerPack = {
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
		["isFragile"] = true,
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
		["isFragile"] = false,
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
					["height"] = 5,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 1,
					["height"] = 5,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 1,
				},
			},
		},
		["centerMode"] = "horizontal",
	},
	["fridge_40"] = {
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
			[2] = {
				["size"] = {
					["width"] = 7,
					["height"] = 4,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
			[3] = {
				["size"] = {
					["width"] = 7,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 2,
				},
			},
			[4] = {
				["size"] = {
					["width"] = 3,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 3,
				},
			},
			[5] = {
				["size"] = {
					["width"] = 3,
					["height"] = 3,
				},
				["position"] = {
					["x"] = 1,
					["y"] = 3,
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
		["isFragile"] = true,
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
		["isFragile"] = true,
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
		["isFragile"] = true,
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
	["stove_15"] = {
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
					["height"] = 3,
				},
				["position"] = {
					["x"] = 0,
					["y"] = 1,
				},
			},
		},
	},
	["sidetable_10"] = {
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
	},
}

TetrisItemData.registerItemDefinitions(itemPack)
TetrisContainerData.registerContainerDefinitions(containerPack)
