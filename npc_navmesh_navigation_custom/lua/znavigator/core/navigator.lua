--================================================================--
-- ZNavigator
-- core/navigator.lua
-- Part 1-1
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Core = ZNavigator.Core or {}

local Class = ZNavigator.Core.Class
local FSM = ZNavigator.Core.FSM

local Navigator = Class.Create("Navigator")

----------------------------------------------------------
-- Registry
----------------------------------------------------------

local Registry = setmetatable({}, {

    __mode = "k"

})

----------------------------------------------------------
-- Constructor
----------------------------------------------------------

function Navigator:Setup(entity)

    assert(

        IsValid(entity),

        "Navigator requires a valid entity."

    )

    ------------------------------------------------------
    -- Entity
    ------------------------------------------------------

    self.Entity = entity

    ------------------------------------------------------
    -- Runtime
    ------------------------------------------------------

    self.Enabled = true
    self.Initialized = false
    self.Destroyed = false

    self.Time = 0
    self.DeltaTime = 0
    self.Frame = 0

    ------------------------------------------------------
    -- Components
    ------------------------------------------------------

    self.Components = {}
    self.ComponentMap = {}

    self.ComponentCount = 0
    self.ComponentDirty = false

    ------------------------------------------------------
    -- Cache
    ------------------------------------------------------

    self.Cache = {}

    ------------------------------------------------------
    -- Data
    ------------------------------------------------------

    self.Data = {}

    ------------------------------------------------------
    -- FSM
    ------------------------------------------------------

    self.FSM = FSM:new(self)

    ------------------------------------------------------
    -- Signals
    ------------------------------------------------------

    self.Signals = {}

    ------------------------------------------------------
    -- Register
    ------------------------------------------------------

    Registry[self.Entity] = self

    self.Entity.ZNavigator = self

end

----------------------------------------------------------
-- Entity
----------------------------------------------------------

function Navigator:GetEntity()

    return self.Entity

end

function Navigator:IsValid()

    return IsValid(self.Entity)

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Navigator:IsEnabled()

    return self.Enabled

end

function Navigator:SetEnabled(state)

    self.Enabled = state == true

end

function Navigator:IsInitialized()

    return self.Initialized

end

function Navigator:IsDestroyed()

    return self.Destroyed

end

function Navigator:GetFrame()

    return self.Frame

end

function Navigator:GetTime()

    return self.Time

end

function Navigator:GetDeltaTime()

    return self.DeltaTime

end

----------------------------------------------------------
-- Cache
----------------------------------------------------------

function Navigator:SetCache(key, value)

    self.Cache[key] = value

end

function Navigator:GetCache(key, default)

    local value = self.Cache[key]

    if value == nil then
        return default
    end

    return value

end

function Navigator:ClearCache()

    table.Empty(self.Cache)

end

----------------------------------------------------------
-- Data
----------------------------------------------------------

function Navigator:SetData(key, value)

    self.Data[key] = value

end

function Navigator:GetData(key, default)

    local value = self.Data[key]

    if value == nil then
        return default
    end

    return value

end

----------------------------------------------------------
-- FSM
----------------------------------------------------------

function Navigator:GetFSM()

    return self.FSM

end

function Navigator:SetState(state, ...)

    return self.FSM:Set(state, ...)

end

function Navigator:TrySetState(state, ...)

    return self.FSM:TrySet(state, ...)

end

function Navigator:GetState()

    return self.FSM:GetState()

end

function Navigator:IsState(state)

    return self.FSM:Is(state)

end

----------------------------------------------------------
-- Signals
----------------------------------------------------------

function Navigator:RegisterSignal(name)

    local signal = self.Signals[name]

    if signal then
        return signal
    end

    signal = ZNavigator.Core.Signal:new()

    self.Signals[name] = signal

    return signal

end

function Navigator:GetSignal(name)

    return self.Signals[name]

end

