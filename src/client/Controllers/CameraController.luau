local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CameraController = {}

local ARM_PARTS = {
	["Left Arm"] = true,
	["Right Arm"] = true,
	["LeftUpperArm"] = true,
	["LeftLowerArm"] = true,
	["LeftHand"] = true,
	["RightUpperArm"] = true,
	["RightLowerArm"] = true,
	["RightHand"] = true,
}

function CameraController:Start()
	print("CameraController Started.")
	local player = Players.LocalPlayer

	player.CameraMode = Enum.CameraMode.LockFirstPerson

	player.CharacterAdded:Connect(function(character)
		self:SetupCharacter(character)
	end)

	if player.Character then
		self:SetupCharacter(player.Character)
	end
end

function CameraController:SetupCharacter(character)
	RunService.RenderStepped:Connect(function()
		for _, part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") and ARM_PARTS[part.Name] then
				part.LocalTransparencyModifier = 0
			end
		end
	end)

	local humanoid = character:WaitForChild("Humanoid")
	task.wait(0.1)

	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		self:SetupR15Tilt(character)
	else
		self:SetupR6Tilt(character)
	end
end

function CameraController:SetupR15Tilt(character)
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

	local camera = Workspace.CurrentCamera

	RunService.RenderStepped:Connect(function()
		local humanoid = character:FindFirstChild("Humanoid")
		if not character.PrimaryPart or (humanoid and humanoid.Health <= 0) then
			return
		end

		-- The math.clamp prevents the NaN error that freezes the joints!
		local pitch = math.asin(math.clamp(camera.CFrame.LookVector.Y, -1, 1))

		-- Bend the torso and head halfway
		waist.C0 = waistC0 * CFrame.Angles(pitch * 0.5, 0, 0)
		neck.C0 = neckC0 * CFrame.Angles(pitch * 0.5, 0, 0)

		-- Bend the arms the rest of the way so the gun perfectly aligns with the camera!
		rightShoulder.C0 = rsC0 * CFrame.Angles(pitch * 0.5, 0, 0)
		leftShoulder.C0 = lsC0 * CFrame.Angles(pitch * 0.5, 0, 0)
	end)
end

function CameraController:SetupR6Tilt(character)
	local torso = character:WaitForChild("Torso")
	local rightShoulder = torso:WaitForChild("Right Shoulder")
	local leftShoulder = torso:WaitForChild("Left Shoulder")

	local rsC0 = rightShoulder.C0
	local lsC0 = leftShoulder.C0
	local camera = Workspace.CurrentCamera

	RunService.RenderStepped:Connect(function()
		local humanoid = character:FindFirstChild("Humanoid")
		if not character.PrimaryPart or (humanoid and humanoid.Health <= 0) then
			return
		end

		local pitch = math.asin(math.clamp(camera.CFrame.LookVector.Y, -1, 1))

		-- R6 shoulders have a native 90-degree rotation, so we rotate on the Z axis here
		rightShoulder.C0 = rsC0 * CFrame.Angles(0, 0, pitch)
		leftShoulder.C0 = lsC0 * CFrame.Angles(0, 0, -pitch)
	end)
end

return CameraController
