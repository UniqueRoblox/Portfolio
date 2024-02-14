local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local MapConfig = require(ReplicatedStorage.Modules.Config.Maps)

local ElevatorRemote = ReplicatedStorage.Remotes.Elevator
local MovingEvent = ReplicatedStorage:WaitForChild("MovingElevator")
local LeftRemote = ReplicatedStorage.Remotes.Leave

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid")

local PlayerUi = LocalPlayer.PlayerGui
local MapSelectScreen = PlayerUi.MapSelection
local MapSelectUi = MapSelectScreen.MapSelect
local MapButtons = ReplicatedStorage.Storage.Ui.MapButton
local ExitButton = MapSelectScreen:WaitForChild("Exit")
local ScrollingFrame = MapSelectUi.ScrollingFrame

local Teleporters = workspace.Teleporters

local camera = workspace.CurrentCamera

local ExitConnect = nil


local function ClearButtons()
	for i, Button in ScrollingFrame:GetChildren() do
		if Button:IsA("GuiButton") then
			Button:Destroy()
		end
	end
end


local function CloseUi()
	if MapSelectUi.Visible == true then
		MapSelectUi.Visible = false
	end
	ExitButton.Visible = false
	MapSelectUi.Visible = false

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = LocalPlayer.Character.Humanoid
	
	ExitConnect:Disconnect()
	
	ClearButtons()
end

LeftRemote.OnClientEvent:Connect(CloseUi)

local function OpenLevels(Name, Teleporter, Data)
	ClearButtons()
	local LevelConfig = MapConfig[Name]["Levels"]
	local CompletedLevels = Data["MapsCompleted"][Name]
	for LevelName, Level in LevelConfig do
		local Button = MapButtons:Clone()
		Button.Label1.Text = Level.Text1
		Button.Label2.Text = Level.Text2
		if Data["MapsCompleted"][Name]["Levels"][LevelName] == false then
			Button.Image = "rbxassetid://"..Level.LockedImage
			print("Locked")
		else 
			Button.Activated:Connect(function()
				print("Rats")
				ElevatorRemote:FireServer(Teleporter, Level["TeleportID"])
			end)
			Button.Image = "rbxassetid://"..Level.Image
		end

		Button.Parent = ScrollingFrame
	end
end


local function OpenMapUi(FirstPlayer, Teleporter)
	local Data = ReplicatedStorage.GetData:InvokeServer()
	ExitButton.Visible = true
	
	ExitConnect = ExitButton.Activated:Once(function()
		CloseUi()
		LeftRemote:FireServer(Teleporter)
end)	
	
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = Teleporter.Camera.CFrame
	
	if not FirstPlayer then
		return
	end
	
	MapSelectUi.Visible = true
	
	for Name, Maps in MapConfig do
		local Button = MapButtons:Clone()
		local LevelConfig = MapConfig[Name]["Levels"]
		local CompletedLevels = Data["MapsCompleted"][Name]
		
		Button.Name = Name

		Button.Label1.Text = Maps.Text1
		Button.Label2.Text = Maps.Text2
	
		if Data["MapsCompleted"][Name]["Completed"] == false and Maps["UnlockedByDefault"] ~= true then
			Button.Image = "rbxassetid://"..Maps.LockedImage
		else 
			Button.Activated:Connect(function()
				OpenLevels(Name, Teleporter, Data)
			end)

			Button.Image = "rbxassetid://"..Maps.Image
		end

		Button.Parent = ScrollingFrame
	end
end

ElevatorRemote.OnClientEvent:Connect(OpenMapUi)


MovingEvent.OnClientEvent:Connect(function()
	CloseUi()
end)
