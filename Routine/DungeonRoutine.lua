runner.Routines.DungeonRoutine = runner.Routines.BaseRoutine:extend()
local DungeonRoutine = runner.Routines.DungeonRoutine
runner.Routines.DungeonRoutine = DungeonRoutine

function DungeonRoutine:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "DungeonRoutine"
    self.Description = "DungeonRoutine"
    self.Steps = {}
end

function DungeonRoutine:Run()
    if not IsInInstance() then
        return
    end

    local player = runner.LocalPlayer
    local role = player.Role

    local dungeon_profile = self:FindProfile()
    if dungeon_profile then
        if tableCount(self.Steps) == 0 then
            self.Steps = dungeon_profile.Steps
        end
        local step = self.Steps[1]
        local lootable = self:GetClosestLootableEnemy()

        if runner.LocalPlayer.IsDead then
            RePopMe()
            self.Steps = dungeon_profile.Steps
            return
        end

        if lootable and not UnitAffectingCombat("player") then
            if lootable:DistanceFromPlayer() < 4 then
                runner.UI.menuFrame:UpdateStatusText("Moving to loot " .. lootable.Name)
                Unlock(MoveForwardStop)
                runner.nn.ObjectInteract(lootable.pointer)
            else
                runner.UI.menuFrame:UpdateStatusText("Looting " .. lootable.Name)
                runner.Engine.Navigation:MoveTo(lootable.pointer)
            end
            return
        end

        if UnitAffectingCombat("player") then
            if step.Task == "kill" then
                if step.Mechanics and self:NeedToDoMechanic(step.Mechanics) then
                    for k, mechanic in pairs(step.Mechanics) do
                        if self:MechanicConditionMet(mechanic.Condition) then
                            if mechanic.Task == "interact_without_aura" then
                                local interactable = runner.Engine.ObjectManager:GetClosestByName(mechanic.Object)
                                if interactable then
                                    if interactable:DistanceFromPlayer() < 4 then
                                        runner.UI.menuFrame:UpdateStatusText("Interacting with " .. mechanic.Object)
                                        Unlock(MoveForwardStop)
                                        runner.nn.ObjectInteract(interactable.pointer)
                                    else
                                        runner.UI.menuFrame:UpdateStatusText("Move to " .. mechanic.Object)
                                        runner.Engine.Navigation:MoveTo(interactable.pointer)
                                    end
                                end
                            end
                            if mechanic.Task == "move_to_with_aura" then
                                local mob = self:FindMobWithNameAndAura(mechanic.Mob, mechanic.Aura)
                                if mob then
                                    if mob:DistanceFromPlayer() > 8 then
                                        runner.UI.menuFrame:UpdateStatusText("Moving to " .. mechanic.Mob)
                                        runner.Engine.Navigation:MoveTo(mob.pointer)
                                    else
                                        Unlock(MoveForwardStop)
                                    end
                                end
                            end
                        end
                    end
                    return
                else
                    runner.UI.menuFrame:UpdateStatusText("No mechanics to do")
                end
            end

            local closestEnemy = self:GetClosestEnemy()
            if closestEnemy then
                if closestEnemy:DistanceFromPlayer() > runner.rotation.PullRange then
                    runner.UI.menuFrame:UpdateStatusText("Moving to fight " .. closestEnemy.Name)
                    runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
                else
                    Unlock("MoveForwardStop")
                    runner.UI.menuFrame:UpdateStatusText("Fighting " .. closestEnemy.Name)
                    Unlock(TargetUnit, closestEnemy.pointer)
                    runner.Engine.Navigation:FaceUnit(closestEnemy.pointer)
                    runner.rotation:Pulse(closestEnemy)
                end
            end
            return
        end

        if step then
            if self:NeedStep(step) then
                if step.Task == "move_to" then
                    local location = step.Locations[1]
                    local x = location.X
                    local y = location.Y
                    local z = location.Z
                    local radius = location.Radius

                    runner.Draw:Circle(x, y, z, radius)
                    runner.Draw:Text(step.Name, "GAMEFONTNORMAL", x, y, z)

                    if player:DistanceFromPoint(x, y, z) > radius then
                        runner.Engine.Navigation:MoveToPoint(x, y, z)
                    else
                        Unlock(MoveForwardStop)
                        DungeonRoutine:MarkStepComplete(step, self.Steps)
                    end
                end
                if step.Task == "kill" then
                    local mob = self:FindMobWithName(step.Mobs[1])
                    local deadmob = self:FindMobWithNameDead(step.Mobs[1])
                    if deadmob then
                        DungeonRoutine:MarkStepComplete(step, self.Steps)
                    end
                    if mob and (mob.isDead or mob.CanLoot) then
                        DungeonRoutine:MarkStepComplete(step, self.Steps)
                    end
                    if mob then
                        if mob:DistanceFromPlayer() > 8 then
                            runner.Engine.Navigation:MoveTo(mob.pointer)
                        end
                    end
                end
                if step.Task == "interact_with" then
                    local interactable = runner.Engine.ObjectManager:GetClosestByName(step.Object)
                    print("We found an interactable: " .. interactable.Name)
                    if interactable then
                        if interactable:DistanceFromPlayer() < 4 then
                            print("Interacting with " .. step.Object)
                            runner.UI.menuFrame:UpdateStatusText("Interacting with " .. step.Object)
                            Unlock(MoveForwardStop)
                            runner.nn.ObjectInteract(interactable.pointer)
                            DungeonRoutine:MarkStepComplete(step, self.Steps)
                        else
                            print("Moving to " .. step.Object)
                            runner.UI.menuFrame:UpdateStatusText("Move to " .. step.Object)
                            runner.Engine.Navigation:MoveTo(interactable.pointer)
                        end
                    end
                end
            else
                DungeonRoutine:MarkStepComplete(step, self.Steps)
            end
        else
            print("We are fucking done")
        end
    end

    --if role == "TANK" then
    --    local closestEnemy = self:GetClosestEnemy()
    --    if closestEnemy then
    --        if closestEnemy:DistanceFromPlayer() > 30 then
    --            print("Moving to enemy")
    --            runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
    --        else
    --            print("Fight stuff")
    --            Unlock(TargetUnit, closestEnemy.pointer)
    --            if not UnitAffectingCombat("player") then
    --                Unlock(CastSpellByName, "Throw Glaive", closestEnemy.pointer)
    --            end
    --            runner.Engine.Navigation:FaceUnit(closestEnemy.pointer)
    --            if closestEnemy:DistanceFromPlayer() > 6 then
    --                Unlock(MoveForwardStart)
    --            else
    --                Unlock(MoveForwardStop)
    --            end
    --            runner.rotation:Pulse(closestEnemy)
    --        end
    --    end
    --else
    --    local tank = self:GetTank()
    --    if tank then
    --        if tank:DistanceFromPlayer() > 20 then
    --            runner.Engine.Navigation:MoveTo(tank)
    --        else
    --            local target = Unlock(AssistUnit, tank.pointer)
    --            Unlock(CastSpellByName, "Throw Glaive", target)
    --            runner.rotation:Pulse(target)
    --        end
    --    end
    --end
