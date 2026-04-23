local WeaponData = {
	AssaultRifle = {
		Type = "Ranged",
		BaseDamage = 25,
		FireRate = 0.1,
		MaxAmmo = 30,
		ReloadTime = 2,
		Automatic = true,
		IdleAnimation = "rbxassetid://82735357454134",
		-- Notice: MuzzleFlash and Tracer are GONE from here!
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
