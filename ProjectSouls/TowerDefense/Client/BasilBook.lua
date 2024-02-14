local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ShopModule = require(ReplicatedStorage.Module.LobbyModules:WaitForChild("ShopModule"))
local Utility = require(ReplicatedStorage.Module:WaitForChild("Utility"))
local PlayerData = require(ReplicatedStorage.Module.PlayerModules:WaitForChild("PlayerDataBase"))
local TowerStats = require(ReplicatedStorage.Module.TowerModules:WaitForChild("TowerStats"))

local EquipRemote = ReplicatedStorage.Remote.EquipRemote

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local TowerUIStorage = ReplicatedStorage.Storage.UIStorage
local TowerScreen = PlayerGui.TowerMenu
local PlayerInterfaceScreen = PlayerGui.PlayerInterface
local TowerMenu = PlayerInterfaceScreen.TowerMenu.Book
local HeroMenu = PlayerInterfaceScreen.TowerMenu.HeroBook
local Pages = TowerUIStorage.PageImages
local HeroPages = TowerUIStorage.HeroPagesImages
local BookPages = TowerUIStorage.BookPages

local UIActive = false
local ActiveInfo = false
local ActiveMoreInfo = false
local CurrentTowerInfo = nil

local InputConnection 
local EquipConnection
local MoreInfoConnection
local TowerButtonConnection = {} -- Connection Array

local PagesArray = {} -- {Page1, Page2, ..., Page7} is an array
local HeroPageArray = {} -- {HeroPage1, HeroPage2, HeroPage3, HeroPage4} Is an array
local InventoryForTowers = {} -- {Towers, Tower, Tower} Array Of Sorted Towers
local InventoryButtons = {} --{Button1, Button2, ..., Button6} Array of Buttons
local CurrentPage = 1

for i = 1, #Pages:GetChildren() do
	table.insert(PagesArray,Pages:FindFirstChild("Page"..i))
end


for i = 1, #HeroPages:GetChildren() do
	print(i)
	table.insert(HeroPageArray,HeroPages:FindFirstChild("Page"..i))
end


for i = 1, 6 do
	table.insert(InventoryButtons,BookPages:FindFirstChild("Button"..i))
end

print(HeroPageArray)

local function TowerSorter(Hero)
	local Data = PlayerData.Get(LocalPlayer)
	local Inventory = Data["TowersInventory"]
	local Equipped = Data["EquippedTowers"]
	local TowerInventoryTemp = {}
	if Hero then
		Inventory = Data["HeroTowersInventory"]
		Equipped = Data["EquippedHeroTowers"]
		print("Ran")
	end

	for i, Towers in Inventory do
		local TowerIndex = table.find(TowerInventoryTemp,Towers)
		if TowerIndex then
			continue
		end
		table.insert(TowerInventoryTemp, Towers)
	end

	for i, EquippedTower in Equipped do
		local TowerIndex = table.find(TowerInventoryTemp,EquippedTower)
		if TowerIndex then
			continue
		end
		table.insert(TowerInventoryTemp, EquippedTower)
	end
	InventoryForTowers = TowerInventoryTemp
end


local function Update(PageNumber, Hero)
	if TowerButtonConnection then
		for i, Connections in TowerButtonConnection do
			Connections:Disconnect()
		end
	end
	TowerSorter(Hero)
	CurrentPage = PageNumber
	local LastIndex = CurrentPage*6 -- Assuming 6 buttons per
	for i,Button in InventoryButtons do
		local TowerIndex = 6 - (LastIndex-i)
		local Tower = InventoryForTowers[TowerIndex]
		if TowerStats[Tower] ~= nil then
			Button.Image = TowerStats[Tower]["Tower Visuals"]["Tower Upgrade Image"]
		else
			Button.Image = "rbxassetid://"..13157549446 -- Template for Locked Tower
		end
		TowerButtonConnection[#TowerButtonConnection + 1] = Button.MouseButton1Down:Connect(function()
			if Tower ~= nil then
				local Data = PlayerData.Get(LocalPlayer)
				local Inventory = Data["TowersInventory"]

				local IsEquipped = false

				local TowerInfoFolder = TowerUIStorage.TowerInfo
				local TowerInfo = TowerInfoFolder:FindFirstChild("Info"..i)
				local TowerMenu = TowerScreen.BookPages

				if ActiveInfo == false then
					ActiveInfo = true
					CurrentTowerInfo = TowerInfo
					TowerInfo.Parent = TowerScreen.BookPages
					TowerUIStorage.Equip.Parent = TowerScreen.BookPages



				elseif ActiveInfo == true and CurrentTowerInfo == TowerScreen.BookPages:FindFirstChild("Info"..i) then
					ActiveInfo = false
					ActiveMoreInfo = false
					TowerMenu:FindFirstChild("Info"..i).Parent = TowerInfoFolder
					TowerScreen.BookPages.Equip.Parent = TowerUIStorage

					MoreInfoConnection:Disconnect()
					EquipConnection:Disconnect()
					return

				elseif ActiveInfo == true and CurrentTowerInfo ~= TowerScreen.BookPages:FindFirstChild("Info"..i) then
					EquipConnection:Disconnect()
					MoreInfoConnection:Disconnect()

					ActiveMoreInfo = false

					CurrentTowerInfo.Parent = TowerInfoFolder
					TowerInfo.Parent = TowerScreen.BookPages
					CurrentTowerInfo = TowerInfo
					print(IsEquipped)
				end

				for i, EquippedTowers in Data["EquippedTowers"] do
					if EquippedTowers == Tower then
						IsEquipped = true
						break
					else
						IsEquipped = false
					end
				end

				local PlayerEquipUi = TowerScreen.BookPages.Equip


				if IsEquipped == true then

					PlayerEquipUi.Text = "Unequip"
				elseif IsEquipped == false then
					PlayerEquipUi.Text = "Equip"
				end

				--Connects the Equip
				EquipConnection = TowerScreen.BookPages.Equip.Activated:Connect(function()
					print("Ran")
					print(IsEquipped)
					EquipRemote:FireServer(Tower)
					PlayerData.Equip(LocalPlayer, Tower, TowerStats[Tower]["IsAHero"])
					for i, EquippedTowers in Data["EquippedTowers"] do
						if EquippedTowers == Tower then
							IsEquipped = true
							break
						else
							IsEquipped = false
						end
					end

					print(IsEquipped)

					if #Data["EquippedTowers"] == 3 and IsEquipped == false then
						PlayerEquipUi.Parent = TowerUIStorage
					end

					if IsEquipped == true then
						PlayerEquipUi.Text = "Unequip"

					elseif IsEquipped == false then
						PlayerEquipUi.Text = "Equip"

					end
					print(IsEquipped)
					IsEquipped = false
					task.wait(1)
					print(PlayerData.Get(LocalPlayer))
				end)

				--Connects the MoreInfo
				MoreInfoConnection = TowerScreen.BookPages:FindFirstChild("Info"..i).MoreInfo.Activated:Connect(function()
					if ActiveMoreInfo == false then
						ActiveMoreInfo = true
						print("Opened more Info")
					elseif ActiveMoreInfo == true then
						ActiveMoreInfo = false
						print("Closed")
					end
				end)
			end
		end)
	end
