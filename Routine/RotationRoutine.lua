runner.Routines.RotationRoutine = runner.Routines.BaseRoutine:extend()
local RotationRoutine = runner.Routines.RotationRoutine
runner.Routines.RotationRoutine = RotationRoutine

function RotationRoutine:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "RotationRoutine"
    self.Description = "RotationRoutine"
end

function RotationRoutine:Run()
    if runner.rotation then
        runner.rotation:Pulse()
    end
end

function RotationRoutine:HideGUI()
    if self.StatusFrame then
        self.StatusFrame:Hide()
    end
end
function RotationRoutine:ShowGUI()
    if self.StatusFrame then
        self.StatusFrame:Show()
    end
end

registerRoutine(RotationRoutine)