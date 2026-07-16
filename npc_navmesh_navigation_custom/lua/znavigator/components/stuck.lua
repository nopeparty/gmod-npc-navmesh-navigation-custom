--================================================================--
-- ZNavigator
-- components/stuck.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Stuck = Component:Extend("Stuck")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Stuck:Initialize()

    self.LastPosition = vector_origin

    self.LastMoveTime = CurTime()

    self.StuckTime = 1.5
    self.MoveThreshold = 8

    self.RecoveryCount = 0
    self.MaxRecoveries = 5

    self.IsCurrentlyStuck = false

end

----------------------------------------------------------
-- Components
----------------------------------------------------------

function Stuck:GetRuntime()

    return self:GetNavigator():GetComponent("Runtime")

end

function Stuck:GetMovement()

    return self:GetNavigator():GetComponent("Movement")

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Stuck:HasMoved()

    local runtime = self:GetRuntime()

    if not runtime then
        return false
    end

    local moved = runtime:GetPosition():DistToSqr(self.LastPosition)

    return moved >= (self.MoveThreshold * self.MoveThreshold)

end

----------------------------------------------------------
-- Check
----------------------------------------------------------

function Stuck:IsStuck()

    local runtime = self:GetRuntime()

    if not runtime then
        return false
    end

    if not runtime:IsOnGround() then
        return false
    end

    if self:HasMoved() then

        self.LastPosition = runtime:GetPosition()
        self.LastMoveTime = CurTime()

        self.IsCurrentlyStuck = false

        return false

    end

    if CurTime() - self.LastMoveTime >= self.StuckTime then

        self.IsCurrentlyStuck = true

        return true

    end

    return false

end

----------------------------------------------------------
-- Recover
----------------------------------------------------------

function Stuck:Recover()

    local ent = self:GetEntity()

    if not IsValid(ent) then
        return false
    end

    local runtime = self:GetRuntime()

    if not runtime then
        return false
    end

    self.RecoveryCount = self.RecoveryCount + 1

    local velocity =
        runtime:GetForward() * -120

    velocity.z = 180

    ent:SetVelocity(velocity)

    self.LastMoveTime = CurTime()
    self.LastPosition = runtime:GetPosition()

    self:GetNavigator():Fire(
        "Stuck",
        self.RecoveryCount
    )

    return true

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Stuck:Update()

    if not self:IsStuck() then
        return
    end

    if self.RecoveryCount >= self.MaxRecoveries then

        local navigator = self:GetNavigator()

        navigator:Fire("NavigationFailed")

        if navigator.FSM then
            navigator:TrySetState("Failed")
        end

        return

    end

    self:Recover()

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Stuck:IsRecovering()

    return self.IsCurrentlyStuck

end

function Stuck:GetRecoveryCount()

    return self.RecoveryCount

end

----------------------------------------------------------
-- Settings
----------------------------------------------------------

function Stuck:SetTimeout(time)

    self.StuckTime = time

end

function Stuck:SetThreshold(distance)

    self.MoveThreshold = distance

end

function Stuck:SetMaxRecoveries(count)

    self.MaxRecoveries = count

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Stuck:Reset()

    self.LastPosition = vector_origin

    self.LastMoveTime = CurTime()

    self.RecoveryCount = 0

    self.IsCurrentlyStuck = false

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Stuck:Dump()

    print("========= Stuck =========")

    print("IsStuck    :", self.IsCurrentlyStuck)
    print("Recoveries :", self.RecoveryCount)
    print("Timeout    :", self.StuckTime)
    print("Threshold  :", self.MoveThreshold)

    print("=========================")

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Stuck = Stuck

return Stuck