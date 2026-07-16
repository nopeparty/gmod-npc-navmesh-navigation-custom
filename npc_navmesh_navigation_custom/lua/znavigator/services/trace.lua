--================================================================--
-- ZNavigator
-- services/trace.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Services = ZNavigator.Services or {}

local Trace = {}

Trace.DefaultMask = MASK_NPCSOLID

--------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------

local function Build(filter, startPos, endPos, mins, maxs, mask)

    return {
        start = startPos,
        endpos = endPos,
        filter = filter,
        mins = mins,
        maxs = maxs,
        mask = mask or Trace.DefaultMask
    }

end

--------------------------------------------------------------------
-- Line
--------------------------------------------------------------------

function Trace.Line(filter, startPos, endPos, mask)

    return util.TraceLine(
        Build(
            filter,
            startPos,
            endPos,
            nil,
            nil,
            mask
        )
    )

end

--------------------------------------------------------------------
-- Hull
--------------------------------------------------------------------

function Trace.Hull(filter, startPos, endPos, mins, maxs, mask)

    return util.TraceHull(
        Build(
            filter,
            startPos,
            endPos,
            mins,
            maxs,
            mask
        )
    )

end

--------------------------------------------------------------------
-- Forward
--------------------------------------------------------------------

function Trace.Forward(ent, distance, height, mask)

    local startPos = ent:GetPos()

    startPos = startPos + Vector(
        0,
        0,
        height or 32
    )

    local endPos =
        startPos +
        ent:GetForward() *
        (distance or 64)

    return Trace.Line(
        ent,
        startPos,
        endPos,
        mask
    )

end

--------------------------------------------------------------------
-- Forward Hull
--------------------------------------------------------------------

function Trace.ForwardHull(ent, distance, mins, maxs, height, mask)

    local startPos = ent:GetPos()

    startPos = startPos + Vector(
        0,
        0,
        height or 32
    )

    local endPos =
        startPos +
        ent:GetForward() *
        (distance or 64)

    return Trace.Hull(
        ent,
        startPos,
        endPos,
        mins or Vector(-12, -12, 0),
        maxs or Vector(12, 12, 32),
        mask
    )

end

--------------------------------------------------------------------
-- Ground
--------------------------------------------------------------------

function Trace.Ground(ent, distance)

    local startPos = ent:GetPos()

    local endPos =
        startPos -
        Vector(0, 0, distance or 256)

    return Trace.Line(
        ent,
        startPos,
        endPos
    )

end

--------------------------------------------------------------------
-- Step
--------------------------------------------------------------------

function Trace.Step(ent, forwardDistance, stepHeight)

    local startPos =
        ent:GetPos() +
        Vector(0, 0, stepHeight or 24)

    local endPos =
        startPos +
        ent:GetForward() *
        (forwardDistance or 32)

    return Trace.Hull(

        ent,

        startPos,

        endPos,

        Vector(-8,-8,0),

        Vector(8,8,24)

    )

end

--------------------------------------------------------------------
-- Drop
--------------------------------------------------------------------

function Trace.Drop(position, filter, distance)

    return Trace.Line(

        filter,

        position,

        position - Vector(

            0,

            0,

            distance or 256

        )

    )

end

--------------------------------------------------------------------
-- Visibility
--------------------------------------------------------------------

function Trace.Visible(filter, fromPos, toPos)

    local tr = Trace.Line(
        filter,
        fromPos,
        toPos
    )

    return not tr.Hit

end

--------------------------------------------------------------------
-- Obstacle
--------------------------------------------------------------------

function Trace.Obstacle(ent, distance)

    local tr = Trace.ForwardHull(
        ent,
        distance
    )

    return tr.Hit, tr

end

--------------------------------------------------------------------
-- Clearance
--------------------------------------------------------------------

function Trace.Clearance(ent, height)

    local startPos = ent:GetPos()

    local endPos =
        startPos +
        Vector(
            0,
            0,
            height or 72
        )

    return Trace.Line(
        ent,
        startPos,
        endPos
    )

end

--------------------------------------------------------------------
-- Ceiling
--------------------------------------------------------------------

function Trace.Ceiling(ent)

    local tr = Trace.Clearance(
        ent,
        128
    )

    return tr.Hit, tr

end

--------------------------------------------------------------------
-- Wall
--------------------------------------------------------------------

function Trace.Wall(ent)

    local tr = Trace.ForwardHull(
        ent,
        32
    )

    return tr.Hit, tr

end

--------------------------------------------------------------------
-- Ledge
--------------------------------------------------------------------

function Trace.Ledge(ent)

    local forward = ent:GetPos() +
        ent:GetForward() * 48

    local tr = Trace.Drop(
        forward,
        ent,
        128
    )

    return not tr.Hit, tr

end

--------------------------------------------------------------------
-- Debug
--------------------------------------------------------------------

function Trace.Draw(tr, duration, color)

    if not tr then
        return
    end

    debugoverlay.Line(

        tr.StartPos,

        tr.HitPos,

        duration or 0.1,

        color or Color(0,255,0),

        true

    )

end

--------------------------------------------------------------------
-- Export
--------------------------------------------------------------------

ZNavigator.Services.Trace = Trace

return Trace