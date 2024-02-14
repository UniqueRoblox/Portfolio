local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local TowerStats = require(ReplicatedStorage.Module.Configs.TowerStats)
local EmotionStats = require(ReplicatedStorage.Module.Configs.TowerEmotions)
local Utility = require(ReplicatedStorage.Module.NikoModules.Utility)
local TowerData = require(ReplicatedStorage.Module.TowerModules.TowerData)
local GameData = require(ReplicatedStorage.Module.GameModules.GameData)
local PlayerData = require(ReplicatedStorage.Module.GameModules.PlayerData)
local EnemyData = require(ReplicatedStorage.Module.EnemyModules.EnemyData)

local PlaceTowerRemote = ReplicatedStorage.Remote.PlaceTower
local SellRemote = ReplicatedStorage.Remote.SellRemote
local UpgradeRemote = ReplicatedStorage.Remote.UpgradeRemote
local UpdateRemote = ReplicatedStorage.Remote.UpdateRemote

local CurrentCamera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local PlayerScreen = PlayerGui.ScreenGui
local TowerGui = PlayerScreen.Towers
local TowerList = TowerGui.TowerList
local MoneyGUI = PlayerScreen.Money.TextLabel
local TowerGUI = ReplicatedStorage.Storage.UIStorage.PlaceHolder
local UpgradeGuiPlaceholder = ReplicatedStorage.Storage.UIStorage.PlaceHolderUpgradeUI

local MouseIgnoreParams = RaycastParams.new()

local TowerStorage = ReplicatedStorage.Storage.TowerStorage

local SelectedTower = nil
local TowerPlaced = false
local CurrentUpgradeUI = nil
local SelectedUnit = nil
local ActiveHeroMenu = false
local TowerCanceled = false
local Rotate = 0

local TowerButtons = {}

local TowerStorage = ReplicatedStorage.Storage.TowerStorage
local ActiveTower = workspace.TowerDefense.ActiveTowers
local CurrentTower = workspace.TowerDefense.SelectedTower
local Entities = workspace.Entities -- The Players in game


local function TowerPlacment()
	local NumOfTowers = 0
	
	local FindTower = TowerStorage:FindFirstChild(SelectedTower)
	local ClonedTower = FindTower:Clone()

	local CloneDesendants = ClonedTower:GetDescendants()
	local Range = TowerStats[ClonedTower.Name]["Range"]
	local IsAHero = TowerStats[ClonedTower.Name]["Is A Hero"]
	local TowerType = TowerStats[ClonedTower.Name]["Tower Name"]
	
	local TowerGameData = GameData.Get(LocalPlayer)["PlacedTowers"]
	
	if GameData.Get(LocalPlayer).Money >= TowerStats[ClonedTower.Name]["Cost"] then -- Checks if the player can buy the tower\
		ClonedTower.Parent = workspace.TowerDefense.SelectedTower
			
		for i, DummyParts in CloneDesendants do
			if DummyParts:IsA("BasePart") then
				DummyParts.CanCollide = false
			end
		end

		PlayerScreen.Towers.Visible = false -- Makes it where you can't see the tower placment UI
		PlayerScreen.TowerPlacmentInfo.Visible = true -- Makes Tower info UI appear

		while SelectedTower ~= nil do -- a while true loop
			
			if SelectedUnit ~= nil then
				SelectedUnit.TowerDefenseParts.Range.Transparency = 1
				CurrentUpgradeUI:Destroy()
				CurrentUpgradeUI = nil
				SelectedUnit = nil
			end
			
			local Ignore = {ActiveTower, Entities, CurrentTower, }
			local TowerLocation = Utility.GetMousePosition(Ignore)

			if TowerLocation then
				local TowersPlaced = workspace.TowerDefense.ActiveTowers:GetChildren()
				local CanBePlaced = true
				local TowerParts = ClonedTower.TowerDefenseParts

				-- Code Below Rotates the tower when you press R by 90 degrees
				TowerParts.HitBoxRadius.CFrame = CFrame.new(TowerLocation.Position) * CFrame.Angles(0,math.rad(Rotate),math.rad(90)) + Vector3.new(0,0.05,0)
				TowerParts.Range.Size = Vector3.new(.1,Range*2,Range*2) -- Sets the size on the range circle

				for i, Towers in TowersPlaced do 

					local ActiveTowerLocation = Towers.TowerDefenseParts.HitBoxRadius.Position
					local ClonedTowerLocation = ClonedTower.TowerDefenseParts.HitBoxRadius.Position
					local Distance = (ActiveTowerLocation - ClonedTowerLocation).Magnitude

					if Distance <= 5 then -- Prevents towers from being placed to close togeather
						CanBePlaced = false
					end
				end

				if TowerLocation.Instance.Name == "Grass" and CanBePlaced == true then
					ClonedTower.TowerDefenseParts.Range.Color = Color3.fromRGB(0, 0, 0) -- Black

					if TowerPlaced == true then -- Checks if all conditions are valid for it to be placed
						PlaceTowerRemote:FireServer(ClonedTower.TowerDefenseParts.HitBoxRadius.CFrame, ClonedTower.Name, IsAHero) -- Places the tower
						ClonedTower:Destroy()
						SelectedTower = nil
					end
				else
					ClonedTower.TowerDefenseParts.Range.Color = Color3.fromRGB(170, 0, 0) -- Red
				end

				if TowerCanceled == true then -- Checks if Q was pressed
					ClonedTower:Destroy()
					SelectedTower = nil
				end
			end
			task.wait()
		end
		Rotate = 0
		PlayerScreen.TowerPlacmentInfo.Visible = false -- Hides Tower Info Help UI
		PlayerScreen.Towers.Visible = true -- Displays tower placment options
	elseif GameData.Get(LocalPlayer)["Money"] <= TowerStats[ClonedTower.Name]["Cost"] then -- Runs if you don't have enough Money to place a tower
	end
