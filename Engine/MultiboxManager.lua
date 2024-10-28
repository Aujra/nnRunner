local nn = ...
runner.Engine.MultiboxManager = {}
local MBM = runner.Engine.MultiboxManager
runner.Engine.MultiboxManager = MBM

function MBM:init()
    self.addonPrefix = "MBXR"
    C_ChatInfo.RegisterAddonMessagePrefix(self.addonPrefix)
    
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
    self.eventFrame:SetScript("OnEvent", function(frame, event, ...) self:OnEvent(event, ...) end)
end

function MBM:OnEvent(event, ...)
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

function MBM:HandleMasterBroadcast(masterGUID, masterName, sender)
    local localPlayer = runner.LocalPlayer
    if not localPlayer then return end
    
    -- If we're currently master and someone else is claiming mastership
    if localPlayer.isMaster and masterGUID ~= UnitGUID("player") then
        localPlayer.isMaster = false
        localPlayer.multiboxRole = "none"
    end
    
    -- Update our master reference if we're not the master
    if masterGUID ~= UnitGUID("player") then
        localPlayer:SetAsSlave(masterGUID, masterName)
    end
end

function MBM:HandleMasterTarget(targetGUID, sender)
    local localPlayer = runner.LocalPlayer
    if not localPlayer or localPlayer.isMaster then return end
    
    -- Update target if we're a slave
    if localPlayer.masterGUID and sender == localPlayer.masterName then
        for _, unit in pairs(runner.Engine.ObjectManager.units) do
            if UnitGUID(unit.pointer) == targetGUID then
                Unlock(TargetUnit, unit.pointer)
                break
            end
        end
    end
end

MBM:init()
