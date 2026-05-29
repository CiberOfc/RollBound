local UpgradeData = {
	Blessings = {
		BlessedDie = {
			Category = "Blessing",
			Id = "BlessedDie",

			Stat = "BaseDamage",
			Type = "DmgMultiplier",
			Rarity = "Scrap",
			Value = {
				[1] = 1.2,
				[2] = 1.4,
				[3] = 1.6,
				[4] = 1.8,
				[5] = 2.2,
			},
			MaxLevel = 5,
			Name = "Blessed Die",
			Description = "",
		},

		CelestialEcho = {
			Category = "Blessing",
			Id = "CelestialEcho",

			Stat = "Luck",
			Type = "ReboundChance",
			Rarity = "Reforged",
			Value = {
				[1] = 0.2,
				[2] = 0.5,
			},
			MaxLevel = 2,
			Name = "Celestial Echo",
			Description = "",
		},

		AngleShield = {
			Category = "Blessing",
			Id = "AngelShield",

			Stat = "Shield",
			Type = "ShieldMultiplier",
			Rarity = "Star-Forged",
			Value = {
				[1] = 0.8,
			},
			MaxLevel = 1,
			Name = "Angle Shield",
			Description = "",
		},
	},
	Decay = {
		ToxicPop = {
			Category = "Decay",
			Id = "ToxicPop",

			Stat = "Toxic",
			Type = "ToxicStacks",
			Rarity = "Scrap",
			Value = {
				[1] = 1,
				[2] = 2,
				[3] = 3,
				[4] = 4,
				[5] = 5,
			},
			MaxLevel = 5,
			Name = "Toxic Pop",
			Description = "",
		},
		LingeringPoison = {
			Category = "Decay",
			Id = "LingeringPoison",

			Stat = "Toxic",
			Type = "ToxicStacksLast",
			Rarity = "Reforged",
			Value = {
				[1] = 0.3,
				[2] = 0.5,
				[3] = 0.8,
			},
			MaxLevel = 3,
			Name = "Lingering Poison",
			Description = "",
		},
	},
	Blood = {
		BloodBlade = {
			Category = "Blood",
			Id = "BloodBlade",

			Stat = "Blood",
			Type = "BloodDamage",
			Rarity = "Scrap",
			Value = {
				[1] = 5,
				[2] = 12,
				[3] = 16,
			},
			MaxLevel = 3,
			Name = "Blood Blade",
			Description = "",
		},
		SelfSacrifice = {
			Category = "Blood",
			Id = "SelfSacrifice",

			Stat = "Blood",
			Type = "Blood",
			Rarity = "Scrap",
			Value = {
				[1] = {
					DamageBoost = 0.2,
					SelfDamage = 0.02,
				},
				[2] = {
					DamageBoost = 0.3,
					SelfDamage = 0.04,
				},
				[3] = {
					DamageBoost = 0.4,
					SelfDamage = 0.06,
				},
			},
			MaxLevel = 3,
			Name = "Self Sacrifice",
			Description = "",
		},
	},
}

return UpgradeData
