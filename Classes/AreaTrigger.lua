runner.Classes.AreaTrigger = runner.Classes.GameObject:extend()
local AreaTrigger = runner.Classes.AreaTrigger
runner.Classes.AreaTrigger = AreaTrigger

runner.AreaTriggerViewColumns = {
    "x","y","z","radius"
}

function AreaTrigger:init(pointer)
    runner.Classes.GameObject.init(self, pointer)
    self.Creator = runner.nn.ObjectCreator(self.pointer)
end

function AreaTrigger:Update()
    runner.Classes.GameObject.Update(self)
end

function AreaTrigger:ToViewerRow()
    return {
        self.x,
        self.y,
        self.z,
        self.Creator
    }
end