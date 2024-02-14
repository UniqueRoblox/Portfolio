local myModule = require(game.ReplicatedStorage.Modules.SwordStats)

local x = 3000
local SwordSwing = game.ReplicatedStorage.Remotes.SwordSwing
local TrailEnabler = game.ReplicatedStorage.Remotes.TrailEnabler

local HasDebuff = {}

local IsBlocking = false
local BlockNum = nil

local function Blocking(BlockBool)
	
	IsBlocking = BlockBool
	if IsBlocking == true then
		BlockNum = 2
	elseif IsBlocking == false then
		BlockNum = nil
	end
	
end
SwordSwing.OnServerEvent:Connect(Blocking)

local function ATKDamaged(Player, WeaponName, Combo, EnemyHumanoid, EnemyLookVector, HRP)
	
	local Damage = myModule[WeaponName]["Swing"..Combo]["Damage"]
	local Poision = myModule[WeaponName]["Swing"..Combo]["Poision"]
	local Fire = myModule[WeaponName]["Swing"..Combo]["Fire"]
	local Corrosion = myModule[WeaponName]["Swing"..Combo]["Corrosion"]
	local Knockback = myModule[WeaponName]["Swing"..Combo]["Knockback"]
	
	
	local EnemyRootPart = EnemyHumanoid.Parent:FindFirstChild("HumanoidRootPart")
	
	if EnemyHumanoid.Health ~= 0 then
		local Distance = (EnemyRootPart.position-HRP.position).Magnitude
		if Distance < 10 then
				print("Hit")
				EnemyHumanoid.Health -= Damage 
			if Knockback == true then
				EnemyRootPart:ApplyImpulse(EnemyLookVector*Vector3.new(x,0,x))
			end
			
			if Poision.DebuffDamage ~= 0 and HasDebuff[EnemyHumanoid] == nil then
				for i = 1, Poision.DebuffLength do
					HasDebuff[EnemyHumanoid] = true
					EnemyHumanoid.Health -= Poision.DebuffDamage
					print("Posioned")
					task.wait(Poision.DebuffSpeed)
					if i == Poision.DebuffLength then
						print("Is Not Poisioned")
						HasDebuff[EnemyHumanoid] = nil
					end
				end
			end
			
			if Fire.DebuffDamage ~= 0 and HasDebuff[EnemyHumanoid] == nil then
				for i = 1, Fire.DebuffLength do
					HasDebuff[EnemyHumanoid] = true
					EnemyHumanoid.Health -= Fire.DebuffDamage
					print("Is On Fire")
					task.wait(Fire.DebuffSpeed)
					if i == Fire.DebuffLength then
						print("Is Not On Fire")
						HasDebuff[EnemyHumanoid] = nil
					end
				end
			end
			
			if Corrosion.DebuffDamage ~= 0 and HasDebuff[EnemyHumanoid] == nil then
				for i = 1, Corrosion.DebuffLength do
					HasDebuff[EnemyHumanoid] = true
					EnemyHumanoid.Health -= Corrosion.DebuffDamage
					print("Corrosion")
					task.wait(Corrosion.DebuffSpeed)
					if i == Corrosion.DebuffLength then
						print("Is Not Corroding")
						HasDebuff[EnemyHumanoid] = nil
					end
				end
			end
			
		end
	end
end
SwordSwing.OnServerEvent:Connect(ATKDamaged)
local function Trail(Player, Bool)
	local Trail = Player.Character.Katana.Handle.Trail
	Trail.Enabled = Bool
	task.wait(1)
	Trail.Enabled = false
end
TrailEnabler.OnServerEvent:Connect(Trail)
