runner.Rotations.WarriorRotation = runner.Rotations.BaseRotation:extend()
local WarriorRotation = runner.Rotations.WarriorRotation
runner.Rotations.WarriorRotation = WarriorRotation

function WarriorRotation:init()
    runner.Rotations.BaseRotation:init(self)
    self.Class = "Warrior"
    self.Name = "Warrior"
    self.Description = "Warrior Rotation"
    self.PullRange = 20
    self.CombatRange = 6
end

function WarriorRotation:OutOfCombat()
    if runner.LocalPlayer.isDead then return end

    if runner.LocalPlayer.IsCasting then
        return true
    end
    return false
end

function WarriorRotation:Pull(target)
    if not target then
        return
    end
    if self:CanCast("Charge", target) then self:Cast("Charge", target.pointer) return end
    if self:CanCast("Throw", target) then self:Cast("Throw", target.pointer) return end
end

function WarriorRotation:Pulse(target)
    runner.Rotations.BaseRotation.Pulse(self, target)
    target = self.target

    if Unlock(UnitAffectingCombat, "player") and target and (
            Unlock(UnitAffectingCombat, target.pointer) or string.find(target.Name, "Training")) then

        if runner.LocalPlayer.IsCasting then
            return
        end

        if self.ClosestCaster then
            if self:CanCast("Pummel", self.ClosestCaster) then self:Cast("Pummel", self.ClosestCaster.pointer) return end
            if self:CanCast("Shield Bash", self.ClosestCaster) then self:Cast("Shield Bash", self.ClosestCaster.pointer) return end
        end

        if runner.LocalPlayer.specName == "Protection" then
            if self:CanCast("Exectute", target) then self:Cast("Exectute", target.pointer) return end
            if self:CanCast("Shield Slam", target) then self:Cast("Shield Slam", target.pointer) return end
            if self:CanCast("Revenge", target) then self:Cast("Revenge", target.pointer) return end
            if self:CanCast("Thunder Clap", target) then self:Cast("Thunder Clap", target.pointer) return end
            if self:CanCast("Devastate", target) then self:Cast("Devastate", target.pointer) return end
            if self:CanCast("Heroic Strike", target) then self:Cast("Heroic Strike", target.pointer) return end
        end

        if self:CanCast("Execute", target) then self:Cast("Execute", target.pointer) return end
        if self:CanCast("Shield Slam", target) then self:Cast("Shield Slam", target.pointer) return end
        if self:CanCast("Slam", target) then self:Cast("Slam", target.pointer) return end
    end
end

registerRotation(WarriorRotation)