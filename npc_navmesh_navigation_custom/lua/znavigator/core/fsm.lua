--================================================================--
-- ZNavigator
-- core/fsm.lua
-- Part 1 / 3
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Core = ZNavigator.Core or {}

local Class = ZNavigator.Core.Class

local FSM = Class.Create("FSM")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function FSM:Initialize(owner)

    self.Owner = owner

    self.States = {}

    self.Current = nil
    self.Previous = nil

    self.StateData = nil

    self.Time = 0
    self.Elapsed = 0

end

----------------------------------------------------------
-- Owner
----------------------------------------------------------

function FSM:GetNavigator()

    return self.Owner

end

----------------------------------------------------------
-- Register
----------------------------------------------------------

function FSM:Register(name, state)

    assert(type(name) == "string", "State name expected.")

    state = state or {}

    state.Name = name

    self.States[name] = state

    return state

end

----------------------------------------------------------
-- Remove
----------------------------------------------------------

function FSM:Remove(name)

    self.States[name] = nil

end

----------------------------------------------------------
-- Exists
----------------------------------------------------------

function FSM:HasState(name)

    return self.States[name] ~= nil

end

----------------------------------------------------------
-- Getter
----------------------------------------------------------

function FSM:GetState()

    return self.Current

end

function FSM:GetPreviousState()

    return self.Previous

end

function FSM:GetStateObject()

    if not self.Current then
        return nil
    end

    return self.States[self.Current]

end

----------------------------------------------------------
-- Time
----------------------------------------------------------

function FSM:GetTime()

    return self.Time

end

function FSM:GetElapsed()

    return self.Elapsed

end

----------------------------------------------------------
-- Data
----------------------------------------------------------

function FSM:GetStateData()

    return self.StateData

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function FSM:Is(state)

    return self.Current == state

end

function FSM:IsValid()

    return self.Current ~= nil

end

----------------------------------------------------------
-- Iterator
----------------------------------------------------------

function FSM:ForEach(callback)

    for name, state in pairs(self.States) do

        callback(
            name,
            state
        )

    end

end

----------------------------------------------------------
-- Count
----------------------------------------------------------

function FSM:GetStateCount()

    local count = 0

    for _ in pairs(self.States) do
        count = count + 1
    end

    return count

end

----------------------------------------------------------
-- Internal
----------------------------------------------------------

local function CallStateFunction(state, name, ...)

    if not state then
        return
    end

    local func = state[name]

    if func then
        return func(state, ...)
    end

end

----------------------------------------------------------
-- Transition
----------------------------------------------------------

function FSM:CanTransition(nextState, ...)

    if not self:HasState(nextState) then
        return false
    end

    local current = self:GetStateObject()

    if current and current.CanExit then

        if current:CanExit(nextState, ...) == false then
            return false
        end

    end

    local target = self.States[nextState]

    if target.CanEnter then

        if target:CanEnter(self.Current, ...) == false then
            return false
        end

    end

    return true

end

----------------------------------------------------------
-- Set State
----------------------------------------------------------

function FSM:Set(name, ...)

    if not self:HasState(name) then
        return false
    end

    if self.Current == name then
        return false
    end

    local previousState = self:GetStateObject()

    if previousState then

        CallStateFunction(
            previousState,
            "Exit",
            self.Owner,
            name,
            ...
        )

    end

    self.Previous = self.Current
    self.Current = name

    self:SetStateData(...)

    self.Time = CurTime()
    self.Elapsed = 0

    local currentState = self:GetStateObject()

    if currentState then

        CallStateFunction(
            currentState,
            "Enter",
            self.Owner,
            self.Previous,
            ...
        )

    end

    return true

end

----------------------------------------------------------
-- Try Set
----------------------------------------------------------

function FSM:TrySet(name, ...)

    if not self:CanTransition(name, ...) then
        return false
    end

    return self:Set(name, ...)

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function FSM:Update(dt)

    if not self.Current then
        return
    end

    self.Elapsed = self.Elapsed + dt

    local state = self:GetStateObject()

    if not state then
        return
    end

    local data = self.StateData

    if data then

        CallStateFunction(

            state,

            "Update",

            self.Owner,

            dt,

            table.unpack(
                data,
                1,
                data.n
            )

        )

    else

        CallStateFunction(

            state,

            "Update",

            self.Owner,

            dt

        )

    end

end

----------------------------------------------------------
-- Think
----------------------------------------------------------

function FSM:Think()

    local state = self:GetStateObject()

    if not state then
        return
    end

    CallStateFunction(

        state,

        "Think",

        self.Owner

    )

end

----------------------------------------------------------
-- LateUpdate
----------------------------------------------------------

function FSM:LateUpdate(dt)

    local state = self:GetStateObject()

    if not state then
        return
    end

    CallStateFunction(

        state,

        "LateUpdate",

        self.Owner,

        dt

    )

end

----------------------------------------------------------
-- State Time
----------------------------------------------------------

function FSM:GetStateTime()

    return CurTime() - self.Time

end

----------------------------------------------------------
-- Helpers
----------------------------------------------------------

function FSM:HasCurrentState()

    return self.Current ~= nil

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function FSM:Reset()

    local state = self:GetStateObject()

    if state then

        CallStateFunction(

            state,

            "Exit",

            self.Owner,

            nil

        )

    end

    self.Current = nil
    self.Previous = nil

    self.Time = 0
    self.Elapsed = 0

    if self.StateData then

        table.Empty(self.StateData)

    end

end

----------------------------------------------------------
-- State Data
----------------------------------------------------------

function FSM:SetStateData(...)

    self.StateData = self.StateData or {}

    table.Empty(self.StateData)

    local n = select("#", ...)

    for i = 1, n do

        self.StateData[i] = select(i, ...)

    end

    self.StateData.n = n

end

function FSM:ClearStateData()

    if self.StateData then
        table.Empty(self.StateData)
    end

end

----------------------------------------------------------
-- Destroy
----------------------------------------------------------

function FSM:Destroy()

    self:Reset()

    table.Empty(self.States)

    self.Owner = nil
    self.States = nil
    self.StateData = nil

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function FSM:Dump()

    print("--------------------------------")

    print("Current  :", self.Current or "None")
    print("Previous :", self.Previous or "None")
    print("Elapsed  :", self.Elapsed)
    print("States   :", self:GetStateCount())

    print("--------------------------------")

end

----------------------------------------------------------
-- tostring
----------------------------------------------------------

function FSM:__tostring()

    return string.format(

        "FSM<State=%s>",

        self.Current or "None"

    )

end

----------------------------------------------------------
-- Iterator
----------------------------------------------------------

function FSM:States()

    return pairs(self.States)

end

----------------------------------------------------------
-- Static
----------------------------------------------------------

function FSM.Create(owner)

    return FSM:new(owner)

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Core.FSM = FSM

return FSM