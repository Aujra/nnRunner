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
    self:BuildGUI()
    self.leaveAfter = 0
    self.BlackList = {
        "Vent Stalker", "Speaker Mechhand", "Reinforce Stalker", "Eternal Flame", "Dummy Stalker", "Mini-Boss Stalker"
    }
end

function DungeonRoutine:Run()
    if not IsInInstance() then
        print("Resetting steps")
        self.Steps = {}
        if not IsIndoors() and not IsMounted() then
            C_MountJournal.SummonByID(284)
        end
        local repair = runner.Engine.ObjectManager:GetClosestByName("Drix Blackwrench")
        if repair then
            if repair:DistanceFromPlayer() < 10 then
                runner.nn.ObjectInteract(repair.pointer)
            else
                runner.Engine.Navigation:MoveTo(repair.pointer)
            end
            if MerchantRepairAllButton:IsVisible() then
                MerchantRepairAllButton:Click()
            end
            if MerchantSellAllJunkButton:IsVisible() then
                MerchantSellAllJunkButton:Click()
            end
        end

        if (select(1,GetLFGQueueStats(LE_LFG_CATEGORY_LFD))) == nil then
            if not LFDQueueFrame:IsVisible() then
                ToggleLFDParentFrame()
            else
                print("Need to queue")
                Unlock(RunMacroText, "/click LFDQueueFrameFindGroupButton")
            end
        end
        if LFGDungeonReadyDialogEnterDungeonButton and LFGDungeonReadyDialogEnterDungeonButton:IsVisible() then
            print("Time to enter")
            Unlock(RunMacroText, "/click LFGDungeonReadyDialogEnterDungeonButton")
        end
    else
        local player = runner.LocalPlayer
        local role = player.Role

        local dungeon_profile = self:FindProfile()
        if dungeon_profile then
            local copy = deep_copy(dungeon_profile.Steps)
            if tableCount(self.Steps) == 0 then
                print("Setting steps")
                self.Steps = copy
                table.insert(self.Steps, {Task = "end_dungeon", Name = "End dungeon" })
            end

            self:UpdateStepText(self.Steps)

            local step = self.Steps[1]
            local lootable = self:GetClosestLootableEnemy()

            if runner.LocalPlayer.isDead then
                RepopMe()
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
                                        if mob:DistanceFromPlayer() > 5 then
                                            runner.UI.menuFrame:UpdateStatusText("Moving to " .. mechanic.Mob)
                                            runner.Engine.Navigation:MoveTo(mob.pointer)
                                        else
                                            Unlock(MoveForwardStop)
                                        end
                                    end
                                end
                                if mechanic.Task == "move_to" then
                                    local location = mechanic.Locations[1]
                                    local x = location.X
                                    local y = location.Y
                                    local z = location.Z
                                    local radius = location.Radius

                                    runner.Draw:Circle(x, y, z, radius)
                                    runner.Draw:Text(mechanic.Name, "GAMEFONTNORMAL", x, y, z)

                                    if player:DistanceFromPoint(x, y, z) > radius then
                                        runner.UI.menuFrame:UpdateStatusText("Moving to " .. mechanic.Name)
                                        runner.Engine.Navigation:MoveToPoint(x, y, z)
                                    else
                                        Unlock(MoveForwardStop)
                                    end
                                end
                            end
                        end
                        return
                    else
                        runner.UI.menuFrame:UpdateStatusText("No mechanics to do")
                    end
                end

                local closestEnemy = self:getBestTarget()
                if closestEnemy then
                    if closestEnemy:DistanceFromPlayer() > runner.rotation.combatRange or not closestEnemy:LOS() then
                        runner.UI.menuFrame:UpdateStatusText("Moving to fight " .. closestEnemy.Name)
                        runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
                    else
                        Unlock("MoveForwardStop")
                        runner.UI.menuFrame:UpdateStatusText("Fighting " .. closestEnemy.Name)
                        Unlock(TargetUnit, closestEnemy.pointer)
                        runner.Engine.Navigation:FaceUnit(closestEnemy.pointer)
                        if not Unlock(UnitAffectingCombat, closestEnemy.pointer) then
                            runner.rotation:Pull(closestEnemy)
                        else
                            runner.rotation:Pulse(closestEnemy)
                        end
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
                        if interactable then
                            if interactable:DistanceFromPlayer() < step.Range then
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
                    if step.Task == "end_dungeon" then
                        C_PartyInfo.LeaveParty()
                    end
                else
                    DungeonRoutine:MarkStepComplete(step, self.Steps)
                end
            end
        end
    end
