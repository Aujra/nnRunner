runner.Classes.Point = class()
local Point = runner.Classes.Point
runner.Classes.Point = Point

function Point:init(x, y, z)
    self.X = x
    self.Y = y
    self.Z = z
end

function Point:DistanceFromXYZ(x, y, z)
    return math.sqrt((self.X - x) ^ 2 + (self.Y - y) ^ 2 + (self.Z - z) ^ 2)
end

function Point:DistanceFromPoint(point)
    return math.sqrt((self.X - point.X) ^ 2 + (self.Y - point.Y) ^ 2 + (self.Z - point.Z) ^ 2)
end

function Point:DistanceFromPlayer()
    local px, py, pz = ObjectPosition("player")
    return math.sqrt((self.X - px) ^ 2 + (self.Y - py) ^ 2 + (self.Z - pz) ^ 2)
end

function Point:DistanceFromUnit(unit)
    local x, y, z = ObjectPosition(unit.Pointer)
    return math.sqrt((self.X - x) ^ 2 + (self.Y - y) ^ 2 + (self.Z - z) ^ 2)
end

function Point:ToString()
    return string.format("X: %f Y: %f Z: %f", self.X, self.Y, self.Z)
end