function Navigator:Connect(name, callback)

    local signal = self:RegisterSignal(name)

    return signal:Connect(callback)

end

function Navigator:Once(name, callback)

    local signal = self:RegisterSignal(name)

    return signal:Once(callback)

end

function Navigator:Fire(name, ...)

    local signal = self.Signals[name]

    if signal then
        signal:Fire(...)
    end

end

----------------------------------------------------------
-- Components
----------------------------------------------------------

function Navigator:GetComponents()

    return self.Components

end

function Navigator:GetComponentCount()

    return self.ComponentCount

end

function Navigator:GetComponent(name)

    return self.ComponentMap[name]

end

function Navigator:HasComponent(name)

    return self.ComponentMap[name] ~= nil

end

----------------------------------------------------------
-- Component Iterator
----------------------------------------------------------

function Navigator:ForEachComponent(callback)

    for i = 1, self.ComponentCount do

        callback(
            self.Components[i],
            i
        )

    end

end

----------------------------------------------------------
-- Component Lookup
----------------------------------------------------------

function Navigator:FindComponent(predicate)

    for i = 1, self.ComponentCount do

        local component = self.Components[i]

        if predicate(component) then
            return component
        end

    end

    return nil

end

----------------------------------------------------------
-- Component Refresh
----------------------------------------------------------

function Navigator:RefreshComponents()

    self.ComponentDirty = true

end

----------------------------------------------------------
-- Validation
----------------------------------------------------------

function Navigator:CanUpdate()

    return self.Enabled
       and self.Initialized
       and not self.Destroyed
       and self:IsValid()

end

----------------------------------------------------------
-- Component Sorting
----------------------------------------------------------

function Navigator:SortComponents()

    if not self.ComponentDirty then
        return
    end

    for i, c in ipairs(self.Components) do
        print(
            "[ZN] Sort",
            i,
            c:GetName(),
            "Priority =",
            c:GetPriority()
        )
    end

    --table.sort(self.Components, function(a, b)

--        return a:GetPriority() < b:GetPriority()

--    end)
	
	table.sort(self.Components, function(a, b)

		local pa = a.Priority or 100
		local pb = b.Priority or 100

		return pa < pb

	end)
	
    self.ComponentDirty = false

end

----------------------------------------------------------
-- Add Component
----------------------------------------------------------

function Navigator:AddComponent(component)

    assert(component, "Component expected.")

    local name = component:GetName()

    if self.ComponentMap[name] then
        return self.ComponentMap[name]
    end

    ------------------------------------------------------
    -- Owner
    ------------------------------------------------------

    if component.Setup then
		component:Setup(self)
	else
		component.Owner = self
	end
	
	print(
		"[ZN] Component",
		component:GetName(),
		"Priority",
		component.Priority
	)

    ------------------------------------------------------
    -- Insert
    ------------------------------------------------------

    self.ComponentCount = self.ComponentCount + 1

    self.Components[self.ComponentCount] = component

    self.ComponentMap[name] = component

    self.ComponentDirty = true

    ------------------------------------------------------
    -- Initialize
    ------------------------------------------------------

    if self.Initialized then

        self:SortComponents()

        if component._Initialize then
            component:_Initialize()
        elseif component.Initialize then
            component:Initialize()
        end

    end

    return component

end

----------------------------------------------------------
-- Remove Component
----------------------------------------------------------

function Navigator:RemoveComponent(name)

    local component = self.ComponentMap[name]

    if not component then
        return false
    end

    if component._Destroy then
        component:_Destroy()
    elseif component.Destroy then
        component:Destroy()
    end

    self.ComponentMap[name] = nil

    for i = 1, self.ComponentCount do

        if self.Components[i] == component then

            table.remove(self.Components, i)

            self.ComponentCount = self.ComponentCount - 1

            break

        end

    end

    self.ComponentDirty = true

    return true

