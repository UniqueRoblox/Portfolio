local MainMenu = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

local PlayerGui = LocalPlayer.PlayerGui
local Menu = PlayerGui.Menu
local UniverseSelect = Menu.UniverseSelection
local Catagories = UniverseSelect.Catagories

local Config = require(Menu.Config.MenuConfig)

local Button = ReplicatedStorage.Storage.GuiStorage.MenuButton

MainMenu.CharacterSelected = Instance.new("BindableEvent")

local function CreateButton(Name)
	local ButtonClone = Button:Clone()
	
	ButtonClone.Name = Name
	ButtonClone.Text = Name
	ButtonClone.Parent = Catagories

	return ButtonClone
end


local function Reset()
	for i, v in Catagories:GetChildren() do
		if v:IsA("GuiButton") then
			v:Destroy()
		end
	end
end


local function CharacterSelect(Config)
	for _, Character in Config do
		local ButtonClone = CreateButton(Character)
		
		ButtonClone.Activated:Connect(function()
			MainMenu.CharacterSelected:Fire(ButtonClone.Name)
			Menu.Enabled = false
			Reset()
		end)
	end
	local BackButton = CreateButton("Back")
	
	BackButton.Activated:Connect(function()
		Reset()
		MainMenu.MenuOpen()
	end)
end

MainMenu.MenuOpen = function()
	Menu.Enabled = true
	for CatagoryName, Table in Config do
		local ButtonClone = CreateButton(CatagoryName)

		ButtonClone.Activated:Connect(function()
			Reset()
			CharacterSelect(Table)
		end)
	end
end

return MainMenu
