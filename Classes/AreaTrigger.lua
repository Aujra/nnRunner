runner.Classes.AreaTrigger = runner.Classes.GameObject:extend()
local AreaTrigger = runner.Classes.AreaTrigger
runner.Classes.AreaTrigger = AreaTrigger

runner.AreaTriggerViewColumns = {
    "x","y","z","radius"
}

function AreaTrigger:init(pointer)
    self.pointer = pointer
    self.radius = 0
    self.spellID = 0
end

function AreaTrigger:Update()
    self.radius = runner.nn.ObjectField(self.pointer, 280*4, 4)
    self.creatorID = runner.nn.ObjectField(self.pointer,356*4, 5)
    self.creatorName = runner.nn.ObjectName(self.creatorID)
    --self.Reaction = Unlock(UnitReaction, self.creatorID, "player")
    self.z = runner.nn.ObjectField(self.pointer, 112*4, 4)
    self.y = runner.nn.ObjectField(self.pointer, 504*4, 4)
    self.x = runner.nn.ObjectField(self.pointer, 896*4, 4)

    local q,w,e = ObjectPosition(self.pointer)
    --print("Found this " .. self.pointer .. " at " .. q .. " " .. w .. " " .. e)

    --print("y " .. self.y)

    local x, y, z = ObjectPosition("player")

    self.Distance = self:DistanceFromPlayer()

    for i=0, 2000, 4 do
        local t = runner.nn.ObjectField(self.pointer, i*4, 4)
        if t > 1500 and t < 3000 or i == 896 then
            --print("Found this " .. t .. " at " .. i .. " using pointer " .. self.pointer)
        end
    end
end

function AreaTrigger:ToViewerRow()
    return {
        self.x,
        self.y,
        self.z,
        self.Creator
    }
end