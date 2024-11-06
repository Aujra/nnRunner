runner.Behaviors.BaseBehavior = class({}, "BaseBehavior")
local BaseBehavior = runner.Behaviors.BaseBehavior
runner.Behaviors.BaseBehavior = BaseBehavior

function BaseBehavior:init()
    self.Name = "BaseBehavior"
    self.Type = "Base"
    self.CanHaveChildren = false
    self.IsComplete = false
    self.CurrentProfile = {}
    self.Index = 0
end

function BaseBehavior:Run()
    if runner.LocalPlayer.isDead then
        RepopMe()
        if self.CurrentProfile then
            for k,v in pairs(self.CurrentProfile.Steps) do
                v.step.IsComplete = false
            end
        end
        return
    end
end

function BaseBehavior:SelfDefense()
    if UnitAffectingCombat("player") then
        local target = self:GetBestTarget()
        if target then
            if target:DistanceFromPlayer() > runner.rotation.CombatRange then
                runner.Engine.Navigation:MoveTo(target.pointer)
            else
                Unlock(TargetUnit, target.pointer)
                runner.Engine.Navigation:FaceUnit(target.pointer)
                Unlock(MoveForwardStop)
                runner.rotation:Pulse(target)
            end
        end

        --for k,v in pairs(runner.Engine.ObjectManager.areatrigger) do
        --    if v.Reaction then
        --        if v:DistanceFromPlayer() < v.radius then
        --            print("We are in an area trigger made by " .. v.creatorName)
        --        end
        --    end
        --end

        return true
    end
    return false
end

function BaseBehavior:BuildStepGUI(container)
end

function BaseBehavior:Save()
end

function BaseBehavior:Load(data)
end

function BaseBehavior:GetBestTarget()
    local bestTarget = nil
    local bestScore = -999999
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Reaction and v.Reaction <= 4 and not v.isDead then
            local score = v:GetScore()
            if score > bestScore then
                bestScore = score
                bestTarget = v
            end
        end
    end
    return bestTarget
end

registerBehavior("Base",BaseBehavior)