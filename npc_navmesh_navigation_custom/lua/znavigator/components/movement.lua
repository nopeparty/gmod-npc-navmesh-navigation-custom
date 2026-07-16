--================================================================--
-- ZNavigator
-- components/movement.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Movement = Component:Extend("Movement")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Movement:Initialize()

    self.Walking = false
    self.Running = true
    self.Moving = false

    self.DesiredSpeed = nil

    self.FaceTarget = true
    self.StopDistance = 24

end

----------------------------------------------------------
-- Components
----------------------------------------------------------

function Movement:GetRuntime()

    return self:GetNavigator():GetComponent("Runtime")

end

function Movement:GetWaypoint()

    return self:GetNavigator():GetComponent("Waypoint")

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Movement:IsMoving()

    return self.Moving

end

function Movement:IsWalking()

    return self.Walking

end

function Movement:IsRunning()

    return self.Running

end

----------------------------------------------------------
-- Speed
----------------------------------------------------------

function Movement:Walk()

    self.Walking = true
    self.Running = false

    local ent = self:GetEntity()

    if IsValid(ent) and ent.SetSchedule then
        ent:SetSchedule(SCHED_FORCED_GO)
    end

end

function Movement:Run()

    self.Walking = false
    self.Running = true

    local ent = self:GetEntity()

    if IsValid(ent) and ent.SetSchedule then
        ent:SetSchedule(SCHED_CHASE_ENEMY)
    end

end

function Movement:SetDesiredSpeed(speed)

    self.DesiredSpeed = speed

end

----------------------------------------------------------
-- Stop
----------------------------------------------------------

function Movement:Stop()

    self.Moving = false

    local ent = self:GetEntity()

    if not IsValid(ent) then
        return
    end

    ent:SetVelocity(-ent:GetVelocity())

end

----------------------------------------------------------
-- Move
----------------------------------------------------------

function Movement:MoveTowards(position)

    local ent = self:GetEntity()

    if not IsValid(ent) then
        return
    end

    ent:SetLastPosition(position)
    ent:SetSchedule(SCHED_FORCED_GO_RUN)

    self.Moving = true

end

----------------------------------------------------------
-- Face
----------------------------------------------------------

function Movement:Face(position)

    local ent = self:GetEntity()

    if not IsValid(ent) then
        return
    end

    local dir = position - ent:GetPos()
    dir.z = 0

    ent:SetAngles(dir:Angle())

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Movement:Update()

	--print("[ZN] Movement Update")

    local waypoint = self:GetWaypoint()

    if not waypoint then
        return
    end

    if not waypoint:IsActive() then

        self.Moving = false

        return

    end

    local position = waypoint:GetPosition()

    if not position then
        return
    end

    if self.FaceTarget then
        self:Face(position)
    end

    self:MoveTowards(position)

end

----------------------------------------------------------
-- Think
----------------------------------------------------------

function Movement:Think()

    local runtime = self:GetRuntime()

    if not runtime then
        return
    end

    self.Moving = runtime:IsMoving()

end

----------------------------------------------------------
-- Utility
----------------------------------------------------------

function Movement:GetDistance()

    local waypoint = self:GetWaypoint()

    if not waypoint then
        return math.huge
    end

    return waypoint:GetDistance()

end

function Movement:IsNearWaypoint()

    return self:GetDistance() <= self.StopDistance

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Movement:Reset()

    self.Walking = false
    self.Running = true
    self.Moving = false

    self.DesiredSpeed = nil

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Movement:Dump()

    print("======= Movement =======")

    print("Moving   :", self.Moving)
    print("Walking  :", self.Walking)
    print("Running  :", self.Running)
    print("Distance :", self:GetDistance())

    print("========================")

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Movement = Movement

return Movement