end

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Navigator:InitializeComponents()

    self:SortComponents()

    for i = 1, self.ComponentCount do

        local component = self.Components[i]

        if component._Initialize then

            component:_Initialize()

        elseif component.Initialize then

            component:Initialize()

        end

    end

end

----------------------------------------------------------
-- Initialize Navigator
----------------------------------------------------------

function Navigator:Initialize(entity)

	if entity then
        self:Setup(entity)
    end

    if self.Initialized then
        return
    end

    self.Initialized = true

    self:InitializeComponents()

    self:Fire("Initialize", self)

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Navigator:UpdateRuntime(dt)

    self.Time = CurTime()
    self.Frame = FrameNumber()
    self.DeltaTime = dt or FrameTime()

end

----------------------------------------------------------
-- Think Components
----------------------------------------------------------

function Navigator:ThinkComponents()

    for i = 1, self.ComponentCount do

        local component = self.Components[i]

        if component:CanTick() then

            if component.Think then

                component:Think()

            end

        end

    end

end

----------------------------------------------------------
-- Update Components
----------------------------------------------------------

function Navigator:UpdateComponents(dt)

    for i = 1, self.ComponentCount do

        local component = self.Components[i]

        if component:CanTick() then

            if component.Update then

                component:Update(dt)

            end

        end

    end

end

----------------------------------------------------------
-- Late Update Components
----------------------------------------------------------

function Navigator:LateUpdateComponents(dt)

    for i = 1, self.ComponentCount do

        local component = self.Components[i]

        if component:CanTick() then

            if component.LateUpdate then

                component:LateUpdate(dt)

            end

        end

    end

end

----------------------------------------------------------
-- Main Update
----------------------------------------------------------

function Navigator:Update(dt)
	
	--print("[ZN] Navigator Update")
	
	--print("[ZN] Update", self:GetEntity())
	
    if self.Destroyed then
        return
    end

    if not self.Initialized then
        self:Initialize()
    end

    if not self:CanUpdate() then
        return
    end

    if self.ComponentDirty then
        self:SortComponents()
    end

    self:UpdateRuntime(dt)

    ------------------------------------------------------
    -- FSM
    ------------------------------------------------------

    self.FSM:Update(self.DeltaTime)

    ------------------------------------------------------
    -- Think
    ------------------------------------------------------

    self:ThinkComponents()

    ------------------------------------------------------
    -- Update
    ------------------------------------------------------

    self:UpdateComponents(self.DeltaTime)

    ------------------------------------------------------
    -- Late Update
    ------------------------------------------------------

    self:LateUpdateComponents(self.DeltaTime)

    ------------------------------------------------------
    -- Event
    ------------------------------------------------------

    self:Fire(

        "Update",

        self,

        self.DeltaTime

    )

end

----------------------------------------------------------
-- Tick Alias
----------------------------------------------------------

Navigator.Tick = Navigator.Update

----------------------------------------------------------
-- Pause
----------------------------------------------------------

function Navigator:Pause()

    self.Enabled = false

end

function Navigator:Resume()

    self.Enabled = true

end

----------------------------------------------------------
-- Reload
----------------------------------------------------------

function Navigator:Reload()

    self:InitializeComponents()

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function Navigator:Reset()

    self:ClearCache()

    self.FSM:Reset()

    for i = 1, self.ComponentCount do

        local component = self.Components[i]

        if component.Reset then

            component:Reset()

        end

    end

    self:Fire("Reset", self)

end

----------------------------------------------------------
-- Shutdown Components
----------------------------------------------------------

function Navigator:ShutdownComponents()

    for i = self.ComponentCount, 1, -1 do

        local component = self.Components[i]

        if component._Destroy then

            component:_Destroy()

        elseif component.Destroy then

            component:Destroy()

        end

    end

    table.Empty(self.Components)
    table.Empty(self.ComponentMap)

    self.ComponentCount = 0
    self.ComponentDirty = false

end

