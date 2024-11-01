runner.Rotations.ShamanRotation = runner.Rotations.BaseRotation:extend()
local ShamanRotation = runner.Rotations.ShamanRotation
runner.Rotations.ShamanRotation = ShamanRotation

function ShamanRotation:init()
    runner.Rotations.BaseRotation.init(self)
    self.Class = "Shaman"
    self.Name = "Shaman"
    self.Description = "Shaman Rotation"
end

function ShamanRotation:Pull(target)
    self:Cast("Chain Lightning", target.pointer)
end

function ShamanRotation:Pulse(target)
    runner.Rotations.BaseRotation.Pulse(self, target)
    target = self.target

    if Unlock(UnitAffectingCombat, "player") and target and (
            Unlock(UnitAffectingCombat, target.pointer) or string.find(target.Name, "Training")) then

        if runner.LocalPlayer.IsCasting then
            return
        end

        if runner.LocalPlayer.specName == "Elemental" then
            local enemiesAround = self.target:EnemiesInRange(8)

            if self:CanCast("Stone Bulwark Totem", runner.LocalPlayer) and runner.LocalPlayer.HP < 50 then
                self:Cast("Stone Bulwark Totem")
                return
            end

            if self:CanCast("Healing Stream Totem", runner.LocalPlayer) and runner.LocalPlayer.HP < 70 then
                self:Cast("Healing Stream Totem")
                return
            end

            if self:CanCast("Earth Shield", runner.LocalPlayer) and not runner.LocalPlayer:HasAura("Earth Shield", HELPFUL) then
                self:Cast("Earth Shield")
                return
            end

            if self.ClosestCaster and self.ClosestCaster:DistanceFromPlayer() < 25 and self:CanCast("Wind Shear", self.ClosestCaster.pointer) then
                self:Cast("Wind Shear", self.ClosestCaster.pointer)
                return
            end

            local itemID = GetInventoryItemID("player", 13) -- 13 for trinket1, 14 for trinket2
            local start, duration, enable = C_Container.GetItemCooldown(itemID)
            if enable == 1 and duration == 0 then
                return
                Unlock(RunMacroText, "/use 13")
            end
            local itemID = GetInventoryItemID("player", 14) -- 13 for trinket1, 14 for trinket2
            local start, duration, enable = C_Container.GetItemCooldown(itemID)
            if enable == 1 and duration == 0 then
                Unlock(RunMacroText, "/use 14")
                return
            end

            if self:CanCast("Storm Elemental", runner.LocalPlayer) then
                self:Cast("Storm Elemental")
                return
            end
            if self:CanCast("Stormkeeper", runner.LocalPlayer) then
                self:Cast("Stormkeeper")
                return
            end
            if self:CanCast("Ancestral Swiftness", runner.LocalPlayer) then
                self:Cast("Ancestral Swiftness")
                return
            end
            if self:CanCast("Primordial Wave", self.Target) then
                self:Cast("Primordial Wave", self.Target.pointer)
                return
            end
            if self:CanCast("Ascendance", runner.LocalPlayer) then
                self:Cast("Ascendance")
                return
            end
            if self:CanCast("Liquid Magma Totem", self.Target) then
                self:Cast("Liquid Magma Totem", self.Target.pointer)
                return
            end
            if self:CanCast("Flame Shock", self.Target) and not self.Target:HasAura("Flame Shock", "HARMFUL") then
                self:Cast("Flame Shock", self.Target.pointer)
                return
            end
            if self:CanCast("Earthquake", self.Target) and enemiesAround > 2 then
                self:Cast("Earthquake", self.Target.pointer)
                return
            end
            if self:CanCast("Earth Shock", self.Target) and enemiesAround <= 2 then
                self:Cast("Earth Shock", self.Target.pointer)
                return
            end
            if self:CanCast("Lava Burst", self.Target) then
                self:Cast("Lava Burst", self.Target.pointer)
                return
            end
            if runner.LocalPlayer:HasAura("Tempest", "HELPFUL") then
                self:Cast("Tempest", self.Target.pointer)
                return
            end
            if self:CanCast("Chain Lightning", self.Target) and enemiesAround > 2 then
                self:Cast("Chain Lightning", self.Target.pointer)
                return
            end
            self:Cast("Lightning Bolt", self.Target.pointer)
        end

        if runner.LocalPlayer.specName == "Restoration" then
            if self.LowestPlayer then
                if self:CanCast("Healing Surge", self.LowestPlayer) and self.LowestPlayer.HP < 50 then
                    self:Cast("Healing Surge", self.LowestPlayer.pointer)
                    return
                end
                if self:CanCast("Healing Wave", self.LowestPlayer) and self.LowestPlayer.HP < 70 then
                    self:Cast("Healing Wave", self.LowestPlayer.pointer)
                    return
                end
                if self:CanCast("Riptide", self.LowestPlayer) and self.LowestPlayer.HP < 90 then
                    self:Cast("Riptide", self.LowestPlayer.pointer)
                    return
                end
                if self:CanCast("Healing Rain", self.LowestPlayer) and self.LowestPlayer.HP < 95 then
                    self:Cast("Healing Rain", self.LowestPlayer.pointer)
                    return
                end
                if self:CanCast("Earth Shield", self.Tank) and not self.Tank:HasAura("Earth Shield", "HELPFUL") then
                    print("Casting Earth Shield on Tank")
                    self:Cast("Earth Shield", self.Tank.pointer)
                    return
                end
            end
            if self.Target then
                if self:CanCast("Flame Shock", self.Target) and not self.Target:HasAura("Flame Shock", "HARMFUL") then
                    self:Cast("Flame Shock", self.Target.pointer)
                    return
                end
                if self:CanCast("Lava Burst", self.Target) then
                    self:Cast("Lava Burst", self.Target.pointer)
                    return
                end
                if self:CanCast("Lightning Bolt", self.Target) then
                    self:Cast("Lightning Bolt", self.Target.pointer)
                    return
                end
            end
        end
    end
end

registerRotation(ShamanRotation)