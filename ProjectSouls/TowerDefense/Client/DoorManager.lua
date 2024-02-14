local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teleport = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local TweenGoals = require(ReplicatedStorage.Module.NikoModules.TweenGoals)
local TweenStyle = require(ReplicatedStorage.Module.NikoModules.EasingStyle)

local LocalPlayer = Players.LocalPlayer
local PlayerUi = LocalPlayer.PlayerGui
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local Sounds = ReplicatedStorage.Storage.Sounds

local DoorUI = {}

local Camera = workspace.CurrentCamera
local UIs = ReplicatedStorage.Storage.UIStorage

local MapDoors = workspace.TowerDefense.Lobby.MapDoors
local DoorsChildren = MapDoors:GetChildren()

local function TeleportPlayer(Door)
	local Prompt = Door.Door.ProximityPrompt
	local Hinge = Door.Hinge
	local CameraParts = Door.CameraPart
	local WhiteGui = PlayerUi.Effects.White
	local CurrentSong = nil
	
	Camera.CameraType = Enum.CameraType.Scriptable
	Character.Parent = game.ServerStorage
	
	local CameraGoal1 = {}
	CameraGoal1.CFrame = CameraParts.MainCamera.CFrame
	local CameraTween = TweenService:Create(Camera, TweenInfo.new(2, Enum.EasingStyle.Linear),  CameraGoal1)
	
	CameraTween:Play()
	CameraTween.Completed:Wait(1.5)
	
	--Next Tween
	
	local DoorGoal1 = {}
	DoorGoal1.CFrame = Hinge.CFrame*CFrame.Angles(0,math.rad(-160),0)
	local DoorOpen = TweenService:Create(Hinge, TweenInfo.new(4, Enum.EasingStyle.Linear), DoorGoal1)
	DoorOpen:Play()
	
	for i, Music in Sounds.Music:GetChildren() do
		if Music.Playing == true then
			local SoundFadeOut = TweenService:Create(Music, TweenInfo.new(4, TweenStyle.Linear), TweenGoals.SoundFadeOut)
			SoundFadeOut:Play()
			CurrentSong = Music
			break
		end
	end
	
	
	DoorOpen.Completed:Wait()
	
	CurrentSong:Pause()
	CurrentSong.Volume = .5
	-- Next Tween
	
	WhiteGui.Visible = true
	
	local FadeToWhiteGoal = {}
	FadeToWhiteGoal.Transparency = 0
	local FadeToWhite = TweenService:Create(WhiteGui, TweenInfo.new(3, Enum.EasingStyle.Linear), FadeToWhiteGoal)
	FadeToWhite:Play()
	
	local CameraGoal2 = {}
	CameraGoal2.CFrame = CameraParts.EnterCamera.CFrame
	local DoorOpen = TweenService:Create(Camera, TweenInfo.new(3, Enum.EasingStyle.Linear), CameraGoal2)
	DoorOpen:Play()
	DoorOpen.Completed:Wait(1)
	
	--Next Tween
	local BackToReality = {}
	BackToReality.Transparency = 1
	local UnFadeWhite = TweenService:Create(WhiteGui, TweenInfo.new(3, Enum.EasingStyle.Linear), BackToReality)
	UnFadeWhite:Play()
	
	local DoorGoal2 = {}
	DoorGoal2.CFrame = Hinge.CFrame*CFrame.Angles(0,math.rad(160),0)
	Camera.CameraType = Enum.CameraType.Custom
	local DoorClose = TweenService:Create(Hinge, TweenInfo.new(.5, Enum.EasingStyle.Linear), DoorGoal2)
	
	DoorClose:Play()
	Door.Audio.DoorSlam:Play()

	--Tween Completed
	Camera.CameraType = Enum.CameraType.Custom
	Character.Parent = workspace.Entities
	if Door.Name == "WhiteSpaceDoor" then
		HRP.CFrame = MapDoors.HeadSpaceDoor.HeadSpaceSpawn.CFrame
		PlayerUi.Effects.VastForestLogo.Parent = PlayerUi.Effects.Area
		PlayerUi.Effects.Area.VastForestLogo.Visible = true
		--Sounds.Music
	elseif Door.Name == "HeadSpaceDoor" then
		HRP.CFrame = MapDoors.WhiteSpaceDoor.WhiteSpaceSpawn.CFrame
	end
	
	Prompt.MaxActivationDistance = 10
	
	DoorClose.Completed:Wait()
	
	
	local Logo = PlayerUi.Effects.Area:GetChildren()
	if Logo[1] then
		Logo[1].Visible = true
		local LogoGoal = {}
		LogoGoal.ImageTransparency = 0
		local LogoFadeIn = TweenService:Create(Logo[1], TweenInfo.new(2, Enum.EasingStyle.Linear), LogoGoal)
		LogoFadeIn:Play()
		
		LogoFadeIn.Completed:Wait(5)
		
		local LogoGoal2 = {}
		LogoGoal2.ImageTransparency = 1
		local LogoFadeOut = TweenService:Create(Logo[1], TweenInfo.new(2, Enum.EasingStyle.Linear), LogoGoal2)
		
		LogoFadeOut:Play()
		
		LogoFadeOut.Completed:Wait()
		Logo[1].Parent = PlayerUi.Effects
		Logo[1].Visible = false
		WhiteGui.Visible = false
	end
end


for _, Doors in DoorsChildren do
	local Prompt = Doors.Door.ProximityPrompt
	Prompt.Triggered:Connect(function()
		Prompt.MaxActivationDistance = 0
		TeleportPlayer(Doors)
	end)
end