----------------------------------------------------------
-- Destroy Signals
----------------------------------------------------------

function Navigator:DestroySignals()

    for _, signal in pairs(self.Signals) do

        signal:Destroy()

    end

    table.Empty(self.Signals)

end

----------------------------------------------------------
-- Destroy
----------------------------------------------------------

function Navigator:Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed = true

    self:Fire("Destroy", self)

    ------------------------------------------------------
    -- Components
    ------------------------------------------------------

    self:ShutdownComponents()

    ------------------------------------------------------
    -- FSM
    ------------------------------------------------------

    if self.FSM then

        self.FSM:Destroy()

        self.FSM = nil

    end

    ------------------------------------------------------
    -- Signals
    ------------------------------------------------------

    self:DestroySignals()

    ------------------------------------------------------
    -- Cache / Data
    ------------------------------------------------------

    table.Empty(self.Cache)
    table.Empty(self.Data)

    ------------------------------------------------------
    -- Registry
    ------------------------------------------------------

    Registry[self.Entity] = nil

    if IsValid(self.Entity) then

        self.Entity.ZNavigator = nil

    end

    self.Entity = nil

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Navigator:Dump()

    print("--------------------------------")

    print("Navigator")

    print("Initialized :", self.Initialized)
    print("Destroyed   :", self.Destroyed)
    print("Enabled     :", self.Enabled)

    print("Components  :", self.ComponentCount)

    if self:IsValid() then
        print("Entity      :", self.Entity)
    end

    print("--------------------------------")

end

----------------------------------------------------------
-- tostring
----------------------------------------------------------

function Navigator:__tostring()

    return string.format(

        "Navigator<%s>",

        tostring(self.Entity)

    )

end

----------------------------------------------------------
-- Registry API
----------------------------------------------------------

function Navigator.Get(entity)

    if not IsValid(entity) then
        return nil
    end

    return Registry[entity]

end

function Navigator.Attach(entity)

    if not IsValid(entity) then
        return nil
    end

    local navigator = Registry[entity]

    if navigator then
        return navigator
    end

    navigator = Navigator:new(entity)

    Registry[entity] = navigator

	print("[ZN] Attach", entity)
	
    return navigator

end

function Navigator.Remove(entity)

    local navigator = Navigator.Get(entity)

    if not navigator then
        return false
    end

    navigator:Destroy()

    return true

end

----------------------------------------------------------
-- Registry Iterator
----------------------------------------------------------

function Navigator.ForEach(callback)

    assert(isfunction(callback), "Callback expected.")

    for _, navigator in pairs(Registry) do

        callback(navigator)

    end

end

----------------------------------------------------------
-- Registry Count
----------------------------------------------------------

function Navigator.Count()

    local count = 0

    for _ in pairs(Registry) do

        count = count + 1

    end

    return count

end

----------------------------------------------------------
-- Update All
----------------------------------------------------------

function Navigator.UpdateAll(dt)

	--print("[ZN] Registry Count", Navigator.Count())

    for entity, navigator in pairs(Registry) do

        if not IsValid(entity) then

            navigator:Destroy()

        else

            navigator:Update(dt)

        end

    end

end

----------------------------------------------------------
-- Clear Registry
----------------------------------------------------------

function Navigator.Clear()

    local list = {}

    for _, navigator in pairs(Registry) do

        list[#list + 1] = navigator

    end

    for i = 1, #list do

        list[i]:Destroy()

    end

end

----------------------------------------------------------
-- Exists
----------------------------------------------------------

function Navigator.Exists(entity)

    return Navigator.Get(entity) ~= nil

end

----------------------------------------------------------
-- Factory
----------------------------------------------------------

function Navigator.Create(entity)

    return Navigator.Attach(entity)

end

----------------------------------------------------------
-- Metamethods
----------------------------------------------------------

Navigator.__call = function(self, dt)

    return self:Update(dt)

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Core.Navigator = Navigator

return Navigator