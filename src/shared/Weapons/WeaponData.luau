local WeaponData = {
	AssaultRifle = {
		Type = "Ranged",
		BaseDamage = 25,
		FireRate = 0.1,
		MaxAmmo = 30,
		ReloadTime = 2,
		Automatic = true,
		IdleAnimation = "rbxassetid://82735357454134", -- Replace with your AR Idle ID
	},

	CombatKnife = {
		Type = "Melee",
		BaseDamage = 50,
		FireRate = 0.6,
		Range = 5,
		Automatic = false,
		IdleAnimation = "rbxassetid://99710352770917", -- Replace with your Karambit Idle ID
	},
}

return WeaponData
