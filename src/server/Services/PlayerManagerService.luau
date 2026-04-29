local Players = game:GetService("Players")
local GameLoopService = require(script.Parent.GameLoopService)

local PlayerManagerService = {}

function PlayerManagerService:Start()
	print("PlayerManagerService Started.")

	-- Listen for the raid ending
	GameLoopService.RaidEnded.Event:Connect(function()
		self:PunishUnextractedPlayers()
	end)

	Players.PlayerAdded:Connect(function(player)
		self:SetPlayerState(player, "InHub")

		player.CharacterAdded:Connect(function(character)
			self:OnCharacterAdded(player, character)
		end)
	end)
end

function PlayerManagerService:PunishUnextractedPlayers()
	print("Checking for players left in the raid...")
	for _, player in pairs(Players:GetPlayers()) do
		if player:GetAttribute("PlayerState") == "InRaid" then
			print(player.Name .. " failed to extract in time!")

			if player.Character then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.Health = 0
				end
			end
		end
	end
end

function PlayerManagerService:OnCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		self:SetPlayerState(player, "Dead")
		print(player.Name .. " has died.")

		-- Wait a few seconds, then respawn them in the hub
		task.delay(3, function()
			if player then
				self:SetPlayerState(player, "InHub")
				player:LoadCharacter()
			end
		end)
	end)
end

-- Universal function for changing states!
function PlayerManagerService:SetPlayerState(player, newState)
	player:SetAttribute("PlayerState", newState)
	print(player.Name .. "'s state changed to: " .. newState)
end

return PlayerManagerService
