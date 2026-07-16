--================================================================--
-- ZNavigator
-- components/goal.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Goal = Component:Extend("Goal")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Goal:Initialize()

    self.Position = nil
    self.NavArea = nil
    self.Entity = nil

    self.ReachDistance = 32
    self.ReachDistanceSqr = self.ReachDistance * self.ReachDistance

    self.LastUpdate = 0
    self.Dirty = false

end

----------------------------------------------------------
-- Goal
----------------------------------------------------------

function Goal:Set(position, area)

    assert(isvector(position), "Goal:Set expected Vector.")

    self.Position = position
    self.NavArea = area
    self.Entity = nil

    self.LastUpdate = CurTime()
    self.Dirty = true

    local navigator = self:GetNavigator()

    navigator:Fire("GoalChanged", position, area)

    if navigator.FSM then
        navigator:TrySetState("GoalAssigned")
    end

    return self

end

function Goal:SetEntity(ent)

    if not IsValid(ent) then
        return false
    end

    self.Entity = ent

    self:Set(ent:GetPos())

    return true

end

----------------------------------------------------------
-- Clear
----------------------------------------------------------

function Goal:Clear()

    self.Position = nil
    self.NavArea = nil
    self.Entity = nil

    self.Dirty = true

    self:GetNavigator():Fire("GoalChanged", nil)

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Goal:Update()

    if not IsValid(self.Entity) then
        return
    end

    self.Position = self.Entity:GetPos()

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Goal:HasGoal()

    return self.Position ~= nil

end

function Goal:GetPosition()

    return self.Position

end

function Goal:GetArea()

    return self.NavArea

end

function Goal:GetEntity()

    return self.Entity

end

----------------------------------------------------------
-- Reach Distance
----------------------------------------------------------

function Goal:SetReachDistance(distance)

    self.ReachDistance = distance
    self.ReachDistanceSqr = distance * distance

end

function Goal:GetReachDistance()

    return self.ReachDistance

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Goal:IsDirty()

    return self.Dirty

end

function Goal:Clean()

    self.Dirty = false

end

----------------------------------------------------------
-- Distance
----------------------------------------------------------

function Goal:GetDistance()

    if not self.Position then
        return math.huge
    end

    local runtime = self:GetNavigator():GetComponent("Runtime")

    if not runtime then
        return math.huge
    end

    return runtime:Distance(self.Position)

end

function Goal:GetDistanceSqr()

    if not self.Position then
        return math.huge
    end

    local runtime = self:GetNavigator():GetComponent("Runtime")

    if not runtime then
        return math.huge
    end

    return runtime:DistanceSqr(self.Position)

end

----------------------------------------------------------
-- Direction
----------------------------------------------------------

function Goal:GetDirection()

    if not self.Position then
        return vector_origin
    end

    local runtime = self:GetNavigator():GetComponent("Runtime")

    if not runtime then
        return vector_origin
    end

    return runtime:Direction(self.Position)

end

----------------------------------------------------------
-- Reach Check
----------------------------------------------------------

function Goal:IsReached()

    if not self.Position then
        return false
    end

    return self:GetDistanceSqr() <= self.ReachDistanceSqr

end

----------------------------------------------------------
-- Think
----------------------------------------------------------

function Goal:Think()

    if not self.Position then
        return
    end

    if self:IsReached() then

        local navigator = self:GetNavigator()

        navigator:Fire("GoalReached", self.Position)

        if navigator.FSM then
            navigator:TrySetState("Finished")
        end

    end

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Goal:Reset()

    self.Position = nil
    self.NavArea = nil
    self.Entity = nil

    self.Dirty = false

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Goal:Dump()

    print("===== Goal =====")

    print("Position :", self.Position)
    print("Area     :", self.NavArea)
    print("Distance :", self:GetDistance())

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Goal = Goal

return Goal