end


local function TowerPlacementControls(Input, GameProcessed)
	if GameProcessed then -- If input was not within the game IE: Text box or pressed a UI then it doesn't run this code
		return
	end

	if SelectedTower ~= nil then

		if Input.UserInputType == Enum.UserInputType.MouseButton1 then -- Places the tower
			TowerPlaced = true
			task.wait()
			TowerPlaced = false
		end

		if Input.KeyCode == Enum.KeyCode.Q then -- Cancels tower placment
			TowerCanceled = true
			task.wait()
			TowerCanceled = false
		end

		if Input.KeyCode == Enum.KeyCode.R then -- Rotates tower
			Rotate += 90
			if Rotate == 360 then
				Rotate = 0
			end
		end
	end
end

UserInputService.InputBegan:Connect(TowerPlacementControls)


local function UpgradeTowerUi(Input, GameProcessed, IsAHero)
	if GameProcessed then
		return
	end
	
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		local ActiveTower = workspace.TowerDefense.ActiveTowers
		local BlackList = {Entities}
		local MouseLocation = Utility.GetMousePosition(BlackList)
		if MouseLocation then
			local MouseInstance = MouseLocation.Instance
			local TowerTarget = MouseInstance.Parent
			local PlacedTower = GameData.Get(LocalPlayer)["PlacedTowers"]

			if TowerTarget:IsDescendantOf(ActiveTower) and not table.find(PlacedTower, TowerTarget) then
				print(TowerTarget)
				print(PlacedTower)
				print("You Do not own this tower")
				return
			end
			
			if TowerTarget ~= SelectedUnit and SelectedUnit ~= nil  and not TowerTarget:IsDescendantOf(ActiveTower) then
				
				SelectedUnit.TowerDefenseParts.Range.Transparency = 1 
				CurrentUpgradeUI:Destroy() 
				SelectedUnit = nil 
				CurrentUpgradeUI = nil 
				return 
			end
			
			if TowerTarget and TowerTarget:IsDescendantOf(ActiveTower) and TowerTarget ~= SelectedUnit and SelectedTower == nil then -- check if its a valid tower
				local TowerDefenseParts = TowerTarget.TowerDefenseParts
				if SelectedUnit ~= nil then
					SelectedUnit.TowerDefenseParts.Range.Transparency = 1
					CurrentUpgradeUI:Destroy()
					print(TowerTarget)
				end
				
				local CurrentTowerStats = TowerStats[TowerTarget.Name]
				local TargetList = CurrentTowerStats["TargetOptions"]
				local TowerInfo = TowerData.Get(TowerTarget)
				local Target = TowerInfo["CurrentTarget"]
				
				local TowerStatsInfo = TowerStats[TowerTarget.Name]
				local UpgradeGUI = UpgradeGuiPlaceholder:Clone() 
				local TowerGuiStats = UpgradeGUI.UpgradeData
				
				UpgradeGUI.Name = TowerTarget.Name
				UpgradeGUI.Parent = PlayerScreen
				UpgradeGUI.TowerName.UnitName.Text = TowerStatsInfo["Tower Name"]
				TowerGuiStats.Unit.Image = TowerInfo["Tower Visuals"]["Tower Upgrade Image"]
				TowerGuiStats.Attack.Text = "Attack: "..TowerInfo["Attack"]
				TowerGuiStats.Range.Text = "Range: "..TowerInfo["Range"]
				TowerGuiStats.Cooldown.Text = "AttackSpeed: "..TowerInfo["Attack Speed"]
				TowerGuiStats.Level.Text = "Level ".. TowerStatsInfo["Level"]
				UpgradeGUI.Sell.Text = "Sell "..TowerStatsInfo["Sell Price"]
				UpgradeGUI.TargetName.Target.Text = TargetList[Target]
				
				if TowerStatsInfo["Next Upgrade"] ~= nil then
					UpgradeGUI.Upgrade.Text = "Upgrade "..TowerStatsInfo["Upgrade Price"]
				else
					UpgradeGUI.Upgrade.Text = "Max level"
				end
				TowerDefenseParts.Range.Transparency = .8
				
				CurrentUpgradeUI = UpgradeGUI
				print(TowerTarget)
				SelectedUnit = TowerTarget
				
				
				local Range = SelectedUnit.TowerDefenseParts.Range
				
				CurrentUpgradeUI.TargetButton.Activated:Connect(function() -- Targetting Button connection
					local CurrentTowerStats = TowerStats[TowerTarget.Name]
					local TargetList = CurrentTowerStats["TargetOptions"]
					local Target = TowerData.Get(TowerTarget)["CurrentTarget"]
					
					if Target == #TargetList then
						Target = TowerData.Set(TowerTarget, "CurrentTarget", 1)
						print(TargetList[Target])
						UpgradeGUI.TargetName.Target.Text = TargetList[Target]
						return
					end
					
					Target = TowerData.Set(TowerTarget, "CurrentTarget", Target+1)
					
					print(TargetList[Target])
					
					UpgradeGUI.TargetName.Target.Text = TargetList[Target]
					
				end)
				CurrentUpgradeUI.Sell.Activated:Connect(function()
					local i = 0
					local TowerType = TowerStats[SelectedUnit.Name]["Tower Name"]
					
					SellRemote:FireServer(SelectedUnit.Name, SelectedUnit)
					Range.Transparency = 1
					CurrentUpgradeUI:Destroy()
					CurrentUpgradeUI = nil
					SelectedUnit = nil
				end)
				CurrentUpgradeUI.Upgrade.Activated:Connect(function()
						
					if TowerStatsInfo["Next Upgrade"] ~= nil and GameData.Get(LocalPlayer)["Money"] >= TowerStats[SelectedUnit.Name]["Upgrade Price"] then
						local Range = SelectedUnit.TowerDefenseParts.Range
						
						UpgradeRemote:FireServer(SelectedUnit, SelectedUnit.TowerDefenseParts.HitBoxRadius.CFrame)
						
						
						print("Upgraded")
						SelectedUnit.TowerDefenseParts.Range.Transparency = 1
						SelectedUnit:Destroy()
						CurrentUpgradeUI:Destroy()
						CurrentUpgradeUI = nil
						SelectedUnit = nil
					end
				end)
			end
		elseif SelectedUnit ~= nil then
			CurrentUpgradeUI:Destroy()
			SelectedUnit.TowerDefenseParts.Range.Transparency = 1
			CurrentUpgradeUI = nil
			SelectedUnit = nil
		end
	end