end

function DungeonRoutine:NeedStep(step)
    if step.MobAlive then
        local mob = self:FindMobWithName(step.MobAlive)
        if mob and not mob.isDead then
            return true
        else
            return false
        end
    else
        return true
    end
    return true
end

function DungeonRoutine:GetClosestLootableEnemy()
    local closestEnemy = nil
    local closestDistance = 9999

    for k, enemy in pairs(runner.Engine.ObjectManager.units) do
        if enemy.Reaction and enemy.Reaction < 4 and enemy.CanLoot then
            local distance = enemy:DistanceFromPlayer()
            if distance < closestDistance then
                closestEnemy = enemy
                closestDistance = distance
            end
        end
    end
    return closestEnemy
end

function DungeonRoutine:NeedToDoMechanic(mechanics)
    for k, mechanic in pairs(mechanics) do
        if mechanic.Condition then
            if self:MechanicConditionMet(mechanic.Condition) then
                return true
            end
        end
    end
    return false
end

function DungeonRoutine:MechanicConditionMet(condition)
    if not condition then
        return false
    end

    if condition.Type == "casting" then
        local mob = self:FindMobWithName(condition.Mob)
        if mob then
            passed = mob:CastingSpellByName(condition.SpellName)
            if not passed then
                return false
            end
        end
    end

    if condition.NoAuraPlayer then
        passed = not runner.LocalPlayer:HasAura(condition.NoAuraPlayer)
        if not passed then
            return false
        end
    end

    if condition.PlayerAura then
        passed = runner.LocalPlayer:HasAura(condition.PlayerAura)
        if not passed then
            return false
        end
    end

    return true
end

function DungeonRoutine:FindMobWithNameAndAura(name, aura)
    print("Looking for mob with name " .. name .. " and aura " .. aura)
    for k, mob in pairs(runner.Engine.ObjectManager.units) do
        if mob.Name == name then
            print("We found a mob with the name " .. name .. " needs aura " .. aura)
            if mob:HasAura(aura, "HELPFUL") then
                return mob
            end
        end
    end
    return nil
end

function DungeonRoutine:FindMobWithName(name)
    for k, mob in pairs(runner.Engine.ObjectManager.units) do
        if mob.Name == name then
            return mob
        end
    end
    return nil
end

function DungeonRoutine:FindMobWithNameDead(name)
    for k, mob in pairs(runner.Engine.ObjectManager.units) do
        if mob.Name == name and (mob.isDead or mob.CanLoot) then
            return mob
        end
    end
    return nil
end

function DungeonRoutine:MarkStepComplete(step, steps)
    for k,v in pairs(steps) do
        if v == step then
            table.remove(steps, k)
            print("Step complete: " .. step.Name)
            break
        end
    end
end

function DungeonRoutine:FindClosestStep()
    local player = runner.LocalPlayer
    local closestStep = nil
    local closestDistance = 9999
    local location = nil
    local distance = 99999

    for k, step in pairs(self.Steps) do
        if step.Task == "move_to" then
            location = step.Locations[1]
        end
        if step.Task == "kill" then
            local mob = self:FindMobWithName(step["Mobs"][1])
            location.X, location.Y, location.Z = runner.nn.ObjectPosition(mob.pointer)
            print("Mob location: " .. tostring(location))
        end
        if location ~= nil then
            distance = player:DistanceFromPoint(location.X, location.Y, location.Z)
        end
        if distance < closestDistance then
            closestStep = step
            closestDistance = distance
        end
    end
    return closestStep
end

function DungeonRoutine:FindProfile()
    local instanceName = GetInstanceInfo()
    for i, profile in ipairs(runner.profiles) do
        if profile.Name == instanceName then
            return profile
        end
    end
    return nil
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