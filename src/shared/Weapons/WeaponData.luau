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
		RunAnimation = "rbxassetid://00000000000", -- Optional for the AR
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
			"rbxassetid://117598264340206", -- Slash 1
			"rbxassetid://124053686608236", -- Slash 2
			"rbxassetid://139883539777396", -- Replace with your new Slash 3 ID
			"rbxassetid://82332546535930", -- Replace with your new Slash 4 ID
		},
		RunAnimation = "rbxassetid://118023174337729", -- Replace with your Sword Run ID
	},
}

return WeaponData
