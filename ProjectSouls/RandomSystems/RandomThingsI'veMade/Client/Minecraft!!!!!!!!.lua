local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utilities = require(ReplicatedStorage.Utilities.Utility)

local Storage = ReplicatedStorage.Storage

local Grid = 4

local function Snap()
	local MouseHit = Utilities.GetMousePosition({Players.LocalPlayer.Character})
	
	local PosX, PosY, PosZ
	
	PosX = math.floor(MouseHit.X / Grid) * Grid
	PosY = math.floor(MouseHit.Y / Grid) * Grid
	PosZ = math.floor(MouseHit.Z / Grid) * Grid
	
	local SnapPos = Vector3.new(PosX, PosY, PosZ) + Vector3.new(2, 2, 2)
	
	return SnapPos
end

local function Place(Input, GameService)
	if GameService then
		return
	end
	
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		local SnapPos = Snap()

		local Block = Storage.Block:Clone()

		Block.CFrame = CFrame.new(SnapPos)
		Block.Parent = workspace
	end
end

UserInputService.InputBegan:Connect(Place)
