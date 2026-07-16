--================================================================--
-- ZNavigator
-- services/pathfinder.lua
-- Part 1
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Services = ZNavigator.Services or {}

local NavMesh = ZNavigator.Services.NavMesh

local Pathfinder = {}

Pathfinder.__index = Pathfinder

--------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------

function Pathfinder.new()

    local self = setmetatable({}, Pathfinder)

    self:Reset()

    return self

end

--------------------------------------------------------------------
-- Reset
--------------------------------------------------------------------

function Pathfinder:Reset()

	self.OpenHeap = {}

    self.StartArea = nil
    self.GoalArea = nil

    self.Open = {}
    self.Closed = {}

    self.Parent = {}

    self.GScore = {}
    self.FScore = {}

end

--------------------------------------------------------------------
-- Areas
--------------------------------------------------------------------

function Pathfinder:SetStart(area)

    self.StartArea = area

end

function Pathfinder:SetGoal(area)

    self.GoalArea = area

end

--------------------------------------------------------------------
-- Utility
--------------------------------------------------------------------

--function Pathfinder:GetLowestOpen()

  --  local best
  --  local bestScore = math.huge

--    for area in pairs(self.Open) do

  --      local score = self.FScore[area] or math.huge

    --    if score < bestScore then

      --      bestScore = score
        --    best = area

        --end

    --end

--    return best

--end

--------------------------------------------------------------------
-- Cost
--------------------------------------------------------------------

function Pathfinder:G(area)

    return self.GScore[area] or math.huge

end

function Pathfinder:F(area)

    return self.FScore[area] or math.huge

end

--------------------------------------------------------------------
-- Heuristic
--------------------------------------------------------------------

function Pathfinder:H(area)

    if not self.GoalArea then
        return 0
    end

    return area:GetCenter():DistToSqr(
        self.GoalArea:GetCenter()
    )

end

--------------------------------------------------------------------
-- Open
--------------------------------------------------------------------

function Pathfinder:OpenNode(area)

    self.Open[area] = true

end

function Pathfinder:CloseNode(area)

    self.Open[area] = nil

    self.Closed[area] = true

end

function Pathfinder:IsOpen(area)

    return self.Open[area] == true

end

function Pathfinder:IsClosed(area)

    return self.Closed[area] == true

end

--------------------------------------------------------------------
-- Parent
--------------------------------------------------------------------

function Pathfinder:SetParent(area, parent)

    self.Parent[area] = parent

end

function Pathfinder:GetParent(area)

    return self.Parent[area]

end

--------------------------------------------------------------------
-- Score
--------------------------------------------------------------------

function Pathfinder:SetG(area, score)

    self.GScore[area] = score

end

function Pathfinder:SetF(area, score)

    self.FScore[area] = score

end

--------------------------------------------------------------------
-- Initialize Search
--------------------------------------------------------------------

function Pathfinder:Begin(startArea, goalArea)

    self:Reset()

    self.StartArea = startArea
    self.GoalArea = goalArea

    self:OpenNode(startArea)

    self:SetG(startArea, 0)

    self:SetF(
        startArea,
        self:H(startArea)
    )

end

--------------------------------------------------------------------
-- Validation
--------------------------------------------------------------------

function Pathfinder:IsValid()

    return self.StartArea ~= nil
       and self.GoalArea ~= nil

end

--------------------------------------------------------------------
-- Internal : Heap
--------------------------------------------------------------------

