--================================================================--
-- ZNavigator
-- init.lua
--================================================================--

ZNavigator = ZNavigator or {}

ZNavigator.Version = "1.0.0"

ZNavigator.Core = ZNavigator.Core or {}
ZNavigator.Components = ZNavigator.Components or {}
ZNavigator.Services = ZNavigator.Services or {}
ZNavigator.Utils = ZNavigator.Utils or {}

--------------------------------------------------------------------
-- Loader
--------------------------------------------------------------------

local function Include(path)

    if SERVER then
        AddCSLuaFile(path)
    end

    return include(path)

end

--------------------------------------------------------------------
-- Core
--------------------------------------------------------------------
print("[ZN] class")
Include("znavigator/core/class.lua")
print("[ZN] signal")
Include("znavigator/core/signal.lua")
print("[ZN] component")
Include("znavigator/core/component.lua")
print("[ZN] fsm")
Include("znavigator/core/fsm.lua")

--------------------------------------------------------------------
-- Services
--------------------------------------------------------------------

print("[ZN] navmesh")
Include("znavigator/services/navmesh.lua")
print("[ZN] pathfinder")
Include("znavigator/services/pathfinder.lua")
print("[ZN] trace")
Include("znavigator/services/trace.lua")

--------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------

print("[ZN] math")
Include("znavigator/utils/math.lua")
print("[ZN] nav util")
Include("znavigator/utils/navmesh.lua")

--------------------------------------------------------------------
-- Components
--------------------------------------------------------------------

print("[ZN] runtime")
Include("znavigator/components/runtime.lua")
print("[ZN] ai")
Include("znavigator/components/ai.lua")
print("[ZN] navigation")
Include("znavigator/components/navigation.lua")
print("[ZN] goal")
Include("znavigator/components/goal.lua")
print("[ZN] path")
Include("znavigator/components/path.lua")
print("[ZN] waypoint")
Include("znavigator/components/waypoint.lua")
print("[ZN] movement")
Include("znavigator/components/movement.lua")
print("[ZN] jump")
Include("znavigator/components/jump.lua")
print("[ZN] stuck")
Include("znavigator/components/stuck.lua")
print("[ZN] object")
Include("znavigator/components/object.lua")
print("[ZN] debug")
Include("znavigator/components/debug.lua")

--------------------------------------------------------------------
-- Navigator
--------------------------------------------------------------------

print("[ZN] navigator")
Include("znavigator/core/navigator.lua")
print("[ZN] done")

--------------------------------------------------------------------
-- Factory
--------------------------------------------------------------------

function ZNavigator.Attach(ent)

    return ZNavigator.Core.Navigator.Attach(ent)

end

function ZNavigator.Get(ent)

    return ZNavigator.Core.Navigator.Get(ent)

end

function ZNavigator.Remove(ent)

    return ZNavigator.Core.Navigator.Remove(ent)

end

--------------------------------------------------------------------
-- NPC Helper
--------------------------------------------------------------------

function ZNavigator.AttachNPC(npc)

	print("[ZN] AttachNPC called", npc)

    local nav = ZNavigator.Attach(npc)

    if not nav then
        return nil
    end

    --nav:AddComponent(
    --    ZNavigator.Components.Runtime.new(nav)
    --)

	-- 여기만 수정
    local runtime = ZNavigator.Components.Runtime:new(nav)

    print("[ZN] metatable =", getmetatable(runtime))
    PrintTable(getmetatable(runtime))
	
	print("[ZN] Runtime table =", ZNavigator.Components.Runtime)
	PrintTable(ZNavigator.Components)
	
	print("[ZN] Runtime class name =", ZNavigator.Components.Runtime:GetClassName())
	
    nav:AddComponent(runtime)

    -- 아래는 그대로 둠

	nav:AddComponent(
    	ZNavigator.Components.AI:new(nav)
	)


    nav:AddComponent(
        ZNavigator.Components.Goal:new(nav)
    )

    nav:AddComponent(
        ZNavigator.Components.Path:new(nav)
    )

    nav:AddComponent(
        ZNavigator.Components.Waypoint:new(nav)
    )

    nav:AddComponent(
        ZNavigator.Components.Movement:new(nav)
    )

    nav:AddComponent(
        ZNavigator.Components.Jump:new(nav)
    )

    nav:AddComponent(
        ZNavigator.Components.Stuck:new(nav)
    )

    nav:AddComponent(
        ZNavigator.Components.Object:new(nav)
    )

    nav:AddComponent(
        ZNavigator.Components.Debug:new(nav)
    )

    nav:Initialize()
	
	print("[ZN] Attached", nav)

    return nav

end

--------------------------------------------------------------------
-- Global Update
--------------------------------------------------------------------

hook.Add("Think", "ZNavigator.Update", function()

    if not ZNavigator.Core.Navigator then
		return
	end

    ZNavigator.Core.Navigator.UpdateAll(FrameTime())

end)

--------------------------------------------------------------------
-- Cleanup
--------------------------------------------------------------------

hook.Add("PostCleanupMap", "ZNavigator.Reset", function()

    if not ZNavigator.Core.Navigator then
        return
    end

    ZNavigator.Core.Navigator.Clear()

end)

--------------------------------------------------------------------
-- Entity Removed
--------------------------------------------------------------------

hook.Add("EntityRemoved", "ZNavigator.EntityRemoved", function(ent)

    ZNavigator.Remove(ent)

end)

--------------------------------------------------------------------
-- Export
--------------------------------------------------------------------

return ZNavigator
