local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local DebrisService = game:GetService("Debris")

local Utility = require(ReplicatedStorage.Modules.NikosModules.Utilities.Utility)
local Projectile = require(ReplicatedStorage.Modules.Classes.Projectile)
local UpdateUI = require(ReplicatedStorage.Modules.Gui.UpdateUI)
local MouseController = require(ReplicatedStorage.Modules.NikosModules.ShiftLockController)
local SpringModule = require(ReplicatedStorage.Modules.OSModules.spring)

local FireSpring = nil

local TargetHit = ReplicatedStorage.Remotes.TargetHit

local LocalPlayer = PlayerService.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.Camera
local Mouse = LocalPlayer:GetMouse()

local PlayerGUI = LocalPlayer.PlayerGui
local Hud = PlayerGUI.Hud
local WeaponInfo = Hud.WeaponInfo
local RandomObject = Random.new()

local Weapon = nil
local Connections = {}

local Reloading = false
local Running = false
local Debounce = false

local function Visual(FirePointPos, MousePos, RayCast)
	local BulletHole = script.BulletHole:Clone()
	local DustParticles = BulletHole.Attachment.Dust
	
	DustParticles.Color = ColorSequence.new(RayCast.Instance.Color)
	
	BulletHole.CFrame = CFrame.lookAt(RayCast.Position, RayCast.Position + RayCast.Normal)
	BulletHole.Parent = workspace
	
	DustParticles:Emit(DustParticles.EmitCount.Value)
	
	DebrisService:AddItem(BulletHole, 5)
end


local function Recoil()
	local Config = require(Weapon.Configs.Recoil)
	
	FireSpring:shove(Vector3.new(RandomObject:NextNumber(Config["X"]["Min"], Config["X"]["Max"]), RandomObject:NextNumber(Config["Y"]["Min"], Config["Y"]["Max"]), 0))
end


local function Reload()
	local Configs = Weapon.Configs
	local MaxAmmo = Configs.MaxAmmo
	local CurrentAmmo = MaxAmmo.CurrentAmmo
	local ReservedAmmo = Configs.ReservedAmmo
	
	local SFX = require(Configs.SFX)
	
	if CurrentAmmo.Value == MaxAmmo.Value or ReservedAmmo.Value == 0 then return end
	Reloading = true
	
	local TotalTime = 0
	
	SFX.Reloading:Play()
	while TotalTime <= Configs.ReloadTime.Value do
		local Time = task.wait(1/60)
		TotalTime += Time
	end
	
	if Reloading == false then return end
	
	local AmmoCount = (MaxAmmo.Value - CurrentAmmo.Value) > ReservedAmmo.Value and ReservedAmmo.Value or (MaxAmmo.Value - CurrentAmmo.Value)
	
	ReservedAmmo.Value -= AmmoCount
	CurrentAmmo.Value += AmmoCount
	
	Reloading = false
end


local function Fire()
	local Configs = Weapon.Configs
	local AmmoCount = Configs.MaxAmmo.CurrentAmmo
	local SFX = require(Configs.SFX)
	
	local Handle = Weapon.Handle
	local FirePointPos = Handle.FirePoint.WorldPosition
	local MousePos, Result = Utility.GetMousePosition({Character})
	
	local IgnoreParams = RaycastParams.new()
	IgnoreParams.FilterDescendantsInstances = {Character}
	IgnoreParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local RayCast = workspace:Raycast(FirePointPos, (MousePos - FirePointPos).Unit * 300, IgnoreParams)
	
	local Bullet = script.Bullet:Clone()
	
	--Projectile.New(FirePointPos + (MousePos - FirePointPos).Unit, 10, 5, Bullet)
	
	Recoil()
	SFX.Fire:Play()
	AmmoCount.Value -= 1
	 
	if 	Handle.GunFlash then
		Handle.GunFlash.BeamMuzzleEffect:Emit(1)
	end
	if Handle.SmokeTrail then
		Handle.SmokeTrail.Enabled = true
		task.delay(.5, function() Handle.SmokeTrail.Enabled = false end)
	end
	
	Bullet.CFrame = CFrame.new(FirePointPos)
	
	if RayCast then
		Visual(FirePointPos, MousePos, RayCast)
		
		local InstanceParent = RayCast.Instance.Parent
		local EnemyHumanoid = InstanceParent:FindFirstChild("Humanoid") or InstanceParent.Parent:FindFirstChild("Humanoid")
		
		if EnemyHumanoid then
			TargetHit:FireServer(EnemyHumanoid.Parent, RayCast.Instance, Weapon.Name)
		end
	end
	
	Bullet.CFrame = CFrame.lookAt(Bullet.Position, MousePos)
	Bullet.Parent = workspace
	
	Projectile.New(MousePos, .2, 5, Bullet)
end


local function WeaponType()
	local Configs = Weapon.Configs
	local FullAuto = Configs.FullAuto
	local AmmoCount = Configs.MaxAmmo.CurrentAmmo
	
	if AmmoCount.Value == 0 or Reloading == true then return end
	
	if Debounce == true or Running == true then return end

	if FullAuto.Value == true then
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			if AmmoCount.Value == 0 or Reloading == true or Weapon == nil then break end
			Running = true
			Fire()
			task.wait(Configs.FireRate.Value)
			print("Ran Auto")
		end	
		Running = false
	else
		Debounce = true
		Fire()
		task.wait(Configs.FireRate.Value)
		Debounce = false
	end

end


local function ChildAdded(Child)
	if Child.ClassName == "Tool" then
		Weapon = Child
		local VisualConfigs = Weapon.Configs.Visuals
		Mouse.Icon = VisualConfigs.MouseIcon.Value
		
		local Config = require(Weapon.Configs.Recoil)
		
		MouseController.ShiftLock(true)
		UpdateUI.UpdateHUD(LocalPlayer, Weapon)
		
		FireSpring = SpringModule:create(Config["Mass"], Config["Force"], Config["Damping"], Config["Speed"])
		
		Connections[#Connections + 1] = Weapon.Activated:Connect(WeaponType)
		Connections[#Connections + 1] = UserInputService.InputBegan:Connect(function(Input, GameService)
			if GameService then return end
			
			if Input.KeyCode == Enum.KeyCode.R then
				Reload()
			end 
		end)
	end
end

Character.ChildAdded:Connect(ChildAdded) 


Character.ChildRemoved:Connect(function(Child)
	if Child.ClassName == "Tool" then
		if Weapon ~= nil then
			WeaponInfo.Visible = false
			Weapon = nil
			Reloading = false
			FireSpring = nil
			
			Mouse.Icon = ""
			
			MouseController.ShiftLock(false)
			
			for i, v in Connections do
				v:Disconnect()
			end
			UpdateUI.DisconnectUI()
			Connections = {}
		end
	end
end)


while true do
	local DeltaTime = task.wait()
	if FireSpring == nil then continue end
	local Recoil = FireSpring:update(DeltaTime)
	Camera.CFrame *= CFrame.Angles(Recoil.X, Recoil.Y, Recoil.Z)
end
