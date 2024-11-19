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
    if self.creatorID then
        self.Reaction = Unlock(UnitReaction, self.creatorID, "player")
    else
        self.Reaction = 8
    end

    self.x, self.y, self.z = ObjectPosition(self.pointer)
    self.sx, self.sy, self.sz = self.x, self.y, self.z

    self.Distance = self:DistanceFromPlayer()
    self.PlayerInside = self.Distance < self.radius

    --if self:AreWeIn() then
    --    local qx, qy, qz = self:ScanForSafeSpot(self.sx, self.sy, self.sz)
    --end
    --
    --runner.Draw:SetColor(0, 255, 0, 255)
    --runner.Draw:Circle(self.sx, self.sy, self.sz, 2)

end

function AreaTrigger:ToViewerRow()
    return {
        self.x,
        self.y,
        self.z,
        self.Creator
    }
end
--
--function AreaTrigger:ScanForSafeSpot(x,y,z)
--    print("We are in a trigger scanning for safe spot")
--    self.sx = self.sx + runner.randomBetween(self,-self.radius, self.radius)
--    self.sy = self.sy + runner.randomBetween(self,-self.radius, self.radius)
--    for k,v in pairs(runner.Engine.ObjectManager.areatrigger) do
--        if self:PointInTrigger(self.sx, self.sy, self.sz, v) then
--            self.sy = self.sy + self.radius
--            self.sx = self.x
--            self:ScanForSafeSpot(self.sx, self.sy, self.sz)
--        else
--            print("Found a safe spot moving to it")
--            return self.sx, self.sy, self.sz
--        end
--    end
--end
--
--function AreaTrigger:PointInTrigger(x, y, z, trigger)
--    local dx, dy, dz = x - trigger.x, y - trigger.y, z - trigger.z
--    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
--    if distance < trigger.radius then
--        return true
--    end
--    return false
--end