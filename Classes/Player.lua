runner.Classes.Player = runner.Classes.Unit:extend()
local Player = runner.Classes.Player
runner.Classes.Player = Player

runner.PlayerViewColumns = {
    "Name",
    "Pointer",
    "Distance",
    "Reaction",
    "Level",
    "IsCasting",
    "HP",
    "Focus"
}
function Player:init(pointer)
    runner.Classes.Unit.init(self, pointer)
    self.Race = select(2, UnitRace(self.pointer))
    self.Class = UnitClassBase(self.pointer)
    self.Focus = Unlock(UnitPower, self.pointer, 2)
    self.Mana = Unlock(UnitPower, self.pointer, 0) / Unlock(UnitPowerMax, self.pointer, 0) * 100
    self.Energy = Unlock(UnitPower, self.pointer, 3) / Unlock(UnitPowerMax, self.pointer, 3) * 100
    self.Rage = Unlock(UnitPower, self.pointer, 1) / Unlock(UnitPowerMax, self.pointer, 1) * 100
    self.ComboPoints = Unlock(UnitPower, self.pointer, 4)
    self.ArcaneCharges = Unlock(UnitPower, self.pointer, 16)
    self.HolyPower = Unlock(UnitPower, self.pointer, 9)
    self.SoulShards = Unlock(UnitPower, self.pointer, 7)
    self.LunarPower = Unlock(UnitPower, self.pointer, 8)
    self.Maelstrom = Unlock(UnitPower, self.pointer, 11)
    self.Insanity = Unlock(UnitPower, self.pointer, 13)
    self.Fury = Unlock(UnitPower, self.pointer, 17)
    self.Role = UnitGroupRolesAssigned(self.pointer)
end

function Player:Update()
    runner.Classes.Unit.Update(self)
    self.Mana = Unlock(UnitPower, self.pointer, 0) / Unlock(UnitPowerMax, self.pointer, 0) * 100
    self.Energy = Unlock(UnitPower, self.pointer, 3) / Unlock(UnitPowerMax, self.pointer, 3) * 100
    self.Rage = Unlock(UnitPower, self.pointer, 1) / Unlock(UnitPowerMax, self.pointer, 1) * 100
    self.ComboPoints = Unlock(UnitPower, self.pointer, 4)
    self.ArcaneCharges = Unlock(UnitPower, self.pointer, 16)
    self.HolyPower = Unlock(UnitPower, self.pointer, 9)
    self.SoulShards = Unlock(UnitPower, self.pointer, 7)
    self.LunarPower = Unlock(UnitPower, self.pointer, 8)
    self.Maelstrom = Unlock(UnitPower, self.pointer, 11)
    self.Insanity = Unlock(UnitPower, self.pointer, 13)
    self.Fury = Unlock(UnitPower, self.pointer, 17)
    self.Role = UnitGroupRolesAssigned(self.pointer)
end

function Player:ToViewerRow()
    return {
    self.Name,
    self.pointer,
    string.format("%.2f", self.Distance),
    self.Reaction,
    self.Level,
    self.IsCasting and "Yes" or "No",
    string.format("%.2f", self.HP),
    self.IsFocus and "yes" or "no"
    }
end