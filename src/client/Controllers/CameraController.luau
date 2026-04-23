local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local CameraController = {}

-- Track the state of the mouse
CameraController.IsMouseLocked = true
CameraController.CrosshairGui = nil

function CameraController:Start()
	print("CameraController Started (Third-Person + Crosshair Toggle).")
	local player = Players.LocalPlayer

	player.CameraMode = Enum.CameraMode.Classic
	player.CameraMinZoomDistance = 6
	player.CameraMaxZoomDistance = 12

	-- Setup the Crosshair UI
	self:SetupCrosshair(player)

	-- Listen for the LeftControl key to toggle the mouse
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftControl then
			self.IsMouseLocked = not self.IsMouseLocked
		end
	end)

	player.CharacterAdded:Connect(function(character)
		self:SetupThirdPerson(character)
	end)

	if player.Character then
		self:SetupThirdPerson(player.Character)
	end
end

function CameraController:SetupCrosshair(player)
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CrosshairGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local crosshair = Instance.new("ImageLabel")
	crosshair.Name = "Crosshair"
	crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
	crosshair.Size = UDim2.new(0, 40, 0, 40) -- Change this to adjust the size of the crosshair!
	crosshair.BackgroundTransparency = 1

	-- PASTE YOUR CROSSHAIR DECAL ID HERE:
	crosshair.Image = "rbxassetid://123878670104695"

	crosshair.Parent = screenGui

	self.CrosshairGui = screenGui
end

function CameraController:SetupThirdPerson(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	humanoid.CameraOffset = Vector3.new(2, 2, 0)
	humanoid.AutoRotate = false

	task.wait(0.1)

	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		self:SetupR15(character, humanoid, rootPart)
	else
		self:SetupR6(character, humanoid, rootPart)
	end
end

function CameraController:SetupR15(character, humanoid, rootPart)
	local upperTorso = character:WaitForChild("UpperTorso")
	local head = character:WaitForChild("Head")
	local rightUpperArm = character:WaitForChild("RightUpperArm")
	local leftUpperArm = character:WaitForChild("LeftUpperArm")

	local waist = upperTorso:WaitForChild("Waist")
	local neck = head:WaitForChild("Neck")
	local rightShoulder = rightUpperArm:WaitForChild("RightShoulder")
	local leftShoulder = leftUpperArm:WaitForChild("LeftShoulder")

	local waistC0 = waist.C0
	local neckC0 = neck.C0
	local rsC0 = rightShoulder.C0
	local lsC0 = leftShoulder.C0

	RunService.RenderStepped:Connect(function()
		if humanoid.Health <= 0 then
			return
		end

		if self.IsMouseLocked then
			-- HIDE the cursor, LOCK the mouse, SHOW the crosshair
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
			if self.CrosshairGui then
				self.CrosshairGui.Enabled = true
			end

			local camera = Workspace.CurrentCamera
			local lookVector = camera.CFrame.LookVector

			local flatLookVector = Vector3.new(lookVector.X, 0, lookVector.Z)
			if flatLookVector.Magnitude > 0.001 then
				rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flatLookVector.Unit)
			end

			local pitch = math.asin(math.clamp(lookVector.Y, -1, 1))

			waist.C0 = waistC0 * CFrame.Angles(pitch * 0.5, 0, 0)
			neck.C0 = neckC0 * CFrame.Angles(pitch * 0.5, 0, 0)

			rightShoulder.C0 = rsC0 * CFrame.Angles(pitch * 0.5, 0, 0)
			leftShoulder.C0 = lsC0 * CFrame.Angles(pitch * 0.5, 0, 0)
		else
			-- SHOW the cursor, FREE the mouse, HIDE the crosshair
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
			if self.CrosshairGui then
				self.CrosshairGui.Enabled = false
			end

			-- Notice we do NOT update the spine or rootPart rotation here!
			-- This freezes the character in place while you use menus.
		end
	end)
end

function CameraController:SetupR6(character, humanoid, rootPart)
	local torso = character:WaitForChild("Torso")
	local rightShoulder = torso:WaitForChild("Right Shoulder")
	local leftShoulder = torso:WaitForChild("Left Shoulder")

	local rsC0 = rightShoulder.C0
	local lsC0 = leftShoulder.C0

	RunService.RenderStepped:Connect(function()
		if humanoid.Health <= 0 then
			return
		end

		if self.IsMouseLocked then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
			if self.CrosshairGui then
				self.CrosshairGui.Enabled = true
			end

			local camera = Workspace.CurrentCamera
			local lookVector = camera.CFrame.LookVector

			local flatLookVector = Vector3.new(lookVector.X, 0, lookVector.Z)
			if flatLookVector.Magnitude > 0.001 then
				rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flatLookVector.Unit)
			end

			local pitch = math.asin(math.clamp(lookVector.Y, -1, 1))

			rightShoulder.C0 = rsC0 * CFrame.Angles(0, 0, pitch)
			leftShoulder.C0 = lsC0 * CFrame.Angles(0, 0, -pitch)
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
			if self.CrosshairGui then
				self.CrosshairGui.Enabled = false
			end
		end
	end)
end

return CameraController
