runner.Routines.MultiboxRoutine = runner.Routines.BaseRoutine:extend()
local MultiboxRoutine = runner.Routines.MultiboxRoutine
runner.Routines.MultiboxRoutine = MultiboxRoutine

function MultiboxRoutine:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "MultiboxRoutine"
    self.Description = "Multibox routine for master/slave control"
    self.addonPrefix = "MBXR"
    
    -- Register for group roster updates
    if not self.rosterFrame then
        self.rosterFrame = CreateFrame("Frame")
        self.rosterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        self.rosterFrame:SetScript("OnEvent", function() self:UpdateFormation() end)
    end
end

function MultiboxRoutine:ShowGUI()
    runner.Routines.BaseRoutine.ShowGUI(self)
    
    -- Initialize addon communication
    C_ChatInfo.RegisterAddonMessagePrefix(self.addonPrefix)
    
    -- Register slash commands
    _G.SLASH_MBXR1 = "/mbxr"
    _G.SlashCmdList["MBXR"] = function(msg) self:HandleSlashCommands(msg) end
    
    -- Create event frame for addon communication and target changes
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
        self.eventFrame:SetScript("OnEvent", function(frame, event, ...) self:OnEvent(event, ...) end)
    end
    
    runner.UI.menuFrame:UpdateStatusText("Multibox: Ready")

    print("Multibox Routine (MBXR) v1.0 loaded")
    print("Use /mbxr on|off to enable/disable")
    print("Use /mbxr master to set current character as master")
    print("Use /mbxr follow to toggle forced follow mode")
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
            if message:sub(1, 10) == "FORMATION:" then
                if not runner.LocalPlayer.isMaster then
                    self:HandleFormationUpdate(message:sub(11))
                end
            elseif message:sub(1, 7) == "MASTER:" then
                local masterGUID, masterName = message:match("MASTER:([^:]+):(.+)")
                if masterGUID and masterName then
                    -- If we were master before and someone else is taking over
                    if runner.LocalPlayer.isMaster and masterGUID ~= UnitGUID("player") then
                        runner.LocalPlayer.isMaster = false
                        self.eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
                        runner.Engine.DebugManager:Debug("MultiboxRoutine", "No longer master - unregistered target events", "TARGETING")
                    end
                    
                    self:HandleMasterBroadcast(masterGUID, masterName, sender)
                    
                    -- If we're the new master, register for target changes
                    if runner.LocalPlayer.isMaster then
                        self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
                        runner.Engine.DebugManager:Debug("MultiboxRoutine", "Became master - registered target events", "TARGETING")
                    end
                end
            elseif message:sub(1, 13) == "MASTERTARGET:" then
                -- Ignore our own broadcasts
                if sender == UnitName("player") then return end
                
                local targetGUID = message:match("MASTERTARGET:(.+)")
                if targetGUID then
                    self:HandleMasterTarget(targetGUID, sender)
                end            
            elseif message:sub(1, 6) == "STATE:" then
                local guid, enabled = message:match("STATE:([^:]+):(%d)")
                if guid and enabled then
                    self:HandleStateSync(guid, enabled == "1")
                end
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" and runner.LocalPlayer.isMaster then
        -- Broadcast new target when master changes target
        if UnitExists("target") then
            local targetGUID = UnitGUID("target")
            local message = "MASTERTARGET:" .. targetGUID
            
            runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
                "Master target changed - broadcasting: %s",
                UnitName("target")
            ), "TARGETING")
            
            if IsInRaid() then
                C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "RAID")
            elseif IsInGroup() then
                C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "PARTY")
            end
        end
    end
end

function MultiboxRoutine:HandleFormationUpdate(positionData)
    runner.Engine.DebugManager:Debug("MultiboxRoutine", "Received formation update from master", "FORMATION")
    
    local positions = {}
    local posCount = 0
    
    for posStr in positionData:gmatch("[^|]+") do
        local guid, x, y, z = posStr:match("([^:]+):([^:]+):([^:]+):([^:]+)")
        if guid and x and y and z then
            positions[guid] = {
                x = tonumber(x),
                y = tonumber(y),
                z = tonumber(z)
            }
            posCount = posCount + 1
            
            runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
                "Parsed position - GUID=%s, x=%.2f, y=%.2f, z=%.2f",
                guid, positions[guid].x, positions[guid].y, positions[guid].z
            ), "POSITIONING")
        end
    end
    
    runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
        "Updated formation with %d positions", posCount
    ), "POSITIONING")
    
    runner.Engine.FormationManager.positions = positions
    runner.Engine.FormationManager:DumpDebugState()
end