function Pathfinder:HeapPush(area)

    local heap = self.OpenHeap

    heap[#heap + 1] = area

    local index = #heap

    while index > 1 do

        local parent = math.floor(index * 0.5)

        if self:F(heap[parent]) <= self:F(heap[index]) then
            break
        end

        heap[parent], heap[index] =
            heap[index], heap[parent]

        index = parent

    end

end

function Pathfinder:HeapPop()

    local heap = self.OpenHeap

    local size = #heap

    if size == 0 then
        return nil
    end

    local root = heap[1]

    heap[1] = heap[size]
    heap[size] = nil

    size = size - 1

    local index = 1

    while true do

        local left = index * 2
        local right = left + 1

        local smallest = index

        if left <= size and
            self:F(heap[left]) < self:F(heap[smallest]) then

            smallest = left

        end

        if right <= size and
            self:F(heap[right]) < self:F(heap[smallest]) then

            smallest = right

        end

        if smallest == index then
            break
        end

        heap[index], heap[smallest] =
            heap[smallest], heap[index]

        index = smallest

    end

    return root

end

--------------------------------------------------------------------
-- Search
--------------------------------------------------------------------

function Pathfinder:Expand(current)

    local neighbours = NavMesh.GetAdjacent(current)

    for i = 1, #neighbours do

        local neighbour = neighbours[i]

        if not NavMesh.CanTraverse(current, neighbour) then
            continue
        end

        if self:IsClosed(neighbour) then
            continue
        end

        local tentativeG =
            self:G(current) +
            NavMesh.Distance(current, neighbour)

        if not self:IsOpen(neighbour) then

            self:OpenNode(neighbour)

            self:HeapPush(neighbour)

        elseif tentativeG >= self:G(neighbour) then

            continue

        end

        self:SetParent(
            neighbour,
            current
        )

        self:SetG(
            neighbour,
            tentativeG
        )

        self:SetF(
            neighbour,
            tentativeG +
            self:H(neighbour)
        )

    end

end

--------------------------------------------------------------------
-- Step
--------------------------------------------------------------------

function Pathfinder:Step()

    local current = self:HeapPop()

    if not current then
        return false, "no_path"
    end

    self:CloseNode(current)

    if current == self.GoalArea then
        return true
    end

    self:Expand(current)

    return nil

end

--------------------------------------------------------------------
-- Complete
--------------------------------------------------------------------

function Pathfinder:Search()

    self.OpenHeap = {}

    self:HeapPush(self.StartArea)

    while true do

        local result, err = self:Step()

        if result ~= nil then
            return result, err
        end

    end

end

--------------------------------------------------------------------
-- Reconstruct Path
--------------------------------------------------------------------

function Pathfinder:Reconstruct()

    local areas = {}

    local current = self.GoalArea

    while current do

        areas[#areas + 1] = current

        current = self:GetParent(current)

    end

    local count = #areas

    for i = 1, math.floor(count * 0.5) do

        local j = count - i + 1

        areas[i], areas[j] =
            areas[j], areas[i]

    end

    return areas

end

--------------------------------------------------------------------
-- Areas -> Points
--------------------------------------------------------------------

function Pathfinder:BuildPoints(areas)

    local points = {}

    for i = 1, #areas do

        local area = areas[i]

        points[i] = area:GetCenter()

    end

    return points

end

--------------------------------------------------------------------
-- Path Smoothing
--------------------------------------------------------------------

function Pathfinder:Smooth(points)

    if #points <= 2 then
        return points
    end

    local result = {}

    result[1] = points[1]

    local last = points[1]

    for i = 2, #points - 1 do

        local current = points[i]

        if last:DistToSqr(current) >= (32 * 32) then

            result[#result + 1] = current

            last = current

        end

    end

    result[#result + 1] = points[#points]

    return result

end

--------------------------------------------------------------------
-- Optimize
--------------------------------------------------------------------

function Pathfinder:Optimize(points)

    if #points <= 2 then
        return points
    end

    local result = {}

    result[1] = points[1]

    local previous = points[1]

    for i = 2, #points - 1 do

        local current = points[i]
        local nextPoint = points[i + 1]

        local dirA = (current - previous):GetNormalized()
        local dirB = (nextPoint - current):GetNormalized()

        if dirA:Dot(dirB) < 0.995 then

            result[#result + 1] = current

            previous = current

        end

    end

    result[#result + 1] = points[#points]

    return result

end

--------------------------------------------------------------------
-- Compute
--------------------------------------------------------------------

function Pathfinder:Compute(startPos, goalPos)

    local startArea = NavMesh.GetArea(startPos)
    local goalArea = NavMesh.GetArea(goalPos)

    if not startArea or not goalArea then
        return false, "invalid_area"
    end

    self:Begin(startArea, goalArea)

    local ok, err = self:Search()

    if not ok then
        return false, err
    end

    local areas = self:Reconstruct()

    local points = self:BuildPoints(areas)

    points = self:Smooth(points)
    points = self:Optimize(points)

    return true, {
        Areas = areas,
        Points = points
    }

end

--------------------------------------------------------------------
-- Debug
--------------------------------------------------------------------

function Pathfinder:Draw(result, duration)

    if not result then
        return
    end

    duration = duration or 0.2

    local points = result.Points

    for i = 1, #points do

        debugoverlay.Cross(
            points[i],
            8,
            duration,
            Color(0,255,0),
            true
        )

        if i < #points then

            debugoverlay.Line(
                points[i],
                points[i + 1],
                duration,
                Color(0,150,255),
                true
            )

        end

    end

end

--------------------------------------------------------------------
-- Convenience
--------------------------------------------------------------------

local Shared = Pathfinder.new()

function Pathfinder.Find(startPos, goalPos)

    return Shared:Compute(
        startPos,
        goalPos
    )

end

--------------------------------------------------------------------
-- Export
--------------------------------------------------------------------

ZNavigator.Services.Pathfinder = Pathfinder

return Pathfinder