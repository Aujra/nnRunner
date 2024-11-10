runner.Rotations.BaseRotation = class()
local BaseRotation = runner.Rotations.BaseRotation
runner.Rotations.BaseRotation = BaseRotation

function BaseRotation:init()
    self.Class = "any"
    self.Name = "Base"
    self.Description = "Base Rotation"
    self.ClosestCaster = nil
    self.Tank = nil
    self.Focus = nil
    self.DeEnrage = nil
    self.Target = nil
    self.LowestPlayer = nil
    self.AoeEnemies = 0
    self.PullRange = 30
    self.combatRange = 30
    self.CombatRange = 30
end

function BaseRotation:OutOfCombat()
end

function BaseRotation:Pull(target)
    target = target or UnitTarget("player")
    if not target then
        return
    end
    if type(target) ~= "table" then
        target = runner.Engine.ObjectManager:GetByPointer(target)
    end
    if not target then
        return
    end
    self.Target = target

    if SpellIsTargeting() then
        local x,y,z = runner.nn.ObjectPosition('target')
        runner.nn.ClickPosition(x,y,z)
    end

    if not C_Spell.IsCurrentSpell(6603) then
        self:Cast("Auto Attack")
    end
end

function BaseRotation:Pulse(target)
    target = target or UnitTarget("player")
    if not target then
        return
    end
    if type(target) ~= "table" then
        target = runner.Engine.ObjectManager:GetByPointer(target)
    end
    if not target then
        return
    end
    self.Target = target
    self.ClosestCaster = self:GetClosestCastingEnemy()
    self.Tank = self:GetTank()
    self.target = target
    self.Focus = self:GetFocus()
    self.DeEnrage = self:GetDeEnrage()
    self.SpellSteal = self:ClosestSpellSteal()
    self.LowestPlayer = self:GetLowestPlayer()
    self.Pet = UnitName("pet")
    self.AoeEnemies = self.Target:EnemiesInRange(10)

    if runner.LocalPlayer.IsCasting then
        return
    end

    if SpellIsTargeting() then
        local x,y,z = runner.nn.ObjectPosition('target')
        runner.nn.ClickPosition(x,y,z)
    end
end

function BaseRotation:GetLowestPlayer(range)
    range = range or 40
    local lowestPlayer = nil
    local lowestHP = 100
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if v.HP < lowestHP and v:DistanceFromPlayer() < range then
            lowestPlayer = v
            lowestHP = v.HP
        end
    end
    if runner.LocalPlayer.HP < lowestHP then
        lowestPlayer = runner.LocalPlayer
    end
    return lowestPlayer
end

function BaseRotation:ClosestSpellSteal()
    local closestSteal = nil
    local closestDistance = 9999
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v:HasStealable() and v:DistanceFromPlayer() < closestDistance then
            closestSteal = v
            closestDistance = v:DistanceFromPlayer()
        end
    end
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if v:HasStealable() and v:DistanceFromPlayer() < closestDistance then
            closestSteal = v
            closestDistance = v:DistanceFromPlayer()
        end
    end
    return closestSteal
end

function BaseRotation:IsSpellOnCD(spell)
    local spellInfo = C_Spell.GetSpellCooldown(spell)
    return spellInfo.duration > 0
end

function BaseRotation:EnemyCountWithDebuff(debuff)
    local count = 0
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v:HasAura(debuff, "HARMFUL") then
            count = count + 1
        end
    end
    return count
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
            focus = v
            break
        end
    end
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.IsFocus then
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
        if v.Reaction and v.Reaction <= 4 and v.InCombat and
        v:ShouldInterruptCasting() and v:DistanceFromPlayer() < range then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closestCaster = v
                closestDistance = distance
            end
        end
    end
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if v.Reaction and v.Reaction <= 4 and v.InCombat and
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

function BaseRotation:IsGCD()
    local spellInfo = C_Spell.GetSpellCooldown(61304)
    if spellInfo.enabled == 1 then
        return false
    end
    return true
end

function BaseRotation:GetClosestWithoutDebuff(debuff)
    local closest = nil
    local closestDistance = 9999
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if not v:HasAura(debuff, "HARMFUL") and v:DistanceFromPlayer() < closestDistance
        and v.Reaction and v.Reaction < 4 and v.InCombat then
            closest = v
            closestDistance = v:DistanceFromPlayer()
        end
    end
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if not v:HasAura(debuff, "HARMFUL") and v:DistanceFromPlayer() < closestDistance
                and v.Reaction and v.Reaction < 4 then
            closest = v
            closestDistance = v:DistanceFromPlayer()
        end
    end
    return closest
end

function BaseRotation:CanCast(spell, target, forceMelee, debug)
    forceMelee = forceMelee or false
    debug = debug or false
    target = target or "target"
    if not spell then
        return false
    end
    if type(target) ~= "table" then
        target = runner.Engine.ObjectManager:GetByPointer(target)
    end

    if not target then
        return false
    end

    local spellInfo = C_Spell.GetSpellInfo(spell)
    if not spellInfo then
        print("Spell not found: " .. spell)
        return false
    end
    local isKnown = IsPlayerSpell(spellInfo.spellID)
    if not isKnown then
        print("Spell not known: " .. spell)
        return false
    end

    local cdInfo = C_Spell.GetSpellCooldown(spell)
    local onCD = cdInfo.duration > 0

    local gcdCD = C_Spell.GetSpellCooldown(61304)
    local gcdOnCD = gcdCD.duration > 0

    local inRange = false
    if not forceMelee then
        inRange = target:DistanceFromPlayer() < spellInfo.maxRange or spellInfo.maxRange == 0
    else
        inRange = target:DistanceFromPlayer() < 10
    end
    local canCast = C_Spell.IsSpellUsable(spell)

    if debug then
        print("Spell: " .. spell .. " Known: " .. tostring(isKnown) .. " CD: " .. tostring(onCD) .. " Range: " .. tostring(inRange) .. " Castable: " .. tostring(canCast))
    end
    return (not onCD and not gcdOnCD) and inRange and isKnown and canCast
end

function BaseRotation:Cast(spell, target)
    target = target or "target"
    --print("Casting: " .. spell .. " on " .. target)
    Unlock(CastSpellByName, spell, target)
end

registerRotation(BaseRotation)