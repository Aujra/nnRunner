runner.Classes.GameObject = class({}, "GameObject")
local GameObject = runner.Classes.GameObject
runner.Classes.GameObject = GameObject

runner.GameObjectViewColumns = {
    "Name",
    "Pointer",
    "Distance",
    "Type",
    "Lootable"
}

function GameObject:init(pointer)
    self.pointer = pointer
    self.Name = ObjectName(self.pointer)
    self.Type = runner.nn.GameObjectType(self.pointer)
    self.x, self.y, self.z = ObjectPosition(self.pointer)
    self.Facing = ObjectFacing(self.pointer)
    self.BoundingRadius = ObjectBoundingRadius(self.pointer)
    self.Height = ObjectHeight(self.pointer)
    self.Distance = 99999
    self.PathDistance = 0
    self.CanLoot = false
end

function GameObject:Update()
    self.Name = ObjectName(self.pointer)
    self.Type = runner.nn.GameObjectType(self.pointer)
    self.x, self.y, self.z = ObjectPosition(self.pointer)
    self.Distance = self:DistanceFromPlayer()
    self.Facing = ObjectFacing(self.pointer)
    self.CanLoot = runner.nn.ObjectLootable(self.pointer)
end

function GameObject:Debug()
    local px, py, pz = ObjectPosition("player")
    local x, y, z = ObjectPosition(self.pointer)
    runner.Draw:Line(px, py, pz, x, y, z, 1, 0, 0, 1)
    runner.Draw:Circle(x, y, z, 8)
end

function GameObject:ToViewerRow()
    return {
        self.Name,
        self.pointer,
        string.format("%.2f", self.Distance),
        self.Type,
        self.CanLoot and "Yes" or "No"
    }
end

function GameObject:NavigationDistance()
    return runner.Engine.Navigation:PathDistance(self.pointer)
end

function GameObject:DistanceFromPlayer()
    local x1, y1, z1 = self.x, self.y, self.z
    local x2, y2, z2 = ObjectPosition("player")
    if not x2 then
        return 99999
    end
    local dist = math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
    return dist
end

function GameObject:DistanceFrom(unit)
    local x1, y1, z1 = self.x, self.y, self.z
    local x2, y2, z2 = unit.x, unit.y, unit.z
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

function GameObject:DistanceFromPoint(x, y, z)
    local x1, y1, z1 = self.x, self.y, self.z
    if not x1 then
        return 99999
    end
    return math.sqrt((x - x1)^2 + (y - y1)^2 + (z - z1)^2) or 99999
end

function GameObject:UnitsInRange(range)
    local units = 0
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Distance <= range and not v.IsDead then
            units = units + 1
        end
    end
    return units
end

function GameObject:PlayersInRange(range)
    local units = 0
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        if v.Distance <= range and not v.IsDead then
            units = units + 1
        end
    end
    return units
end

function GameObject:EnemiesInRange(range)
    local units = 0
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if self:DistanceFrom(v) <= range and v.Reaction and v.Reaction <= 4 and not v.isDead then
            units = units + 1
        end
    end
    return units
end

function GameObject:FriendsInRange(range)
    local units = 0
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Distance <= range and v.Reaction > 4 and not v.IsDead then
            units = units + 1
        end
    end
    return units
end