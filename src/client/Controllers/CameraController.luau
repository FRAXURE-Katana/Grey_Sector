local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local CameraController = {}

function CameraController:Start()
	print("CameraController Started (Third-Person with Spine Tilt).")
	local player = Players.LocalPlayer

	player.CameraMode = Enum.CameraMode.Classic
	player.CameraMinZoomDistance = 6
	player.CameraMaxZoomDistance = 12

	player.CharacterAdded:Connect(function(character)
		self:SetupThirdPerson(character)
	end)

	if player.Character then
		self:SetupThirdPerson(player.Character)
	end
end

function CameraController:SetupThirdPerson(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	-- Over-the-shoulder offset
	humanoid.CameraOffset = Vector3.new(2, 2, 0)
	humanoid.AutoRotate = false

	task.wait(0.1) -- Wait for joints to fully load

	-- Branch logic based on Rig Type
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

	-- Store default resting poses
	local waistC0 = waist.C0
	local neckC0 = neck.C0
	local rsC0 = rightShoulder.C0
	local lsC0 = leftShoulder.C0

	RunService.RenderStepped:Connect(function()
		if humanoid.Health <= 0 then
			return
		end

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		local camera = Workspace.CurrentCamera
		local lookVector = camera.CFrame.LookVector

		-- 1. HORIZONTAL ROTATION (Turn the whole body left/right)
		local flatLookVector = Vector3.new(lookVector.X, 0, lookVector.Z)
		-- Prevent NaN errors if looking perfectly straight up or down
		if flatLookVector.Magnitude > 0.001 then
			rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flatLookVector.Unit)
		end

		-- 2. VERTICAL ROTATION (Tilt the waist, neck, and arms up/down)
		local pitch = math.asin(math.clamp(lookVector.Y, -1, 1))

		waist.C0 = waistC0 * CFrame.Angles(pitch * 0.5, 0, 0)
		neck.C0 = neckC0 * CFrame.Angles(pitch * 0.5, 0, 0)

		rightShoulder.C0 = rsC0 * CFrame.Angles(pitch * 0.5, 0, 0)
		leftShoulder.C0 = lsC0 * CFrame.Angles(pitch * 0.5, 0, 0)
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

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		local camera = Workspace.CurrentCamera
		local lookVector = camera.CFrame.LookVector

		-- 1. HORIZONTAL ROTATION
		local flatLookVector = Vector3.new(lookVector.X, 0, lookVector.Z)
		if flatLookVector.Magnitude > 0.001 then
			rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flatLookVector.Unit)
		end

		-- 2. VERTICAL ROTATION
		local pitch = math.asin(math.clamp(lookVector.Y, -1, 1))

		-- R6 shoulders rotate on the Z axis natively
		rightShoulder.C0 = rsC0 * CFrame.Angles(0, 0, pitch)
		leftShoulder.C0 = lsC0 * CFrame.Angles(0, 0, -pitch)
	end)
end

return CameraController
