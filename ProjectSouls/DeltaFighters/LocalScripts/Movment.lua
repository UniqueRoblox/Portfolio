local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Utility = require(ReplicatedStorage.Modules.NikoModules.Utility)
local PlayerPhysics = require(ReplicatedStorage.Modules.NikoModules.PlayerPhysicsNew)
local ForceConfig = require(ReplicatedStorage.Modules.Configs.KnockbackConfig)
local PlayerData = require(ReplicatedStorage.Modules.WeevesModules.PlayerData)
local StateManager = require(ReplicatedStorage.Modules.NikoModules.StateManager)
local Config = require(script:WaitForChild("Configs"))

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChild("Humanoid")
local HRP = Character:FindFirstChild("HumanoidRootPart")

local SFX = ReplicatedStorage.Storage.Audio.SFX
local PlayerSFX = SFX.PlayerSFX

local Data = PlayerData.GetData(LocalPlayer)

local IsDashing = false
local Sprinting = false

local DashConfig = Config["Dash"]
local RunningConfig = Config["Running"]

local DashPress = {
	["W"] = {
		LastPressed = os.clock(),
		Name = "ForwardDash",
	},
	["A"] = {
		LastPressed = os.clock(),
		Name = "LeftDash",
	},
	["S"] = {
		LastPressed = os.clock(),
		Name = "BackDash"
	},
	["D"] = {
		LastPressed = os.clock(),
		Name = "RightDash",
	},
}


local function DirectionCheck(Bool)
	task.defer(function()
		Sprinting = true
		while true do
			local DeltaTime = task.wait()
			
			StateManager.ActionTaken(LocalPlayer, Humanoid, Config["ActionTime"], Data)
			Data.Stamina = math.clamp(Data.Stamina - RunningConfig["StaminaLoss"]*DeltaTime,0,200)
			if Bool then
				if not UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then
					Humanoid.WalkSpeed = 16
					break
				end
			end
			if Humanoid.MoveDirection == Vector3.new(0,0,0) or Data.Stamina <= 1 then
				Humanoid.WalkSpeed = 16
				break
			end
		end
		Sprinting = false
	end)
end


local function Dash(Input, GameInput)
	if GameInput or Data.Character == "None" then
		return
	end
	
	if Sprinting == true then return end
	
	local ConfigModule = require(ReplicatedStorage.Modules.Characters[Data.Character])
	local CharacterConfig = ConfigModule["Phase"..Data.Phase]["Config"]
	local AnimationConfig = CharacterConfig["Animations"][Humanoid.RigType]
	
	local InputData = DashPress[Input.KeyCode.Name] --Dashing
	if InputData then
		if os.clock() - InputData.LastPressed <= 0.2 and IsDashing == false then
			if Data.Stamina < 20 or Humanoid.WalkSpeed < 16 then return end
			IsDashing = true
			
			local KnockbackConfig = ForceConfig[InputData["Name"]]

			Utility.Animation(Humanoid, AnimationConfig["Dash"][InputData["Name"]])
			PlayerSFX.PlayerMovmentSFX.Dash:Play()

			Data.Stamina -= 20

			StateManager.InAction(Humanoid, 1.5, Data)
			StateManager.ActionTaken(LocalPlayer, Humanoid, Config["ActionTime"], Data)
			StateManager.IFrames(Humanoid, 2/60, Data)
			
			PlayerPhysics.StartPhysics(PlayerPhysics.Velocity(HRP), HRP, InputData["Name"], LocalPlayer)
			Humanoid.WalkSpeed = 34
			
			DirectionCheck()

			task.wait(KnockbackConfig["Cooldown"])
			IsDashing = false
		end
		InputData.LastPressed = os.clock()
	end
	
	if Input.KeyCode == Enum.KeyCode.LeftShift then
		DirectionCheck(true)
		Humanoid.WalkSpeed = 32
	end
end

UserInput.InputBegan:Connect(Dash)
