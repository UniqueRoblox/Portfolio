local Module = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStore = game:GetService("DataStoreService")

local UpdateRemote = ReplicatedStorage.Remote.UpdateRemote

local DefaultPlayerData = {
	Clams = 6000,
	Level = 1,
	Exp = 0,
	TowersInventory = {"Tower1"},
	HeroTowersInventory = {"Aubrey"},
	EquippedTowers = {"Tower1"},
	EquippedHeroTowers = {"Omori"},
	CurrentMap = {"VastForest"},
	
}

local PlayerDataBase = {} --[[Data in table
DefaultPlayerData = {
	Clams = Amount of Money,
	Level = What Level You are,
	Exp = EXP amount,
	TowersInventory = {Towers In Inventory},
	HeroTowersInventory = {Hero In Inventory},
	EquippedTowers = {Equipped Towers},
	EquippedHeroTowers = {Hero Towers},
	CurrentMap = {Maps},
	
}]]


local UpdateRemote = ReplicatedStorage.Remote.UpdateRemote

Module.Get = function(Player)
	while PlayerDataBase[Player] == nil do
		task.wait(.5)
		print("Yielding for",Player.Name,"Data")
	end
	return PlayerDataBase[Player]
end

Module.Set = function(Player,Property,Value, DontReplicate)
	PlayerDataBase[Player][Property] = Value
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


Module.TowerAdded = function(Player, Tower, HeroTower)
	if HeroTower ~= true then
		local PlayerData = PlayerDataBase[Player]["TowersInventory"]
		table.insert(PlayerData, Tower)
	elseif HeroTower == true then
		local PlayerData = PlayerDataBase[Player]["HeroTowersInventory"]
			table.insert(PlayerData, Tower)
		end
	if RunService:IsServer() then
		Module.Replicate(Player)
	end
end


if RunService:IsClient() then
	local function Update(Player, Info)
		PlayerDataBase[Player] = Info
	end
	UpdateRemote.OnClientEvent:Connect(Update)
end



--Equips Towers


local function IsEquipped(Tower,IsHero, Player)
	local PlayerData = Module.Get(Player)
	if IsHero then
		return table.find(PlayerData.EquippedHeroTowers,Tower)
	else
		return table.find(PlayerData.EquippedTowers,Tower)
	end
end


Module.Equip = function(Player, Tower, IsAHero)
	local TowerNumLocation = nil
	local PlayerData = Module.Get(Player)
	local AlreadyEquipped = false
	
	local AlreadyEquipped = IsEquipped(Tower,IsAHero, Player)
	
	local Inventory,EquippedInventory = nil,nil
	if IsAHero then
		Inventory = PlayerData.HeroTowersInventory
		EquippedInventory = PlayerData.EquippedHeroTowers
	else
		Inventory = PlayerData.TowersInventory
		EquippedInventory = PlayerData.EquippedTowers
	end

	local TowerIndex = table.find(EquippedInventory,Tower)
	if TowerIndex then -- If it exist that means its already equipped
		table.remove(EquippedInventory, TowerIndex)
		table.insert(Inventory, Tower)
	elseif #PlayerData["EquippedTowers"] < 3 then -- Tower is not equipped, so going to add it to equip table
		table.remove(Inventory, table.find(Inventory,Tower))
		table.insert(EquippedInventory, Tower)
	end
end


--Misc

Module.CurrentMap = function(Player, Map)
	local PlayerData = PlayerDataBase[Player]["CurrentMap"]
	table.insert(PlayerData, Map)
	if RunService:IsServer() then
		Module.Replicate(Player)
	end
end

if RunService:IsServer() then
	local DataBase = DataStore:GetDataStore("Player Data") 

	-- PlayerAdded
	function PlayerAdded(Player)
		local Success, PlayerData = nil,nil
		local Attempt = 0

		while not Success and Attempt <= 5 do
			Success, PlayerData = pcall(function()
				print(Player.UserId)
				--return DataBase:GetAsync(Player.UserId)
				return DataBase:GetAsync(28249453)
			end)

			if not Success then
				Attempt = Attempt + 1
				warn(PlayerData)
				task.wait(3)
			end
		end

		PlayerDataBase[Player] = {}
		for Property, Value in PlayerData do
			Module.Set(Player, Property, Value, true)
		end

		for Property, Value in DefaultPlayerData do
			if PlayerDataBase[Player][Property] == nil then
				Module.Set(Player, Property, Value, true)
			end
		end
		Module.Replicate(Player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)

	for _,Player in Players:GetPlayers() do
		PlayerAdded(Player)
	end
end


	--Player Data Store

function PlayerLeft(Player)
	local Data = nil

	local Success = nil
	local ErrorMsg = nil
	local Attempt = 1

	repeat
		Success, ErrorMsg = pcall(function()
		DataStore:SetAsync(Player.UserId, PlayerDataBase[Player])
				
	end)

		Attempt += 1
		if not Success then
			warn(ErrorMsg)
			task.wait(3)
		end
	until Success or Attempt == 5
		
	if Success then
		print("Data saved for", Player.Name)
	else
		warn("Unable To Save Data for", Player.Name)
	end

	Players.PlayerRemoving:Connect(PlayerLeft)
end


return Module
