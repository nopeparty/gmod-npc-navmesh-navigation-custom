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

    self.NextUpdate = 0

    self.UpdateInterval = 0.15

    self.RepathDistance = 128

end

----------------------------------------------------------
-- Think
----------------------------------------------------------

function AI:Think()

    if CurTime() < self.NextUpdate then
        return
    end

    self.NextUpdate = CurTime() + self.UpdateInterval

    local npc = self:GetEntity()

    if not IsValid(npc) then
        return
    end

    local goal = self:GetComponent("Goal")

    if not goal then
        return
    end

    local enemy = npc:GetEnemy()

    ------------------------------------------------------
    -- Lost Enemy
    ------------------------------------------------------

    if not IsValid(enemy) then

        if self.Enemy then

            self.Enemy = nil

            if goal.Clear then
                goal:Clear()
            end

            self:GetNavigator():Fire(
                "EnemyLost"
            )

        end

        return

    end

    ------------------------------------------------------
    -- New Enemy
    ------------------------------------------------------

    if enemy ~= self.Enemy then

        self.Enemy = enemy

        goal:SetEntity(enemy)

        self:GetNavigator():Fire(

            "EnemyChanged",

            enemy

        )

        return

    end

    ------------------------------------------------------
    -- Enemy moved
    ------------------------------------------------------

    local pos = enemy:GetPos()

    if not goal.Position then

        goal:SetEntity(enemy)

        return

    end

    if goal.Position:DistToSqr(pos) >
        self.RepathDistance * self.RepathDistance then

        goal:SetEntity(enemy)

    end

end

----------------------------------------------------------
-- Export
----------------------------------------------------------

ZNavigator.Components.AI = AI

return AI
