--[[
This code is to help new programmers learn the concept of lerping this is not the best way to do this I know
--]]

local WayPoints = workspace.WayPoints

local PartA = WayPoints.A
local PartB = WayPoints.B
local PartC = WayPoints.C
local PartD = WayPoints.D

local RatPart = workspace.Point

local Alpha = 0

local Array = {PartA, PartB, PartC, PartD}

local NewValue = nil


while true do
    for Index, Value in Array do
        
        while true do
            local DeltaTime = task.wait() -- 1/60th
            
            local CurrentValue = Index
            
            if not Array[Index+1] then
                CurrentValue = 0
            end
            
            Alpha += .01

            local NewCFrame = Value.CFrame:Lerp(Array[CurrentValue+1].CFrame, Alpha)

            workspace.Point.CFrame = NewCFrame

            if Alpha >= 1 then
                Alpha = 0
                break
            end
        end
        
    end
end
