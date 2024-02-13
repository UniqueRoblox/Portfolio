local Damage = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Physics = require(ReplicatedStorage.Modules.NikoModules.PlayerPhysicsNew)
local Utility = require(ReplicatedStorage.Modules.NikoModules.Utility)
local StateManager = require(ReplicatedStorage.Modules.NikoModules.StateManager)
local PlayerData = require(ReplicatedStorage.Modules.WeevesModules.PlayerData)

Damage.TargetHit = function(Player, Target, Ability, HitNum)
	local Data = PlayerData.GetData(Player)
	local Character = Player.Character
	local HRP = Character.HumanoidRootPart

	local EnemyPlayer = Players:GetPlayerFromCharacter(Target)
	local EnemyData = Utility.GetPlayerData(Target)
	local EnemyHumanoid = Target.Humanoid
	local EnemyHRP = Target.HumanoidRootPart

	local AbilityConfig = require(ReplicatedStorage.Modules.Characters[Data.Character][Ability].Config)
	local Config = AbilityConfig["Server Configs"][HitNum]

	if not EnemyData then
		return
	end

	if not EnemyPlayer then
		EnemyHRP:SetNetworkOwner(Player)
		StateManager.Ownership(EnemyHumanoid, 3, EnemyData)
	end

	EnemyData.Health -= Config["Damage"]*EnemyData.DamageMultiplier

	for State, Duration in Config["States"] do
		if EnemyPlayer then
			State:FireClient(EnemyPlayer, Duration)
		else
			StateManager[State.Name](EnemyHumanoid, Duration, EnemyData)
		end
	end

	if Config["Knockback"] then
		local Velocity = Physics.Velocity(EnemyHRP)
		Physics.StartPhysics(Velocity, HRP, "Knockback")
	end

end

return Damage
