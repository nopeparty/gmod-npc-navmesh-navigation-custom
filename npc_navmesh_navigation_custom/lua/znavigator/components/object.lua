--================================================================--
-- ZNavigator
-- components/object.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Object = Component:Extend("Object")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Object:Initialize()

    self.Enabled = true

    self.TraceDistance = 48
    self.TraceHeight = 32

    self.CheckInterval = 0.15
    self.NextCheck = 0

    self.LastEntity = nil
    self.LastTrace = nil

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Object:GetRuntime()

    return self:GetNavigator():GetComponent("Runtime")

end

----------------------------------------------------------
-- Trace
----------------------------------------------------------

function Object:TraceForward()

    local runtime = self:GetRuntime()

    if not runtime then
        return nil
    end

    local ent = self:GetEntity()

    if not IsValid(ent) then
        return nil
    end

    local startPos = runtime:GetPosition() + vector_up * self.TraceHeight

    local endPos =
        startPos +
        runtime:GetForward() * self.TraceDistance

    local tr = util.TraceHull({

        start = startPos,

        endpos = endPos,

        mins = Vector(-12, -12, 0),

        maxs = Vector(12, 12, 32),

        filter = ent,

        mask = MASK_NPCSOLID

    })

    self.LastTrace = tr
    self.LastEntity = tr.Entity

    return tr

end

----------------------------------------------------------
-- Helpers
----------------------------------------------------------

function Object:GetTrace()

    return self.LastTrace

end

function Object:GetEntityAhead()

    return self.LastEntity

end

----------------------------------------------------------
-- Object Checks
----------------------------------------------------------

function Object:IsDoor(ent)

    if not IsValid(ent) then
        return false
    end

    local class = ent:GetClass()

    return class == "prop_door_rotating"
        or class == "func_door"
        or class == "func_door_rotating"

end

function Object:IsBreakable(ent)

    if not IsValid(ent) then
        return false
    end

    return ent:GetClass() == "func_breakable"

end

function Object:IsPhysics(ent)

    if not IsValid(ent) then
        return false
    end

    return ent:GetMoveType() == MOVETYPE_VPHYSICS

end

----------------------------------------------------------
-- Interaction
----------------------------------------------------------

function Object:HandleDoor(ent)

    if not self:IsDoor(ent) then
        return false
    end

    ent:Fire("Open")

    self:GetNavigator():Fire("DoorOpened", ent)

    return true

end

function Object:HandlePhysics(ent)

    if not self:IsPhysics(ent) then
        return false
    end

    local runtime = self:GetRuntime()

    local force =
        runtime:GetForward() * 250

    ent:SetVelocity(force)

    return true

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Object:Update()

    if CurTime() < self.NextCheck then
        return
    end

    self.NextCheck = CurTime() + self.CheckInterval

    local tr = self:TraceForward()

    if not tr or not tr.Hit then
        return
    end

    local ent = tr.Entity

    if not IsValid(ent) then
        return
    end

    if self:HandleDoor(ent) then
        return
    end

    self:HandlePhysics(ent)

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Object:Reset()

    self.LastEntity = nil
    self.LastTrace = nil

    self.NextCheck = 0

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Object:Dump()

    print("========= Object =========")

    print("Entity :", self.LastEntity)
    print("Trace  :", self.LastTrace)

    print("==========================")

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Object = Object

return Object