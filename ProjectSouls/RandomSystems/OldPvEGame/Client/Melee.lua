local myModule = require(game.ReplicatedStorage.Modules.SwordStats)

local PlayerService = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")


local SwordSwing = game.ReplicatedStorage.Remotes.SwordSwing
local TrailRemote = game.ReplicatedStorage.Remotes.TrailEnabler
local Blocking = game.ReplicatedStorage.Remotes.Blocking

local Character = PlayerService.LocalPlayer.Character or PlayerService.LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local Tool = nil
local WeaponName = nil

local Storage = workspace.HitBoxes.GameHitBoxes
local SlashPart = workspace.HitBoxes.HitBoxVisuals.Slash
local HitIndication = workspace.VFXStorage.WindHit
local Shock = workspace.VFXStorage.Shockwave

local Animator = Humanoid.Animator
local AnimationCache = {}


local Combo = 0

local LastSwing = os.clock()
local IdleTimer = 2

local SwingCooldown = false


local function VFX(EnemyHRP, EnemyHumanoid, Combo)
	if EnemyHumanoid.Health ~= 0 then
		local Hit = HitIndication:Clone()
		local HitPos = EnemyHRP.CFrame
		local HitGoal = {}
		local HitInfo = TweenInfo.new(1)
		
		local Shockwave = Shock:Clone()
		--local ShockPos = EnemyHRP.CFrame*CFrame.new(0,0,-1)
		local ShockGoal = {}
		local ShockInfo = TweenInfo.new(1)
		
		Hit.CFrame = HitPos
		Hit.Parent = workspace.VFXStorage.GameVFX
		HitGoal.Size = Vector3.new(7,7,7)
		HitGoal.Transparency = 1
		
		local HitTween = TweenService:Create(Hit, HitInfo, HitGoal)
		HitTween:Play()
	
		Debris:AddItem(Hit,.5)
		--[[if Combo == 3 then
			Shockwave.CFrame = ShockPos
			Shockwave.Parent = workspace.VFXStorage.GameVFX
			HitGoal.Size = Vector3.new(7,7,7)
			HitGoal.Transparency = 1
			
			local ShockTween = TweenService:Create(Shockwave, ShockInfo, ShockGoal)
			
			ShockTween:Play()
			
			Debris:AddItem(Shockwave,.5)
		end]]
	end
end

local function SwordAttack(WeaponName, Anim, Combo) 
	
	local Randomnum = math.random(1,4)
	
	local SwordHitPart = myModule[WeaponName]["HitBoxType"]
	
	local HitBox = SwordHitPart:Clone()
	local Slash = SlashPart:Clone()
	
	local HRPCFrameOffset = HRP.CFrame*CFrame.new(0,0,-3)
	local AnglePos = {
		HRPCFrameOffset*CFrame.Angles(0,0,30),
		HRPCFrameOffset*CFrame.Angles(0,0,60),
		HRPCFrameOffset*CFrame.Angles(0,0,210),
		HRPCFrameOffset*CFrame.Angles(0,0,240)}
	local Pos = HRP.CFrame*CFrame.new(0,0,-3)
	local AnglePos = AnglePos[Randomnum]
	
	local EnemyLookVector = HRP.CFrame.LookVector
	if WeaponName == "Katana" then
		TrailRemote:FireServer(true)
	end
	
	HitBox.Parent = Storage
	Slash.Parent = Storage

	HitBox.CFrame = Pos
	Slash.CFrame = AnglePos

	Debris:AddItem(HitBox,.5)
	Debris:AddItem(Slash,.5)
	Anim:Play()
	
	local GetParts = workspace:GetPartsInPart(HitBox)
	local AlreadyDamaged = {}
	
	for i = 1, #GetParts do
		local EnemyHumanoid = GetParts[i].Parent:FindFirstChild("Humanoid")
		local EnemyRootPart = GetParts[i].Parent:FindFirstChild("HumanoidRootPart")
		
		if EnemyHumanoid and AlreadyDamaged[EnemyHumanoid] == nil and EnemyHumanoid ~= Humanoid then
			
			AlreadyDamaged[EnemyHumanoid] = true
			
			print(EnemyHumanoid)
			
			SwordSwing:FireServer(WeaponName, Combo, EnemyHumanoid, EnemyLookVector, HRP)
			VFX(EnemyRootPart, EnemyHumanoid, Combo)
		end
	end
	
end

local function ComboAttack()
	local CooldownTimer = myModule[WeaponName]["Swing"..1]["AttackSpeed"]
	if SwingCooldown == false then
		SwingCooldown = true
		if os.clock()-LastSwing >= IdleTimer then
			Combo = 0
		end	
		
		Combo += 1
		
		local AnimationID = myModule[WeaponName]["Swing"..Combo]["Animation"]
		
		local AnimationTrack = AnimationCache[WeaponName..Combo]
		
		if AnimationTrack == nil then
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://"..AnimationID
			Animation.Parent = Humanoid 
			AnimationTrack = Animator:LoadAnimation(Animation)
			AnimationCache[WeaponName..Combo] = AnimationTrack
		end
		SwordAttack(WeaponName, AnimationTrack, Combo)
		if Combo >= 3 then
			Combo = 0
		end
		LastSwing = os.clock()
		task.wait(CooldownTimer)
		SwingCooldown = false 
	end
end

local Connection = nil

local function ChildAdded(Child)
	if Child.ClassName == "Tool" then
		Tool = Child
		WeaponName = Child.Name
		if Connection ~= nil then
			Connection:Disconnect()
		end
		Connection = Tool.Activated:Connect(ComboAttack)
	end
end
Character.ChildAdded:Connect(ChildAdded)
