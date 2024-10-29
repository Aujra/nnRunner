runner.Routines.MultiboxRoutine = runner.Routines.BaseRoutine:extend()
local MultiboxRoutine = runner.Routines.MultiboxRoutine
runner.Routines.MultiboxRoutine = MultiboxRoutine

function MultiboxRoutine:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "MultiboxRoutine"
    self.Description = "Multibox routine for master/slave control"
    self.addonPrefix = "MBXR"
end

function MultiboxRoutine:ShowGUI()
    runner.Routines.BaseRoutine.ShowGUI(self)
    
    -- Initialize addon communication
    C_ChatInfo.RegisterAddonMessagePrefix(self.addonPrefix)
    
    -- Register slash commands
    _G.SLASH_MBXR1 = "/mbxr"
    _G.SlashCmdList["MBXR"] = function(msg) self:HandleSlashCommands(msg) end
    
    -- Create event frame for addon communication
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
        self.eventFrame:SetScript("OnEvent", function(frame, event, ...) self:OnEvent(event, ...) end)
    end
    
    runner.UI.menuFrame:UpdateStatusText("Multibox: Ready")
end

function MultiboxRoutine:HideGUI()
    runner.Routines.BaseRoutine.HideGUI(self)
    
    -- Unregister slash commands
    _G.SlashCmdList["MBXR"] = nil
    _G.SLASH_MBXR1 = nil
    
    -- Unregister events
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end
    
    -- Clean up any active multibox state
    if runner.LocalPlayer then
        runner.LocalPlayer.isMultiboxEnabled = false
        runner.LocalPlayer.isMaster = false
        runner.LocalPlayer.forcedFollow = false
        runner.LocalPlayer.masterGUID = nil
        runner.LocalPlayer.masterName = nil
        runner.LocalPlayer.masterObject = nil
    end
    
    runner.UI.menuFrame:UpdateStatusText("Status: Running")
end

function MultiboxRoutine:OnEvent(event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        
        if prefix == self.addonPrefix then
            if message:sub(1, 7) == "MASTER:" then
                local masterGUID, masterName = message:match("MASTER:([^:]+):(.+)")
                if masterGUID and masterName then
                    self:HandleMasterBroadcast(masterGUID, masterName, sender)
                end
            elseif message:sub(1, 13) == "MASTERTARGET:" then
                local targetGUID = message:match("MASTERTARGET:(.+)")
                if targetGUID then
                    self:HandleMasterTarget(targetGUID, sender)
                end
            end
        end
    end
end

function MultiboxRoutine:HandleMasterBroadcast(masterGUID, masterName, sender)
    local player = runner.LocalPlayer
    if not player then return end
    
    if masterGUID ~= UnitGUID("player") then
        player.isMaster = false
        player.masterGUID = masterGUID
        player.masterName = masterName
        runner.UI.menuFrame:UpdateStatusText("Multibox: Following " .. masterName)
    end
end

function MultiboxRoutine:HandleMasterTarget(targetGUID, sender)
    local player = runner.LocalPlayer
    if not player or player.isMaster then return end
    
    if player.masterGUID then
        for _, unit in pairs(runner.Engine.ObjectManager.units) do
            if UnitGUID(unit.pointer) == targetGUID then
                Unlock(TargetUnit, unit.pointer)
                break
            end
        end
    end
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
        player.isMaster = true
        player.masterGUID = UnitGUID("player")
        player.masterName = UnitName("player")
        
        -- Broadcast master status
        local message = "MASTER:" .. player.masterGUID .. ":" .. player.masterName
        if IsInRaid() then
            C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "PARTY")
        end
        
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

function MultiboxRoutine:HandleCombat(player, masterTarget)
    if not masterTarget then return end
    if not player:IsSafeToAttack(masterTarget) then return end
    
    local combatPos = player:GetCombatPosition(masterTarget)
    -- Only move if we need repositioning
    if combatPos then
        runner.UI.menuFrame:UpdateStatusText("Moving to position for " .. masterTarget.Name)
        runner.Engine.Navigation:MoveToPoint(combatPos.x, combatPos.y, combatPos.z)
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

function MultiboxRoutine:HandleInteraction(interactable)
    if not interactable then return false end
    
    if interactable:DistanceFromPlayer() < 4 then
        runner.UI.menuFrame:UpdateStatusText("Interacting with " .. interactable.Name)
        Unlock(MoveForwardStop)
        runner.nn.ObjectInteract(interactable.pointer)
        return true
    else
        runner.UI.menuFrame:UpdateStatusText("Moving to " .. interactable.Name)
        runner.Engine.Navigation:MoveTo(interactable.pointer)
        return true
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
                C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "RAID")
            elseif IsInGroup() then
                C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "PARTY")
            end
        end
        return
    end
    
    -- Handle looting and chest interaction
    if player:ShouldLoot() then
        local interactable = player:GetClosestInteractable()
        if interactable and self:HandleInteraction(interactable) then
            return
        end
    end
    
    -- Handle following master
    if player:ShouldFollowMaster() then
        local distance = player:GetDistanceFromMaster()
        if distance > player.FOLLOW_MAX_DISTANCE then
            runner.Engine.Navigation:MoveTo(player.masterObject.pointer)
            runner.UI.menuFrame:UpdateStatusText("Following Master")
        end
        return
    end
    
    -- Handle combat
    if UnitAffectingCombat("player") then
        local masterTarget = player:GetMasterTarget()
        if masterTarget then
            self:HandleCombat(player, masterTarget)
        end
    end
end

registerRoutine(MultiboxRoutine)