function MultiboxRoutine:HandleStateSync(guid, enabled)
    runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
        "Received state sync: GUID=%s, Enabled=%s",
        guid, tostring(enabled)
    ), "STATE")
    
    -- Update state for all matching players in ObjectManager
    for _, player in pairs(runner.Engine.ObjectManager.players) do
        if UnitGUID(player.pointer) == guid then
            player.isMultiboxEnabled = enabled
            -- If not enabled, clear master status
            if not enabled then
                player.isMaster = false
            end
            break
        end
    end
    
    -- Update formation after state change
    self:UpdateFormation()
end

function MultiboxRoutine:BroadcastState()
    if not IsInGroup() then return end
    
    local guid = UnitGUID("player")
    local enabled = runner.LocalPlayer.isMultiboxEnabled and "1" or "0"
    local message = string.format("STATE:%s:%s", guid, enabled)
    
    runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
        "Broadcasting state: GUID=%s, Enabled=%s",
        guid, tostring(runner.LocalPlayer.isMultiboxEnabled)
    ), "STATE")
    
    if IsInRaid() then
        C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "PARTY")
    end
end

function MultiboxRoutine:HandleMasterBroadcast(masterGUID, masterName, sender)
    local player = runner.LocalPlayer
    if not player then return end
    
    if masterGUID ~= UnitGUID("player") then
        runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
            "Received master broadcast: GUID=%s, Name=%s",
            masterGUID, masterName
        ), "MASTER")
        
        player.isMaster = false
        player.masterGUID = masterGUID
        player.masterName = masterName
        
        -- Update master object reference
        for _, otherPlayer in pairs(runner.Engine.ObjectManager.players) do
            if UnitGUID(otherPlayer.pointer) == masterGUID then
                player.masterObject = otherPlayer
                otherPlayer.isMaster = true  -- Set master status on master's player object
                break
            end
        end
        
        -- Update formation and request position data
        self:UpdateFormation()
        
        runner.UI.menuFrame:UpdateStatusText("Multibox: Following " .. masterName)
    end
end

function MultiboxRoutine:UpdateFormation()
    runner.Engine.DebugManager:Debug("MultiboxRoutine", "Starting formation update", "FORMATION")
    
    -- Clear existing followers (but keep positions)
    local oldPositions = runner.Engine.FormationManager.positions
    runner.Engine.FormationManager.followers = {}
    
    -- Add current multibox followers
    if IsInGroup() then
        -- First check self if not master
        local selfGUID = UnitGUID("player")
        if runner.LocalPlayer.isMultiboxEnabled and not runner.LocalPlayer.isMaster then
            runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
                "Adding self to formation: GUID=%s, Name=%s",
                selfGUID,
                UnitName("player")
            ), "FORMATION")
            runner.Engine.FormationManager:AddFollower(runner.LocalPlayer)
        end
        
        -- Then check all group members
        local numMembers = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
        for i = 1, numMembers do
            local unit = IsInRaid() and ("raid"..i) or ("party"..i)
            local guid = UnitGUID(unit)
            
            -- Skip self as we already checked it
            if guid ~= selfGUID then
                -- Check if this unit is a multibox follower
                for _, player in pairs(runner.Engine.ObjectManager.players) do
                    if UnitGUID(player.pointer) == guid then
                        if player.isMultiboxEnabled and not player.isMaster then
                            runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
                                "Adding player to formation: %s", UnitName(player.pointer)
                            ), "FORMATION")
                            runner.Engine.FormationManager:AddFollower(player)
                        end
                        break
                    end
                end
            end
        end
    end
    
    -- If we're the master, immediately assign positions
    if runner.LocalPlayer.isMaster then
        local mx, my, mz = ObjectPosition("player")
        local mf = ObjectFacing("player")
        if mx then
            runner.Engine.FormationManager:AssignPositions(mx, my, mz, mf)
            runner.Engine.FormationManager:BroadcastPositions()
        end
    else
        -- If we're a follower, restore our old position if we had one
        runner.Engine.FormationManager.positions = oldPositions
    end
    
    runner.Engine.FormationManager:DumpDebugState()
end

