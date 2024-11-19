runner.Routines.AutoQuestRoutine = class({}, "AutoQuestRoutine")
local AutoQuestRoutine = runner.Routines.AutoQuestRoutine
runner.Routines.AutoQuestRoutine = AutoQuestRoutine

function AutoQuestRoutine:init()
    self.Name = "AutoQuestRoutine"
    self.Description = "AutoQuestRoutine"
    self.SettingsGUI = {}
    self.IsComplete = false

    self.ClosestObjective = nil
end

function AutoQuestRoutine:Run()
    C_CVar.SetCVar("autoLootDefault", 1)
    local closestLoot = runner.Engine.ObjectManager:GetClosestLootable()
    local closestQuestGiver = runner.Engine.ObjectManager:GetClosestQuestGiver()
    local closestQuestTurnin = runner.Engine.ObjectManager:GetClosestQuestTurnin()
    local closestEnemy = runner.Engine.ObjectManager:GetClosestEnemy()
    self.closestObjective = runner.Engine.ObjectManager:GetClosestQuestObjective()
    local closestPOI = self:GetClosestPOI()

    local acceptdist = closestQuestGiver and closestQuestGiver:DistanceFromPoint(closestPOI.x, closestPOI.y, closestPOI.z) or 99999
    local turndist = closestQuestTurnin and closestQuestTurnin:DistanceFromPoint(closestPOI.x, closestPOI.y, closestPOI.z) or 99999

    if self.closestObjective then
        for k,v in pairs(self.closestObjective.ObjectiveFor) do
            if runner.QuestOverrides[v] and not C_QuestLog.IsComplete(v) and not C_QuestLog.IsQuestFlaggedCompleted(v) then
                runner.QuestOverrides[v]()
                return
            end
        end
    end

    if C_QuestLog.IsOnQuest(59942) and not select(3, GetQuestObjectiveInfo(59942, 2, false)) then
        runner.QuestOverrides[59942]()
        return
    end

    if UnitAffectingCombat("player") then
        if closestEnemy then
            if closestEnemy:DistanceFromPlayer() > runner.rotation.PullRange or not closestEnemy:LOS() then
                runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
            else
                runner.rotation:Pull(closestEnemy)
                if closestEnemy:DistanceFromPlayer() > runner.rotation.CombatRange then
                    runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
                else
                    Unlock(TargetUnit, closestEnemy.pointer)
                    runner.Engine.Navigation:FaceUnit(closestEnemy.pointer)
                    Unlock(MoveForwardStop)
                    runner.rotation:Pulse(closestEnemy)
                end
            end
        end
    end
    if closestLoot then
        if closestLoot:DistanceFromPlayer() > 4 or not closestLoot:LOS() then
            runner.Engine.Navigation:MoveTo(closestLoot.pointer)
        else
            Unlock(MoveForwardStop)
            runner.nn.ObjectInteract(closestLoot.pointer)
        end
        return
    end

    if closestQuestGiver then
        if closestQuestGiver:DistanceFromPlayer() > 4 or not closestQuestGiver:LOS() then
            runner.Engine.Navigation:MoveTo(closestQuestGiver.pointer)
        else
            Unlock(MoveForwardStop)
            runner.nn.ObjectInteract(closestQuestGiver.pointer)
        end
        return
    end
    if closestQuestTurnin and turndist < 75 then
        if closestQuestTurnin:DistanceFromPlayer() > 4 or not closestQuestTurnin:LOS() then
            runner.Engine.Navigation:MoveTo(closestQuestTurnin.pointer)
        else
            Unlock(MoveForwardStop)
            runner.nn.ObjectInteract(closestQuestTurnin.pointer)
        end
        return
    end
    if self.closestObjective then
        if self.closestObjective.CanAttack then
            if self.closestObjective:DistanceFromPlayer() > runner.rotation.PullRange or not self.closestObjective:LOS() then
                runner.Engine.Navigation:MoveTo(self.closestObjective.pointer)
            else
                Unlock(TargetUnit, self.closestObjective.pointer)
                runner.rotation:Pull(self.closestObjective)
                if self.closestObjective:DistanceFromPlayer() > runner.rotation.CombatRange then
                    runner.Engine.Navigation:MoveTo(self.closestObjective.pointer)
                else
                    Unlock(TargetUnit, self.closestObjective.pointer)
                    runner.Engine.Navigation:FaceUnit(self.closestObjective.pointer)
                    Unlock(MoveForwardStop)
                    runner.rotation:Pulse(self.closestObjective)
                end
            end
        else
            if self.closestObjective:DistanceFromPlayer() > 5 or not self.closestObjective:LOS() then
                runner.Engine.Navigation:MoveTo(self.closestObjective.pointer)
            else
                Unlock(MoveForwardStop)
                runner.nn.ObjectInteract(self.closestObjective.pointer)
            end
        end
        return
    end

    if closestPOI then
        if runner.LocalPlayer:DistanceFromPoint(closestPOI.x, closestPOI.y, closestPOI.z) > 5 then
            runner.Engine.Navigation:MoveToPoint(closestPOI.x, closestPOI.y, closestPOI.z)
        else
            Unlock(MoveForwardStop)
        end
        return
    end
end

function AutoQuestRoutine:ShowGUI()
end

function AutoQuestRoutine:HideGUI()
end

function AutoQuestRoutine:SetStatus(status)
    if self.SettingsGUI then
        self.SettingsGUI:SetStatusText(status)
    end
end

function AutoQuestRoutine:GetClosestPOI()
    local map = C_Map.GetBestMapForUnit("player")
    local px, py, pz = ObjectPosition("player")
    local closestDistance = 9999
    local closestPOI = runner.Classes.Point:new()
    local quests = C_QuestLog.GetQuestsOnMap(map)
    for k,v in pairs(quests) do
        local _, worldpos = C_Map.GetWorldPosFromMapPos(map, CreateVector2D(v.x, v.y))
        local x,y = worldpos:GetXY()
        local z = self:ScanForGround(x, y)
        local distance = runner.LocalPlayer:DistanceFromPoint(x, y, z)
        if distance < closestDistance then
            closestDistance = distance
            closestPOI.x = x
            closestPOI.y = y
            closestPOI.z = z
        end
    end
    return closestPOI
end

function AutoQuestRoutine:ScanForGround(x, y)
    local z = runner.LocalPlayer.z
    for i=-200, 200 do
        local ground = select(3, runner.nn.TraceLine(x, y, z+i, x, y, z-i, 0x110))
        if ground then
            z = ground
            break
        end
    end
    return z
end

registerRoutine(AutoQuestRoutine)

function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