end

function DungeonRoutine:BlackListed(name)
    for k,v in pairs(self.BlackList) do
        if name == v then
            return true
        end
    end
    return false
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

    if condition.DistanceLocation then
        print("We have a distance location")
        local location = condition.Locations[1]
        local x = location.X
        local y = location.Y
        local z = location.Z
        local radius = location.Radius

        local distance = runner.LocalPlayer:DistanceFromPoint(x, y, z)
        if distance < radius then
            return false
        end
    end

    return true
end

function DungeonRoutine:FindMobWithNameAndAura(name, aura)
    for k, mob in pairs(runner.Engine.ObjectManager.units) do
        if mob.Name == name then
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

function DungeonRoutine:getBestTarget()
    local bestTarget = nil
    local bestScore = -999999
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Reaction and v.Reaction <= 4 and not v.isDead and not self:BlackListed(v.Name) then
            local score = v:GetScore()
            if score > bestScore then
                bestScore = score
                bestTarget = v
            end
        end
    end
    return bestTarget
end

function DungeonRoutine:GetClosestEnemy(range)
    range = range or 150
    local player = runner.LocalPlayer
    local closestEnemy = nil
    local closestDistance = 9999

    for k, enemy in pairs(runner.Engine.ObjectManager.units) do
        if enemy.Reaction and enemy.Reaction < 4 and not enemy.isDead and enemy.CanAttack and
        enemy:DistanceFromPlayer() < range and enemy:LOS() then
            local distance = enemy:DistanceFromPlayer()
            if distance < closestDistance then
                closestEnemy = enemy
                closestDistance = distance
            end
        end
    end
    return closestEnemy
end

function DungeonRoutine:BuildGUI()
    if not self.StatusFrame then
        self.StatusFrame = CreateFrame("Frame", "DungeonRoutineself.StatusFrame", UIParent, "BasicFrameTemplateWithInset")
        self.StatusFrame:SetSize(200, 150)
        self.StatusFrame:SetMovable(true)
        self.StatusFrame:EnableMouse(true)
        self.StatusFrame:RegisterForDrag("LeftButton")
        self.StatusFrame:SetScript("OnDragStart", self.StatusFrame.StartMoving)
        self.StatusFrame:SetScript("OnDragStop", self.StatusFrame.StopMovingOrSizing)
        self.StatusFrame:SetPoint("CENTER", UIParent, "CENTER")
        self.StatusFrame.title = self.StatusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.StatusFrame.title:SetPoint("LEFT", self.StatusFrame.TitleBg, "LEFT", 10, -5)
        self.StatusFrame.title:SetText("Dungeon Routine")
        self.StatusFrame.title:SetWidth(200)
        self.StatusFrame.title:SetHeight(20)
        self.StatusFrame.title:SetJustifyH("LEFT")
        self.StatusFrame.title:SetJustifyV("TOP")
        self.StatusFrame:Show()

        local statusText = self.StatusFrame:CreateFontString("StatusText", "OVERLAY", "GameFontNormal")
        statusText:SetPoint("TOPLEFT", self.StatusFrame, "TOPLEFT", 5, -30)
        statusText:SetText("Status: Running")
        self.StatusFrame.text = statusText

        local stepText = self.StatusFrame:CreateFontString("StepText", "OVERLAY", "GameFontNormal")
        stepText:SetPoint("TOPLEFT", self.StatusFrame, "TOPLEFT", 5, -50)
        stepText:SetText("Step: None")
        self.StatusFrame.step = stepText
    end
end

function DungeonRoutine:HideGUI()
    if self.StatusFrame then
        self.StatusFrame:Hide()
    end
end
function DungeonRoutine:ShowGUI()
    if self.StatusFrame then
        self.StatusFrame:Show()
    end
end
function DungeonRoutine:UpdateStatusText(text)
    if self.StatusFrame then
        self.StatusFrame.text:SetText("Status: " .. text)
    end
end
function DungeonRoutine:UpdateStepText(steps)
    if self.StatusFrame then
        self.StatusFrame.step:SetText("Steps\n ------\n")
        for k, step in pairs(steps) do
            self.StatusFrame.step:SetText(self.StatusFrame.step:GetText() .. step.Name .. "\n")
        end
    end
    local stepsCount = tableCount(self.Steps)
    self.StatusFrame:SetHeight(100 + (stepsCount * 12))
end

registerRoutine(DungeonRoutine)