end





local function BasilsNotebook(Hero)
	local PageNumber = 1
	local BookArray

	if UIActive == false then
		UIActive = true

		BookArray = PagesArray

		if Hero then
			BookArray = HeroPageArray
			print(BookArray)
		end

		Update(PageNumber, Hero)

		TowerUIStorage.BookPages.Parent = TowerScreen
		BookArray[PageNumber].Parent = TowerScreen.BookPages


		InputConnection = UserInputService.InputBegan:Connect(function(Input)
			local Page = TowerScreen.BookPages:FindFirstChild("Page"..PageNumber)
			
			if Input.KeyCode == Enum.KeyCode.E then
				if PageNumber < #BookArray then
					if CurrentTowerInfo then
						MoreInfoConnection:Disconnect()
						EquipConnection:Disconnect()
						CurrentTowerInfo.Parent = TowerUIStorage.TowerInfo
						TowerScreen.BookPages.Equip.Parent = TowerUIStorage
						MoreInfoConnection:Disconnect()
						EquipConnection:Disconnect()
						ActiveInfo = false
						CurrentTowerInfo = nil
						ActiveMoreInfo = false
					end
					Page.Parent = TowerUIStorage.PageImages
					PageNumber += 1
					BookArray[PageNumber].Parent = TowerScreen.BookPages
					Update(PageNumber)
				end
			end

			if Input.KeyCode == Enum.KeyCode.Q then
				if PageNumber > 1 then
					if CurrentTowerInfo then
						MoreInfoConnection:Disconnect()
						EquipConnection:Disconnect()
						CurrentTowerInfo.Parent = TowerUIStorage.TowerInfo
						TowerScreen.BookPages.Equip.Parent = TowerUIStorage
						MoreInfoConnection:Disconnect()
						EquipConnection:Disconnect()
						ActiveInfo = false
						CurrentTowerInfo = nil
						ActiveMoreInfo = false
					end
					Page.Parent = TowerUIStorage.PageImages
					PageNumber -= 1
					BookArray[PageNumber].Parent = TowerScreen.BookPages
					Update(PageNumber)
				end
			end
		end)


	elseif UIActive == true then
		UIActive = false
		print("Info"..CurrentPage)
		if CurrentTowerInfo then
			print("Removed1")
			CurrentTowerInfo.Parent = TowerUIStorage.TowerInfo
			TowerScreen.BookPages.Equip.Parent = TowerUIStorage
			MoreInfoConnection:Disconnect()
			EquipConnection:Disconnect()
			ActiveInfo = false
			CurrentTowerInfo = nil
			ActiveMoreInfo = false
		end

		TowerScreen.BookPages:FindFirstChild("Page"..CurrentPage).Parent = TowerUIStorage.PageImages
		TowerScreen.BookPages.Parent = TowerUIStorage



		print(TowerButtonConnection)
		for i, Connections in TowerButtonConnection do
			Connections:Disconnect()
		end
		InputConnection:Disconnect()
	end
end



TowerMenu.Activated:Connect(function()
	BasilsNotebook()
end)

HeroMenu.Activated:Connect(function()
	BasilsNotebook(true)
end)

