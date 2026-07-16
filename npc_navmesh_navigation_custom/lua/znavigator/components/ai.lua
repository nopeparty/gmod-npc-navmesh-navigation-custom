--================================================================--
-- ZNavigator
-- components/ai.lua
--================================================================--

ZNavigator = ZNavigator or {}
ZNavigator.Components = ZNavigator.Components or {}

local Component = ZNavigator.Core.Component

local AI = Component:Extend("AI")

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function AI:Initialize()

    self.Enemy = nil

    self.LastGoalUpdate = 0

    self.UpdateInterval = 0.15

    self.RepathDistance = 128

end

----------------------------------------------------------
-- Think
----------------------------------------------------------

function AI:Think()

    local npc = self:GetEntity()

    if not IsValid(npc) then
        return
    end

    if CurTime() < self.LastGoalUpdate then
        return
    end

    self.LastGoalUpdate =
        CurTime() + self.UpdateInterval

    local goal = self:GetComponent("Goal")

    if not goal then
        return
    end

    ------------------------------------------------------
    -- Enemy
    ------------------------------------------------------

    local enemy = npc:GetEnemy()

    if not IsValid(enemy) then

        if self.Enemy then

            self.Enemy = nil

            goal:Clear()

        end

        return

    end

    ------------------------------------------------------
    -- Enemy Changed
    ------------------------------------------------------

    if enemy ~= self.Enemy then

        self.Enemy = enemy

        goal:SetEntity(enemy)

        return

    end

    ------------------------------------------------------
    -- Enemy Moved
    ------------------------------------------------------

    local pos = enemy:GetPos()

    if not goal.Position then

        goal:SetEntity(enemy)

        return

    end

    if goal.Position:DistToSqr(pos)
        > self.RepathDistance * self.RepathDistance then

        goal:SetEntity(enemy)

    end

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.AI = AI

return AI
