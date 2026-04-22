local GameLoopService = {}

local RAID_DURATION = 15 * 60 -- 15 minutes
local COOLDOWN_DURATION = 2 * 60 -- 2 minutes

-- Create BindableEvents so other scripts can listen for state changes
GameLoopService.RaidStarted = Instance.new("BindableEvent")
GameLoopService.RaidEnded = Instance.new("BindableEvent")

GameLoopService.CurrentPhase = "Cooldown"
GameLoopService.TimeRemaining = 0

function GameLoopService:Start()
	print("GameLoopService Started.")
	task.spawn(function()
		while true do
			self:StartRaidPhase()
			self:StartCooldownPhase()
		end
	end)
end

function GameLoopService:StartRaidPhase()
	self.CurrentPhase = "Raid"
	self.TimeRemaining = RAID_DURATION
	print("--- RAID STARTED: 15 Minutes Remaining ---")

	self.RaidStarted:Fire() -- Let other systems know the raid began

	while self.TimeRemaining > 0 do
		task.wait(1)
		self.TimeRemaining -= 1
	end

	print("--- RAID ENDED ---")
	self.RaidEnded:Fire() -- Signal that time is up!
end

function GameLoopService:StartCooldownPhase()
	self.CurrentPhase = "Cooldown"
	self.TimeRemaining = COOLDOWN_DURATION
	print("--- COOLDOWN STARTED: Next raid in 2 minutes ---")

	while self.TimeRemaining > 0 do
		task.wait(1)
		self.TimeRemaining -= 1
	end
end

return GameLoopService
