local Players = game:GetService("Players")

local HUDController = {}

HUDController.HealthBar = nil
HUDController.AmmoText = nil

-- Variables to hold our active tool connections so we can clean them up
HUDController.CurrentToolConnection1 = nil
HUDController.CurrentToolConnection2 = nil

function HUDController:Start()
	print("HUDController Started (Health & Ammo HUD).")
	local player = Players.LocalPlayer

	self:SetupUI(player)

	player.CharacterAdded:Connect(function(character)
		self:SetupCharacter(character)
	end)

	if player.Character then
		self:SetupCharacter(player.Character)
	end
end

function HUDController:SetupUI(player)
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StatusHUD"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- ==========================================
	-- HEALTH BAR (Bottom Left)
	-- ==========================================
	local healthBg = Instance.new("Frame")
	healthBg.Name = "HealthBackground"
	healthBg.AnchorPoint = Vector2.new(0, 1)
	healthBg.Position = UDim2.new(0.05, 0, 0.95, 0)
	healthBg.Size = UDim2.new(0.2, 0, 0.015, 0)
	healthBg.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
	healthBg.BorderSizePixel = 0
	healthBg.Parent = screenGui

	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthFill"
	healthFill.Size = UDim2.new(1, 0, 1, 0)
	healthFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthBg

	self.HealthBar = healthFill

	-- ==========================================
	-- AMMO TEXT (Bottom Right)
	-- ==========================================
	local ammoText = Instance.new("TextLabel")
	ammoText.Name = "AmmoText"
	ammoText.AnchorPoint = Vector2.new(1, 1)
	ammoText.Position = UDim2.new(0.95, 0, 0.95, 0)
	ammoText.Size = UDim2.new(0.15, 0, 0.05, 0)
	ammoText.BackgroundTransparency = 1
	ammoText.Font = Enum.Font.GothamBold
	ammoText.Text = ""
	ammoText.TextColor3 = Color3.fromRGB(255, 255, 255)
	ammoText.TextScaled = true
	ammoText.TextXAlignment = Enum.TextXAlignment.Right
	ammoText.Parent = screenGui

	self.AmmoText = ammoText
end

function HUDController:SetupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")

	-- 1. HEALTH TRACKING
	humanoid.HealthChanged:Connect(function(health)
		if self.HealthBar then
			local percent = math.clamp(health / humanoid.MaxHealth, 0, 1)
			self.HealthBar.Size = UDim2.new(percent, 0, 1, 0)
		end
	end)

	-- Set initial health on spawn
	if self.HealthBar then
		local percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		self.HealthBar.Size = UDim2.new(percent, 0, 1, 0)
	end

	-- 2. AMMO TRACKING
	-- When a player equips a tool, it moves from their Backpack into their Character!
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			self:HookTool(child)
		end
	end)

	-- When unequipped, it moves out of the Character
	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			self:UnhookTool()
		end
	end)

	-- Just in case they already have a tool equipped when this runs
	local currentTool = character:FindFirstChildOfClass("Tool")
	if currentTool then
		self:HookTool(currentTool)
	end
end

function HUDController:HookTool(tool)
	self:UnhookTool() -- Clear old connections just in case

	local function updateAmmo()
		if self.AmmoText then
			local current = tool:GetAttribute("CurrentAmmo")
			local reserve = tool:GetAttribute("ReserveAmmo")

			if current and reserve then
				self.AmmoText.Text = tostring(current) .. " / " .. tostring(reserve)
			else
				-- If the tool doesn't have ammo attributes (like the Sword), hide the text!
				self.AmmoText.Text = ""
			end
		end
	end

	-- Listen for the ammo values changing (like shooting or reloading)
	self.CurrentToolConnection1 = tool:GetAttributeChangedSignal("CurrentAmmo"):Connect(updateAmmo)
	self.CurrentToolConnection2 = tool:GetAttributeChangedSignal("ReserveAmmo"):Connect(updateAmmo)

	-- Force a UI update immediately so the numbers appear when equipped
	updateAmmo()
end

function HUDController:UnhookTool()
	if self.CurrentToolConnection1 then
		self.CurrentToolConnection1:Disconnect()
		self.CurrentToolConnection1 = nil
	end
	if self.CurrentToolConnection2 then
		self.CurrentToolConnection2:Disconnect()
		self.CurrentToolConnection2 = nil
	end
	if self.AmmoText then
		self.AmmoText.Text = ""
	end
end

return HUDController
