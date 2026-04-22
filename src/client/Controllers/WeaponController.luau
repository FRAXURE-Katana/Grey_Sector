local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService") -- Added RunService

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponData = require(Shared.Weapons.WeaponData)

local WeaponModels = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons")

local WeaponController = {}

WeaponController.EquippedWeapon = nil
WeaponController.CurrentWeaponModel = nil
WeaponController.CanAttack = true
WeaponController.IsHoldingTrigger = false
WeaponController.VisibilityConnection = nil -- Variable to hold our loop

function WeaponController:Start()
	print("WeaponController Started.")

	local player = Players.LocalPlayer
	player.CharacterAdded:Connect(function(character)
		task.wait(0.1)
		self:EquipWeapon("AssaultRifle")
	end)
	if player.Character then
		self:EquipWeapon("AssaultRifle")
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not self.EquippedWeapon then
				return
			end
			self.IsHoldingTrigger = true
			self:HandleAttackInput()
		end

		if input.KeyCode == Enum.KeyCode.One then
			self:EquipWeapon("AssaultRifle")
		elseif input.KeyCode == Enum.KeyCode.Two then
			self:EquipWeapon("CombatKnife")
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.IsHoldingTrigger = false
		end
	end)
end

function WeaponController:EquipWeapon(weaponName)
	if self.EquippedWeapon == weaponName or not WeaponData[weaponName] then
		return
	end

	self.EquippedWeapon = weaponName
	self.IsHoldingTrigger = false
	print("Swapped to: " .. weaponName)

	self:WeldWeaponToCharacter(weaponName)
end

function WeaponController:WeldWeaponToCharacter(weaponName)
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then
		return
	end

	local rightArm = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not rightArm then
		return
	end

	if self.CurrentWeaponModel then
		self.CurrentWeaponModel:Destroy()
	end

	local template = WeaponModels:FindFirstChild(weaponName)
	if template then
		local newWeapon = template:Clone()

		local handle = newWeapon.PrimaryPart or newWeapon:FindFirstChild("Handle")
		if not handle then
			warn(weaponName .. " does not have a PrimaryPart or a part named 'Handle'!")
			newWeapon:Destroy()
			return
		end

		-- PHYSICS & WELDING FIX
		for _, part in pairs(newWeapon:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.Anchored = false
				part.Massless = true

				-- If this part isn't the handle, weld it to the handle!
				if part ~= handle then
					local internalWeld = Instance.new("WeldConstraint")
					internalWeld.Part0 = handle
					internalWeld.Part1 = part
					internalWeld.Parent = handle
				end
			end
		end

		if newWeapon.PrimaryPart then
			newWeapon:PivotTo(rightArm.CFrame)
		else
			local offset = handle.CFrame:Inverse() * newWeapon:GetPivot()
			newWeapon:PivotTo(rightArm.CFrame * offset)
		end

		newWeapon.Parent = character
		self.CurrentWeaponModel = newWeapon

		-- Weld the handle to the arm
		local armWeld = Instance.new("WeldConstraint")
		armWeld.Part0 = rightArm
		armWeld.Part1 = handle
		armWeld.Parent = handle

		if self.VisibilityConnection then
			self.VisibilityConnection:Disconnect()
		end

		self.VisibilityConnection = RunService.RenderStepped:Connect(function()
			if self.CurrentWeaponModel then
				for _, part in pairs(self.CurrentWeaponModel:GetDescendants()) do
					if part:IsA("BasePart") or part:IsA("Decal") then
						part.LocalTransparencyModifier = 0
					end
				end
			end
		end)
	end
end

function WeaponController:HandleAttackInput()
	local stats = WeaponData[self.EquippedWeapon]

	if stats.Automatic then
		while self.IsHoldingTrigger and self.CanAttack do
			self:PerformAttack(stats)
		end
	else
		if self.CanAttack then
			self:PerformAttack(stats)
		end
	end
end

function WeaponController:PerformAttack(stats)
	self.CanAttack = false
	print("Attacking with " .. self.EquippedWeapon .. "!")

	task.wait(stats.FireRate)
	self.CanAttack = true
end

return WeaponController
