local Players = game:GetService("Players")

-- Require the GameLoopService so we can listen to its events
local GameLoopService = require(script.Parent.GameLoopService)

local PlayerManagerService = {}

PlayerManagerService.PlayerStates = {}

function PlayerManagerService:Start()
	print("PlayerManagerService Started.")

	-- Listen for the raid ending
	GameLoopService.RaidEnded.Event:Connect(function()
		self:PunishUnextractedPlayers()
	end)

	Players.PlayerAdded:Connect(function(player)
		self:SetupPlayer(player)

		player.CharacterAdded:Connect(function(character)
			self:OnCharacterAdded(player, character)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.PlayerStates[player] = nil
	end)
end

function PlayerManagerService:PunishUnextractedPlayers()
	print("Checking for players left in the raid...")
	for player, state in pairs(self.PlayerStates) do
		if state == "InRaid" then
			print(player.Name .. " failed to extract in time!")

			-- Kill the player's character
			if player.Character then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.Health = 0
				end
			end
			-- Note: The state will automatically change to "Dead" because of
			-- the Humanoid.Died connection we set up in OnCharacterAdded!
		end
	end
end

function PlayerManagerService:SetupPlayer(player)
	self:SetPlayerState(player, "InHub")
end

function PlayerManagerService:OnCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		self:SetPlayerState(player, "Dead")
		print(player.Name .. " has died.")
	end)
end

function PlayerManagerService:SetPlayerState(player, newState)
	self.PlayerStates[player] = newState
	print(player.Name .. "'s state changed to: " .. newState)
end

function PlayerManagerService:GetPlayerState(player)
	return self.PlayerStates[player]
end

return PlayerManagerService
