runner.Mechanics.Stonevault1 = runner.Mechanics.BaseMechanic:extend()
local BM = runner.Mechanics.Stonevault1
runner.Mechanics.Stonevault1 = BM

function BM:init()
    self.ForDungeon = "Stonevault"
    self.FindSafe = true
    self.SafeSpot = nil
end

function BM:NeedsMechanic()
    --TRASH
    local casting = self:WatchForCast("Pulverizing Pounce")
    if casting then
        local targetID = casting.Target
        local target = runner.Engine.ObjectManager:GetByPointer(targetID)
        if target then
            if target:DistanceFromPlayer() < 15 then
                return true
            end
        end
    end
    local seismicWave = self:WatchForCast("Seismic Wave")
    if seismicWave and not runner.Engine.Navigation:IsBehindTarget(seismicWave) then
        return true
    end

    --EDNA
    local refractingBeam = runner.LocalPlayer:HasAura("Refracting Beam", "HARMFUL")
    local volatileSpike = runner.Engine.ObjectManager:GetClosestByName("Invisible Object")
    if refractingBeam and volatileSpike and volatileSpike:DistanceFromPlayer() > 7 then
        return true
    end

    local volatileSpike = runner.Engine.ObjectManager:GetClosestByName("Invisible Object")
    if volatileSpike then
        if volatileSpike:DistanceFromPlayer() < 7 then
            return true
        end
    end

    --SKARM
    local unstableCrash = self:WatchForCast("Unstable Crash")
    local boss2 = runner.Engine.ObjectManager:GetByName("Skarmorak")
    if unstableCrash and boss2 and boss2:DistanceFromPlayer() < 25 then
        return true
    end
    local crystalShard = runner.Engine.ObjectManager:GetClosestByName("Crystal Shard")
    if crystalShard and not crystalShard.isDead and crystalShard.CanAttack then
        return true
    end
    local unstableFragments = runner.Engine.ObjectManager:GetClosestByName("Unstable Fragment")
    if unstableFragments and unstableFragments:DistanceFromPlayer() > 5 then
        return true
    end

    --TWINS
    local scrapSong = self:WatchForCast("Scrap Song")
    local safetyPoint = runner.Classes.Point:new(-242, 305, 349)
    if scrapSong and safetyPoint:DistanceFromPlayer() < 3 then
        return true
    end

    self.FindSafe = true
    return false
end

function BM:WatchForCast(spellName)
    for k,v in pairs(runner.Engine.ObjectManager.units) do
       if v:CastingSpellByName(spellName) then
           return v
       end
    end
    return nil
end

