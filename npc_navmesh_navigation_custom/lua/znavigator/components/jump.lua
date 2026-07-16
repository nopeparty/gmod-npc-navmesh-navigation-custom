--================================================================--
-- ZNavigator
-- components/jump.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Jump = Component:Extend("Jump")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Jump:Initialize()

    self.Enabled = true

    self.Force = 250
    self.ForwardForce = 64

    self.Cooldown = 0.5
    self.LastJump = 0

    self.MaxStepHeight = 32
    self.TraceDistance = 48

end

----------------------------------------------------------
-- Components
----------------------------------------------------------

function Jump:GetRuntime()

    return self:GetNavigator():GetComponent("Runtime")

end

function Jump:GetWaypoint()

    return self:GetNavigator():GetComponent("Waypoint")

end

----------------------------------------------------------
-- Settings
----------------------------------------------------------

function Jump:SetForce(force)

    self.Force = force

end

function Jump:SetForwardForce(force)

    self.ForwardForce = force

end

function Jump:SetCooldown(time)

    self.Cooldown = time

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Jump:CanJump()

    if not self.Enabled then
        return false
    end

    local runtime = self:GetRuntime()

    if not runtime then
        return false
    end

    if not runtime:IsOnGround() then
        return false
    end

    return CurTime() >= (self.LastJump + self.Cooldown)

end

----------------------------------------------------------
-- Obstacle Trace
----------------------------------------------------------

function Jump:ShouldJump()

    local runtime = self:GetRuntime()

    if not runtime then
        return false
    end

    local ent = self:GetEntity()

    if not IsValid(ent) then
        return false
    end

    local startPos = runtime:GetPosition() + vector_up * self.MaxStepHeight

    local endPos = startPos +
        runtime:GetForward() * self.TraceDistance

    local tr = util.TraceHull({

        start = startPos,

        endpos = endPos,

        mins = Vector(-8, -8, 0),

        maxs = Vector(8, 8, 32),

        filter = ent,

        mask = MASK_NPCSOLID

    })

    return tr.Hit

end

----------------------------------------------------------
-- Execute
----------------------------------------------------------

function Jump:Execute()

    if not self:CanJump() then
        return false
    end

    local ent = self:GetEntity()

    if not IsValid(ent) then
        return false
    end

    local runtime = self:GetRuntime()

    local velocity =
    runtime:GetForward() * self.ForwardForce +
    vector_up * self.Force

    ent:SetVelocity(velocity)

    self.LastJump = CurTime()

    self:GetNavigator():Fire("Jump", velocity)

    return true

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Jump:Update()

    if not self:ShouldJump() then
        return
    end

    self:Execute()

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Jump:GetRemainingCooldown()

    return math.max(
        0,
        (self.LastJump + self.Cooldown) - CurTime()
    )

end

function Jump:IsCoolingDown()

    return self:GetRemainingCooldown() > 0

end

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function Jump:SetEnabled(enabled)

    self.Enabled = enabled == true

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Jump:Reset()

    self.LastJump = 0

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Jump:Dump()

    print("========= Jump =========")

    print("Enabled   :", self.Enabled)
    print("Force     :", self.Force)
    print("Forward   :", self.ForwardForce)
    print("Cooldown  :", self.Cooldown)
    print("Remaining :", self:GetRemainingCooldown())

    print("========================")

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Jump = Jump

return Jump