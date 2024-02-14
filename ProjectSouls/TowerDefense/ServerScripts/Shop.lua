local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopModule = require(ReplicatedStorage.Module.LobbyModules.ShopModule)
local PlayerData = require(ReplicatedStorage.Module.PlayerModules.PlayerDataBase)

local TowerBoughtRemote = ReplicatedStorage.Remote.TowerBought

local function BuyTower(Player, Shop)
	local TowerGatchaRoll = ShopModule[Shop]["Towers"]
	local HeroGatchaRoll = ShopModule[Shop]["HeroTowers"]
	local IsAHero = false
	local RandomTowerPrecent = {}
	
	if PlayerData.Get(Player)["Clams"] >= ShopModule[Shop]["Cost"] then
		if ShopModule[Shop]["Level"] <= PlayerData.Get(Player)["Level"] then
			PlayerData.Increment(Player, "Clams", -ShopModule[Shop]["Cost"])
			
			for Tower, Chance in TowerGatchaRoll do
				for i = 1,Chance do
					table.insert(RandomTowerPrecent, Tower)
				end
			end
			local RandomTower = RandomTowerPrecent[math.random(1,100)]
			if RandomTower == "HeroTower" then
				RandomTower = HeroGatchaRoll[math.random(1,#HeroGatchaRoll)]
				IsAHero = true
			end
			PlayerData.TowerAdded(Player, RandomTower, IsAHero)
		end
	end
end

TowerBoughtRemote.OnServerEvent:Connect(BuyTower)
