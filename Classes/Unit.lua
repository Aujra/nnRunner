runner.Classes.Unit = runner.Classes.GameObject:extend()
local Unit = runner.Classes.Unit
runner.Classes.Unit = Unit

function Unit:init(pointer)
    runner.Classes.GameObject.init(self, pointer)
end

function Unit:Update()
    runner.Classes.GameObject.Update(self)
end