end

UserInputService.InputBegan:Connect(UpgradeTowerUi)


local function TowersLayout(Input, GameProcessed)
	if GameProcessed then
		return
	end

	local ActiveTowers = nil

	if Input.KeyCode == Enum.KeyCode.X then
		if ActiveHeroMenu == true then
			ActiveTowers = PlayerData.Get(LocalPlayer)["EquippedTowers"]
			ActiveHeroMenu = false
			TowerGui.TextLabel.Text = "Towers"
			print(ActiveHeroMenu)
		elseif ActiveHeroMenu == false then
			ActiveTowers = PlayerData.Get(LocalPlayer)["EquippedHeroTowers"]
			TowerGui.TextLabel.Text = "Boss Towers"
			ActiveHeroMenu = true
			print(ActiveHeroMenu)
		end

		for i, Tower in TowerList:GetChildren() do
			if Tower:IsA("ImageButton") then
				Tower:Destroy()
			end
		end

		for i, Connections in TowerButtons do
			Connections:Disconnect()
		end

		for i, Tower in ActiveTowers do
			local Button = TowerGUI:Clone() -- Clones the placeholder GUI
			print(Tower)
			Button.Name = TowerStats[Tower]["Tower Name"]
			Button.Parent = TowerList -- Creates the UI on screen
			Button.TowerName.Text = TowerStats[Tower]["Tower Name"]
			Button.Image = TowerStats[Tower]["Tower Visuals"]["Tower Selection Image"]

			TowerButtons[#TowerButtons + 1] = Button.Activated:Connect(function(Hit)
				local IsAHero = TowerStats[Tower]["Is A Hero"]
				local IsCapped = GameData.TowerCap(LocalPlayer, Tower, IsAHero)

				if IsCapped == true then
					return
				end
				local TowerType = TowerStats[Tower]["Tower Name"]
				print(Tower)
				SelectedTower = Tower
				TowerPlacment()
			end)
		end
	end
end

UserInputService.InputBegan:Connect(TowersLayout)

for i, Tower in PlayerData.Get(LocalPlayer)["EquippedTowers"] do
	local Button = TowerGUI:Clone() -- Clones the placeholder GUI
	print(Tower)
	Button.Name = TowerStats[Tower]["Tower Name"]
	Button.Parent = TowerList -- Creates the UI on screen
	Button.TowerName.Text = TowerStats[Tower]["Tower Name"]
	Button.Image = TowerStats[Tower]["Tower Visuals"]["Tower Selection Image"]

	TowerButtons[#TowerButtons + 1] = Button.Activated:Connect(function(Hit)
		local IsAHero = TowerStats[Tower]["Is A Hero"]
		local IsCapped = GameData.TowerCap(LocalPlayer, Tower, IsAHero)

		if IsCapped == true then
			return
		end
		
		local TowerType = TowerStats[Tower]["Tower Name"]
		SelectedTower = Tower
		print(Tower)
		TowerPlacment(Tower)
	end)
end
