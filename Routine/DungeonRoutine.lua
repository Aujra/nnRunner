runner.Routines.DungeonRoutine = runner.Routines.BaseRoutine:extend()
local DungeonRoutine = runner.Routines.DungeonRoutine
runner.Routines.DungeonRoutine = DungeonRoutine

function DungeonRoutine:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "DungeonRoutine"
    self.Description = "DungeonRoutine"
    self.Steps = {}
    self.StatusFrame = nil
    self.SettingsFrame = nil
    self.leaveAfter = 0
    self.BlackList = {
        "Vent Stalker", "Speaker Mechhand", "Reinforce Stalker", "Eternal Flame", "Dummy Stalker", "Mini-Boss Stalker"
    }
end

function DungeonRoutine:Run()
    if not IsInInstance() then

    else
        local closestEnemy = self:GetBestScoreEnemy()
        local closestLootable = self:GetClosestLootable()

        if closestLootable and not UnitAffectingCombat("player") then
            if closestLootable:DistanceFromPlayer() > 4 or not closestLootable:LOS() then
                runner.Engine.Navigation:MoveTo(closestLootable.pointer)
            else
                Unlock(MoveForwardStop)
                runner.Engine.Navigation:FaceUnit(closestLootable.pointer)
                runner.nn.ObjectInteract(closestLootable.pointer)
            end
            return
        end

        if closestEnemy then
            if closestEnemy:DistanceFromPlayer() > runner.rotation.PullRange or not closestEnemy:LOS() then
                runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
            else
                if not UnitAffectingCombat("player") then
                    runner.Engine.Navigation:FaceUnit(closestEnemy.pointer)
                runner.rotation:Pull(closestEnemy)
                end
                if closestEnemy:DistanceFromPlayer() > runner.rotation.CombatRange then
                    runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
                else
                    Unlock(TargetUnit, closestEnemy.pointer)
                    runner.Engine.Navigation:FaceUnit(closestEnemy.pointer)
                    Unlock(MoveForwardStop)
                    runner.rotation:Pulse(closestEnemy)
                end
            end
            return
        end
    end
end

function DungeonRoutine:GetClosestLootable()
    local closest = nil
    local closestDistance = 9999
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Lootable and v.isDead then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closest = v
                closestDistance = distance
            end
        end
    end
    return closest
end

function DungeonRoutine:GetBestScoreEnemy()
    local bestScore = 0
    local bestEnemy = nil
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.CanAttack then
            local score = v:GetScore()
            if score > bestScore then
                bestScore = score
                bestEnemy = v
            end
        end
    end
    return bestEnemy
end

registerRoutine(DungeonRoutine)