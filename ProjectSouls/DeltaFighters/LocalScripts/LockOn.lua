local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Utility = require(ReplicatedStorage.Modules.NikoModules.Utility)
local PlayerData = require(ReplicatedStorage.Modules.WeevesModules.PlayerData)
local Config = require(script:WaitForChild("Config"))

local SetDataRemote = ReplicatedStorage.Remotes.SetData

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChild("Humanoid")
local HRP = Character:FindFirstChild("HumanoidRootPart")

local Connections = {}

local Camera = workspace.Camera

local SinValue = 0

local Data = PlayerData.GetData(LocalPlayer)

local SFX = Config["SFX"]
local CameraConfig = Config["Camera"]

local function ResetData()
	Camera.CameraType = Enum.CameraType.Custom
	SetDataRemote:FireServer()
	Data.Target.Parent.Lockon:Destroy()
	Utility.DisconnectAll(Connections)
	Data.Target = nil
	Connections = {}
	Humanoid.AutoRotate = true
end


local function LockOn(Input, GameInput)
	if GameInput or Data.Character == "None" then
		return
	end

	if Input.UserInputType == Enum.UserInputType.MouseButton3 or Input.KeyCode == Enum.KeyCode.L then -- lock on
		local MousePos, Result = Utility.GetMousePosition()
		if Result then
			local EnemyHumanoid = Result.Instance.Parent:FindFirstChild("Humanoid") or Result.Instance.Parent.Parent:FindFirstChild("Humanoid")
			if EnemyHumanoid and EnemyHumanoid ~= Humanoid then
				if not Data.Target then
					local EnemyCharacter = EnemyHumanoid.Parent
					local EnemyHRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")

					Data.Target = EnemyHRP
					SetDataRemote:FireServer(EnemyHRP)

					local Highlighter = Config["Highlighter"]:Clone()
					Highlighter.Parent = Data.Target.Parent

					SFX["LockOn"]:Play()

					Connections[1+#Connections] = EnemyHumanoid.Died:Once(ResetData)
					Connections[1+#Connections] = Humanoid.Died:Once(ResetData)

					Camera.CameraType = Enum.CameraType.Scriptable 
					Humanoid.AutoRotate = false

					while true do	
						local DeltaTime = task.wait()
						
						if Data.Target == nil then break end

						local Origin = HRP.CFrame * CameraConfig["CameraOffset"] -- Sets origin of camera + some offset to make it to the side
						local Goal = CFrame.lookAt(Origin, Data.Target.Position)
						local MoveDirection = Humanoid.MoveDirection

						SinValue += 1
						Camera.CFrame = Camera.CFrame:Lerp(
							Goal * 
								CFrame.Angles(math.sin(SinValue/CameraConfig["CameraSwaySpeed"])/CameraConfig["CameraSwayIntensity"],0,0) * -- Rotates camera up and down (Could make it stronger based on speed)
								
								CFrame.Angles(0,0,-math.rad(MoveDirection.X*CameraConfig["CameraTiltIntensity"])), -- Rotates camera left->right based on the movedirection
							.1
						)
						HRP.CFrame = CFrame.lookAt(HRP.Position, Vector3.new(EnemyHRP.Position.X, HRP.Position.Y, EnemyHRP.Position.Z))
					end
				end
			end
		end

		if Data.Target ~= nil then
			SFX["Delock"]:Play()
			SinValue = 0
			ResetData()
		end
	end
end

UserInput.InputBegan:Connect(LockOn)