function MultiboxRoutine:HandleMasterTarget(targetGUID, sender)
    local player = runner.LocalPlayer
    if not player or player.isMaster then return end
    
    if player.masterGUID then
        -- Store the master's target GUID
        player.masterTargetGUID = targetGUID
        
        -- Update our target if needed
        if player:UpdateTargetFromGUID(targetGUID) then
            -- Find target name for status message
            for _, unit in pairs(runner.Engine.ObjectManager.units) do
                if UnitGUID(unit.pointer) == targetGUID then
                    runner.UI.menuFrame:UpdateStatusText("Multibox: Targeting " .. unit.Name)
                    break
                end
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
        self:BroadcastState()  -- Broadcast state change
        self:UpdateFormation()
        runner.UI.menuFrame:UpdateStatusText("Multibox: Enabled")
        print("Multibox enabled")
    elseif command == "off" then
        player.isMultiboxEnabled = false
        player.forcedFollow = false
        self:BroadcastState()  -- Broadcast state change
        self:UpdateFormation()
        runner.UI.menuFrame:UpdateStatusText("Multibox: Disabled")
        print("Multibox disabled")
    elseif command == "master" then
        player.isMaster = true
        player.masterGUID = UnitGUID("player")
        player.masterName = UnitName("player")
        
        -- Broadcast state before master status
        self:BroadcastState()
        
        -- Broadcast master status
        local message = "MASTER:" .. player.masterGUID .. ":" .. player.masterName
        if IsInRaid() then
            C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage(self.addonPrefix, message, "PARTY")
        end
        
        self:UpdateFormation()
        runner.UI.menuFrame:UpdateStatusText("Multibox: Master")
        print("You are now the master")
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
    
    if interactable:DistanceFromPlayer() < 2 then
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

function MultiboxRoutine:HandleMasterInteractTarget(player)
    if not player or player.isMaster then return false end
    
    local targetObject = player:GetMasterInteractTarget()
    if not targetObject then return false end
    
    runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
        "Master is targeting interactable object: %s",
        targetObject.Name
    ), "INTERACTION")
        
    return self:HandleInteraction(targetObject)
end

function MultiboxRoutine:HandleFollowing(player)
    if not player:ShouldFollowMaster() then 
        runner.Engine.DebugManager:Debug("MultiboxRoutine", "Not following: ShouldFollowMaster returned false", "FOLLOW")
        return false 
    end
    
    if not player.masterObject then 
        runner.Engine.DebugManager:Debug("MultiboxRoutine", "Not following: No master object", "FOLLOW")
        return false 
    end
    
    -- Get current position
    local followPos = runner.Engine.FormationManager:GetFollowerPosition(UnitGUID(player.pointer))
    if not followPos then 
        runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
            "Not following: No formation position for %s", UnitName(player.pointer)
        ), "FOLLOW")
        return false 
    end
    
    -- Move if needed
    local px, py, pz = ObjectPosition(player.pointer)
    if not px then 
        runner.Engine.DebugManager:Debug("MultiboxRoutine", "Not following: Could not get player position", "FOLLOW")
        return false 
    end
    
    local distance = math.sqrt((px - followPos.x)^2 + (py - followPos.y)^2)
    runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
        "Follow check: Distance to target = %.2f", 
        distance
    ), "FOLLOW")
    
    if distance > 2 then  -- Within 2 yards of target position
        runner.Engine.DebugManager:Debug("MultiboxRoutine", string.format(
            "Moving to position (%.2f, %.2f, %.2f)", 
            followPos.x, followPos.y, followPos.z
        ), "FOLLOW")
        runner.Engine.Navigation:MoveToPoint(followPos.x, followPos.y, followPos.z)
        runner.UI.menuFrame:UpdateStatusText("Following Master")
        return true
    else
        runner.Engine.DebugManager:Debug("MultiboxRoutine", "At target position, stopping movement", "FOLLOW")
        Unlock(MoveForwardStop)
        return true
    end
end

function MultiboxRoutine:Run()
    local player = runner.LocalPlayer
    if not player.isMultiboxEnabled then return end
    
    -- Draw formation debug visualization
    runner.Engine.FormationManager:DrawDebug()
    
    -- If we're the master, manage formation
    if player.isMaster then
        local mx, my, mz = ObjectPosition(player.pointer)
        local mf = ObjectFacing(player.pointer)
        
        if mx and runner.Engine.FormationManager:ShouldUpdatePositions(mx, my, mf) then
            runner.Engine.DebugManager:Debug("MultiboxRoutine", "Master updating formation positions", "FORMATION")
            runner.Engine.FormationManager:AssignPositions(mx, my, mz, mf)
            runner.Engine.FormationManager:BroadcastPositions()
        end
        return
    end
    
    -- Handle looting
    if not player.isMaster and player:ShouldLoot() then
        local lootable = player:GetClosestLootable()
        if lootable and self:HandleInteraction(lootable) then
            return
        end
    end

    -- Handle interaction with master's target
    if not player.isMaster and not UnitAffectingCombat("player") then
        if self:HandleMasterInteractTarget(player) then
            return
        end
    end
    
    -- Handle following master
    if not player.isMaster and self:HandleFollowing(player) then
        return
    end
    
    -- Handle combat
    if not player.isMaster and UnitAffectingCombat("player") then
        local masterTarget = player:GetMasterTarget()
        if masterTarget then
            self:HandleCombat(player, masterTarget)
        end
    end
end

registerRoutine(MultiboxRoutine)
