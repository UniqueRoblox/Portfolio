local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EnemyWaves = require(ReplicatedStorage.Module.EnemyModules.EnemyWaves)
local EnemyStats = require(ReplicatedStorage.Module.Configs.EnemyStats)
local PlayerData = require(ReplicatedStorage.Module.GameModules.PlayerData)
local GameData = require(ReplicatedStorage.Module.GameModules.GameData)
local ServerData = require(ReplicatedStorage.Module.GameModules.ServerData)

local StartRoundRemote = game.ReplicatedStorage.Remote.StartRound
local DeleteButtonRemote = game.ReplicatedStorage.Remote.DeleteButton

local GrassyLands = workspace.TowerDefense.Maps.GrassyLands
local Enemy = workspace.TowerDefense.EnemiesStorage
local ActiveEnemies = workspace.TowerDefense.ActiveEnemies

local StartButton = game.StarterGui.ScreenGui.StartButton
local BaseHealthUI = GrassyLands.Decorations.Terrain.Endpoint.Cave3.TopOfCave.HealthBar
local BaseHealth = BaseHealthUI.MaxHealth.CurrentHealth.Health

local WavesHasStarted = false

task.wait(1)
local ServerInfo = ServerData.Get()

print(ServerInfo["BaseHealth"])

BaseHealth.Text = ServerInfo["BaseHealth"].."/"..ServerInfo["BaseHealth"] -- Names the bases health
local function WaveStart()
	StartButton:Destroy()
	WavesHasStarted = true
	DeleteButtonRemote:FireAllClients()
	for Wave = 1, 6 do
		print("Wave "..Wave.." Is Starting")
		if ServerInfo["BaseHealth"] <= 0 then
			BaseHealth.Text = "Game Over"
			print("Server Game Over")
			print("Returning to Lobby")
			break
		end
		if Wave == 1 then
			EnemyWaves.Spawn(Enemy.EnemyNormal, GrassyLands, 1000, 1, "Angry") -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			print(Wave)
		elseif Wave == 2 then
			for _, Player in Players:GetChildren() do
				GameData.Increment(Player, "Money", 70)
				PlayerData.Increment(Player, "Clams", 5)
				GameData.Increment(Player, "Clams", 5)
			end	
			task.wait(5)
			EnemyWaves.Spawn(Enemy.EnemyFast, GrassyLands, 1, 2) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			EnemyWaves.Spawn(Enemy.EnemyNormal, GrassyLands, 2, 2) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			print(Wave)
		elseif Wave == 3 then
			for _, Player in Players:GetChildren() do
				GameData.Increment(Player, "Money", 110)
				PlayerData.Increment(Player, "Clams", 5)
				GameData.Increment(Player, "Clams", 5)
			end	
			task.wait(5)
			EnemyWaves.Spawn(Enemy.EnemyTank, GrassyLands, 1, 3) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			EnemyWaves.Spawn(Enemy.EnemyFast, GrassyLands, 2, 2) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			EnemyWaves.Spawn(Enemy.EnemyNormal, GrassyLands, 4, 2) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			print(Wave)
		elseif Wave == 4 then
			for _, Player in Players:GetChildren() do
				GameData.Increment(Player, "Money", 110)
				PlayerData.Increment(Player, "Clams", 5)
				GameData.Increment(Player, "Clams", 5)
			end	
			task.wait(5)
			EnemyWaves.Spawn(Enemy.EnemyTank, GrassyLands, 1, 3) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			EnemyWaves.Spawn(Enemy.EnemyFast, GrassyLands, 4, 2) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			EnemyWaves.Spawn(Enemy.EnemyNormal, GrassyLands, 1, 2) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			print(Wave)
		elseif Wave == 5 then
			for _, Player in Players:GetChildren() do
				GameData.Increment(Player, "Money", 150)
				PlayerData.Increment(Player, "Clams", 10)
				GameData.Increment(Player, "Clams", 10)
			end	
			task.wait(5)
			EnemyWaves.Spawn(Enemy.EnemyTank, GrassyLands, 6, 3) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			EnemyWaves.Spawn(Enemy.EnemyFast, GrassyLands, 4, 2) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			EnemyWaves.Spawn(Enemy.EnemyNormal, GrassyLands, 3, 2) -- EnemyType, Map, Number Of Enemies Spawned, Seconds Between Spawning
			print(Wave)
		elseif Wave == 6 then
			for _, Player in Players:GetChildren() do
				PlayerData.Increment(Player, "Clams", 30)
				GameData.Increment(Player, "Clams", 30)
			end	
			print("You Win!!!")
			print("Returning to lobby...")
			--[[
			Teleport Back To Lobby Code W.I.P
			]]
			return
		end
		
		repeat task.wait(5) until #ActiveEnemies:GetChildren() == 0 -- plays til all enemies are gone
		print("Wave "..Wave.." Has Ended")
	end
end

if WavesHasStarted == false then
	StartRoundRemote.OnServerEvent:Connect(WaveStart)
end
