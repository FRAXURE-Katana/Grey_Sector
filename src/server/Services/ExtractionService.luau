local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PlayerManagerService = require(script.Parent.PlayerManagerService)

local ExtractionService = {}

ExtractionService.ExtractingPlayers = {}

function ExtractionService:Start()
	local extractionFolder = Workspace:FindFirstChild("ExtractionPoints")
	local hubSpawn = Workspace:FindFirstChild("HubSpawn")

	if not extractionFolder then
		warn("ExtractionPoints folder missing from Workspace")
		return
	end

	if not hubSpawn then
		warn("HubSpawn part missing from Workspace")
		return
	end

	for _, extractZone in pairs(extractionFolder:GetChildren()) do
		if extractZone:IsA("BasePart") then
			extractZone.Touched:Connect(function(hit)
				self:HandleExtraction(hit, hubSpawn)
			end)
		end
	end
end

function ExtractionService:HandleExtraction(hit, hubSpawn)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:FindFirstChild("Humanoid")

	PlayerManagerService:SetPlayerState(player, "InHub")

	if player and humanoid and humanoid.Health > 0 and not self.ExtractingPlayers[player.UserId] then
		self.ExtractingPlayers[player.UserId] = true

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart.CFrame = hubSpawn.CFrame + Vector3.new(0, 3, 0)
		end

		task.delay(3, function()
			self.ExtractingPlayers[player.UserId] = nil
		end)
	end
end

return ExtractionService
