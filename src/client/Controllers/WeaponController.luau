local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponData = require(Shared.Weapons.WeaponData)

local WeaponModels = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons")

local WeaponController = {}

WeaponController.EquippedWeapon = nil
WeaponController.CanAttack = true
WeaponController.IsHoldingTrigger = false
WeaponController.CurrentIdleTrack = nil
WeaponController.VisibilityConnection = nil

function WeaponController:Start()
	print("WeaponController Started (Tool Version).")

	local player = Players.LocalPlayer

	-- Setup tools when character spawns
	player.CharacterAdded:Connect(function(character)
		self:SetupCharacter(character)
	end)
	if player.Character then
		self:SetupCharacter(player.Character)
	end

	-- Listen for Input (Shooting and Swapping)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		-- Shooting
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not self.EquippedWeapon then
				return
			end
			self.IsHoldingTrigger = true
			self:HandleAttackInput()
		end

		-- Swapping weapons using standard Backpack equipping
		local character = player.Character
		local humanoid = character and character:FindFirstChild("Humanoid")
		local backpack = player:FindFirstChild("Backpack")

		if humanoid and backpack then
			if input.KeyCode == Enum.KeyCode.One then
				local tool = backpack:FindFirstChild("AssaultRifle")
				if tool then
					humanoid:EquipTool(tool)
				end
			elseif input.KeyCode == Enum.KeyCode.Two then
				local tool = backpack:FindFirstChild("CombatKnife")
				if tool then
					humanoid:EquipTool(tool)
				end
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.IsHoldingTrigger = false
		end
	end)
end

function WeaponController:SetupCharacter(character)
	local player = Players.LocalPlayer
	local backpack = player:WaitForChild("Backpack")

	-- Clear old tools
	backpack:ClearAllChildren()

	-- Give the player the tools
	self:GiveTool("AssaultRifle", backpack, character)
	self:GiveTool("CombatKnife", backpack, character)

	-- Automatically equip the AR to start
	task.wait(0.1)
	local humanoid = character:FindFirstChild("Humanoid")
	local arTool = backpack:FindFirstChild("AssaultRifle")
	if humanoid and arTool then
		humanoid:EquipTool(arTool)
	end

	-- Keep whatever tool is equipped visible in First Person
	if self.VisibilityConnection then
		self.VisibilityConnection:Disconnect()
	end

	self.VisibilityConnection = RunService.RenderStepped:Connect(function()
		local equippedTool = character:FindFirstChildOfClass("Tool")
		if equippedTool then
			for _, part in pairs(equippedTool:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("Decal") then
					part.LocalTransparencyModifier = 0
				end
			end
		end
	end)
end

function WeaponController:GiveTool(weaponName, backpack, character)
	local template = WeaponModels:FindFirstChild(weaponName)
	if not template or not template:IsA("Tool") then
		warn("Could not find a Tool named " .. weaponName .. "!")
		return
	end

	local newTool = template:Clone()

	-- Listen for native Roblox tool events!
	newTool.Equipped:Connect(function()
		self.EquippedWeapon = weaponName
		self.IsHoldingTrigger = false
		print("Equipped: " .. weaponName)
		self:PlayIdleAnimation(weaponName, character)
	end)

	newTool.Unequipped:Connect(function()
		if self.EquippedWeapon == weaponName then
			self.EquippedWeapon = nil
			self.IsHoldingTrigger = false
		end
		self:StopIdleAnimation()
	end)

	newTool.Parent = backpack
end

function WeaponController:PlayIdleAnimation(weaponName, character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	self:StopIdleAnimation()

	local animId = WeaponData[weaponName].IdleAnimation
	if animId and animId ~= "rbxassetid://00000000000" then
		local animation = Instance.new("Animation")
		animation.AnimationId = animId

		self.CurrentIdleTrack = animator:LoadAnimation(animation)
		self.CurrentIdleTrack.Looped = true
		self.CurrentIdleTrack.Priority = Enum.AnimationPriority.Action
		self.CurrentIdleTrack:Play()
	end
end

function WeaponController:StopIdleAnimation()
	if self.CurrentIdleTrack then
		self.CurrentIdleTrack:Stop()
		self.CurrentIdleTrack:Destroy()
		self.CurrentIdleTrack = nil
	end
end

function WeaponController:HandleAttackInput()
	local stats = WeaponData[self.EquippedWeapon]
	if not stats then
		return
	end

	if stats.Automatic then
		while self.IsHoldingTrigger and self.CanAttack and self.EquippedWeapon do
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
