runner.Rotations.WarlockRotation = runner.Rotations.BaseRotation:extend()
local WarlockRotation = runner.Rotations.WarlockRotation
runner.Rotations.WarlockRotation = WarlockRotation

function WarlockRotation:init()
    runner.Rotations.BaseRotation:init(self)
    self.Class = "Warlock"
    self.Name = "Warlock"
    self.Description = "Warlock Rotation"
    self.PullRange = 30
    self.CombatRange = 30
end

function WarlockRotation:OutOfCombat()
    if runner.LocalPlayer.isDead then return end
    self.Pet = UnitName("pet")
    if not self.Pet then
        self:Cast("Summon Felhunter")
        return true
    end
    return false
end

function WarlockRotation:Pull(target)
    self:Cast("Agony", target.pointer)
end

function WarlockRotation:Pulse(target)
    runner.Rotations.BaseRotation.Pulse(self, target)
    target = self.target

    if Unlock(UnitAffectingCombat, "player") and target and (
            Unlock(UnitAffectingCombat, target.pointer) or string.find(target.Name, "Training")) then

        if runner.LocalPlayer.IsCasting then
            return
        end

        if runner.LocalPlayer.specName == "Affliction" then
            local noAgony = self:GetClosestWithoutDebuff("Agony")
            local noCorruption = self:GetClosestWithoutDebuff("Corruption")
            local unstableCount = self:EnemyCountWithDebuff("Unstable Affliction")
            local seedCount = self:EnemyCountWithDebuff("Seed of Corruption")

            if not self.Pet then
                self:Cast("Summon Felhunter")
                return
            end

            if self.Pet and self.ClosestCaster and self:CanCast("Spell Lock", self.ClosestCaster) then
                self:Cast("Spell Lock", self.ClosestCaster.pointer)
                return
            end

            if self.AoeEnemies > 2 and seedCount < 2 and self:CanCast("Seed of Corruption", self.Target) and not self.Target:HasAura("Seed of Corruption", "HARMFUL") then
                self:Cast("Seed of Corruption")
                return
            end

            if unstableCount < 1 and self:CanCast("Unstable Affliction", self.Target) and not target:HasAura("Unstable Affliction", "HARMFUL") then
                self:Cast("Unstable Affliction", self.Target)
                return
            end
            if self:CanCast("Agony", noAgony) then
                self:Cast("Agony", noAgony.pointer)
                return
            end
            if self:CanCast("Corruption", noCorruption) then
                self:Cast("Corruption", noCorruption.pointer)
                return
            end
            if self:CanCast("Summon Darkglare", self.Target) then
                self:Cast("Summon Darkglare")
                return
            end
            if self:CanCast("Malefic Rapture", self.Target) and runner.LocalPlayer.SoulShards >= 3 then
                self:Cast("Malefic Rapture")
                return
            end
            if self:CanCast("Shadow Bolt", self.Target) then
                self:Cast("Shadow Bolt")
                return
            end
        end
    end
end

registerRotation(WarlockRotation)