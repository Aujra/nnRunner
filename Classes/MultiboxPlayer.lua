runner.Classes.MultiboxPlayer = runner.Classes.Player:extend()
local MultiboxPlayer = runner.Classes.MultiboxPlayer
runner.Classes.MultiboxPlayer = MultiboxPlayer

function MultiboxPlayer:init(pointer)
    runner.Classes.Player.init(self, pointer)
    self.isMultiboxEnabled = false
    self.isMaster = false
    self.forcedFollow = false
    self.masterGUID = nil
    self.masterName = nil
    self.multiboxRole = "none" -- "master" or "slave"
end

function MultiboxPlayer:Update()
    runner.Classes.Player.Update(self)
    -- Update master reference if we're a slave
    if self.multiboxRole == "slave" and self.masterGUID then
        self:UpdateMasterReference()
    end
end

function MultiboxPlayer:SetAsMaster()
    self.isMaster = true
    self.multiboxRole = "master"
    self.masterGUID = UnitGUID(self.pointer)
    self.masterName = self.Name
    self:BroadcastMasterStatus()
end

function MultiboxPlayer:SetAsSlave(masterGUID, masterName)
    self.isMaster = false
    self.multiboxRole = "slave"
    self.masterGUID = masterGUID
    self.masterName = masterName
end

function MultiboxPlayer:UpdateMasterReference()
    if not self.masterGUID then return end
    
    local players = runner.Engine.ObjectManager.players
    for _, player in pairs(players) do
        if UnitGUID(player.pointer) == self.masterGUID then
            self.masterObject = player
            return
        end
    end
    self.masterObject = nil
end

function MultiboxPlayer:BroadcastMasterStatus()
    if not self.isMaster then return end
    
    local message = "MASTER:" .. tostring(self.masterGUID) .. ":" .. self.masterName
    if IsInRaid() then
        C_ChatInfo.SendAddonMessage("MBXR", message, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage("MBXR", message, "PARTY")
    end
end

function MultiboxPlayer:BroadcastTarget()
    if not self.isMaster then return end
    
    local targetGUID = UnitGUID("target")
    if targetGUID then
        local message = "MASTERTARGET:" .. targetGUID
        if IsInRaid() then
            C_ChatInfo.SendAddonMessage("MBXR", message, "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage("MBXR", message, "PARTY")
        end
    end
end

function MultiboxPlayer:ShouldFollowMaster()
    if not self.masterObject then return false end
    if self.isMaster then return false end
    if not self.isMultiboxEnabled then return false end
    
    return self.forcedFollow or not UnitAffectingCombat(self.masterObject.pointer)
end

function MultiboxPlayer:GetDistanceFromMaster()
    if not self.masterObject then return 999999 end
    return self:DistanceFrom(self.masterObject)
end

function MultiboxPlayer:ToViewerRow()
    local baseRow = runner.Classes.Player.ToViewerRow(self)
    table.insert(baseRow, self.multiboxRole)
    table.insert(baseRow, self.masterName or "None")
    return baseRow
end
