runner.Routines.MultiboxRoutine = runner.Routines.BaseRoutine:extend()
local MultiboxRoutine = runner.Routines.MultiboxRoutine
runner.Routines.MultiboxRoutine = MultiboxRoutine

function MultiboxRoutine:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "MultiboxRoutine"
    self.Description = "Multibox routine for master/slave control"
    
    -- Constants
    self.FOLLOW_MIN_DISTANCE = 1
    self.FOLLOW_MAX_DISTANCE = 5
    self.MELEE_RANGE = 5
    self.RANGED_COMBAT_RANGE = 25
    
    -- Register slash commands
    _G.SLASH_MBXR1 = "/mbxr"
    _G.SlashCmdList["MBXR"] = function(msg) self:HandleSlashCommands(msg) end
end

function MultiboxRoutine:HandleSlashCommands(msg)
    local command = msg:lower()
    local player = runner.LocalPlayer
    
    if command == "on" then
        player.isMultiboxEnabled = true
        player.forcedFollow = false
        runner.UI.menuFrame:UpdateStatusText("Multibox: Enabled")
    elseif command == "off" then
        player.isMultiboxEnabled = false
        player.forcedFollow = false
        runner.UI.menuFrame:UpdateStatusText("Multibox: Disabled")
    elseif command == "master" then
        player:SetAsMaster()
        runner.UI.menuFrame:UpdateStatusText("Multibox: Master")
    elseif command == "follow" then
        if not player.isMultiboxEnabled then return end
        player.forcedFollow = not player.forcedFollow
        local status = player.forcedFollow and "Follow Mode" or "Combat Mode"
        runner.UI.menuFrame:UpdateStatusText("Multibox: " .. status)
    else
        print("Usage: /mbxr on|off|master|follow")
    end
end

function MultiboxRoutine:GetClosestLootableEnemy()
    local closestEnemy = nil
    local closestDistance = 9999
    
    for _, enemy in pairs(runner.Engine.ObjectManager.units) do
        if enemy.CanLoot then
            local distance = enemy:DistanceFromPlayer()
            if distance < closestDistance then
                closestEnemy = enemy
                closestDistance = distance
            end
        end
    end
    return closestEnemy
end

function MultiboxRoutine:HandleCombat(masterTarget)
    if not masterTarget then return end
    
    -- Check if it's safe to attack based on role
    local player = runner.LocalPlayer
    local isTank = UnitGroupRolesAssigned("player") == "TANK"
    if not isTank and not UnitAffectingCombat(masterTarget.pointer) then
        return
    end
    
    local distance = masterTarget:DistanceFromPlayer()
    local combatRange = UnitGroupRolesAssigned("player") == "RANGED" and self.RANGED_COMBAT_RANGE or self.MELEE_RANGE
    
    if distance > combatRange then
        runner.UI.menuFrame:UpdateStatusText("Moving to fight " .. masterTarget.Name)
        runner.Engine.Navigation:MoveTo(masterTarget.pointer)
    else
        Unlock(MoveForwardStop)
        runner.UI.menuFrame:UpdateStatusText("Fighting " .. masterTarget.Name)
        Unlock(TargetUnit, masterTarget.pointer)
        runner.Engine.Navigation:FaceUnit(masterTarget.pointer)
        if runner.rotation then
            runner.rotation:Pulse(masterTarget)
        end
    end
end

function MultiboxRoutine:Run()
    local player = runner.LocalPlayer
    if not player.isMultiboxEnabled then return end
    
    -- If we're the master, just update target broadcasts
    if player.isMaster then
        if UnitExists("target") then
            local message = "MASTERTARGET:" .. UnitGUID("target")
            if IsInRaid() then
                C_ChatInfo.SendAddonMessage("MBXR", message, "RAID")
            elseif IsInGroup() then
                C_ChatInfo.SendAddonMessage("MBXR", message, "PARTY")
            end
        end
        return
    end
    
    -- Handle looting
    local lootable = self:GetClosestLootableEnemy()
    if lootable and not UnitAffectingCombat("player") then
        if lootable:DistanceFromPlayer() < 4 then
            runner.UI.menuFrame:UpdateStatusText("Looting " .. lootable.Name)
            Unlock(MoveForwardStop)
            runner.nn.ObjectInteract(lootable.pointer)
        else
            runner.UI.menuFrame:UpdateStatusText("Moving to loot " .. lootable.Name)
            runner.Engine.Navigation:MoveTo(lootable.pointer)
        end
        return
    end
    
    -- Handle following master
    if player.forcedFollow or not UnitAffectingCombat("player") then
        local masterObj = runner.Engine.ObjectManager:GetByPointer(UnitTarget(player.masterGUID))
        if masterObj then
            local distance = masterObj:DistanceFromPlayer()
            if distance > self.FOLLOW_MAX_DISTANCE then
                runner.Engine.Navigation:MoveTo(masterObj.pointer)
                runner.UI.menuFrame:UpdateStatusText("Following Master")
            end
        end
        return
    end
    
    -- Handle combat
    if UnitAffectingCombat("player") then
        local masterTarget = runner.Engine.ObjectManager:GetByPointer(UnitTarget(player.masterGUID))
        if masterTarget then
            self:HandleCombat(masterTarget)
        end
    end
end

registerRoutine(MultiboxRoutine)
