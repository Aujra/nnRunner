runner.Behaviors.BaseBehavior = class({}, "BaseBehavior")
local BaseBehavior = runner.Behaviors.BaseBehavior
runner.Behaviors.BaseBehavior = BaseBehavior

function BaseBehavior:init()
    self.Name = "BaseBehavior"
    self.Type = "Base"
    self.Title = "Base Behavior"
    self.Description = "Base Behavior"
    self.CanHaveChildren = false
    self.IsComplete = false
    self.CurrentProfile = {}
    self.Index = 0
    self.CurrentStep = false

    self.sx, self.sy, self.sz = 0, 0, 0
    self.safeTries = 0
    self.FoundSafeSpot = false
end

function BaseBehavior:Run(target)
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

function BaseBehavior:SelfDefense(preftarget)
    preftarget = preftarget or nil
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

        for k,v in pairs(runner.Engine.ObjectManager.areatrigger) do
            if v.Reaction and v.Reaction < 4 and v.PlayerInside then
                local x, y, z = self:FindSafeSpot(v, preftarget)
                if x and y and z then
                    self.FoundSafeSpot = true
                    if runner.LocalPlayer:DistanceFromPoint(x, y, z) > 3 then
                        runner.Engine.Navigation:MoveTo(x, y, z)
                    else
                        self.FoundSafeSpot = false
                        self.safeTries = 0
                        Unlock(MoveForwardStop)
                    end
                end
            end
        end
        return true
    end
    return false
end

function BaseBehavior:FindSafeSpot(trigger, preftarget)
    if not self.sx then
        self.sx, self.sy, self.sz = trigger.x, trigger.y, trigger.z
    end
    runner.Draw:SetColor(0, 0, 255, 255)
    runner.Draw:Circle(self.sx, self.sy, self.sz, 2)
    self.sx = self.sx + runner.randomBetween(self,-trigger.radius*3, trigger.radius*3)
    self.sy = self.sy + runner.randomBetween(self,-trigger.radius*3, trigger.radius*3)
    for k,v in pairs(runner.Engine.ObjectManager.areatrigger) do
        if v.Reaction and v.Reaction < 4 and self:PointInTrigger(self.sx, self.sy, self.sz, v) then
            return self:FindSafeSpot(trigger)
        end
    end
    if preftarget and preftarget:DistanceFromPoint(self.sx, self.sy, self.sz) > 30 then
        print("Found a spot but not close enough to target")
        return self:FindSafeSpot(trigger)
    end
    return self.sx, self.sy, self.sz
end

function BaseBehavior:PointInTrigger(x, y, z, trigger)
    local distance = math.sqrt((x - trigger.x)^2 + (y - trigger.y)^2 + (z - trigger.z)^2)
    return distance < trigger.radius
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

function BaseBehavior:BuildStepGUI(container)
    container:ReleaseChildren()
    local header = runner.AceGUI:Create("Heading")
    header:SetText(self.Title)
    header:SetFullWidth(true)
    container:AddChild(header)
    local description = runner.AceGUI:Create("Label")
    description:SetText(self.Description)
    description:SetFullWidth(true)
    container:AddChild(description)
end
function BaseBehavior:BuildMiniUI(container)
end
function BaseBehavior:Setup()
end

registerBehavior("Base",BaseBehavior)