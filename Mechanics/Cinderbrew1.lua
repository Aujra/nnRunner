runner.Mechanics.Cinderbrew1 = runner.Mechanics.BaseMechanic:extend()
local BM = runner.Mechanics.Cinderbrew1
runner.Mechanics.Cinderbrew1 = BM

function BM:init()
    self.ForBoss = "Brew Master Aldryr"
end

function BM:NeedsMechanic()
    local mob = runner.Engine.ObjectManager:GetByName(self.ForBoss)
    print("mob: " .. tostring(mob))
    if not mob then
        return false
    end
    if mob.IsDead then
        return false
    end

    local isCasting = mob:CastingSpellByName("Happy Hour")
    if isCasting then
        return true
    end
    return false
end

function BM:DoMechanic()
end

registerMechanic("Brew Master Aldryr", BM)