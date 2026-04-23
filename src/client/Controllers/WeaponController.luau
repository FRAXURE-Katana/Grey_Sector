local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponData = require(Shared.Weapons.WeaponData)
local Cosmetics = ReplicatedStorage:WaitForChild("Cosmetics")

local WeaponController = {}

WeaponController.EquippedWeapon = nil
WeaponController.CanAttack = true
WeaponController.IsHoldingTrigger = false
WeaponController.IsReloading = false
WeaponController.CurrentIdleTrack = nil
WeaponController.CurrentReloadTrack = nil

-- NEW: Combo Tracking Variables
WeaponController.CurrentComboIndex = 1
WeaponController.LastAttackTime = 0

function WeaponController:Start()
	print("WeaponController Started (Combo System Enabled).")

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

		if input.KeyCode == Enum.KeyCode.R then
			self:ReloadWeapon()
		end

		local character = player.Character
		local humanoid = character and character:FindFirstChild("Humanoid")
		local backpack = player:FindFirstChild("Backpack")

		if humanoid and backpack and not self.IsReloading then
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

	backpack.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			self:HookToolEvents(child, character)
		end
	end)

	for _, child in pairs(backpack:GetChildren()) do
		if child:IsA("Tool") then
			self:HookToolEvents(child, character)
		end
	end

	task.delay(0.5, function()
		local humanoid = character:FindFirstChild("Humanoid")
		local arTool = backpack:FindFirstChild("AssaultRifle")
		if humanoid and arTool then
			humanoid:EquipTool(arTool)
		end
	end)
end

function WeaponController:HookToolEvents(tool, character)
	local weaponName = tool.Name

	tool.Equipped:Connect(function()
		self.EquippedWeapon = weaponName
		self.IsHoldingTrigger = false

		-- Reset combo when pulling out the weapon
		self.CurrentComboIndex = 1

		if tool:GetAttribute("CurrentAmmo") then
			print(
				weaponName
					.. " Equipped. Ammo: "
					.. tool:GetAttribute("CurrentAmmo")
					.. " / "
					.. tool:GetAttribute("ReserveAmmo")
			)
		end

		self:PlayIdleAnimation(weaponName, character)
	end)

	tool.Unequipped:Connect(function()
		if self.EquippedWeapon == weaponName then
			self.EquippedWeapon = nil
			self.IsHoldingTrigger = false
			self.IsReloading = false
		end
		self:StopIdleAnimation()
	end)
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

	local stats = WeaponData[weaponName]
	local animId = stats and stats.IdleAnimation

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
	if not stats or self.IsReloading then
		return
	end

	if stats.Automatic then
		while self.IsHoldingTrigger and self.CanAttack and self.EquippedWeapon and not self.IsReloading do
			self:PerformAttack(stats)
		end
	else
		if self.CanAttack then
			self:PerformAttack(stats)
		end
	end
end

-- ==========================================
-- AUDIO HELPER LOGIC
-- ==========================================
function WeaponController:PlaySound(soundId, parentPart, pitch)
	if not soundId or soundId == "rbxassetid://00000000000" or not parentPart then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = parentPart
	sound:Play()

	Debris:AddItem(sound, 3)
end

