runner.Rotations.RogueRotation = runner.Rotations.BaseRotation:extend()
local RogueRotation = runner.Rotations.RogueRotation
runner.Rotations.RogueRotation = RogueRotation

function RogueRotation:init()
    runner.Rotations.BaseRotation:init(self)
    self.Class = "Rogue"
    self.Name = "Rogue"
    self.Description = "Rogue Rotation"
    self.PullRange = 30
    self.CombatRange = 6
end

function RogueRotation:OutOfCombat()
    if runner.LocalPlayer.isDead then return end

    if not runner.LocalPlayer:HasAura("Deadly Poison", "HELPFUL") then
        Unlock(MoveForwardStop)
        self:Cast("Deadly Poison")
        return true
    end

    if runner.LocalPlayer.IsCasting then
        return true
    end
    return false
end

function RogueRotation:Pull(target)
    if not target then
        return
    end
    if not runner.LocalPlayer:HasAura("Stealth", "HELPFUL") then
        self:Cast("Stealth")
        return
    end
    if target:DistanceFromPlayer() > self.CombatRange then
        runner.Engine.Navigation:MoveTo(target.pointer)
        return
    else
        self:Cast("Ambush", target.pointer)
        return
    end
end

function RogueRotation:Pulse(target)
    runner.Rotations.BaseRotation.Pulse(self, target)
    target = self.target

    if Unlock(UnitAffectingCombat, "player") and target and (
            Unlock(UnitAffectingCombat, target.pointer) or string.find(target.Name, "Training")) then

        if runner.LocalPlayer.IsCasting then
            return
        end

        if self.ClosestCaster and self:CanCast("Kick", self.ClosestCaster) then
            self:Cast("Kick", self.ClosestCaster.pointer)
            return
        end

        if self:CanCast("Crimson Vial") and runner.LocalPlayer.HP < 50 then
            self:Cast("Crimson Vial")
            return
        end

        if self:CanCast("Cloak of Shadows") and runner.LocalPlayer.HP < 40 then
            self:Cast("Cloak of Shadows")
            return
        end

        if self:CanCast("Evasion") and runner.LocalPlayer.HP < 30 then
            self:Cast("Evasion")
            return
        end

        if self.Focus and self:CanCast("Tricks of the Trade", self.Focus) then
            self:Cast("Tricks of the Trade", self.Focus.pointer)
            return
        end

        if runner.LocalPlayer.specName == "Assassination" then
            local comboPoints = runner.LocalPlayer.ComboPoints

            if self:CanCast("Shadowstep", target) and target:DistanceFromPlayer() > 20 then
                self:Cast("Shadowstep", target.pointer)
                return
            end

            if self:CanCast("Deathmark", target) and target:HasAura("Garrote", "HARMFUL")
            and target:HasAura("Rupture", "HARMFUL") then
                self:Cast("Deathmark", target.pointer)
                return
            end
            Unlock(RunMacroText, "/use 13")
            Unlock(RunMacroText, "/use 14")
            if self:CanCast("Shiv", target) then
                self:Cast("Shiv", target.pointer)
                return
            end
            if self:CanCast("Envenom", target) and not runner.LocalPlayer:HasAura("Slice and Dice", "HELPFUL") and comboPoints > 2 then
                self:Cast("Envenom", target.pointer)
                return
            end
            if self:CanCast("Kingsbane", target) then
                self:Cast("Kingsbane", target.pointer)
                return
            end
            if self:CanCast("Garrote", target) and not target:HasAura("Garrote", "HARMFUL") then
                self:Cast("Garrote", target.pointer)
                return
            end
            if comboPoints > 3 then
                if self.AoeEnemies > 2 and self:CanCast("Crimson Tempest", target) and not target:HasAura("Crimson Tempest", "HARMFUL") then
                    self:Cast("Crimson Tempest", target.pointer)
                    return
                end
                if self:CanCast("Rupture", target) and not target:HasAura("Rupture", "HARMFUL") then
                    self:Cast("Rupture", target.pointer)
                    return
                end
                if self:CanCast("Envenom", target) and comboPoints >= 4 then
                    self:Cast("Envenom", target.pointer)
                    return
                end
            end
            if self:CanCast("Mutilate", target) then
                self:Cast("Mutilate", target.pointer)
                return
            end
        end
    end
end

registerRotation(RogueRotation)