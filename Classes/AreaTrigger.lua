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
    if self.CreatorID then
        self.Reaction = Unlock(UnitReaction, self.creatorID, "player")
    else
        self.Reaction = 8
    end
    self.z = runner.nn.ObjectField(self.pointer, 112*4, 4)
    self.y = runner.nn.ObjectField(self.pointer, 504*4, 4)
    self.x = runner.nn.ObjectField(self.pointer, 896*4, 4)

    local q,w,e = ObjectPosition(self.pointer)

    local x, y, z = ObjectPosition("player")

    self.Distance = self:DistanceFromPlayer()

    for i=0, 2000, 4 do
        local t = runner.nn.ObjectField(self.pointer, i*4, 4)
        if t > 1500 and t < 3000 or i == 896 then
        end
    end

    if self.x ~= 0 and self.y ~= 0 and self.z ~= 0 then
        runner.Draw:SetColor(255,255,255,255)
        runner.Draw:Circle(self.x, self.y, self.z, self.radius)
        runner.Draw:Text("Distance " .. string.format("%.2f", self:DistanceFromPlayer()) .. "made by " .. self.creatorName, "GAMEFONTNORMAL", self.x, self.y, self.z)
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