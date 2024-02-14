local Module = {}


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStore = game:GetService("DataStoreService")

local TowerData = require(ReplicatedStorage.Module.TowerModules.TowerData)
local TowerStats = require(ReplicatedStorage.Module.Configs.TowerStats)

local UpdateRemote = ReplicatedStorage.Remote.GameUpdateRemote

local DefaultPlayerData = {
	Money = 7000,
	Clams = 0,
	PlacedTowers = {},
}

local PlayerDataBase = {} --[[Data in table
DefaultPlayerData = {
	Money = Num
	Clams = Num
	PlacedTowers = {NormalTowers}
}]]

Module.Get = function(Player)
	while PlayerDataBase[Player] == nil do
		task.wait(.5)
		print("Yielding for",Player.Name,"Data")
	end
	return PlayerDataBase[Player]
end

Module.Set = function(Player,Property,Value, DontReplicate)
	if type(Value) == "table" then
		PlayerDataBase[Player][Property] = table.clone(Value)
	else
		PlayerDataBase[Player][Property] = Value
	end
	if RunService:IsServer() and not DontReplicate then
		Module.Replicate(Player)
	end
end


Module.Replicate = function(Player)
	UpdateRemote:FireAllClients(Player,PlayerDataBase[Player])
end


Module.Increment = function(Player,Property,Value)
	local PlayerData = PlayerDataBase[Player]
	Module.Set(Player,Property,PlayerData[Property] + Value)
end


Module.TowerPlaced = function(Player, Tower)
	local PlacedTower = PlayerDataBase[Player]["PlacedTowers"]
	
	table.insert(PlacedTower, Tower)

	--print(PlacedTower)
	if RunService:IsServer() then
		Module.Replicate(Player)
	end
end

local function FindTower(Player, Tower)
	local PlayerData = Module.Get(Player)
	return table.find(PlayerDataBase[Player]["PlacedTowers"], Tower)
end

Module.TowerRemoved = function(Player, Tower)
	local PlacedTower = PlayerDataBase[Player]["PlacedTowers"]
	local TowerFinder = FindTower(Player, Tower)

	print(TowerFinder)
	table.remove(PlacedTower, TowerFinder)
	if RunService:IsServer() then
		Module.Replicate(Player)
	end
end

Module.TowerCap = function(Player, Tower, IsAHero)
	local TowerData = TowerStats[Tower]
	local TowerType = TowerData["Tower Name"]
	local TowerGameData = Module.Get(Player)["PlacedTowers"]
	local NumOfTowers = 0
	
	for i, Towers in TowerGameData do
		if TowerStats[Towers.Name]["Tower Name"] == TowerType then
			NumOfTowers += 1
			if NumOfTowers >= 4 and not IsAHero then
				return true
			elseif NumOfTowers >= 1 and IsAHero then
				return true
			end
		end
	end
end



if RunService:IsClient() then
	local function Update(Player, Info)
		PlayerDataBase[Player] = Info
	end
	UpdateRemote.OnClientEvent:Connect(Update)
	
end


-- PlayerAdded
if RunService:IsServer() then
	function PlayerAdded(Player)
		
		PlayerDataBase[Player] = {}
		
		for Property, Value in DefaultPlayerData do
			Module.Set(Player, Property, Value, true)
		end
		Module.Replicate(Player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)

	for _,Player in Players:GetPlayers() do
		PlayerAdded(Player)
	end
end

return Module

