local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local MovementController = {}

-- Stamina Settings
MovementController.MaxStamina = 100
MovementController.CurrentStamina = 100
MovementController.IsSprinting = false

-- Speed and Drain Rates
MovementController.WalkSpeed = 16
MovementController.SprintSpeed = 26
MovementController.DrainRate = 20 -- Stamina lost per second of sprinting
MovementController.RegenRate = 12 -- Stamina gained per second when resting

MovementController.StaminaBar = nil

function MovementController:Start()
	print("MovementController Started (Stamina System).")

	local player = Players.LocalPlayer
	self:SetupUI(player)

	-- Listen for the Shift key being pressed
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self:SetSprinting(true)
		end
	end)

	-- Listen for the Shift key being released
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self:SetSprinting(false)
		end
	end)

	-- Update the stamina math every single frame
	RunService.Heartbeat:Connect(function(deltaTime)
		self:UpdateStamina(deltaTime)
	end)
end

function MovementController:SetSprinting(wantsToSprint)
	local player = Players.LocalPlayer
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	-- If they want to sprint AND they have stamina, let them run!
	if wantsToSprint and self.CurrentStamina > 0 then
		self.IsSprinting = true
		humanoid.WalkSpeed = self.SprintSpeed
	else
		self.IsSprinting = false
		humanoid.WalkSpeed = self.WalkSpeed
	end
end

function MovementController:UpdateStamina(deltaTime)
	local player = Players.LocalPlayer
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	-- Check if the player is actually physically moving their character
	local isMoving = humanoid.MoveDirection.Magnitude > 0

	if self.IsSprinting and isMoving then
		-- Drain stamina
		self.CurrentStamina = math.clamp(self.CurrentStamina - (self.DrainRate * deltaTime), 0, self.MaxStamina)

		-- Force them to stop if they run out of breath
		if self.CurrentStamina <= 0 then
			self:SetSprinting(false)
		end
	else
		-- Regenerate stamina
		self.CurrentStamina = math.clamp(self.CurrentStamina + (self.RegenRate * deltaTime), 0, self.MaxStamina)
	end

	-- Update the UI Bar size visually
	if self.StaminaBar then
		self.StaminaBar.Size = UDim2.new(self.CurrentStamina / self.MaxStamina, 0, 1, 0)

		-- Make the bar turn red if they are completely out of breath
		if self.CurrentStamina <= 0 then
			self.StaminaBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		else
			self.StaminaBar.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
		end
	end
end

function MovementController:SetupUI(player)
	local playerGui = player:WaitForChild("PlayerGui")

	-- Create the ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HUDGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Create the dark background bar
	local background = Instance.new("Frame")
	background.Name = "StaminaBackground"
	background.AnchorPoint = Vector2.new(0.5, 1)
	background.Position = UDim2.new(0.5, 0, 0.95, 0) -- Near the bottom middle of the screen
	background.Size = UDim2.new(0.3, 0, 0.015, 0)
	background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	background.BorderSizePixel = 0
	background.Parent = screenGui

	-- Create the white fill bar
	local fill = Instance.new("Frame")
	fill.Name = "StaminaFill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	fill.BorderSizePixel = 0
	fill.Parent = background

	self.StaminaBar = fill
end

return MovementController
