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
			"rbxassetid://117598264340206", -- Replace with Slash 1 ID
			"rbxassetid://124053686608236", -- Replace with Slash 2 ID
		},
	},
}

return WeaponData
