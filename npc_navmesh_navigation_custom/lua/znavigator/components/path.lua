--================================================================--
-- ZNavigator
-- components/path.lua
-- Part 1
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local Path = Component:Extend("Path")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Path:Initialize()

    self.Points = {}
    self.Areas = {}

    self.Index = 1

    self.CurrentPoint = nil
    self.CurrentArea = nil

    self.Valid = false
    self.Ready = false
    self.Dirty = false
    self.Finished = false

    self.LastCompute = 0

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Path:Reset()

    table.Empty(self.Points)
    table.Empty(self.Areas)

    self.Index = 1

    self.CurrentPoint = nil
    self.CurrentArea = nil

    self.Valid = false
    self.Ready = false
    self.Dirty = false
    self.Finished = false

    self.LastCompute = 0

end

----------------------------------------------------------
-- Set
----------------------------------------------------------

function Path:Set(points, areas)

    self:Reset()

    if points then
        self.Points = points
    end

    if areas then
        self.Areas = areas
    end

    self.Ready = #self.Points > 0
    self.Valid = self.Ready

    self.CurrentPoint = self.Points[1]
    self.CurrentArea = self.Areas[1]

    self.LastCompute = CurTime()

    return self

end

----------------------------------------------------------
-- Add
----------------------------------------------------------

