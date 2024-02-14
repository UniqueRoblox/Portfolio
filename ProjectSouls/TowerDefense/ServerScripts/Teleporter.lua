local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTeleportRemote = ReplicatedStorage.Remote.PlayerTeleport
local LeftTeleportRemote = ReplicatedStorage.Remote.PlayerLeftTeleport

local StationPlayers = {} -- Station = {Player1, Player2, Player3} -- Is an array

local function PlayerLeft(Player,Station)
	local RemovePlayer = nil
	for i, QueuedPlayers in StationPlayers[Station] do
		if StationPlayers[Station][i] == Player then
			RemovePlayer = i
		end
	end
	table.remove(StationPlayers[Station], RemovePlayer)
	PlayerTeleportRemote:FireAllClients(Station, nil, Player)
end


LeftTeleportRemote.OnServerEvent:Connect(PlayerLeft)
	
	
local function PlayersInStation(Player, Station)
	if StationPlayers[Station] == nil then
		StationPlayers[Station] = {}
		print(StationPlayers[Station])
	end
	if #StationPlayers[Station] < 4 then
		table.insert(StationPlayers[Station], Player)
		PlayerTeleportRemote:FireAllClients(Station, Player)
	end
end

PlayerTeleportRemote.OnServerEvent:Connect(PlayersInStation)
