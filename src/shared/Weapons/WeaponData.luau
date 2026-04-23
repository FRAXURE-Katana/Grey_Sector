local WeaponData = {
	AssaultRifle = {
		Type = "Ranged",
		BaseDamage = 25,
		FireRate = 0.1,
		MaxAmmo = 30, -- Bullets in the clip
		MaxReserve = 120, -- Total backup bullets
		ReloadTime = 2, -- Seconds it takes to reload
		Automatic = true,
		IdleAnimation = "rbxassetid://82735357454134",
		ReloadAnimation = "rbxassetid://00000000000", -- Replace later with an actual animation!
	},

	Sword = {
		Type = "Melee",
		BaseDamage = 50,
		FireRate = 0.8,
		Range = 8,
		Automatic = false,
		IdleAnimation = "rbxassetid://00000000000",
	},
}

return WeaponData
