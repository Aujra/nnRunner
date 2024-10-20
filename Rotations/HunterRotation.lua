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
    self.Pet = UnitName("pet")
    target = self.target

    if Unlock(UnitAffectingCombat, "player") and target and (
            Unlock(UnitAffectingCombat, target.pointer) or string.find(target.Name, "Training")) then

        if runner.LocalPlayer.IsCasting then
            return
        end

        if runner.LocalPlayer.specName == "Marksmanship" then
            self:Cast("Volley")
            if self.Focus and self.Focus:DistanceFromPlayer() < 40 then
                self:Cast("Misdirection", "focus")
            end
            if self.ClosestCaster then
                self:Cast("Counter Shot", self.ClosestCaster.pointer)
            end
            if self.DeEnrage and self.DeEnrage:DistanceFromPlayer() < 30 then
                print("Tranquilizing Shot")
                self:Cast("Tranquilizing Shot", self.DeEnrage.pointer)
            end
            if not target:HasAura("Hunter's Mark", "HARMFUL") and target.HP > 85 then
                self:Cast("Hunter's Mark")
            end
            if runner.LocalPlayer.HP < 30 then
                self:Cast("Fortitude of the Bear")
            end
            if runner.LocalPlayer.HP < 50 then
                self:Cast("Exhilaration")
            end
            if runner.LocalPlayer.HP < 60 and not runner.LocalPlayer:HasAura("Survival of the Fittest", "HELPFUL") then
                self:Cast("Survival of the Fittest")
            end
            if self.Pet and not UnitIsDead("pet") and (UnitHealth("pet") / UnitHealthMax("pet") * 100) < 90 then
                self:Cast("Mend Pet")
            end
            if IsPlayerSpell(193533) and not player:HasAura("Steady Focus", "HELPFUL") then
                self:Cast("Steady Focus", target.pointer)
            end
            self:Cast("Volley")
            self:Cast("Kill Shot")
            self:Cast("Rapid Fire")
            Unlock(RunMacroText, "/use 13")
            Unlock(RunMacroText, "/use 14")
            self:Cast("Trueshot")
            self:Cast("Wailing Arrow")
            self:Cast("Aimed Shot")
            if runner.LocalPlayer:HasAura("Precise Shots", "HELPFUL") and runner.LocalPlayer.Focus > 55 then
                if target:EnemiesInRange(10) > 2 then
                    self:Cast("Multi-Shot")
                else
                    self:Cast("Arcane Shot")
                end
            end
            self:Cast("Explosive Shot")
            self:Cast("Steady Shot")
        end
    end
end

runner.rotations["hunter"] = HunterRotation