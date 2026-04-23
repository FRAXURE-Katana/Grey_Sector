local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponData = require(Shared.Weapons.WeaponData)

local WeaponService = {}

function WeaponService:Start()
	print("WeaponService Started.")

	-- Automatically create the RemoteEvent so you don't have to do it in Studio!
	local weaponEvent = Shared.Weapons:FindFirstChild("WeaponEvent")
	if not weaponEvent then
		weaponEvent = Instance.new("RemoteEvent")
		weaponEvent.Name = "WeaponEvent"
		weaponEvent.Parent = Shared.Weapons
	end

	-- Listen for clients telling us they hit something
	weaponEvent.OnServerEvent:Connect(function(player, weaponName, hitPart)
		self:HandleWeaponHit(player, weaponName, hitPart)
	end)
end

function WeaponService:HandleWeaponHit(player, weaponName, hitPart)
	if not hitPart or not hitPart.Parent then
		return
	end

	local stats = WeaponData[weaponName]
	if not stats then
		return
	end

	-- Look for a Humanoid in the part's parent (or grandparent for accessories)
	local humanoid = hitPart.Parent:FindFirstChild("Humanoid") or hitPart.Parent.Parent:FindFirstChild("Humanoid")

	if humanoid and humanoid.Health > 0 then
		-- PVE RULE: Check if the target is another Player
		local hitPlayer = Players:GetPlayerFromCharacter(humanoid.Parent)

		-- Prevent players from shooting themselves
		if hitPlayer == player then
			return
		end

		-- Prevent Friendly Fire (since it's a PvE game)
		if hitPlayer then
			print(player.Name .. " hit another player, but friendly fire is off!")
			return
		end

		-- Apply the damage!
		humanoid:TakeDamage(stats.BaseDamage)
		print(
			player.Name
				.. " dealt "
				.. stats.BaseDamage
				.. " damage to "
				.. humanoid.Parent.Name
				.. " with "
				.. weaponName
		)
	end
end

return WeaponService
