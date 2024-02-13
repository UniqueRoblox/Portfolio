local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Utility = require(ReplicatedStorage.Modules.NikoModules.Utility)
local PlayerData = require(ReplicatedStorage.Modules.WeevesModules.PlayerData)
local StateManager = require(ReplicatedStorage.Modules.NikoModules.StateManager)
local Config = require(script.TeleportConfig)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChild("Humanoid")
local HRP = Character:FindFirstChild("HumanoidRootPart")

local Data = PlayerData.GetData(LocalPlayer)

local OnCooldown = false

local function Teleport(Input, GameInput)
	if GameInput or Data.Character == "None" then
		return
	end
	
	if Input.KeyCode == Enum.KeyCode.R then -- Teleport

		if OnCooldown == true or Data.Stunned == true or Data.KnockedDown == true or Data.Blocking == true or Data.ActiveAbility == true or Data.IsAttacking == true or Data.Mana < Config["ManaCost"] then
			return
		end
		OnCooldown = true
		
		Data.Mana -= Config["ManaCost"]
		
		StateManager.InAction(Humanoid, Config["InActionTime"], Data)
		StateManager.ActionTaken(LocalPlayer, Humanoid, Config["ActionTakenTime"], Data)
		
		local HRPPos = HRP.Position
		local LockedOnTarget = Data.Target
		
		
		if LockedOnTarget then
			local TargetPos = LockedOnTarget.Position
			local TeleportMagnitude = (Vector3.new(HRPPos.X, 0, HRPPos.Z) - Vector3.new(TargetPos.X, 0, TargetPos.Z)).Magnitude
			
			local TeleportPosition = CFrame.lookAt(HRP.Position, LockedOnTarget.Position) + HRP.CFrame.LookVector*(TeleportMagnitude-Config["Offset"])
			
			if TeleportMagnitude >= Config["MaxRange"] then
				TeleportPosition = CFrame.lookAt(HRP.Position, LockedOnTarget.Position) + HRP.CFrame.LookVector*(Config["MaxRange"]-Config["Offset"])
			end

			HRP.CFrame = TeleportPosition
		else
			local MousePos, Result = Utility.GetMousePosition()
			
			if Result then
				HRP.CFrame = CFrame.lookAt(HRPPos, Vector3.new(MousePos.X, HRPPos.Y, MousePos.Z))

				local TeleportMagnitude = (Vector3.new(HRPPos.X, 0, HRPPos.Z) - Vector3.new(MousePos.X, 0, MousePos.Z)).Magnitude
				local TeleportPostion = HRP.CFrame.LookVector*(TeleportMagnitude)
				
				if TeleportMagnitude >= Config["MaxRange"]-Config["Offset"] then
					TeleportPostion = HRP.CFrame.LookVector*(Config["MaxRange"]-Config["Offset"])
				end
				
				HRP.CFrame = HRP.CFrame + TeleportPostion
			end
		end
		
		task.wait(Config["Cooldown"])
		OnCooldown = false
	end
end

UserInput.InputBegan:Connect(Teleport)
