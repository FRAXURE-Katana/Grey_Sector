local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponData = require(Shared.Weapons.WeaponData)

local WeaponModels = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Weapons")
local Cosmetics = ReplicatedStorage:WaitForChild("Cosmetics")

local WeaponController = {}

WeaponController.EquippedWeapon = nil
WeaponController.CanAttack = true
WeaponController.IsHoldingTrigger = false
WeaponController.CurrentIdleTrack = nil

function WeaponController:Start()
	print("WeaponController Started (Cosmetics Enabled).")

	local player = Players.LocalPlayer

	player.CharacterAdded:Connect(function(character)
		self:SetupCharacter(character)
	end)
	if player.Character then
		self:SetupCharacter(player.Character)
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
				local tool = backpack:FindFirstChild("Sword")
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

	backpack:ClearAllChildren()

	self:GiveTool("AssaultRifle", backpack, character)
	self:GiveTool("Sword", backpack, character)

	task.wait(0.1)
	local humanoid = character:FindFirstChild("Humanoid")
	local arTool = backpack:FindFirstChild("AssaultRifle")
	if humanoid and arTool then
		humanoid:EquipTool(arTool)
	end
end

function WeaponController:GiveTool(weaponName, backpack, character)
	local template = WeaponModels:FindFirstChild(weaponName)
	if not template or not template:IsA("Tool") then
		return
	end

	local newTool = template:Clone()

	-- ==========================================
	-- MOCK LOADOUT APPLY (Will be moved to Server later)
	-- ==========================================
	if weaponName == "AssaultRifle" then
		-- In the future, the Server will check what the player bought in the store
		-- and apply these attributes before giving them the tool!
		newTool:SetAttribute("MuzzleFlash", "StandardFlash")
		newTool:SetAttribute("Tracer", "StandardTracer")
	end

	newTool.Equipped:Connect(function()
		self.EquippedWeapon = weaponName
		self.IsHoldingTrigger = false
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

-- ==========================================
-- COSMETICS LOGIC
-- ==========================================
function WeaponController:RenderShootVisuals(stats, tool, hitPosition)
	local handle = tool:FindFirstChild("Handle")
	if not handle then
		return
	end

	local muzzle = handle:FindFirstChild("Muzzle")
	if not muzzle then
		return
	end

	local origin = muzzle.WorldPosition
	local distance = (hitPosition - origin).Magnitude

	-- Read what the individual player has equipped from the Tool's Attributes!
	local equippedFlash = tool:GetAttribute("MuzzleFlash")
	local equippedTracer = tool:GetAttribute("Tracer")

	-- 1. Muzzle Flash
	if equippedFlash then
		local flashTemplate = Cosmetics.MuzzleFlashes:FindFirstChild(equippedFlash)
		if flashTemplate then
			local activeFlash = flashTemplate:Clone()
			activeFlash.Parent = muzzle
			activeFlash:Emit(5)
			Debris:AddItem(activeFlash, 1)
		end
	end

	-- 2. Bullet Tracer
	if equippedTracer then
		local tracerTemplate = Cosmetics.Tracers:FindFirstChild(equippedTracer)
		if tracerTemplate then
			local tracer = tracerTemplate:Clone()

			local tracerLength = math.clamp(distance, 1, 40)
			tracer.Size = Vector3.new(tracer.Size.X, tracer.Size.Y, tracerLength)
			tracer.CFrame = CFrame.lookAt(origin, hitPosition) * CFrame.new(0, 0, -tracerLength / 2)
			tracer.Parent = Workspace

			local flightTime = distance / 1000

			local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Linear)
			local goal = {
				CFrame = CFrame.lookAt(hitPosition, hitPosition + (hitPosition - origin))
					* CFrame.new(0, 0, -tracerLength / 2),
				Transparency = 1,
			}

			local tween = TweenService:Create(tracer, tweenInfo, goal)
			tween:Play()

			Debris:AddItem(tracer, flightTime + 0.1)
		end
	end
end

-- ==========================================
-- HIT DETECTION LOGIC
-- ==========================================
function WeaponController:PerformAttack(stats)
	self.CanAttack = false
	local player = Players.LocalPlayer
	local character = player.Character

	if stats.Type == "Ranged" then
		local camera = Workspace.CurrentCamera
		local origin = camera.CFrame.Position
		local direction = camera.CFrame.LookVector * 1000

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = { character }
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local result = Workspace:Raycast(origin, direction, rayParams)

		-- Default hit position to max range if we hit nothing
		local hitPosition = origin + direction
		if result then
			hitPosition = result.Position
		end

		-- RENDER COSMETICS
		local tool = character:FindFirstChild(self.EquippedWeapon)
		if tool then
			self:RenderShootVisuals(stats, tool, hitPosition)
		end

		if result then
			local remote = Shared.Weapons:FindFirstChild("WeaponEvent")
			if remote then
				remote:FireServer(self.EquippedWeapon, result.Instance)
			end
		end
	elseif stats.Type == "Melee" then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local origin = rootPart.Position
			local direction = rootPart.CFrame.LookVector * stats.Range

			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = { character }
			rayParams.FilterType = Enum.RaycastFilterType.Exclude

			local result = Workspace:Spherecast(origin, 3, direction, rayParams)

			if result then
				local remote = Shared.Weapons:FindFirstChild("WeaponEvent")
				if remote then
					remote:FireServer(self.EquippedWeapon, result.Instance)
				end
			end
		end
	end

	task.wait(stats.FireRate)
	self.CanAttack = true
end

return WeaponController
