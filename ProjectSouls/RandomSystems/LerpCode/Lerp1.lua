--[[
This code is to help new programmers learn the concept of lerping this is not the best way to do this I know
--]]
local WayPoints = workspace.WayPoints -- Just a folder of waypoints

local Orgin = WayPoints.A -- The starting point
local EndGoal = WayPoints.B -- The end goal

local Target = workspace.Point -- The Non Transparent Part

local Alpha = 0

task.wait(.5)

while true do
    local DeltaTime = task.wait() -- 1/60th
    
    Alpha += .01 -- Alpha is a point inbetween two vectors you can look at it like a percent of the distance between them

    local NewCFrame = Orgin.CFrame:Lerp(EndGoal.CFrame, Alpha) -- Lerps the CFrame for example if you give the vectors (0,0,0) and (6,6,6) and a alpha of .5 it would return (3,3,3)

    Target.CFrame = NewCFrame -- Sets the CFrame

    if Alpha >= 1 then -- Once Alpha is at 1 breaks the loop
        break
    end
end
