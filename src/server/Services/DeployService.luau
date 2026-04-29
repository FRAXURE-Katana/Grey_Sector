local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local PlayerManagerService = require(script.Parent.PlayerManagerService)

local DeployService = {}

DeployService.Debounce = {}

function DeployService:Start()
	local deployZone = Workspace:FindFirstChild("DeployZone")
	local spawnPointsFolder = Workspace:FindFirstChild("SpawnPoints")

	if not deployZone then
		warn("DeployZone part missing from Workspace")
		return
	end
	if not spawnPointsFolder then
		warn("SpawnPoints folder missing from Workspace")
		return
	end

	deployZone.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		local humanoid = character:FindFirstChild("Humanoid")

		if player and humanoid and humanoid.Health > 0 and not self.Debounce[player.UserId] then
			self.Debounce[player.UserId] = true

			self:DeployPlayer(player, character, spawnPointsFolder)

			task.delay(2, function()
				self.Debounce[player.UserId] = nil
			end)
		end
	end)
end

function DeployService:DeployPlayer(player, character, spawnPointsFolder)
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	PlayerManagerService:SetPlayerState(player, "InRaid")

	if not rootPart then
		return
	end

	local spawns = spawnPointsFolder:GetChildren()
	if #spawns == 0 then
		warn("No spawn points found in the SpawnPoints folder")
		return
	end

	local randomSpawn = spawns[math.random(1, #spawns)]

	rootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 3, 0)

	local forceField = Instance.new("ForceField")
	forceField.Visible = true
	forceField.Parent = character
	Debris:AddItem(forceField, 5)
end

return DeployService
