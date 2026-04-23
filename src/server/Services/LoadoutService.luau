local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponData = require(Shared.Weapons.WeaponData)

local WeaponModels = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons")

local LoadoutService = {}

LoadoutService.PlayerLoadouts = {
	Default = {
		AssaultRifle = {
			MuzzleFlash = "StandardFlash",
			Tracer = "StandardTracer",
		},
		Sword = {},
	},
}

function LoadoutService:Start()
	print("LoadoutService Started.")

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			self:GiveLoadout(player, character)
		end)
	end)
end

function LoadoutService:GiveLoadout(player, character)
	local backpack = player:WaitForChild("Backpack")
	local myLoadout = self.PlayerLoadouts.Default

	backpack:ClearAllChildren()

	if myLoadout.AssaultRifle then
		self:GiveWeapon("AssaultRifle", myLoadout.AssaultRifle, backpack)
	end
	if myLoadout.Sword then
		self:GiveWeapon("Sword", myLoadout.Sword, backpack)
	end
end

function LoadoutService:GiveWeapon(weaponName, cosmeticData, backpack)
	local template = WeaponModels:FindFirstChild(weaponName)
	if not template then
		return
	end

	local newWeapon = template:Clone()

	-- Apply Cosmetics
	for attributeName, attributeValue in pairs(cosmeticData) do
		newWeapon:SetAttribute(attributeName, attributeValue)
	end

	-- INITIALIZE AMMO: Look up the stats and set the starting ammo!
	local stats = WeaponData[weaponName]
	if stats and stats.Type == "Ranged" then
		newWeapon:SetAttribute("CurrentAmmo", stats.MaxAmmo)
		newWeapon:SetAttribute("ReserveAmmo", stats.MaxReserve)
	end

	newWeapon.Parent = backpack
end

return LoadoutService
