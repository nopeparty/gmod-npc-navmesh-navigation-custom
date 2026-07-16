--================================================================--
-- ZNavigator
-- utils/math.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Utils = ZNavigator.Utils or {}

local Math = {}

--------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------

Math.Epsilon = 0.0001

--------------------------------------------------------------------
-- Clamp
--------------------------------------------------------------------

function Math.Clamp(value, minValue, maxValue)

    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value

end

--------------------------------------------------------------------
-- Lerp
--------------------------------------------------------------------

function Math.Lerp(a, b, t)

    return a + (b - a) * t

end

function Math.VectorLerp(a, b, t)

    return Vector(

        Math.Lerp(a.x, b.x, t),
        Math.Lerp(a.y, b.y, t),
        Math.Lerp(a.z, b.z, t)

    )

end

function Math.AngleLerp(a, b, t)

    return Angle(

        Lerp(t, a.p, b.p),
        Lerp(t, a.y, b.y),
        Lerp(t, a.r, b.r)

    )

end

--------------------------------------------------------------------
-- Distance
--------------------------------------------------------------------

function Math.Distance(a, b)

    return a:Distance(b)

end

function Math.DistanceSqr(a, b)

    return a:DistToSqr(b)

end

--------------------------------------------------------------------
-- Direction
--------------------------------------------------------------------

function Math.Direction(from, to)

    return (to - from):GetNormalized()

end

--------------------------------------------------------------------
-- Dot
--------------------------------------------------------------------

function Math.Dot(a, b)

    return a:Dot(b)

end

--------------------------------------------------------------------
-- Cross
--------------------------------------------------------------------

function Math.Cross(a, b)

    return a:Cross(b)

end

--------------------------------------------------------------------
-- Normalize
--------------------------------------------------------------------

function Math.Normalize(vec)

    return vec:GetNormalized()

end

--------------------------------------------------------------------
-- Length
--------------------------------------------------------------------

function Math.Length(vec)

    return vec:Length()

end

function Math.Length2D(vec)

    return vec:Length2D()

end

--------------------------------------------------------------------
-- Project
--------------------------------------------------------------------

function Math.ProjectPointOnLine(point, startPos, endPos)

    local direction = endPos - startPos

    local length = direction:Length()

    if length <= Math.Epsilon then
        return startPos
    end

    direction:Normalize()

    local projection =
        (point - startPos):Dot(direction)

    projection = Math.Clamp(
        projection,
        0,
        length
    )

    return startPos + direction * projection

end

--------------------------------------------------------------------
-- Closest
--------------------------------------------------------------------

function Math.ClosestPoint(position, points)

    local closest
    local best = math.huge

    for i = 1, #points do

        local distance =
            position:DistToSqr(points[i])

        if distance < best then

            best = distance
            closest = points[i]

        end

    end

    return closest, best

end

--------------------------------------------------------------------
-- Midpoint
--------------------------------------------------------------------

function Math.Midpoint(a, b)

    return (a + b) * 0.5

end

--------------------------------------------------------------------
-- Average
--------------------------------------------------------------------

function Math.Average(points)

    if #points == 0 then
        return vector_origin
    end

    local result = Vector()

    for i = 1, #points do

        result:Add(points[i])

    end

    return result / #points

end

--------------------------------------------------------------------
-- Angle
--------------------------------------------------------------------

function Math.LookAt(from, to)

    return (to - from):Angle()

end

--------------------------------------------------------------------
-- Compare
--------------------------------------------------------------------

function Math.NearlyEqual(a, b, epsilon)

    epsilon = epsilon or Math.Epsilon

    return math.abs(a - b) <= epsilon

end

function Math.VectorEqual(a, b, epsilon)

    epsilon = epsilon or Math.Epsilon

    return a:DistToSqr(b) <= (epsilon * epsilon)

end

--------------------------------------------------------------------
-- Random
--------------------------------------------------------------------

function Math.RandomPoint(mins, maxs)

    return Vector(

        math.Rand(mins.x, maxs.x),

        math.Rand(mins.y, maxs.y),

        math.Rand(mins.z, maxs.z)

    )

end

--------------------------------------------------------------------
-- Bounds
--------------------------------------------------------------------

function Math.InBounds(point, mins, maxs)

    return
        point.x >= mins.x and
        point.x <= maxs.x and
        point.y >= mins.y and
        point.y <= maxs.y and
        point.z >= mins.z and
        point.z <= maxs.z

end

--------------------------------------------------------------------
-- Segment
--------------------------------------------------------------------

function Math.PointOnSegment(point, startPos, endPos)

    local projected = Math.ProjectPointOnLine(

        point,

        startPos,

        endPos

    )

    return projected

end

--------------------------------------------------------------------
-- Export
--------------------------------------------------------------------

ZNavigator.Utils.Math = Math

return Math