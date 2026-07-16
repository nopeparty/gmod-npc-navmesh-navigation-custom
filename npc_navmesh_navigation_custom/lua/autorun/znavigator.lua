--================================================================--
-- ZNavigator
-- autorun/znavigator.lua
--================================================================--

if SERVER then
    AddCSLuaFile()
end

--------------------------------------------------------------------
-- Load
--------------------------------------------------------------------

include("znavigator/init.lua")

--------------------------------------------------------------------
-- Console Commands
--------------------------------------------------------------------

local function GetTarget(ply)

    if not IsValid(ply) then
        return nil
    end

    local tr = ply:GetEyeTrace()

    if not IsValid(tr.Entity) then
        return nil
    end

    return tr.Entity

end

----------------------------------------------------------
-- Attach
----------------------------------------------------------

concommand.Add("znav_attach", function(ply)

    local ent = GetTarget(ply)

    if not IsValid(ent) then
        print("[ZNavigator] Invalid target.")
        return
    end

    local nav = ZNavigator.AttachNPC(ent)

    if nav then
        print("[ZNavigator] Attached:", ent)
    end

end)

----------------------------------------------------------
-- Remove
----------------------------------------------------------

concommand.Add("znav_remove", function(ply)

    local ent = GetTarget(ply)

    if not IsValid(ent) then
        print("[ZNavigator] Invalid target.")
        return
    end

    ZNavigator.Remove(ent)

    print("[ZNavigator] Removed:", ent)

end)

----------------------------------------------------------
-- Debug
----------------------------------------------------------

concommand.Add("znav_debug", function(ply)

    local ent = GetTarget(ply)

    if not IsValid(ent) then
        return
    end

    local nav = ZNavigator.Get(ent)

    if not nav then
        print("[ZNavigator] Navigator not found.")
        return
    end

    local debugComponent = nav:GetComponent("Debug")

    if not debugComponent then
        print("[ZNavigator] Debug component missing.")
        return
    end

    debugComponent:SetEnabled(
        not debugComponent:IsEnabled()
    )

    print(
        "[ZNavigator] Debug:",
        debugComponent:IsEnabled()
    )

end)

----------------------------------------------------------
-- Dump
----------------------------------------------------------

concommand.Add("znav_dump", function(ply)

    local ent = GetTarget(ply)

    if not IsValid(ent) then
        return
    end

    local nav = ZNavigator.Get(ent)

    if not nav then
        print("[ZNavigator] Navigator not found.")
        return
    end

    print("========== ZNavigator ==========")

    print("Entity :", ent)

    print("State  :", nav:GetState())

    print("Components :")

    for _, component in ipairs(nav:GetComponents()) do

        print(
            " -",
            component:GetName(),
            component:IsEnabled()
        )

    end

    print("================================")

end)

----------------------------------------------------------
-- Goal
----------------------------------------------------------

concommand.Add("znav_goal", function(ply)

    print("[ZN] znav_goal start")

    local ent = GetTarget(ply)

    print("[ZN] target =", ent)

    if not IsValid(ent) then
        print("[ZN] target invalid")
        return
    end

    local nav = ZNavigator.Get(ent)

    print("[ZN] nav =", nav)

    if not nav then
        print("[ZN] nav nil")
        return
    end

    local goal = nav:GetComponent("Goal")

    print("[ZN] goal =", goal)

    if not goal then
        print("[ZN] goal nil")
        return
    end

    local tr = ply:GetEyeTrace()

    print("[ZN] trace =", tr.HitPos)

    goal:Set(tr.HitPos)

    print("[ZN] goal set")

end)

----------------------------------------------------------
-- Version
----------------------------------------------------------

concommand.Add("znav_version", function()

    print(
        "[ZNavigator]",
        ZNavigator.Version
    )

end)

----------------------------------------------------------
-- Count
----------------------------------------------------------

concommand.Add("znav_count", function()

    print(
		"[ZNavigator] Active:",
		ZNavigator.Core.Navigator.Count()
	)

end)

----------------------------------------------------------
-- Reload
----------------------------------------------------------

concommand.Add("znav_reload", function()

    RunConsoleCommand("lua_openscript_cl", "autorun/znavigator.lua")

    if SERVER then
        RunConsoleCommand("lua_openscript", "autorun/znavigator.lua")
    end

    print("[ZNavigator] Reload requested.")

end)