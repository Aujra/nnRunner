runner.Mechanics.Cinderbrew1 = runner.Mechanics.BaseMechanic:extend()
local BM = runner.Mechanics.Cinderbrew1
runner.Mechanics.Cinderbrew1 = BM

function BM:init()
    self.ForBoss = "Brew Master Aldryr"
end

function BM:NeedsMechanic()
    local mob = runner.Engine.ObjectManager:GetByName(self.ForBoss)
    if not mob then
        return false
    end
    if mob.isDead then
        return false
    end

    local isCasting = mob:CastingSpellByName("Happy Hour")
    if isCasting then
        return true
    end
    return false
end

function BM:DoMechanic()
    if not runner.LocalPlayer:HasAura("Carrying Cinderbrew", "HELPFUL") then
        local cinderbrew = runner.Engine.ObjectManager:GetByName("Mug of Cinderbrew")
        if cinderbrew then
            if cinderbrew:DistanceFromPlayer() > 4 then
                runner.Engine.Navigation:MoveTo(cinderbrew.Pointer)
            else
                runner.Engine.Navigation:FaceUnit(cinderbrew.Pointer)
                Unlock(MoveForwardStop)
                runner.nn.ObjectInteract(cinderbrew.Pointer)
            end
        end
    else
        local rowdy = runner.Engine.ObjectManager:FindMobWithNameAndAura("Thirsty Patron", "Rowdy Yell")
        if rowdy then
            if rowdy:DistanceFromPlayer() > 5 then
                runner.Engine.Navigation:MoveTo(rowdy.Pointer)
            else
                runner.Engine.Navigation:FaceUnit(rowdy.Pointer)
            end
        end
    end
end

registerMechanic("Brew Master Aldryr", BM)