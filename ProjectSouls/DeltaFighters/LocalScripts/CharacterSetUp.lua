local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Utility = require(ReplicatedStorage.Modules.NikoModules.Utility)
local PlayerData = require(ReplicatedStorage.Modules.WeevesModules.PlayerData)
local MainMenu = require(ReplicatedStorage.Modules.Guis.MenuCode)

local CharacterChosenRemote = ReplicatedStorage.Remotes.CharacterChosen

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChild("Humanoid")

local GuiStorage = ReplicatedStorage.Storage.GuiStorage
local PlayerGui = LocalPlayer.PlayerGui
local CombatGui = PlayerGui:WaitForChild("CombatUI")

local Data = PlayerData.GetData(LocalPlayer)

local CurrentMelee = nil

local Connections = {}

local InputConfig = {
	["E"] = {
		Value = 1,
	},
	["Q"] = {
		Value = -1
	},
}

local function UIUpdate(Config, i)
	local x = 1
	for i, Ability in CombatGui.Abilities:GetChildren() do
		if Ability:IsA("Frame") then
			Ability:Destroy()
		end
	end
	
	for Index, Ability in Config["Abilities"][i] do
		local Frame = GuiStorage.Ability:Clone()
		
		Frame.Number.Text = x
		Frame.Parent = CombatGui.Abilities
		x += 1
	end
end


local function Abilities()
	
	for i, Connection in Connections do
		Connection:Disconnect()
	end
	Connections[LocalPlayer] = nil
	CurrentMelee = nil
	
	local x = 1
	while Data.Character == nil do
		task.wait(1)
		warn("Yielding for selection!")
		x += 1
		if x == 5 then
			warn("Something went wrong!")
			return
		end
	end
	
	local MeleeClass = require(ReplicatedStorage.Modules.Classes.Melee:FindFirstChild(Data.Character))
	local CharacterConfig = require(ReplicatedStorage.Modules.Characters[Data.Character])["Phase"..Data.Phase]
	local Config = CharacterConfig["Config"]
	
	local Animations = Config["Animations"][Humanoid.RigType]
	
	for i, Index in Animations do
		if typeof(Index) == "table" then
			for i, Animations in Index do
				Utility.AnimationLoad(Humanoid, Animations)
			end
			continue
		end
		Utility.AnimationLoad(Humanoid, Index)
	end
	
	UIUpdate(CharacterConfig, 1)
	
	if Config["Theme"] then
		Config["Theme"]:Play()
	end
	
	CurrentMelee = MeleeClass.New()
	
	Connections[#Connections+1] = UserInput.InputBegan:Connect(function(Input, GameExecution)
		if GameExecution or Data.Character == "None" or Data.Health <= 0 then return end
		
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			CurrentMelee:Swing()
		end
		
		local AbilityType = CharacterConfig["Abilities"]
		local AbilityInputData = AbilityType[AbilityGroupSelection][Input.KeyCode]
		
		if AbilityInputData then
			AbilityInputData.Use()
		end
		
		local AbilityGroupSelection = 1
		local ChangeAbilityData = InputConfig[Input.KeyCode.Name] --Dashing
		
		if ChangeAbilityData then
			AbilityGroupSelection += ChangeAbilityData["Value"]
			
			if AbilityGroupSelection > #AbilityType then AbilityGroupSelection = 1 end
			if AbilityGroupSelection < 1 then AbilityGroupSelection = #AbilityType end

			--[[
			Animation and start up code here
			]]--

			UIUpdate(CharacterConfig, AbilityGroupSelection)
		end
	end)
	
	Data.Changed:Connect(function(Index, Value)
		if Index == "Character" and Index == "None" then
			CurrentMelee = nil

			for i, Connection in Connections do
				Connection:Disconnect()
			end
			Connections[LocalPlayer] = nil
		end
	end)
end


local function Menu(Player)
	MainMenu.MenuOpen()
	
	MainMenu.CharacterSelected.Event:Connect(function(Character)
		CharacterChosenRemote:FireServer(Character, "Phase1")
	end)
end


local function StartUp()
	for i, Gui in CombatGui:GetChildren() do
		Gui:Destroy()
	end
	
	for i, Gui in GuiStorage.CombatUI:GetChildren() do
		local CloneGui = Gui:Clone()
		CloneGui.Parent = CombatGui
	end

	Menu()
end

StartUp()

local function Chosen()
	Abilities()
end

CharacterChosenRemote.OnClientEvent:Connect(Chosen)
