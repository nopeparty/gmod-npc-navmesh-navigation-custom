--================================================================--
-- ZNavigator
-- components/waypoint.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Waypoint = Component:Extend("Waypoint")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Waypoint:Initialize()

    self.Index = 1

    self.Position = nil
    self.Area = nil

    self.ReachedDistance = 32
    self.ReachedDistanceSqr = self.ReachedDistance * self.ReachedDistance

    self.Active = false

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Waypoint:GetPath()

    return self:GetNavigator():GetComponent("Path")

end

function Waypoint:GetRuntime()

    return self:GetNavigator():GetComponent("Runtime")

end

----------------------------------------------------------
-- Build
----------------------------------------------------------

function Waypoint:Build()

    local path = self:GetPath()

    if not path or path:IsEmpty() then

        self:Reset()

        return false

    end

    self.Index = path:GetCurrentIndex()

    self.Position = path:GetCurrentPoint()
    self.Area = path:GetCurrentArea()

    self.Active = self.Position ~= nil

    return self.Active

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Waypoint:Update()

    local path = self:GetPath()

    if not path then
        return
    end

    if not path:IsReady() then
        return
    end

    if self.Position ~= path:GetCurrentPoint() then

        self.Index = path:GetCurrentIndex()

        self.Position = path:GetCurrentPoint()
        self.Area = path:GetCurrentArea()

        self.Active = self.Position ~= nil

    end

end

----------------------------------------------------------
-- Advance
----------------------------------------------------------

function Waypoint:Advance()

    local path = self:GetPath()

    if not path then
        return false
    end

    if not path:Advance() then

        self.Active = false

        return false

    end

    self.Index = path:GetCurrentIndex()

    self.Position = path:GetCurrentPoint()
    self.Area = path:GetCurrentArea()

    self:GetNavigator():Fire(
        "WaypointChanged",
        self.Position,
        self.Index
    )

    return true

end

----------------------------------------------------------
-- Reach
----------------------------------------------------------

function Waypoint:IsReached()

    if not self.Active then
        return false
    end

    local runtime = self:GetRuntime()

    if not runtime then
        return false
    end

    return runtime:DistanceSqr(self.Position)
        <= self.ReachedDistanceSqr

end

----------------------------------------------------------
-- Think
----------------------------------------------------------

function Waypoint:Think()

    --print("[ZN] WaypointReached", self.Index)
	
    if not self.Active then
        return
    end

    if not self:IsReached() then
        return
    end

    self:GetNavigator():Fire(

        "WaypointReached",

        self.Position,

        self.Index

    )
	
    self:Advance()

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Waypoint:IsActive()

    return self.Active

end

function Waypoint:SetActive(state)

    self.Active = state == true

end

----------------------------------------------------------
-- Distance
----------------------------------------------------------

function Waypoint:GetDistance()

    if not self.Position then
        return math.huge
    end

    return self:GetRuntime():Distance(
        self.Position
    )

end

function Waypoint:GetDistanceSqr()

    if not self.Position then
        return math.huge
    end

    return self:GetRuntime():DistanceSqr(
        self.Position
    )

end

----------------------------------------------------------
-- Direction
----------------------------------------------------------

function Waypoint:GetDirection()

    if not self.Position then
        return vector_origin
    end

    return self:GetRuntime():Direction(
        self.Position
    )

end

----------------------------------------------------------
-- Reach Distance
----------------------------------------------------------

function Waypoint:SetReachDistance(distance)

    self.ReachedDistance = distance
    self.ReachedDistanceSqr = distance * distance

end

function Waypoint:GetReachDistance()

    return self.ReachedDistance

end

----------------------------------------------------------
-- Getters
----------------------------------------------------------

function Waypoint:GetPosition()

    return self.Position

end

function Waypoint:GetArea()

    return self.Area

end

function Waypoint:GetIndex()

    return self.Index

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Waypoint:Reset()

    self.Index = 1

    self.Position = nil
    self.Area = nil

    self.Active = false

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Waypoint:Draw(duration)

    if not self.Position then
        return
    end

    debugoverlay.Sphere(

        self.Position,

        10,

        duration or 0.1,

        Color(255, 200, 0),

        true

    )

end

function Waypoint:Dump()

    print("======= WAYPOINT =======")

    print("Index    :", self.Index)
    print("Position :", self.Position)
    print("Area     :", self.Area)
    print("Distance :", self:GetDistance())
    print("Active   :", self.Active)

    print("========================")

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Waypoint = Waypoint

return Waypoint