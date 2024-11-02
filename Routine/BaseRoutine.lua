runner.Routines.BaseRoutine = class({}, "BaseRoutine")
local BaseRoutine = runner.Routines.BaseRoutine
runner.Routines.BaseRoutine = BaseRoutine

function BaseRoutine:init()
    self.Name = "BaseRoutine"
    self.Description = "BaseRoutine"
end

function BaseRoutine:Run()

end

function BaseRoutine:ShowGUI()
end

function BaseRoutine:HideGUI()
end

registerRoutine(BaseRoutine)

function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
