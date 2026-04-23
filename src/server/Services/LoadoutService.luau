local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponModels = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons")

local LoadoutService = {}

-- MOCK DATABASE: This represents what a player has equipped from the store.
LoadoutService.PlayerLoadouts = {
	Default = {
		AssaultRifle = {
			MuzzleFlash = "StandardFlash",
			Tracer = "StandardTracer",
			-- Skin = "GoldCamo" (You can add anything here later!)
		},
		Sword = {
			-- Empty for now, but ready for Sword Trails or custom sounds!
		},
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

	-- In the future, you will load their actual saved data here.
	local myLoadout = self.PlayerLoadouts.Default

	-- Clear out any default Roblox gear just in case
	backpack:ClearAllChildren()

	-- Give the designated loadout
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

	-- MAGIC LOOP: This dynamically applies EVERY cosmetic listed in the loadout
	-- directly to the Tool as an Attribute!
	for attributeName, attributeValue in pairs(cosmeticData) do
		newWeapon:SetAttribute(attributeName, attributeValue)
	end

	newWeapon.Parent = backpack
end

return LoadoutService
