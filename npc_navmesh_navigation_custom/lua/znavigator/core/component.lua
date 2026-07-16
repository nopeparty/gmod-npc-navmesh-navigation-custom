--================================================================--
-- ZNavigator
-- core/component.lua
-- Part 1 / 2
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Core = ZNavigator.Core or {}

local Class = ZNavigator.Core.Class

local Component = Class.Create("Component")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Component:Initialize()

end

----------------------------------------------------------
-- Constructor
----------------------------------------------------------

function Component:Setup(navigator)

    assert(navigator, "Navigator expected.")

    self.Owner = navigator

    self.Enabled = true

    self.Priority = 100

end

----------------------------------------------------------
-- Name
----------------------------------------------------------

function Component:GetName()

    return self:GetClassName()

end

----------------------------------------------------------
-- Navigator
----------------------------------------------------------

function Component:GetNavigator()

    return self.Owner

end

----------------------------------------------------------
-- Entity
----------------------------------------------------------

function Component:GetEntity()

    return self.Owner:GetEntity()

end

----------------------------------------------------------
-- Runtime
----------------------------------------------------------

function Component:GetComponent(name)

    return self.Owner:GetComponent(name)

end

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function Component:SetEnabled(state)

    self.Enabled = state == true

end

function Component:IsEnabled()

    return self.Enabled

end

----------------------------------------------------------
-- Priority
----------------------------------------------------------

function Component:SetPriority(priority)

    self.Priority = priority

end

function Component:GetPriority()

    return self.Priority

end

----------------------------------------------------------
-- Tick
----------------------------------------------------------

function Component:CanTick()

    return self.Enabled

end

----------------------------------------------------------
-- Events
----------------------------------------------------------

function Component:Fire(...)

    return self.Owner:Fire(...)

end

function Component:Connect(...)

    return self.Owner:Connect(...)

end

----------------------------------------------------------
-- Cache
----------------------------------------------------------

function Component:SetCache(key, value)

    self.Owner:SetCache(key, value)

end

function Component:GetCache(key, default)

    return self.Owner:GetCache(key, default)

end

----------------------------------------------------------
-- Data
----------------------------------------------------------

function Component:SetData(key, value)

    self.Owner:SetData(key, value)

end

function Component:GetData(key, default)

    return self.Owner:GetData(key, default)

end

----------------------------------------------------------
-- Update
----------------------------------------------------------

function Component:Think()

end

function Component:Update(dt)

end

function Component:LateUpdate(dt)

end

function Component:Reset()

end

function Component:Destroy()

end

----------------------------------------------------------
-- Helpers
----------------------------------------------------------

function Component:HasNavigator()

    return self.Owner ~= nil

end

function Component:HasEntity()

    return self.Owner ~= nil
        and self.Owner:IsValid()

end

----------------------------------------------------------
-- State
----------------------------------------------------------

function Component:IsDestroyed()

    return self.Destroyed == true

end

function Component:IsInitialized()

    return self.Initialized == true

end

----------------------------------------------------------
-- Lifecycle
----------------------------------------------------------

function Component:OnInitialize()

end

function Component:OnEnable()

end

function Component:OnDisable()

end

function Component:OnDestroy()

end

----------------------------------------------------------
-- Internal
----------------------------------------------------------

function Component:_Initialize()

    if self.Initialized then
        return
    end

    self.Initialized = true

    self:OnInitialize()

    if self.Initialize then
        self:Initialize()
    end

end

function Component:_Destroy()

    if self.Destroyed then
        return
    end

    self.Destroyed = true

    self:OnDestroy()

    if self.Destroy then
        self:Destroy()
    end

    self.Owner = nil

end

----------------------------------------------------------
-- Enable Override
----------------------------------------------------------

function Component:Enable()

    if self.Enabled then
        return
    end

    self.Enabled = true

    self:OnEnable()

end

function Component:Disable()

    if not self.Enabled then
        return
    end

    self.Enabled = false

    self:OnDisable()

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Component:Dump()

    print("--------------------------------")

    print("Component :", self:GetName())
    print("Enabled   :", self.Enabled)
    print("Priority  :", self.Priority)

    if self:HasEntity() then
        print("Entity    :", self:GetEntity())
    end

    print("--------------------------------")

end

----------------------------------------------------------
-- tostring
----------------------------------------------------------

function Component:__tostring()

    return string.format(
        "Component<%s>",
        self:GetName()
    )

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Core.Component = Component

return Component