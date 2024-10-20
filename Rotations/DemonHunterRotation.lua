    runner.Rotations.DemonHunterRotation = runner.Rotations.BaseRotation:extend()
    local DemonHunterRotation = runner.Rotations.DemonHunterRotation
    runner.Rotations.DemonHunterRotation = DemonHunterRotation

    function DemonHunterRotation:init()
        runner.Rotations.BaseRotation.init(self)
        self.Class = "Demon Hunter"
        self.Name = "Demon Hunter"
        self.Description = "Demon Hunter Rotation"
    end

    function DemonHunterRotation:Pulse(target)
        runner.Rotations.BaseRotation.Pulse(self, target)
        local spec = runner.LocalPlayer.specName

        if runner.LocalPlayer.IsCasting then
            return
        end

        if UnitAffectingCombat("player") then
            if spec == "Vengeance" then
                local fieryBrandCount = self:EnemyCountWithDebuff("Fiery Brand")
                local soulFragments = runner.LocalPlayer.SoulFragments

                if runner.LocalPlayer.HP < 50 then
                    self:Cast("Demon Spikes")
                end
                if runner.LocalPlayer.HP < 30 then
                    self:Cast("Fiery Brand")
                end
                if runner.LocalPlayer.HP < 20 then
                    self:Cast("Metamorphosis")
                end

                if self.ClosestCaster and self:CanCast("Sigil of Silence", self.ClosestCaster) then
                    self:Cast("Sigil of Silence", self.ClosestCaster.pointer)
                    return
                end

                if self.ClosestCaster and self:CanCast("Disrupt", self.ClosestCaster) then
                    self:Cast("Disrupt", self.ClosestCaster.pointer)
                    return
                end

                if (self:CanCast("Infernal Strike", self.Target) and self.Target:DistanceFromPlayer() > 20) then
                    self:Cast("Infernal Strike")
                    return
                end
                if (self:CanCast("The Hunt", self.Target)) then
                    self:Cast("The Hunt")
                    return
                end
                if (self:CanCast("Fiery Brand", self.Target) and fieryBrandCount < 1) then
                    self:Cast("Fiery Brand")
                    return
                end
                if (self:CanCast("Soul Carver", self.Target)) then
                    self:Cast("Soul Carver")
                    return
                end
                if (self:CanCast("Fel Devastation", self.Target)) then
                    self:Cast("Fel Devastation")
                    return
                end
                if (not self.target:HasAura("Sigil of Flame", "HARMFUL") and self:CanCast("Sigil of Flame", self.Target)) then
                    self:Cast("Sigil of Flame")
                    return
                end
                if (self:CanCast("Immolation Aura", self.Target)) then
                    self:Cast("Immolation Aura")
                    return
                end
                if (self:CanCast("Spirit Bomb", self.Target) and soulFragments > 4) then
                    self:Cast("Spirit Bomb")
                    return
                end
                if (self:CanCast("Fracture", self.Target)) then
                    self:Cast("Fracture")
                    return
                end
                if (self:CanCast("Felblade", self.Target)) then
                    self:Cast("Felblade")
                    return
                end
                if (self:CanCast("Soul Cleave", self.Target)) then
                    self:Cast("Soul Cleave")
                    return
                end
                if (self:CanCast("Throw Glaive", self.Target)) then
                    self:Cast("Throw Glaive")
                    return
                end
            end

            if spec == "Havoc" then
                if self.ClosestCaster and self:CanCast("Sigil of Silence", self.ClosestCaster) then
                    self:Cast("Sigil of Silence", self.ClosestCaster.pointer)
                    return
                end

                if self.ClosestCaster and self:CanCast("Disrupt", self.ClosestCaster) then
                    self:Cast("Disrupt", self.ClosestCaster.pointer)
                    return
                end

                if runner.LocalPlayer.HP < 50 then
                    self:Cast("Blur")
                end

                --if self:CanCast("Blade Dance", self.Target) and runner.LocalPlayer:HasAura("Metamorphosis", "HELPFUL") and target:HasAura("Essence Break", "HARMFUL") then
                --    self:Cast("Death Sweep")
                --    return
                --end
                --if self:CanCast("Chaos Strike", self.Target) and runner.LocalPlayer:HasAura("Metamorphosis", "HELPFUL") and target:HasAura("Essence Break", "HARMFUL") then
                --    self:Cast("Annihilation")
                --    return
                --end
                if self:CanCast("Fel Rush", self.Target) and runner.LocalPlayer:HasAura("Unbound Chaos", "HELPFUL") then
                    self:Cast("Fel Rush")
                    return
                end
                if self:CanCast("Immolation Aura", self.Target) then
                    self:Cast("Immolation Aura")
                    return
                end
                if IsPlayerSpell(388108) and self:CanCast("Vengeful Retreat", self.Target) and not runner.LocalPlayer:HasAura("Initiative", "HELPFUL") and
                    self.Target:DistanceFromPlayer() < 15 then
                    self:Cast("Vengeful Retreat")
                    return
                end
                if self:CanCast("Fel Rush", self.Target) and self:IsSpellOnCD("Metamorphosis") and self.Target:DistanceFromPlayer() > 15 then
                    self:Cast("Fel Rush")
                    return
                end
                if self:CanCast("The Hunt", self.Target) then
                    self:Cast("The Hunt")
                    return
                end
                if self:CanCast("Sigil of Doom", self.Target) and runner.LocalPlayer:HasAura("Metamorphosis", "HELPFUL") then
                    self:Cast("Sigil of Doom")
                    return
                end
                if self:CanCast("Essence Break", self.Target) then
                    self:Cast("Essence Break")
                    return
                end
                if self:CanCast("Blade Dance", self.Target) and runner.LocalPlayer:HasAura("Metamorphosis", "HELPFUL") then
                    self:Cast("Death Sweep")
                    return
                end
                if self:CanCast("Sigil of Flame", self.Target) then
                    self:Cast("Sigil of Flame")
                    return
                end
                if self:CanCast("Eye Beam", self.Target) then
                    self:Cast("Eye Beam")
                    return
                end
                if self:CanCast("Metamorphosis", self.Target) and not runner.LocalPlayer:HasAura("Metamorphosis", "HELPFUL") and self:IsSpellOnCD("Eye Beam") then
                    self:Cast("Metamorphosis")
                    return
                end
                if self:CanCast("Blade Dance", self.Target) then
                    self:Cast("Blade Dance")
                    return
                end
                if self:CanCast("Chaos Strike", self.Target) and runner.LocalPlayer:HasAura("Metamorphosis", "HELPFUL") then
                    self:Cast("Annihilation")
                    return
                end
                if self:CanCast("Felblade", self.Target) and runner.LocalPlayer.Fury < 80 then
                    self:Cast("Felblade")
                    return
                end
                if self:CanCast("Chaos Strike", self.Target) then
                    self:Cast("Chaos Strike")
                    return
                end
                if self:CanCast("Immolation Aura", self.Target) then
                    self:Cast("Immolation Aura")
                    return
                end
                if self:CanCast("Throw Glaive", self.Target) then
                    self:Cast("Throw Glaive")
                    return
                end
            end

        end

    end

    runner.rotations["demonhunter"] = DemonHunterRotation