function Path:AddPoint(point, area)

    self.Points[#self.Points + 1] = point
    self.Areas[#self.Areas + 1] = area

    if not self.CurrentPoint then

        self.CurrentPoint = point
        self.CurrentArea = area

    end

end

----------------------------------------------------------
-- Getters
----------------------------------------------------------

function Path:GetPoints()

    return self.Points

end

function Path:GetAreas()

    return self.Areas

end

function Path:GetPoint(index)

    return self.Points[index]

end

function Path:GetArea(index)

    return self.Areas[index]

end

function Path:GetCurrentPoint()

    return self.CurrentPoint

end

function Path:GetCurrentArea()

    return self.CurrentArea

end

function Path:GetCurrentIndex()

    return self.Index

end

----------------------------------------------------------
-- Count
----------------------------------------------------------

function Path:Count()

    return #self.Points

end

function Path:IsEmpty()

    return #self.Points == 0

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Path:IsReady()

    return self.Ready

end

function Path:IsValid()

    return self.Valid

end

function Path:IsDirty()

    return self.Dirty

end

function Path:IsFinished()

    return self.Finished

end

----------------------------------------------------------
-- Dirty
----------------------------------------------------------

function Path:SetDirty(state)

    self.Dirty = state == true

end

----------------------------------------------------------
-- Ready
----------------------------------------------------------

function Path:SetReady(state)

    self.Ready = state == true

end

----------------------------------------------------------
-- Valid
----------------------------------------------------------

function Path:SetValid(state)

    self.Valid = state == true

end

----------------------------------------------------------
-- Finished
----------------------------------------------------------

function Path:SetFinished(state)

    self.Finished = state == true

end

----------------------------------------------------------
-- Current
----------------------------------------------------------

function Path:SetCurrent(index)

    self.Index = math.Clamp(index, 1, #self.Points)

    self.CurrentPoint = self.Points[self.Index]
    self.CurrentArea = self.Areas[self.Index]

    return self.CurrentPoint

end

----------------------------------------------------------
-- Has
----------------------------------------------------------

function Path:HasNext()

    return self.Index < #self.Points

end

function Path:HasPrevious()

    return self.Index > 1

end

----------------------------------------------------------
-- Previous
----------------------------------------------------------

function Path:GetPreviousPoint()

    return self.Points[self.Index - 1]

end

function Path:GetNextPoint()

    return self.Points[self.Index + 1]

end

----------------------------------------------------------
-- Time
----------------------------------------------------------

function Path:GetLastCompute()

    return self.LastCompute

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Path:Dump()

    print("========== PATH ==========")

    print("Points    :", #self.Points)
    print("Areas     :", #self.Areas)
    print("Index     :", self.Index)
    print("Ready     :", self.Ready)
    print("Valid     :", self.Valid)
    print("Finished  :", self.Finished)
    print("Dirty     :", self.Dirty)

    print("==========================")

end

----------------------------------------------------------
-- Advance
----------------------------------------------------------

function Path:Advance()

    if not self:HasNext() then

        self:SetFinished(true)

        local navigator = self:GetNavigator()

        if navigator then
            navigator:Fire("PathFinished", self)
        end

        return false

    end

    self.Index = self.Index + 1

    self.CurrentPoint = self.Points[self.Index]
    self.CurrentArea = self.Areas[self.Index]

    local navigator = self:GetNavigator()

    if navigator then
        navigator:Fire(
            "WaypointChanged",
            self.CurrentPoint,
            self.Index
        )
    end

    return true

end

----------------------------------------------------------
-- Retreat
----------------------------------------------------------

function Path:Retreat()

    if not self:HasPrevious() then
        return false
    end

    self.Index = self.Index - 1
	
	print(
		"[ZN] Advance",
		self.Index,
		"/",
		#self.Points
	)

    self.CurrentPoint = self.Points[self.Index]
    self.CurrentArea = self.Areas[self.Index]

    return true

end

----------------------------------------------------------
-- Jump
----------------------------------------------------------

function Path:JumpTo(index)

    if index < 1 or index > #self.Points then
        return false
    end

    self.Index = index

    self.CurrentPoint = self.Points[index]
    self.CurrentArea = self.Areas[index]

    return true

end

----------------------------------------------------------
-- Complete
----------------------------------------------------------

function Path:Complete()

    self:SetFinished(true)

    local navigator = self:GetNavigator()

    if navigator then
        navigator:Fire("PathFinished", self)

        if navigator.FSM then
            navigator:TrySetState("Finished")
        end
    end

end

----------------------------------------------------------
-- Compute Request
----------------------------------------------------------

function Path:RequestCompute()

    self.Dirty = true

    local navigator = self:GetNavigator()

    if navigator then

        navigator:Fire("PathComputeRequested", self)

        if navigator.FSM then
            navigator:TrySetState("PathFinding")
        end

    end

end

----------------------------------------------------------
-- Compute Finished
----------------------------------------------------------

function Path:ComputeFinished(points, areas)

    self:Set(points, areas)

    self.Dirty = false
    self.Ready = true
    self.Valid = true
    self.Finished = false

    local navigator = self:GetNavigator()

    if navigator then

        navigator:Fire("PathComputed", self)

        if navigator.FSM then
            navigator:TrySetState("Moving")
        end

    end

end

----------------------------------------------------------
-- Compute Failed
----------------------------------------------------------

function Path:ComputeFailed()

    self:Reset()

    self.Dirty = false
    self.Valid = false
    self.Ready = false

    local navigator = self:GetNavigator()

    if navigator then

        navigator:Fire("PathFailed", self)

        if navigator.FSM then
            navigator:TrySetState("Failed")
        end

    end

end

----------------------------------------------------------
-- Validation
----------------------------------------------------------

function Path:Validate()

    if self:IsEmpty() then
        return false
    end

    if #self.Points ~= #self.Areas then
        return false
    end

    for i = 1, #self.Points do

        if not isvector(self.Points[i]) then
            return false
        end

    end

    self.Valid = true

    return true

end

----------------------------------------------------------
-- Waypoint
----------------------------------------------------------

function Path:IsLast()

    return self.Index >= #self.Points

end

function Path:GetRemaining()

    return math.max(
        #self.Points - self.Index,
        0
    )

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Path:GetProgress()

    if #self.Points == 0 then
        return 0
    end

    return self.Index / #self.Points

end

----------------------------------------------------------
-- Utility
----------------------------------------------------------

function Path:ForEach(callback)

    for i = 1, #self.Points do

        callback(

            self.Points[i],

            self.Areas[i],

            i

        )

    end

end

function Path:GetClosestPoint(position)

    local best
    local bestDistance = math.huge

    for i = 1, #self.Points do

        local dist = self.Points[i]:DistToSqr(position)

        if dist < bestDistance then

            bestDistance = dist
            best = i

        end

    end

    return best

end

----------------------------------------------------------
-- Copy
----------------------------------------------------------

function Path:Copy()

    local points = table.Copy(self.Points)
    local areas = table.Copy(self.Areas)

    return {
        Points = points,
        Areas = areas,
        Index = self.Index,
        Ready = self.Ready,
        Valid = self.Valid,
        Finished = self.Finished
    }

end

----------------------------------------------------------
-- Merge
----------------------------------------------------------

function Path:Merge(other)

    if not other then
        return
    end

    local points = other.Points or other:GetPoints()
    local areas = other.Areas or other:GetAreas()

    if not points then
        return
    end

    for i = 1, #points do

        self.Points[#self.Points + 1] = points[i]
        self.Areas[#self.Areas + 1] = areas and areas[i] or nil

    end

    self.Ready = #self.Points > 0
    self.Valid = self:Validate()

end

----------------------------------------------------------
-- Reverse
----------------------------------------------------------

function Path:Reverse()

    local count = #self.Points

    for i = 1, math.floor(count / 2) do

        local j = count - i + 1

        self.Points[i], self.Points[j] =
            self.Points[j], self.Points[i]

        self.Areas[i], self.Areas[j] =
            self.Areas[j], self.Areas[i]

    end

    self:SetCurrent(1)

end

----------------------------------------------------------
-- Trim
----------------------------------------------------------

function Path:Trim(index)

    index = math.Clamp(index or self.Index, 1, #self.Points)

    for i = index - 1, 1, -1 do

        table.remove(self.Points, i)
        table.remove(self.Areas, i)

    end

    self:SetCurrent(1)

end

----------------------------------------------------------
-- Optimize
----------------------------------------------------------

function Path:Optimize(minDistance)

    minDistance = minDistance or 16

    local sqr = minDistance * minDistance

    local optimizedPoints = {}
    local optimizedAreas = {}

    local last

    for i = 1, #self.Points do

        local point = self.Points[i]

        if not last or last:DistToSqr(point) >= sqr then

            optimizedPoints[#optimizedPoints + 1] = point
            optimizedAreas[#optimizedAreas + 1] = self.Areas[i]

            last = point

        end

    end

    self.Points = optimizedPoints
    self.Areas = optimizedAreas

    self:SetCurrent(1)

end

----------------------------------------------------------
-- Serialize
----------------------------------------------------------

function Path:Serialize()

    local data = {

        Index = self.Index,

        Ready = self.Ready,

        Valid = self.Valid,

        Finished = self.Finished,

        Points = {},

        Areas = {}

    }

    for i = 1, #self.Points do

        local p = self.Points[i]

        data.Points[i] = {

            x = p.x,
            y = p.y,
            z = p.z

        }

        local area = self.Areas[i]

        if area then
            data.Areas[i] = area:GetID()
        end

    end

    return data

end

----------------------------------------------------------
-- Deserialize
----------------------------------------------------------

function Path:Deserialize(data)

    self:Reset()

    if not data then
        return false
    end

    for i = 1, #(data.Points or {}) do

        local p = data.Points[i]

        self.Points[i] = Vector(
            p.x,
            p.y,
            p.z
        )

        local id = data.Areas and data.Areas[i]

        if id then
            self.Areas[i] = navmesh.GetNavAreaByID(id)
        end

    end

    self.Index = data.Index or 1
    self.Ready = data.Ready or false
    self.Valid = data.Valid or false
    self.Finished = data.Finished or false

    self:SetCurrent(self.Index)

    return true

end

----------------------------------------------------------
-- Draw
----------------------------------------------------------

function Path:Draw(duration)

    duration = duration or 0.1

    for i = 1, #self.Points do

        debugoverlay.Cross(
            self.Points[i],
            6,
            duration,
            Color(0, 200, 255),
            true
        )

        if i < #self.Points then

            debugoverlay.Line(
                self.Points[i],
                self.Points[i + 1],
                duration,
                Color(0, 255, 0),
                true
            )

        end

    end

end

----------------------------------------------------------
-- Draw Current
----------------------------------------------------------

function Path:DrawCurrent(duration)

    if not self.CurrentPoint then
        return
    end

    debugoverlay.Sphere(
        self.CurrentPoint,
        12,
        duration or 0.1,
        Color(255, 200, 0),
        true
    )

end

----------------------------------------------------------
-- Draw Areas
----------------------------------------------------------

function Path:DrawAreas(duration)

    duration = duration or 0.1

    for _, area in ipairs(self.Areas) do

        if area then
            area:Draw()
        end

    end

end

----------------------------------------------------------
-- Clear Debug
----------------------------------------------------------

function Path:ClearDebug()

    debugoverlay.Clear()

end

----------------------------------------------------------
-- Dump
----------------------------------------------------------

function Path:Dump()

    print("========== PATH ==========")
    print("Points    :", #self.Points)
    print("Areas     :", #self.Areas)
    print("Index     :", self.Index)
    print("Progress  :", string.format("%.2f%%", self:GetProgress() * 100))
    print("Ready     :", self.Ready)
    print("Valid     :", self.Valid)
    print("Finished  :", self.Finished)
    print("Dirty     :", self.Dirty)
    print("Compute   :", self.LastCompute)
    print("==========================")

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.Path = Path

return Path