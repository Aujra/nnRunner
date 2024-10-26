runner.Routines.DungeonRoutine = runner.Routines.BaseRoutine:extend()
local DungeonRoutine = runner.Routines.DungeonRoutine
runner.Routines.DungeonRoutine = DungeonRoutine

function DungeonRoutine:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "DungeonRoutine"
    self.Description = "DungeonRoutine"
end

function DungeonRoutine:Run()
    if not IsInInstance() then
        return
    end

    local player = runner.LocalPlayer
    local role = player.Role

    if role == "TANK" then
        local closestEnemy = self:GetClosestEnemy()
        if closestEnemy then
            if closestEnemy:DistanceFromPlayer() > 30 then
                print("Moving to enemy")
                runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
            else
                print("Fight stuff")
                Unlock(TargetUnit, closestEnemy.pointer)
                if not UnitAffectingCombat("player") then
                    Unlock(CastSpellByName, "Throw Glaive", closestEnemy.pointer)
                end
                runner.Engine.Navigation:FaceUnit(closestEnemy.pointer)
                if closestEnemy:DistanceFromPlayer() > 6 then
                    Unlock(MoveForwardStart)
                else
                    Unlock(MoveForwardStop)
                end
                runner.rotation:Pulse(closestEnemy)
            end
        end
    else
        local tank = self:GetTank()
        if tank then
            if tank:DistanceFromPlayer() > 20 then
                runner.Engine.Navigation:MoveTo(tank)
            else
                local target = Unlock(AssistUnit, tank.pointer)
                Unlock(CastSpellByName, "Throw Glaive", target)
                runner.rotation:Pulse(target)
            end
        end
    end
end

function DungeonRoutine:GetTank()
    for i, unit in ipairs(runner.Engine.ObjectManager.players) do
        if unit.Role == "TANK" then
            return unit
        end
    end
    return nil
end

function DungeonRoutine:GetClosestEnemy()
    local player = runner.LocalPlayer
    local closestEnemy = nil
    local closestDistance = 9999

    for k, enemy in pairs(runner.Engine.ObjectManager.units) do
        if enemy.Reaction and enemy.Reaction < 4 and not enemy.isDead and enemy.CanAttack then
            local distance = enemy:DistanceFromPlayer()
            if distance < closestDistance then
                closestEnemy = enemy
                closestDistance = distance
            end
        end
    end
    return closestEnemy
end

registerRoutine(DungeonRoutine)