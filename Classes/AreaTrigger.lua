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
    self.Reaction = Unlock(UnitReaction, self.creatorID, "player")
    self.z = runner.nn.ObjectField(self.pointer, 112*4, 4)
    self.y = runner.nn.ObjectField(self.pointer, 504*4, 4)
    self.x = runner.nn.ObjectField(self.pointer, 896*4, 4)

    --print("y " .. self.y)

    local x, y, z = ObjectPosition("player")

    self.Distance = self:DistanceFromPlayer()

    for i=0, 10000, 4 do
            local t = runner.nn.ObjectField(self.pointer, i*4, 4)
            if t > -3000 and t < -2900 then
                --print("Found this " .. t .. " at " .. i .. " using pointer " .. self.pointer)
            end
    end
    if self.x and self.y and self.z then
        runner.Draw:Line(x, y, z, self.x, self.y, self.z, 1, 0, 0, 1)
    end
end

function AreaTrigger:InRangeValue(v)
    local x = runner.LocalPlayer.x
    return (abs(x-v) < 30)
end

function AreaTrigger:ToViewerRow()
    return {
        self.x,
        self.y,
        self.z,
        self.Creator
    }
end