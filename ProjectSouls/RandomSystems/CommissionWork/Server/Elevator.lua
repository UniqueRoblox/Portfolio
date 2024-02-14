--[[
Made in combination with someone else added onto there code
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local SafeTeleport = require(ServerScriptService.SafeTeleport)

local ElevatorRemote = ReplicatedStorage.Remotes.Elevator
local LeftRemote = ReplicatedStorage.Remotes.Leave
local ElevatorMove = ReplicatedStorage.MovingElevator

local camera = workspace.CurrentCamera

local elevators = workspace.Teleporters

local MaxTime = 20

local Countdown = false

local Teleporters = {}


local function Setup(Teleporter)
	local Gui = Teleporter.Screen.SurfaceGui
	Teleporters[Teleporter]["Queue"] = {}
	Gui.Title.Text = 0 .. "/" .. 4 .. " Players"
	Gui.Status.Text = "Waiting..."
end


local function TeleportPlayers(Teleporter)
	local Queue = Teleporters[Teleporter]["Queue"]

	local placeId = Teleporters[Teleporter]["SelectedMap"]
	local server = TeleportService:ReserveServer(placeId)
	local options = Instance.new("TeleportOptions")
	options.ReservedServerAccessCode = server
	SafeTeleport(placeId, Queue, options)
	print("Finished Teleport")
end


local function MoveElevator(Teleporter)
	local Queue = Teleporters[Teleporter]["Queue"]
	local Gui = Teleporter.Screen.SurfaceGui
	
	local prismatic = Teleporter.Shaft.PrismaticConstraint
	for i, Player in Queue do
		ElevatorMove:FireClient(Player)
	end
	Gui.Status.Text = "Teleporting Players..."
	prismatic.TargetPosition = -20
	TeleportPlayers(Teleporter)
	task.defer(function()
		task.wait(10)
		prismatic.TargetPosition = 0
		task.wait(8)
		Setup(Teleporter)
	end)
end


local function RunCountdown(Teleporter)
	Countdown = true
	
	local Gui = Teleporter.Screen.SurfaceGui
	task.defer(function()
		for i=10, 1, -1 do
			local Queue = Teleporters[Teleporter]["Queue"]
			if #Queue == 0 then
				Countdown = false
				--Setup(Teleporter)
				return
			end
			Gui.Status.Text = "Starting in: " .. i
			task.wait(1)
		end
		if Teleporters[Teleporter]["SelectedMap"] ~= nil then
			MoveElevator(Teleporter)
		else
			for i, Player in Teleporters[Teleporter]["Queue"] do
				local Character = Player.Character
				Character.PrimaryPart.CFrame = Teleporter.TeleportOut.CFrame
				LeftRemote:FireClient(Player)
			end
			Setup(Teleporter)
		end

	end)
end


local function StartElevator(Humanoid, Teleporter)
	local prismatic = Teleporter.Shaft.PrismaticConstraint
	local Gui = Teleporter.Screen.SurfaceGui
	local Queue = Teleporters[Teleporter]["Queue"]
	local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)
		
	for i, QueuePlayers in Queue do
		if Player == QueuePlayers then
			return
		end
	end
	
	if #Queue <= 4 then
		if #Queue == 0 then
			RunCountdown(Teleporter)
			ElevatorRemote:FireClient(Player, true, Teleporter)
		elseif #Queue > 0 then
			ElevatorRemote:FireClient(Player, false, Teleporter)
		end
		table.insert(Queue, Player)
		Player.Character.PrimaryPart.CFrame = Teleporter.TeleportIn.CFrame
		
		Gui.Title.Text = #Queue .. "/" .. 4 .. " Players"
	end
end


local function LeftTeleporter(Player, Teleporter)
	local Queue = Teleporters[Teleporter]["Queue"]
	local Gui = Teleporter.Screen.SurfaceGui
	
	if Player == Queue[1] then
		for i, Player in Queue do
			local Character = Player.Character
			Character.PrimaryPart.CFrame = Teleporter.TeleportOut.CFrame
			print("Ran")
		end
		Queue = {}
		Gui.Title.Text = 0 .. "/" .. 4 .. " Players"
		Setup(Teleporter)
		return
	end
	
	local FindPlayer = table.find(Queue, Player)
	
	print(FindPlayer, Player)
	
	table.remove(Queue, FindPlayer)
	
	Player.Character.PrimaryPart.CFrame = Teleporter.TeleportOut.CFrame
	Gui.Title.Text = #Queue .. "/" .. 4 .. " Players"
end

LeftRemote.OnServerEvent:Connect(LeftTeleporter)


for i, Teleporter in elevators:GetChildren() do
	
	Teleporters[Teleporter] = {}
	Teleporters[Teleporter]["Queue"] = {}
	Teleporters[Teleporter]["Time"] = {}
	--Teleporters[Teleporter]["SelectedMap"] = nil
	
	
	Teleporter.Entrance.Touched:Connect(function(OtherPart)
		local Humanoid = OtherPart.Parent:FindFirstChild("Humanoid") or OtherPart.Parent.Parent:FindFirstChild("Humanoid")
		if Humanoid then
			
			StartElevator(Humanoid, Teleporter)
		end
	end)
end


local function TeleportID(Player, Teleporter, ID)
	print(Teleporter)
	Teleporters[Teleporter]["SelectedMap"] = ID
end

ElevatorRemote.OnServerEvent:Connect(TeleportID)
