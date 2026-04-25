local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local NPCService = {}

-- AI Settings
NPCService.DetectionRadius = 60
NPCService.AttackRadius = 4
NPCService.ZombieDamage = 15
NPCService.AttackCooldown = 1

function NPCService:Start()
	print("NPCService Started (Zombie Hivemind & UI Enabled).")

	local zombieFolder = Workspace:FindFirstChild("Zombies")
	if not zombieFolder then
		warn("No 'Zombies' folder found in Workspace!")
		return
	end

	for _, zombie in pairs(zombieFolder:GetChildren()) do
		local rootPart = zombie:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart:SetNetworkOwner(nil)
		end
	end

	task.spawn(function()
		while task.wait(0.5) do
			self:UpdateZombies(zombieFolder)
		end
	end)
end

function NPCService:UpdateZombies(zombieFolder)
	for _, zombie in pairs(zombieFolder:GetChildren()) do
		local rootPart = zombie:FindFirstChild("HumanoidRootPart")
		local humanoid = zombie:FindFirstChild("Humanoid")

		if rootPart and humanoid and humanoid.Health > 0 then
			-- NEW: Inject the custom UI if the zombie doesn't have it yet!
			if not zombie:FindFirstChild("ZombieUI") then
				self:SetupZombieUI(zombie, humanoid)
			end

			self:ProcessZombie(zombie, rootPart, humanoid)
		end
	end
end

-- ==========================================
-- FLOATING HEALTH BAR LOGIC
-- ==========================================
function NPCService:SetupZombieUI(zombie, humanoid)
	local head = zombie:FindFirstChild("Head")
	if not head then
		return
	end

	-- Create the Billboard (A UI that hovers in 3D space)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ZombieUI"
	billboard.Adornee = head
	billboard.Size = UDim2.new(3, 0, 0.4, 0) -- 3 studs wide
	billboard.StudsOffset = Vector3.new(0, 1.5, 0) -- Hover slightly above the head
	billboard.MaxDistance = 50 -- Disappear if the player is further than 50 studs away
	billboard.AlwaysOnTop = true -- Render through walls/darkness

	-- Dark Background
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	bg.BorderSizePixel = 0
	bg.Parent = billboard

	-- Red Fill Bar
	local fill = Instance.new("Frame")
	fill.Name = "HealthFill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	fill.BorderSizePixel = 0
	fill.Parent = bg

	billboard.Parent = zombie

	-- Update the red bar dynamically when the zombie takes damage
	humanoid.HealthChanged:Connect(function(health)
		local percent = math.clamp(health / humanoid.MaxHealth, 0, 1)
		fill.Size = UDim2.new(percent, 0, 1, 0)

		-- Hide the UI completely when the zombie dies
		if health <= 0 then
			billboard.Enabled = false
		end
	end)
end

-- ==========================================
-- AI LOGIC
-- ==========================================
function NPCService:ProcessZombie(zombie, zombieRoot, zombieHumanoid)
	local nearestPlayer, distance = self:GetNearestPlayer(zombieRoot.Position)

	if nearestPlayer and distance <= self.DetectionRadius then
		local playerRoot = nearestPlayer.Character.HumanoidRootPart
		zombieHumanoid:MoveTo(playerRoot.Position)

		if distance <= self.AttackRadius then
			self:AttackPlayer(zombie, nearestPlayer)
		end
	end
end

function NPCService:GetNearestPlayer(zombiePosition)
	local nearestPlayer = nil
	local shortestDistance = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if rootPart and humanoid and humanoid.Health > 0 then
				local distance = (rootPart.Position - zombiePosition).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					nearestPlayer = player
				end
			end
		end
	end

	return nearestPlayer, shortestDistance
end

function NPCService:AttackPlayer(zombie, player)
	local lastAttack = zombie:GetAttribute("LastAttackTime") or 0
	if os.clock() - lastAttack < self.AttackCooldown then
		return
	end

	zombie:SetAttribute("LastAttackTime", os.clock())

	local humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid:TakeDamage(self.ZombieDamage)
		print(zombie.Name .. " hit " .. player.Name .. " for " .. self.ZombieDamage .. " damage!")
	end
end

return NPCService
