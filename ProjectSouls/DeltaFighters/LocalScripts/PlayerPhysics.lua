local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KnockbackConfig = require(ReplicatedStorage.Modules.Configs.KnockbackConfig)

local StartPhysics = ReplicatedStorage.Remotes.PlayerForce

local Physics = {}

Physics.Velocity = function(TargetHRP)

	for i, Object in TargetHRP:GetChildren() do
		if Object.ClassName == "LinearVelocity" or Object.Name == "LinearAttachment" then
			Object:Destroy()
		end
	end

	local Knockback = Instance.new("LinearVelocity")
	local Attachment = Instance.new("Attachment")

	Attachment.Name = "LinearAttachment"
	Attachment.Parent = TargetHRP

	Knockback.Attachment0 = Attachment
	Knockback.Parent = TargetHRP

	return Knockback
end

Physics.StartPhysics = function(LinearVelocity, HRP, Type, Ignore)
	local Config = KnockbackConfig[Type]
	LinearVelocity.MaxForce = Config["MaxForce"]
	LinearVelocity.VectorVelocity = HRP.CFrame[Config["DirectionType"]] * Config["Direction"] * Config["Force"]
	
	--[[
	Math for knockback coming soon add here
	]]
	
	if not Ignore then
		task.delay(Config["Time"], function() task.wait(Config["Time"]) LinearVelocity:Destroy() end)
	else
		task.wait(Config.Time) LinearVelocity:Destroy() 
	end
end

if RunService:IsClient() then
	StartPhysics.OnClientEvent:Connect(Physics.StartPhysics)
end

return Physics
