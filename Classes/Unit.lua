runner.Classes.Unit = class({}, "Unit")
local Unit = runner.Classes.Unit
runner.Classes.Unit = Unit

function Unit:init(pointer)
    self.pointer = pointer
    self.Name = ObjectName(self.pointer)
    self.x, self.y, self.z = ObjectPosition(self.pointer)
end

function Unit:Update()
    self.Name = ObjectName(self.pointer)
    self.x, self.y, self.z = ObjectPosition(self.pointer)
end