function BM:DoMechanic()
    --TRASH
    local casting = self:WatchForCast("Pulverizing Pounce")
    if casting then
        local targetID = casting.Target
        local target = runner.Engine.ObjectManager:GetByPointer(targetID)
        if target then
            if target:DistanceFromPlayer() < 15 then
                if not self.SafeSpot or self.FindSafe then
                    self.SafeSpot = runner.Engine.Navigation:waypointAwayFrom(runner.LocalPlayer.x, runner.LocalPlayer.y, runner.LocalPlayer.z, 25)
                end
                if self.SafeSpot then
                    runner.Draw:SetColor(255,255,255,255)
                    runner.Draw:Circle(self.SafeSpot.X, self.SafeSpot.Y, self.SafeSpot.Z, 5)
                    self.FindSafe = false
                    if self.SafeSpot:DistanceFromPlayer() > 5 then
                        self.FindSafe = false
                        runner.Engine.Navigation:MoveToPoint(self.SafeSpot.X, self.SafeSpot.Y, self.SafeSpot.Z)
                    else
                        self.FindSafe = true
                        Unlock(MoveForwardStop)
                    end
                end
            end
        end
    end
    local seismicWave = self:WatchForCast("Seismic Wave")
    if seismicWave then
        local behind = runner.Engine.Navigation:MoveBehindUnit(seismicWave)
        if behind.x then
            local behindspot = runner.Classes.Point:new(behind.x,behind.y,behind.z)
            if behindspot:DistanceFromPlayer() > 2 then
                runner.Engine.Navigation:MoveToPoint(behind.x,behind.y,behind.z)
            else
                Unlock(MoveForwardStop)
            end
        end
    end

    --EDNA
    if runner.LocalPlayer:HasAura("Refracting Beam", "HARMFUL") then
        local volatileSpike = runner.Engine.ObjectManager:GetClosestByName("Invisible Object")
        if volatileSpike then
            if volatileSpike:DistanceFromPlayer() > 8 then
                print("Moving to Volatile Spike")
                runner.Engine.Navigation:MoveTo(volatileSpike.Pointer)
            else
                print("Facing Volatile Spike")
                runner.Engine.Navigation:FaceUnit(volatileSpike.Pointer)
                Unlock(MoveForwardStop)
            end
        end
    else
        local volatileSpike = runner.Engine.ObjectManager:GetClosestByName("Invisible Object")
        if volatileSpike then
            if volatileSpike:DistanceFromPlayer() < 7 then
                if self.FindSafe or not self.SafeSpot then
                    self.SafeSpot = runner.Engine.Navigation:waypointAwayFrom(runner.LocalPlayer.x, runner.LocalPlayer.y, runner.LocalPlayer.z, 20)
                end
                if self.SafeSpot then
                    self.FindSafe = false
                    runner.Draw:Circle(self.SafeSpot.X, self.SafeSpot.Y, self.SafeSpot.Z, 5)
                    if self.SafeSpot:DistanceFromPlayer() > 5 then
                        print("Moving from Volatile Spike")
                        runner.Engine.Navigation:MoveToPoint(self.SafeSpot.X, self.SafeSpot.Y, self.SafeSpot.Z)
                    else
                        print("Safe Spot Reached")
                        self.FindSafe = true
                        Unlock(MoveForwardStop)
                    end
                end
            end
        end
    end

    --SKARM
    local unstableCrash = self:WatchForCast("Unstable Crash")
    local boss2 = runner.Engine.ObjectManager:GetByName("Skarmorak")
    if unstableCrash and boss2 and boss2:DistanceFromPlayer() < 20 then
        if not self.SafeSpot or self.FindSafe then
            self.SafeSpot = runner.Engine.Navigation:waypointAwayFrom(boss2.x, boss2.y, boss2.z, 25)
        end
        if self.SafeSpot then
            self.FindSafe = false
            if self.SafeSpot:DistanceFromPlayer() > 5 then
                runner.Engine.Navigation:MoveToPoint(self.SafeSpot.X, self.SafeSpot.Y, self.SafeSpot.Z)
            else
                self.FindSafe = true
                Unlock(MoveForwardStop)
            end
        end
    end
    local crystalShard = runner.Engine.ObjectManager:GetClosestByName("Crystal Shard")
    if crystalShard and crystalShard.CanAttack and not crystalShard.isDead then
        if crystalShard:DistanceFromPlayer() > runner.rotation.CombatRange then
            runner.Engine.Navigation:MoveTo(crystalShard.Pointer)
        else
            Unlock(TargetUnit, crystalShard.Pointer)
            runner.Engine.Navigation:FaceUnit(crystalShard.Pointer)
            Unlock(MoveForwardStop)
            runner.rotation:Pulse(crystalShard)
        end
    end
    local unstableFragments = runner.Engine.ObjectManager:GetClosestByName("Unstable Fragment")
    if unstableFragments then
        print("Unstable Fragment")
        if unstableFragments:DistanceFromPlayer() > 5 then
            runner.Engine.Navigation:MoveTo(unstableFragments.Pointer)
        else
            Unlock(TargetUnit, unstableFragments.Pointer)
            runner.Engine.Navigation:FaceUnit(unstableFragments.Pointer)
            Unlock(MoveForwardStop)
        end
    end

    --TWINS
    local scrapSong = self:WatchForCast("Scrap Song")
    local safetyPoint = runner.Classes.Point:new(-242, 305, 349)
    if scrapSong then
        if safetyPoint:DistanceFromPlayer() > 3 then
            runner.Engine.Navigation:MoveToPoint(safetyPoint.X, safetyPoint.Y, safetyPoint.Z)
        else
            Unlock(MoveForwardStop)
        end
    end
end

registerMechanic("Stonevault", BM)