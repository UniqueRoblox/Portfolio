local TweenService = game:GetService("TweenService")
local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local PlayerUI = LocalPlayer:WaitForChild("PlayerGui")
local LevelUi = PlayerUI.ScreenGui.LevelGui
local DisplayText = LevelUi.Display.DisplayLevelStats
local EXPBarBack = LevelUi.Background
local ExperienceBar = EXPBarBack.CurrentLevel
local LevelDisplay = EXPBarBack.DisplayLevel


local Configs = {
	["DefaultEXP"] = 100,
	["Multiplier"] = 1.15,
	["ScrapStart"] = 3,
	["IncreaseIncerment"] = 50,
	["MaxIncermentLevel"] = 4,
}


local PlayerData = {
	["Experience"] = {
		["Level"] = 1,
		["Scrap"] = 0,
		["MaxEXP"] = Configs["DefaultEXP"],
		["CurrentEXP"] = 0,
		["ScrapPerLevel"] = Configs["ScrapStart"],
	},
}

local EXPConfig = PlayerData["Experience"]


local function Check(Index, Value)
	if Value >= EXPConfig["MaxEXP"] then
		EXPConfig["CurrentEXP"] -= EXPConfig["MaxEXP"]
		
		EXPConfig["Level"] += 1
		EXPConfig["Scrap"] += EXPConfig["ScrapPerLevel"]
		DisplayText.Text = "Current Level: "..EXPConfig["Level"]
		
		if EXPConfig["Level"] ~= Configs["MaxIncermentLevel"] then
			EXPConfig["MaxEXP"] += Configs["IncreaseIncerment"]
			EXPConfig["ScrapPerLevel"] = math.round(EXPConfig["ScrapPerLevel"] * Configs["Multiplier"])
			
			print(PlayerData)
		end
	end
end


local function Update(Index, Value)
	Check(Index, Value)
	
	if Index == "Exp" then
		print("Updating")
		ExperienceBar:TweenSize((UDim2.new(EXPConfig["CurrentEXP"]/EXPConfig["MaxEXP"],0,1,0)), Enum.EasingDirection.In, Enum.EasingStyle.Linear)
		LevelDisplay.Text = EXPConfig["CurrentEXP"].."/"..EXPConfig["MaxEXP"]
	end
end

while true do
	task.wait(1.5)
	EXPConfig["CurrentEXP"] += 50 -- Kill
	Update("Exp", EXPConfig["CurrentEXP"])
end
