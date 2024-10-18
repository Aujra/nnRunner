runner.Rotations.BaseRotation = class()
local BaseRotation = runner.Rotations.BaseRotation
runner.Rotations.BaseRotation = BaseRotation

function BaseRotation:init()
    self.Class = "Base"
    self.Name = "Base"
    self.Description = "Base Rotation"
    self.ClosestCaster = nil
    self.Tank = nil
    self.Focus = nil
    self.DeEnrage = nil
end

function BaseRotation:Pulse(target)
    target = target or UnitTarget("player")
    if type(target) ~= "table" then
        target = runner.Engine.ObjectManager:GetByPointer(target)
    end
    if not target then
        return
    end
    self.ClosestCaster = self:GetClosestCastingEnemy()
    self.Tank = self:GetTank()
    self.target = target
    self.Focus = self:GetFocus()
    self.DeEnrage = self:GetDeEnrage()
end

function BaseRotation:GetDeEnrage()
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.DeEnrage then
            return v
        end
    end
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if v.DeEnrage then
            return v
        end
    end
    return nil
end

function BaseRotation:GetFocus()
    local focus = nil
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if v.IsFocus then
            print("Found focus")
            focus = v
            break
        end
    end
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.IsFocus then
            print("Found focus")
            focus = v
            break
        end
    end
    return focus
end

function BaseRotation:GetClosestCastingEnemy(range)
    range = range or 30
    local closestCaster = nil
    local closestDistance = 9999
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Reaction <= 4 and v.InCombat and
        v:ShouldInterruptCasting() and v:DistanceFromPlayer() < range then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closestCaster = v
                closestDistance = distance
            end
        end
    end
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if v.Reaction <= 4 and v.InCombat and
        v:ShouldInterruptCasting() and v:DistanceFromPlayer() < range then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closestCaster = v
                closestDistance = distance
            end
        end
    end
    return closestCaster
end

function BaseRotation:GetTank()
    local tank = nil
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if v.Role == "TANK" then
            tank = v
            break
        end
    end
    return tank
end

function BaseRotation:Cast(spell, target)
    Unlock(CastSpellByName, spell, target)
end