-- ==========================================
-- RELOADING LOGIC
-- ==========================================
function WeaponController:ReloadWeapon()
	if not self.EquippedWeapon or self.IsReloading then
		return
	end

	local player = Players.LocalPlayer
	local tool = player.Character:FindFirstChild(self.EquippedWeapon)
	if not tool then
		return
	end

	local stats = WeaponData[self.EquippedWeapon]
	if not stats or stats.Type ~= "Ranged" then
		return
	end

	local currentAmmo = tool:GetAttribute("CurrentAmmo")
	local reserveAmmo = tool:GetAttribute("ReserveAmmo")

	if currentAmmo >= stats.MaxAmmo or reserveAmmo <= 0 then
		print("Cannot reload (Clip full or no reserve).")
		return
	end

	self.IsReloading = true
	self.IsHoldingTrigger = false
	print("Reloading " .. self.EquippedWeapon .. "...")

	self:PlaySound(stats.ReloadSound, tool:FindFirstChild("Handle"))

	local humanoid = player.Character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	if animator and stats.ReloadAnimation and stats.ReloadAnimation ~= "rbxassetid://00000000000" then
		local animation = Instance.new("Animation")
		animation.AnimationId = stats.ReloadAnimation
		self.CurrentReloadTrack = animator:LoadAnimation(animation)
		self.CurrentReloadTrack.Priority = Enum.AnimationPriority.Action4
		self.CurrentReloadTrack:Play()
	end

	task.wait(stats.ReloadTime)

	if self.EquippedWeapon == tool.Name then
		local ammoNeeded = stats.MaxAmmo - currentAmmo
		local ammoToTake = math.min(ammoNeeded, reserveAmmo)

		tool:SetAttribute("CurrentAmmo", currentAmmo + ammoToTake)
		tool:SetAttribute("ReserveAmmo", reserveAmmo - ammoToTake)

		print(
			"Reload Complete! Ammo: " .. tool:GetAttribute("CurrentAmmo") .. " / " .. tool:GetAttribute("ReserveAmmo")
		)
	end

	if self.CurrentReloadTrack then
		self.CurrentReloadTrack:Stop()
		self.CurrentReloadTrack:Destroy()
		self.CurrentReloadTrack = nil
	end

	self.IsReloading = false
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

	local equippedFlash = tool:GetAttribute("MuzzleFlash")
	local equippedTracer = tool:GetAttribute("Tracer")

	if equippedFlash then
		local flashTemplate = Cosmetics.MuzzleFlashes:FindFirstChild(equippedFlash)
		if flashTemplate then
			local activeFlash = flashTemplate:Clone()
			activeFlash.Parent = muzzle
			activeFlash:Emit(5)
			Debris:AddItem(activeFlash, 1)
		end
	end

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
	local tool = character:FindFirstChild(self.EquippedWeapon)

	if stats.Type == "Ranged" then
		if not tool then
			return
		end

		local currentAmmo = tool:GetAttribute("CurrentAmmo")
		if currentAmmo <= 0 then
			print("Click! Out of Ammo.")
			self.CanAttack = true
			self.IsHoldingTrigger = false
			self:ReloadWeapon()
			return
		end

		tool:SetAttribute("CurrentAmmo", currentAmmo - 1)

		local randomPitch = math.random(90, 110) / 100
		self:PlaySound(stats.ShootSound, tool:FindFirstChild("Handle"), randomPitch)

		local humanoid = character:FindFirstChild("Humanoid")
		local animator = humanoid and humanoid:FindFirstChild("Animator")
		if animator and stats.ShootAnimation and stats.ShootAnimation ~= "rbxassetid://00000000000" then
			local animation = Instance.new("Animation")
			animation.AnimationId = stats.ShootAnimation
			local track = animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action3
			track:Play()
		end

		local camera = Workspace.CurrentCamera
		local origin = camera.CFrame.Position
		local direction = camera.CFrame.LookVector * 1000

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = { character }
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local result = Workspace:Raycast(origin, direction, rayParams)

		local hitPosition = origin + direction
		if result then
			hitPosition = result.Position
		end

		self:RenderShootVisuals(stats, tool, hitPosition)

		if result then
			local remote = Shared.Weapons:FindFirstChild("WeaponEvent")
			if remote then
				remote:FireServer(self.EquippedWeapon, result.Instance)
			end
		end
	elseif stats.Type == "Melee" then
		if not tool then
			return
		end

		local randomPitch = math.random(90, 110) / 100
		self:PlaySound(stats.SwingSound, tool:FindFirstChild("Handle"), randomPitch)

		-- NEW: Combo System Logic
		local humanoid = character:FindFirstChild("Humanoid")
		local animator = humanoid and humanoid:FindFirstChild("Animator")

		-- Reset combo if it's been more than 1.5 seconds since the last swing
		if os.clock() - self.LastAttackTime > 1.5 then
			self.CurrentComboIndex = 1
		end
		self.LastAttackTime = os.clock()

		if animator and stats.AttackAnimations and #stats.AttackAnimations > 0 then
			-- Ensure the index loops back around if it goes out of bounds
			if self.CurrentComboIndex > #stats.AttackAnimations then
				self.CurrentComboIndex = 1
			end

			local animId = stats.AttackAnimations[self.CurrentComboIndex]
			if animId and animId ~= "rbxassetid://00000000000" then
				local animation = Instance.new("Animation")
				animation.AnimationId = animId
				local track = animator:LoadAnimation(animation)
				track.Priority = Enum.AnimationPriority.Action3
				track:Play()
			end

			-- Prepare the next animation for the next click
			self.CurrentComboIndex += 1
		end

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
