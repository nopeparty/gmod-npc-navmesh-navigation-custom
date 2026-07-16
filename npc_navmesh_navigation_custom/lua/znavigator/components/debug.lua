--================================================================--
-- ZNavigator
-- components/debug.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Debug = Component:Extend("Debug")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Debug:Initialize()

    self.Enabled = false

    self.DrawPath = true
    self.DrawWaypoint = true
    self.DrawGoal = true
    self.DrawNavArea = false

    self.PrintState = false

    self.Duration = 0.1

end

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function Debug:SetEnabled(enabled)

    self.Enabled = enabled == true

end

function Debug:IsEnabled()

    return self.Enabled

end

----------------------------------------------------------
-- Components
----------------------------------------------------------

function Debug:GetRuntime()

    return self:GetNavigator():GetComponent("Runtime")

end

function Debug:GetGoal()

    return self:GetNavigator():GetComponent("Goal")

end

function Debug:GetPath()

    return self:GetNavigator():GetComponent("Path")

end

function Debug:GetWaypoint()

    return self:GetNavigator():GetComponent("Waypoint")

end

----------------------------------------------------------
-- Draw Goal
----------------------------------------------------------

function Debug:DrawGoalMarker()

    local goal = self:GetGoal()

    if not goal or not goal:HasGoal() then
        return
    end

    debugoverlay.Sphere(
        goal:GetPosition(),
        goal:GetReachDistance(),
        self.Duration,
        Color(255, 0, 0),
        true
    )

end

----------------------------------------------------------
-- Draw Waypoint
----------------------------------------------------------

function Debug:DrawWaypointMarker()

    local waypoint = self:GetWaypoint()

    if not waypoint or not waypoint:IsActive() then
        return
    end

    debugoverlay.Sphere(
        waypoint:GetPosition(),
        12,
        self.Duration,
        Color(255, 200, 0),
        true
    )

end

----------------------------------------------------------
-- Draw Path
----------------------------------------------------------

function Debug:DrawPathLines()

    local path = self:GetPath()

    if not path or path:IsEmpty() then
        return
    end

    path:Draw(self.Duration)

end

----------------------------------------------------------
-- Draw Nav Area
----------------------------------------------------------

function Debug:DrawCurrentArea()

    local runtime = self:GetRuntime()

    if not runtime then
        return
    end

    local area = runtime:GetNavArea()

    if area then
        area:Draw()
    end

end

----------------------------------------------------------
-- Draw Entity Info
----------------------------------------------------------

function Debug:DrawEntityInfo()

    local runtime = self:GetRuntime()

    if not runtime then
        return
    end

    local pos = runtime:GetPosition() + Vector(0, 0, 80)

    debugoverlay.Text(
        pos,
        ("State: %s\nSpeed: %.1f")
            :format(
                self:GetNavigator():GetState() or "None",
                runtime:GetSpeed()
            ),
        self.Duration
    )

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Debug:Update()

    if not self.Enabled then
        return
    end

    if self.DrawGoal then
        self:DrawGoalMarker()
    end

    if self.DrawWaypoint then
        self:DrawWaypointMarker()
    end

    if self.DrawPath then
        self:DrawPathLines()
    end

    if self.DrawNavArea then
        self:DrawCurrentArea()
    end

    if self.PrintState then
        self:DrawEntityInfo()
    end

end

----------------------------------------------------------
-- Console
----------------------------------------------------------

function Debug:Dump()

    print("========== Debug ==========")

    print("Enabled      :", self.Enabled)
    print("Draw Goal    :", self.DrawGoal)
    print("Draw Path    :", self.DrawPath)
    print("Draw Waypoint:", self.DrawWaypoint)
    print("Draw Area    :", self.DrawNavArea)

    print("===========================")

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Debug = Debug

return Debug