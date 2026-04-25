local WeaponData = {
	AssaultRifle = {
		Type = "Ranged",
		BaseDamage = 25,
		FireRate = 0.1,
		MaxAmmo = 30,
		MaxReserve = 120,
		ReloadTime = 2,
		Automatic = true,
		IdleAnimation = "rbxassetid://82735357454134",
		ReloadAnimation = "rbxassetid://135233323910967",
		ShootAnimation = "rbxassetid://96858727197533",
		ShootSound = "rbxassetid://123304996879837",
		ReloadSound = "rbxassetid://105895546453287",
		HitSound = "rbxassetid://71222139822639",
		RunAnimation = "rbxassetid://00000000000",
	},

	Sword = {
		Type = "Melee",
		BaseDamage = 50,
		FireRate = 0.8,
		Range = 8,
		Automatic = false,
		IdleAnimation = "rbxassetid://119340501302594",
		SwingSound = "rbxassetid://140496995751307",
		AttackAnimations = {
			"rbxassetid://117598264340206",
			"rbxassetid://124053686608236",
			"rbxassetid://139883539777396",
			"rbxassetid://82332546535930",
		},
		HitSound = "rbxassetid://123467515416190",
		RunAnimation = "rbxassetid://118023174337729",
	},
}

return WeaponData
