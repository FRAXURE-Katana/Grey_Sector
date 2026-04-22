local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponData = require(Shared.Weapons.WeaponData)

local WeaponController = {}

WeaponController.EquippedWeapon = "AssaultRifle"
WeaponController.CanAttack = true
WeaponController.IsHoldingTrigger = false

function WeaponController:Start()
	print("WeaponController Started. Equipped: " .. self.EquippedWeapon)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.IsHoldingTrigger = true
			self:HandleAttackInput()
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.IsHoldingTrigger = false
		end
	end)
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

	print("Attacking with " .. self.EquippedWeapon)

	task.wait(stats.FireRate)
	self.CanAttack = true
end

return WeaponController
