--================================================================--
-- ZNavigator
-- services/navmesh.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Services = ZNavigator.Services or {}

local NavMesh = {}

--------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------

NavMesh.DefaultSearchRadius = 512
NavMesh.DefaultStepHeight = 64

--------------------------------------------------------------------
-- Area
--------------------------------------------------------------------

function NavMesh.GetArea(position, radius)

    if not navmesh.IsLoaded() then
        return nil
    end

    return navmesh.GetNearestNavArea(
        position,
        false,
        radius or NavMesh.DefaultSearchRadius,
        true,
        true
    )

end

function NavMesh.GetAreaSafe(position)

    local area = NavMesh.GetArea(position)

    if area then
        return area
    end

    return nil

end

--------------------------------------------------------------------
-- Position
--------------------------------------------------------------------

function NavMesh.GetPosition(area)

    if not area then
        return nil
    end

    return area:GetCenter()

end

--------------------------------------------------------------------
-- Validation
--------------------------------------------------------------------

function NavMesh.IsValidArea(area)

    return area ~= nil

end

function NavMesh.IsLoaded()

    return navmesh.IsLoaded()

end

--------------------------------------------------------------------
-- Distance
--------------------------------------------------------------------

function NavMesh.Distance(a, b)

    if not a or not b then
        return math.huge
    end

    return a:GetCenter():Distance(
        b:GetCenter()
    )

end

function NavMesh.DistanceSqr(a, b)

    if not a or not b then
        return math.huge
    end

    return a:GetCenter():DistToSqr(
        b:GetCenter()
    )

end

--------------------------------------------------------------------
-- Neighbours
--------------------------------------------------------------------

function NavMesh.GetAdjacent(area)

    if not area then
        return {}
    end

    return area:GetAdjacentAreas()

end

--------------------------------------------------------------------
-- Random
--------------------------------------------------------------------

function NavMesh.GetRandomArea()

    local tbl = navmesh.GetAllNavAreas()

    if #tbl == 0 then
        return nil
    end

    return tbl[math.random(#tbl)]

end

function NavMesh.GetRandomPosition()

    local area = NavMesh.GetRandomArea()

    if not area then
        return nil
    end

    return area:GetRandomPoint()

end

--------------------------------------------------------------------
-- Visibility
--------------------------------------------------------------------

function NavMesh.IsVisible(a, b)

    if not a or not b then
        return false
    end

    return a:IsCompletelyVisible(b)

end

--------------------------------------------------------------------
-- Height
--------------------------------------------------------------------

function NavMesh.HeightDifference(a, b)

    if not a or not b then
        return math.huge
    end

    return math.abs(
        a:GetCenter().z -
        b:GetCenter().z
    )

end

--------------------------------------------------------------------
-- Area Size
--------------------------------------------------------------------

function NavMesh.GetSize(area)

    if not area then
        return 0
    end

    return area:GetSizeX() *
           area:GetSizeY()

end

--------------------------------------------------------------------
-- Closest Position
--------------------------------------------------------------------

function NavMesh.GetClosestPoint(area, position)

    if not area then
        return nil
    end

    return area:GetClosestPointOnArea(
        position
    )

end

--------------------------------------------------------------------
-- Contains
--------------------------------------------------------------------

function NavMesh.Contains(area, position)

    if not area then
        return false
    end

    return area:Contains(position)

end

--------------------------------------------------------------------
-- Ladder
--------------------------------------------------------------------

function NavMesh.HasLadder(area)

    if not area then
        return false
    end

    local ladders = area:GetLadders()

    return ladders and #ladders > 0

end

--------------------------------------------------------------------
-- Water
--------------------------------------------------------------------

function NavMesh.IsUnderwater(area)

    if not area then
        return false
    end

    return area:IsUnderwater()

end

--------------------------------------------------------------------
-- Traversable
--------------------------------------------------------------------

function NavMesh.CanTraverse(fromArea, toArea, stepHeight)

    if not fromArea or not toArea then
        return false
    end

    local delta = math.abs(
        fromArea:ComputeAdjacentConnectionHeightChange(
            toArea
        )
    )

    return delta <= (stepHeight or NavMesh.DefaultStepHeight)

end

--------------------------------------------------------------------
-- Build Area List
--------------------------------------------------------------------

function NavMesh.BuildAreaList(startArea)

    if not startArea then
        return {}
    end

    local visited = {}
    local queue = { startArea }
    local result = {}

    while #queue > 0 do

        local area = table.remove(queue, 1)

        if not visited[area] then

            visited[area] = true

            result[#result + 1] = area

            for _, neighbour in ipairs(
                area:GetAdjacentAreas()
            ) do

                if not visited[neighbour] then

                    queue[#queue + 1] = neighbour

                end

            end

        end

    end

    return result

end

--------------------------------------------------------------------
-- Draw
--------------------------------------------------------------------

function NavMesh.Draw(area, duration)

    if not area then
        return
    end

    area:Draw()

end

--------------------------------------------------------------------
-- Debug
--------------------------------------------------------------------

function NavMesh.Debug(position)

    local area = NavMesh.GetArea(position)

    if not area then
        print("[NavMesh] No Area")
        return
    end

    print("Nav ID :", area:GetID())
    print("Center :", area:GetCenter())
    print("Size X :", area:GetSizeX())
    print("Size Y :", area:GetSizeY())

end

--------------------------------------------------------------------
-- Export
--------------------------------------------------------------------

ZNavigator.Services.NavMesh = NavMesh

return NavMesh