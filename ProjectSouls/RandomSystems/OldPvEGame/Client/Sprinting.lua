local UserInputService = game:GetService("UserInputService")
local PlayerService = game:GetService("Players")

local Character = PlayerService.LocalPlayer.Character or PlayerService.LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local function Sprint(Input)
	if Input.KeyCode == Enum.KeyCode.LeftControl then
		if Humanoid.Health > 25 then
			Humanoid.WalkSpeed = 30
		elseif Humanoid.Health < 30 then
			Humanoid.WalkSpeed = 16
		end
	end
end
UserInputService.InputBegan:Connect(Sprint)

local function Walk(Input)
	if Input.KeyCode == Enum.KeyCode.LeftControl then
		if Humanoid.Health > 30 then
			Humanoid.WalkSpeed = 16
		elseif Humanoid.Health < 30 then
			Humanoid.WalkSpeed = 9
		end
	end
end
UserInputService.InputEnded:Connect(Walk)

local function DamagedState()
	if Humanoid.Health < 30 then
		Humanoid.WalkSpeed = 9
	end
end

Humanoid:GetPropertyChangedSignal("Health"):Connect(DamagedState)
