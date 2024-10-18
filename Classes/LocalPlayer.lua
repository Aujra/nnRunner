runner.Classes.LocalPlayer = runner.Classes.Player:extend()
local LocalPlayer = runner.Classes.LocalPlayer
runner.Classes.LocalPlayer = LocalPlayer

function LocalPlayer:init(pointer)
    runner.Classes.Player.init(self, pointer)
    self.spec = GetSpecialization()
    self.specName = select(2, GetSpecializationInfo(self.spec))
end

function LocalPlayer:Update()
    runner.Classes.Player.Update(self)
    self.spec = GetSpecialization()
    self.specName = select(2, GetSpecializationInfo(self.spec))
end