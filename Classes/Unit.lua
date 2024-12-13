runner.Classes.Unit = runner.Classes.GameObject:extend()
local Unit = runner.Classes.Unit
runner.Classes.Unit = Unit

runner.UnitViewColumns = {
    "Name",
    "Pointer",
    "Distance",
    "Reaction",
    "Level",
    "IsCasting",
    "HP",
    "Height",
    "BoundingRadius",
    "Lootable",
    "Dead"
}

function Unit:init(pointer)
    runner.Classes.GameObject.init(self, pointer)
    self.Reaction = Unlock(UnitReaction, self.pointer, "player")
    self.Level = Unlock(UnitLevel, self.pointer)
    self.IsCasting = false
    self.HP = Unlock(UnitHealth, self.pointer) / Unlock(UnitHealthMax, self.pointer) * 100
    self.InCombat = Unlock(UnitAffectingCombat, self.pointer)
    self.IsFocus = false
    self.Dispellable = false
    self.DeEnrage = false
    self.isDead = Unlock(UnitIsDeadOrGhost, self.pointer)
    self.CanAttack = Unlock(UnitCanAttack, "player", self.pointer)
    self.SoulFragments = 0
    self.Threat = 0
    self.ThreatPercent = 0
    self.IsPlayer = false
    self.Role = UnitGroupRolesAssigned(self.pointer)
    self.Target = nil
end

function Unit:Update()
    runner.Classes.GameObject.Update(self)
    self.Reaction = Unlock(UnitReaction, self.pointer, "player")
    self.Level = Unlock(UnitLevel, self.pointer)
    self.IsCasting = Unlock(UnitCastingInfo, self.pointer) ~= nil or Unlock(UnitChannelInfo, self.pointer) ~= nil
    self.HP = Unlock(UnitHealth, self.pointer) / Unlock(UnitHealthMax, self.pointer) * 100
    self.InCombat = Unlock(UnitAffectingCombat, self.pointer)
    self.IsFocus = self:IsPlayerFocus()
    self.Dispellable = self:ShouldDispell()
    self.DeEnrage = self:ShouldDeEnrage()
    self.isDead = Unlock(UnitIsDeadOrGhost, self.pointer)
    self.IsPlayer = Unlock(UnitIsPlayer, self.pointer)
    self.CanAttack = Unlock(UnitCanAttack, "player", self.pointer)
    self.SoulFragments = self:GetAuraCount("Soul Fragments", "HELPFUL")
    self.Threat = select(5, Unlock(UnitDetailedThreatSituation, "player", self.pointer))
    self.ThreatPercent = select(3, Unlock(UnitDetailedThreatSituation, "player", self.pointer))
    self.Role = UnitGroupRolesAssigned(self.pointer)
    self.Target = Unlock(UnitTarget, self.pointer)
    self.Trivial = Unlock(UnitIsTrivial, self.pointer)
    self.score = self:GetScore()
    local fields = {}

    for i=0, 250, 4 do
        local t = runner.nn.ObjectField(self.pointer, i*4, 1)
        table.insert(fields, i .. " with " .. t)
    end

    self.Fields = fields
    self:Debug()
    --self:ScanAuras()
end

function Unit:Debug()
    runner.Draw:Text(self.score, "GAMEFONTNORMAL", self.X, self.Y, self.Z+2, 1, 1, 1, 1)
end

function Unit:ScanAuras()
    for i = 1, 40 do
        local buffInfo = Unlock(C_UnitAuras.GetAuraDataByIndex, self.pointer, i, "HELPFUL")
        if buffInfo then
            runner.UI.ObjectViewer:AddAura(buffInfo, self.Name)
        end
    end
    for i = 1, 40 do
        local buffInfo = Unlock(C_UnitAuras.GetAuraDataByIndex, self.pointer, i, "HARMFUL")
        if buffInfo then
            runner.UI.ObjectViewer:AddAura(buffInfo, self.Name)
        end
    end
end

function Unit:GetScore()
    local score = 0
    if self.Trivial then
        return -10000
    end
    local distance = self:DistanceFromPlayer()
    local HP = self.HP
    score = score + (800 - (distance * 5))
    score = score + ((100 - HP) * 3)
    if self.InCombat then
        score = score + 300
    end
    if self.Threat and runner.LocalPlayer.Role == "TANK" then
        score = score + ((4-self.Threat) * 30)
    end
    if not self:LOS() then
        score = score - 400
    end
    if self.isDead then
        score = score - 100000
    end
    return score
end

function Unit:CastingSpellByName(name)
    local spellName, _, _, _, _, _, _, _, _, spellId = Unlock(UnitCastingInfo, self.pointer)
    if not spellName then
        spellName, _, _, _, _, _, _, _, _, spellId = Unlock(UnitChannelInfo, self.pointer)
    end

    return spellName == name
end

function Unit:GetAuraCount(name, filter)
    local auraName, icon, auraCount, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal,
    spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = AuraUtil.FindAuraByName(name, self.pointer, filter)
    if not auraName then
        return 0
    end
    return auraCount
end

function Unit:ShouldDeEnrage()
    local deEnrage = false
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = Unlock(UnitBuff, self.pointer, i)
        if not name then
            break
        end
        local dispelType = select(5, GetSpellInfo(spellId))
        if dispelType == "Enrage" or dispelType == "Magic" then
            deEnrage = true
            break
        end
    end
    return deEnrage
end

function Unit:ShouldDispell()
    local dispellable = false
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = Unlock(UnitDebuff, self.pointer, i)
        if not name then
            break
        end
        local dispelType = select(5, GetSpellInfo(spellId))
        if dispelType == "Magic" or dispelType == "Curse" or dispelType == "Disease" or dispelType == "Poison" then
            dispellable = true
            break
        end
    end
    return dispellable
end

function Unit:HasStealable()
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = Unlock(UnitBuff, self.pointer, i)
        if not name then
            break
        end
        local dispelType = select(5, GetSpellInfo(spellId))
        if dispelType == "Magic" then
            return true
        end
    end
    return false
end

function Unit:IsPlayerFocus()
    return self.pointer == runner.nn:GetFocus()
end

function Unit:ToViewerRow()
    return {
        self.Name,
        self.pointer,
        string.format("%.2f", self.Distance),
        self.Reaction,
        self.Level,
        self.IsCasting and "Yes" or "No",
        string.format("%.2f", self.HP),
        string.format("%.2f", self.Height),
        string.format("%.2f", self.BoundingRadius),
        self.CanLoot and "Yes" or "No",
        self.isDead and "Yes" or "No"
    }
end

function Unit:HasAura(name, filter)
    local aname = AuraUtil.FindAuraByName(name, self.pointer, filter)

    return aname ~= nil
end

function Unit:ShouldInterruptCasting()
    local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo(self.pointer)
    if not name then
        name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo(self.pointer)
    end
    if not name then
        return false
    end
    local elapsed = GetTime() - (startTimeMS / 1000)
    return name and not notInterruptible and elapsed > 0.2
end