runner.Routines.BaseRoutine = class({}, "BaseRoutine")
local BaseRoutine = runner.Routines.BaseRoutine
runner.Routines.BaseRoutine = BaseRoutine

function BaseRoutine:init()
    self.Name = "BaseRoutine"
    self.Description = "BaseRoutine"
end

function BaseRoutine:Run()
    local target = UnitTarget("player")
    if target then
        runner.Engine.Navigation:MoveTo(target)
    end
end

function BaseRoutine:BuildGUI()
end

registerRoutine(BaseRoutine)

function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end