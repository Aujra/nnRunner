runner.Rotations.HunterRotation = runner.Rotations.BaseRotation:extend()
local HunterRotation = runner.Rotations.HunterRotation
runner.Rotations.HunterRotation = HunterRotation

function HunterRotation:init()
    runner.Rotations.BaseRotation.init(self)
    self.Class = "Hunter"
    self.Name = "Hunter"
    self.Description = "Hunter Rotation"
end

function HunterRotation:Pulse(target)
    runner.Rotations.BaseRotation.Pulse(self, target)
    target = self.target

    if Unlock(UnitAffectingCombat, "player") and target and (
            Unlock(UnitAffectingCombat, target.pointer) or string.find(target.Name, "Training")) then

        if runner.LocalPlayer.IsCasting then
            return
        end

        if not target:HasAura("Hunter's Mark", "HARMFUL") and target.HP > 85 then
            self:Cast("Hunter's Mark")
        end

        if runner.LocalPlayer.specName == "Survival" then
            if (self:CanCast("Kill Command", self.Target) and runner.LocalPlayer:GetAuraCount("Tip of the Spear") < 1 and
            runner.LocalPlayer:HasAura("Coordinated Assault", "HELPFUL")) then
                self:Cast("Kill Command")
                return
            end
            if (self:CanCast("Coordinated Assult")) then
                self:Cast("Coordinated Assult")
                return
            end
            if (self:CanCast("Spearhead", self.Target)) then
                self:Cast("Spearhead")
                return
            end
            if (self:CanCast("Mongoose Bite", self.Target) and not self.Target:HasAura("Serpent Sting", "HARMFUL")) then
                self:Cast("Mongoose Bite")
                return
            end
            if (self:CanCast("Flanking Strike", self.Target) and runner.LocalPlayer:GetAuraCount("Tip of the Spear", "HELPFUL") > 0)
            and runner.LocalPlayer:GetAuraCount("Tip of the Spear", "HELPFUL") < 3 then
                self:Cast("Flanking Strike")
                return
            end
            if (self:CanCast("Explosive Shot", self.Target)) then
                self:Cast("Explosive Shot")
                return
            end
            if (self:CanCast("Explosive Shot", self.Target)) then
                self:Cast("Explosive Shot")
                return
            end
            if (self:CanCast("Kill Command", self.Target)) then
                self:Cast("Kill Command")
                return
            end
            if (self:CanCast("Wildfire Bomb", self.Target)) then
                self:Cast("Wildfire Bomb")
                return
            end
            if (self:CanCast("Raptor Strike", self.Target)) then
                self:Cast("Raptor Strike")
                return
            end
        end

        if runner.LocalPlayer.specName == "Marksmanship" then
            if (self.Focus and self:CanCast("Misdirection", self.Focus) and self.Focus:DistanceFromPlayer() < 40) then
                self:Cast("Misdirection", "focus")
                return
            end
            if (self.ClosestCaster and self:CanCast("Counter Shot", self.ClosestCaster)) then
                self:Cast("Counter Shot", self.ClosestCaster.pointer)
                return
            end
            if (self.DeEnrage and self:CanCast("Tranquilizing Shot", self.DeEnrage) and self.DeEnrage:DistanceFromPlayer() < 30) then
                print("Tranquilizing Shot")
                self:Cast("Tranquilizing Shot", self.DeEnrage.pointer)
                return
            end

            if (runner.LocalPlayer.HP < 30) then
                self:Cast("Fortitude of the Bear", "player")
                return
            end
            if (runner.LocalPlayer.HP < 50) then
                self:Cast("Exhilaration", "player")
                return
            end
            if (runner.LocalPlayer.HP < 60 and not runner.LocalPlayer:HasAura("Survival of the Fittest", "HELPFUL")) then
                self:Cast("Survival of the Fittest", "player")
                return
            end
            if self.Pet and not UnitIsDead("pet") and self:CanCast("Mend Pet", self.Pet) and (UnitHealth("pet") / UnitHealthMax("pet") * 100) < 90 then
                self:Cast("Mend Pet")
                return
            end
            if IsPlayerSpell(193533) and self:CanCast("Steady Shot", self.Target) and not runner.LocalPlayer:HasAura("Steady Focus", "HELPFUL") then
                self:Cast("Steady Shot")
                return
            end
            if IsPlayerSpell(260243) and self:CanCast("Volley", self.Target) then
                self:Cast("Volley")
                return
            end
            if self:CanCast("Kill Shot", self.Target) then
                self:Cast("Kill Shot")
                return
            end
            if self:CanCast("Rapid Fire", self.Target) then
                self:Cast("Rapid Fire")
                return
            end
            Unlock(RunMacroText, "/use 13")
            Unlock(RunMacroText, "/use 14")
            if self:CanCast("Trueshot", self.Target) then
                self:Cast("Trueshot")
                return
            end
            if self:CanCast("Wailing Arrow", self.Target) then
                self:Cast("Wailing Arrow")
                return
            end
            if self:CanCast("Aimed Shot", self.Target) then
                self:Cast("Aimed Shot")
                return
            end
            if IsPlayerSpell(19434) and runner.LocalPlayer:HasAura("Precise Shots", "HELPFUL") and self:CanCast("Arcane Shot", self.Target) and runner.LocalPlayer.Focus > 55 then
                if target:EnemiesInRange(10) > 2 then
                    self:Cast("Multi-Shot")
                    return
                else
                    self:Cast("Arcane Shot")
                    return
                end
            end
            if self:CanCast("Explosive Shot", self.Target) then
                self:Cast("Explosive Shot")
                return
            end
            if self:CanCast("Steady Shot", self.Target) then
                self:Cast("Steady Shot")
                return
            end
        end
    end
end

registerRotation(HunterRotation)