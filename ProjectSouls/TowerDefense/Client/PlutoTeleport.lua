local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teleport = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local Controls = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()---GetControls

local PlayerTeleportRemote = ReplicatedStorage.Remote.PlayerTeleport
local LeftTeleportRemote = ReplicatedStorage.Remote.PlayerLeftTeleport

local LocalPlayer = Players.LocalPlayer
local PlayerUi = LocalPlayer.PlayerGui
local PlayerUiScreen = PlayerUi.Effects
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid")
local HRP = Character:FindFirstChild("HumanoidRootPart")

local PlutoTeleport = workspace.TowerDefense.Lobby.PlutoMapTeleporters

local StoredUi = ReplicatedStorage.Storage.UIStorage
local SpaceUi = PlayerUiScreen.SpaceStationUI

local ActivelyTeleporting = false

local AttackConnection
local RunConnection

local PlayerGoToPart = nil

local ActiveTeleportUi = {} -- Station = bool
local PlayerCapacity = {}  --[[ Station = {
	["Player"] = Player
	["Part"] = Part
	["SlotNumber"] = x
}
]]


local function PlayerTeleport(Station)
	
	Controls:Disable()
	Humanoid:MoveTo(PlayerGoToPart.Position)
	SpaceUi.Attack.Parent = StoredUi
	Humanoid.MoveToFinished:Wait()
	
	
	local TurnGoal = {} 
	TurnGoal.CFrame = CFrame.new(PlayerGoToPart.CFrame.x, HRP.CFrame.y, PlayerGoToPart.CFrame.z)*CFrame.Angles(0,math.rad(-90),0)--HRP.CFrame.y
	local TurnTween = TweenService:Create(HRP, TweenInfo.new(.7, Enum.EasingStyle.Linear), TurnGoal)
	TurnTween:Play()
	
	
	print("You Entered the Quene")
	StoredUi.Run.Parent = SpaceUi
	
		RunConnection = SpaceUi.Run.Activated:Connect(function()
		Controls:Enable()
		print("Poggers")
		SpaceUi.Run.Parent = StoredUi
		LeftTeleportRemote:FireServer(Station)
		RunConnection:Disconnect()
		StoredUi.Attack.Parent = SpaceUi
		ActivelyTeleporting = false
	end)
end


--Replicates Table Data
local function ReplicatePlayerData(Station, PlayerJoined, PlayerLeft)
	local StationData = PlayerCapacity[Station]
	
	if PlayerJoined then
		for i = 1,4 do
			local Slot = StationData[i]

			if Slot.Player == nil then
				Slot.Player = PlayerJoined
				PlayerGoToPart = Slot.Part
				break
			end
		end
	end

	if PlayerLeft then
		for i = 1,4 do
			local Slot = StationData[i]

			if Slot.Player == PlayerLeft then
				Slot.Player = nil
				break
			end
		end
	end
	if PlayerJoined == LocalPlayer and PlayerLeft == nil then 
		PlayerTeleport(Station)
	end
end

PlayerTeleportRemote.OnClientEvent:Connect(ReplicatePlayerData)


for i, Station in PlutoTeleport:GetChildren() do
	local StationData = {}
	local StandPart = Station.StandPositions

	PlayerCapacity[Station] = StationData
	for i = 1,4 do

		StationData[i] = {
			["Player"] = nil,
			["Part"] = StandPart:FindFirstChild("Stand"..i),
			["SlotNumber"] = i,
		}
		--print(PlayerCapacity[Station][i]["Part"])
	end
end



while true do
	for _, Station in PlutoTeleport:GetChildren() do
		local PlayerDistance = (Character.HumanoidRootPart.Position - Station.Platform.Position).Magnitude
		if PlayerDistance <= 10 and ActiveTeleportUi[Station] ~= true and ActivelyTeleporting == false then
			print("In range")
			ActiveTeleportUi[Station] = true
			StoredUi.Attack.Parent = SpaceUi
			AttackConnection = SpaceUi.Attack.Activated:Connect(function()
				ActivelyTeleporting = true
				PlayerTeleportRemote:FireServer(Station)
			end)
		elseif PlayerDistance >= 10 and ActiveTeleportUi[Station] == true then
			print("Not in range")
			if ActivelyTeleporting == false then
				ActiveTeleportUi[Station] = false
				SpaceUi.Attack.Parent = StoredUi
				if AttackConnection then
					AttackConnection:Disconnect()
				end
				print("UI deleted")
			end
		end
	end
	task.wait()
end
