local Module = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStore = game:GetService("DataStoreService")

local EnemyStats = require(ReplicatedStorage.Module.Configs.EnemyStats)
local TowerStats = require(ReplicatedStorage.Module.Configs.TowerStats)

local UpdateRemote = ReplicatedStorage.Remote.EnemyUpdate


local EnemyDataBase = {}
--[[Data in table
{
	Enemy = {
	"Health" = num
	"Speed" = num
	"Total Alpha" = num
	}
}]]

Module.Get = function(Enemy)
	if Enemy == nil then
		return nil
	end
	while EnemyDataBase[Enemy] == nil do
		task.wait(.5)
		print("Yielding for",Enemy.Name,"Data")
	end
	return EnemyDataBase[Enemy]
end

Module.Set = function(Enemy, Property, Value, DontReplicate)
	if type(Value) == "table" then
		EnemyDataBase[Enemy][Property] = table.clone(Value)
	else
		EnemyDataBase[Enemy][Property] = Value
	end
	if RunService:IsServer() and not DontReplicate then
		Module.Replicate(Enemy)
	end
end


Module.Replicate = function(Enemy)
	UpdateRemote:FireAllClients(Enemy, EnemyDataBase[Enemy])
end


Module.Increment = function(Enemy, Property, Value, DontReplicate)
	local EnemyData = EnemyDataBase[Enemy]
	Module.Set(Enemy, Property, EnemyData[Property] + Value, DontReplicate)
end


Module.EnemyStatus = function(Enemy)
	
	EnemyDataBase[Enemy] = {}
	for Index, TStats in EnemyStats[Enemy.Name] do
		Module.Set(Enemy, Index, TStats)
	end
end


Module.RemoveEnemyStatus = function(Enemy)
	EnemyDataBase[Enemy] = nil

	if RunService:IsServer() then
		Module.Replicate(Enemy)
	end
end


Module.Slowness = function(Tower, Enemy, Ability)
	local TowerInfo = TowerStats[Tower.Name]
	local EnemyInfo = EnemyStats[Enemy.Name]
	local SlownessAbility = TowerInfo[Ability]["Slowness"]
	local Slowness = SlownessAbility["Slowdown Amount"]
	local Speed = EnemyInfo["Speed"]
	
	local Precentage = (1 - Slowness) * Speed
	
	if Module.Get(Enemy)["Slowed"] == false then
		
		Module.Set(Enemy, "Speed", Precentage)
		Module.Set(Enemy, "Slowed", true)
		task.defer(function()
			task.wait(SlownessAbility["Slowness Duration"])
			Module.Set(Enemy, "Speed", EnemyInfo["Speed"])
			Module.Set(Enemy, "Slowed", false)
		end)
	end
end



if RunService:IsClient() then
	local function Update(Enemy, Info)
		EnemyDataBase[Enemy] = Info
	end

	UpdateRemote.OnClientEvent:Connect(Update)

end

return Module
