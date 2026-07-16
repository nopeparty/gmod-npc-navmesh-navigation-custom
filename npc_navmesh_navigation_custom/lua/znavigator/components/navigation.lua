--================================================================--
-- ZNavigator
-- components/navigation.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Pathfinder = ZNavigator.Services.Pathfinder

local Navigation = Component:Extend("Navigation")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Navigation:Initialize()

    self.RepathCooldown = 0.25
    self.NextRepath = 0

end

----------------------------------------------------------
-- Components
----------------------------------------------------------

function Navigation:GetGoal()

    return self:GetNavigator():GetComponent("Goal")

end

function Navigation:GetPath()

    return self:GetNavigator():GetComponent("Path")

end

function Navigation:GetWaypoint()

    return self:GetNavigator():GetComponent("Waypoint")

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Navigation:Update()

    if CurTime() < self.NextRepath then
        return
    end

    local goal = self:GetGoal()

    if not goal or not goal:IsDirty() then
        return
    end

    local position = goal:GetPosition()

    if not position then
        return
    end

    local npc = self:GetEntity()

    if not IsValid(npc) then
        return
    end

    self.NextRepath = CurTime() + self.RepathCooldown

    local ok, result = Pathfinder.Find(
        npc:GetPos(),
        position
    )

    local path = self:GetPath()

    if not path then
        return
    end

    if not ok then

        path:ComputeFailed()

        goal:Clean()

        return

    end

    path:ComputeFinished(

        result.Points,

        result.Areas

    )

    local waypoint = self:GetWaypoint()

    if waypoint then

        waypoint:Build()

    end

    goal:Clean()

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Navigation = Navigation

return Navigation
