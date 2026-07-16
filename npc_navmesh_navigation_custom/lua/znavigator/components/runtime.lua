--================================================================--
-- ZNavigator
-- components/runtime.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Runtime = Component:Extend("Runtime")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Runtime:Initialize()

    self.Position = vector_origin
    self.LastPosition = vector_origin

    self.Velocity = vector_origin
    self.Forward = vector_origin

    self.Angles = angle_zero

    self.EyePosition = vector_origin

    self.NavArea = nil

    self.Speed = 0
    self.GroundSpeed = 0

    self.OnGround = false
    self.WaterLevel = 0

    self.CurTime = CurTime()
    self.Frame = FrameNumber()

    self.DeltaTime = 0

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Runtime:Update(dt)

    local ent = self:GetEntity()

    if not IsValid(ent) then
        return
    end

    self.DeltaTime = dt

    self.CurTime = CurTime()
    self.Frame = FrameNumber()

    self.LastPosition = self.Position

    self.Position = ent:GetPos()
    self.Angles = ent:GetAngles()

    self.Forward = self.Angles:Forward()

    self.Velocity = ent:GetVelocity()

    self.Speed = self.Velocity:Length2D()
    self.GroundSpeed = self.Velocity:Length()

    self.OnGround = ent:IsOnGround()
    self.WaterLevel = ent:WaterLevel()

    if ent.EyePos then
        self.EyePosition = ent:EyePos()
    else
        self.EyePosition = self.Position
    end

    self.NavArea = navmesh.GetNearestNavArea(
        self.Position,
        false,
        256,
        true,
        true
    )

end

----------------------------------------------------------
-- Position
----------------------------------------------------------

function Runtime:GetPosition()

    return self.Position

end

function Runtime:GetLastPosition()

    return self.LastPosition

end

function Runtime:GetEyePosition()

    return self.EyePosition

end

----------------------------------------------------------
-- Angles
----------------------------------------------------------

function Runtime:GetAngles()

    return self.Angles

end

function Runtime:GetForward()

    return self.Forward

end

----------------------------------------------------------
-- Velocity
----------------------------------------------------------

function Runtime:GetVelocity()

    return self.Velocity

end

function Runtime:GetSpeed()

    return self.Speed

end

function Runtime:GetGroundSpeed()

    return self.GroundSpeed

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Runtime:IsMoving()

    return self.Speed > 1

end

function Runtime:IsOnGround()

    return self.OnGround

end

function Runtime:IsInWater()

    return self.WaterLevel > 0

end

----------------------------------------------------------
-- Navigation
----------------------------------------------------------

function Runtime:GetNavArea()

    return self.NavArea

end

----------------------------------------------------------
-- Distance
----------------------------------------------------------

function Runtime:Distance(position)

    return self.Position:Distance(position)

end

function Runtime:DistanceSqr(position)

    return self.Position:DistToSqr(position)

end

----------------------------------------------------------
-- Direction
----------------------------------------------------------

function Runtime:Direction(position)

    return (position - self.Position):GetNormalized()

end

----------------------------------------------------------
-- Trace
----------------------------------------------------------

function Runtime:TraceForward(distance, mask)

    local tr = {}

    tr.start = self.Position
    tr.endpos = self.Position + self.Forward * distance
    tr.filter = self:GetEntity()
    tr.mask = mask or MASK_NPCSOLID

    return util.TraceLine(tr)

end

----------------------------------------------------------
-- Movement
----------------------------------------------------------

function Runtime:MovedDistance()

    return self.Position:Distance(
        self.LastPosition
    )

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Runtime:Reset()

    self.Position = vector_origin
    self.LastPosition = vector_origin

    self.Velocity = vector_origin

    self.Forward = vector_origin

    self.Angles = angle_zero

    self.NavArea = nil

    self.Speed = 0
    self.GroundSpeed = 0

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Runtime:Dump()

    print("===== Runtime =====")

    print("Position :", self.Position)
    print("Velocity :", self.Velocity)
    print("Speed    :", self.Speed)
    print("Ground   :", self.OnGround)
    print("NavArea  :", self.NavArea)

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Runtime = Runtime

return Runtime