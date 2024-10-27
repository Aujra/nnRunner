runner.Classes.AreaTrigger = runner.Classes.GameObject:extend()
local AreaTrigger = runner.Classes.AreaTrigger
runner.Classes.AreaTrigger = AreaTrigger

runner.AreaTriggerViewColumns = {
    "Name",
    "Pointer",
    "Distance",
    "Creator",
}

function AreaTrigger:init(pointer)
    runner.Classes.GameObject.init(self, pointer)
    self.SpellID = runner.nn.ObjectField(pointer, CGAreaTriggerData__SpellID, 3)
end

function AreaTrigger:Update()
    runner.Classes.GameObject.Update(self)
    self.SpellID = runner.nn.ObjectField(self.pointer, CGAreaTriggerData__SpellID, 3)
end

function AreaTrigger:ToViewerRow()
    return {
        self.Name,
        self.pointer,
        string.format("%.2f", self.Distance),
    }
end