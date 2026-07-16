--================================================================--
-- ZNavigator
-- utils/navmesh.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Utils = ZNavigator.Utils or {}

local NavMesh = ZNavigator.Services.NavMesh

local Utils = {}

--------------------------------------------------------------------
-- Cache
--------------------------------------------------------------------

local AreaCache = setmetatable({}, {
    __mode = "v"
})

--------------------------------------------------------------------
-- Area
--------------------------------------------------------------------

function Utils.GetArea(position)

    local key = tostring(position)

    local area = AreaCache[key]

    if area then
        return area
    end

    area = NavMesh.GetArea(position)

    if area then
        AreaCache[key] = area
    end

    return area

end

function Utils.GetAreaCenter(area)

    if not area then
        return nil
    end

    return area:GetCenter()

end

--------------------------------------------------------------------
-- Convert
--------------------------------------------------------------------

function Utils.AreasToPoints(areas)

    local points = {}

    for i = 1, #areas do

        points[i] = areas[i]:GetCenter()

    end

    return points

end

function Utils.PointsToAreas(points)

    local areas = {}

    for i = 1, #points do

        areas[i] = Utils.GetArea(points[i])

    end

    return areas

end

--------------------------------------------------------------------
-- Validation
--------------------------------------------------------------------

function Utils.ValidateAreas(areas)

    if #areas == 0 then
        return false
    end

    for i = 1, #areas do

        if not NavMesh.IsValidArea(areas[i]) then
            return false
        end

    end

    return true

end

--------------------------------------------------------------------
-- Length
--------------------------------------------------------------------

function Utils.PathLength(points)

    local length = 0

    for i = 2, #points do

        length = length +
            points[i - 1]:Distance(points[i])

    end

    return length

end

--------------------------------------------------------------------
-- Nearest
--------------------------------------------------------------------

function Utils.NearestArea(position, areas)

    local best
    local bestDistance = math.huge

    for i = 1, #areas do

        local dist =
            position:DistToSqr(
                areas[i]:GetCenter()
            )

        if dist < bestDistance then

            bestDistance = dist
            best = areas[i]

        end

    end

    return best

end

--------------------------------------------------------------------
-- Search
--------------------------------------------------------------------

function Utils.FindArea(id)

    if not id then
        return nil
    end

    return navmesh.GetNavAreaByID(id)

end

--------------------------------------------------------------------
-- Visibility
--------------------------------------------------------------------

function Utils.IsVisible(a, b)

    if not a or not b then
        return false
    end

    return a:IsCompletelyVisible(b)

end

--------------------------------------------------------------------
-- Connections
--------------------------------------------------------------------

function Utils.GetConnections(area)

    if not area then
        return {}
    end

    return area:GetAdjacentAreas()

end

--------------------------------------------------------------------
-- Random
--------------------------------------------------------------------

function Utils.RandomArea()

    local areas = navmesh.GetAllNavAreas()

    if #areas == 0 then
        return nil
    end

    return areas[math.random(#areas)]

end

function Utils.RandomPoint()

    local area = Utils.RandomArea()

    if not area then
        return nil
    end

    return area:GetRandomPoint()

end

--------------------------------------------------------------------
-- Debug
--------------------------------------------------------------------

function Utils.DrawArea(area)

    if not area then
        return
    end

    area:Draw()

end

function Utils.DrawAreas(areas)

    for i = 1, #areas do

        areas[i]:Draw()

    end

end

--------------------------------------------------------------------
-- Cache
--------------------------------------------------------------------

function Utils.ClearCache()

    table.Empty(AreaCache)

end

--------------------------------------------------------------------
-- Export
--------------------------------------------------------------------

ZNavigator.Utils.NavMesh = Utils

return Utils