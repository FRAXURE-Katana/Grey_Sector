local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CameraController = {}

-- A dictionary of all possible arm part names for both R6 and R15 rigs
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
		self:MakeArmsVisible(character)
	end)

	if player.Character then
		self:MakeArmsVisible(player.Character)
	end
end

function CameraController:MakeArmsVisible(character)
	RunService.RenderStepped:Connect(function()
		for _, part in pairs(character:GetChildren()) do
			-- Only make the part visible if its name is in our ARM_PARTS list
			if part:IsA("BasePart") and ARM_PARTS[part.Name] then
				part.LocalTransparencyModifier = 0
			end
		end
	end)
end

return CameraController
