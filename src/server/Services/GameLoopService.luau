local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local GameLoopService = {}

GameLoopService.RaidEnded = Instance.new("BindableEvent")

GameLoopService.RaidDuration = 15 -- 15 mins
GameLoopService.CooldownDuration = 30 -- 30 secs

function GameLoopService:Start()
	local timerValue = Instance.new("StringValue")
	timerValue.Name = "GlobalTimer"
	timerValue.Value = "WAITING..."
	timerValue.Parent = ReplicatedStorage

	task.spawn(function()
		while true do
			Workspace:SetAttribute("RaidActive", true)

			for i = self.RaidDuration, 0, -1 do
				local minutes = math.floor(i / 60)
				local seconds = i % 60
				timerValue.Value = "RAID ENDS IN: " .. string.format("%02d:%02d", minutes, seconds)
				task.wait(1)
			end

			self.RaidEnded:Fire()

			Workspace:SetAttribute("RaidActive", false)

			for i = self.CooldownDuration, 0, -1 do
				local minutes = math.floor(i / 60)
				local seconds = i % 60
				timerValue.Value = "NEXT RAID IN: " .. string.format("%02d:%02d", minutes, seconds)
				task.wait(1)
			end
		end
	end)
end

function GameLoopService:WipeRaid()
	for _, player in pairs(Players:GetPlayers()) do
		if player:GetAttribute("InRaid") then
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.Health = 0 -- Kill them
					print(player.Name .. " failed to extract and was lost to the Grey Sector.")
				end
			end

			player:SetAttribute("InRaid", false)
		end
	end
end

return GameLoopService
