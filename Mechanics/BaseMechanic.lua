runner.Mechanics.BaseMechanic = class()
local BM = runner.Mechanics.BaseMechanic
runner.Mechanics.BaseMechanic = BM

function BM:init()
    self.ForBoss = ""
end

function BM:NeedsMechanic()
    return false
end

function BM:DoMechanic()
end