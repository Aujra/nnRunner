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

print("hi")

function GameObject:init(pointer)
    self.pointer = pointer
    self.Pointer = pointer
    self.Name = ObjectName(self.pointer)
    self.Type = runner.nn.ObjectType(self.pointer)
    self.GameObjectType = runner.nn.GameObjectType(self.pointer)
    self.x, self.y, self.z = ObjectPosition(self.pointer)
    self.X, self.Y, self.Z = self.x, self.y, self.z
    self.Facing = ObjectFacing(self.pointer)
    self.BoundingRadius = ObjectBoundingRadius(self.pointer)
    self.Height = ObjectHeight(self.pointer)
    self.Distance = 99999
    self.PathDistance = 0
    self.CanLoot = false
    self.Lootable = false
    self.ObjectType = runner.nn.GameObjectType(self.pointer)
    self.CanGather = self.ObjectType == 50
    self.CanAttack = false
    self.UpdateRate = 0
    self.IsQuestGiver = runner.nn.ObjectField(self.pointer, 16*4, 1) == 67 or runner.nn.ObjectField(v, 16*4, 1) == 1
    self.IsQuestTurnin = runner.nn.ObjectField(self.pointer, 16*4, 1) == 68 or runner.nn.ObjectField(v, 16*4, 1) == 6
    self.IsQuestObjective = self:isQuestObjective()
    self.ObjectiveFor = {}
    self.objectCount = tableCount(runner.Engine.ObjectManager.gameobjects) + tableCount(runner.Engine.ObjectManager.units) + tableCount(runner.Engine.ObjectManager.players)
    self.NextUpdate = GetTime() + runner:randomBetween(self.objectCount, (self.objectCount*3.5)) / 1000
end

function GameObject:Update()
    if GetTime() < self.NextUpdate then
        return
    end
    self.Name = ObjectName(self.pointer)
    self.Type = runner.nn.GameObjectType(self.pointer)
    self.x, self.y, self.z = ObjectPosition(self.pointer)
    self.Distance = self:DistanceFromPlayer()
    self.Facing = ObjectFacing(self.pointer)
    self.Lootable = runner.nn.ObjectLootable(self.pointer)
    self.CanLoot = runner.nn.ObjectLootable(self.pointer)
    self.ObjectType = runner.nn.GameObjectType(self.pointer)
    self.CanGather = self.ObjectType == 50
    self.CanAttack = Unlock(UnitCanAttack, "player", self.pointer)
    self.IsQuestGiver = runner.nn.ObjectField(self.pointer, 16*4, 1) == 67 or runner.nn.ObjectField(self.pointer, 16*4, 1) == 1
    self.IsQuestTurnin = runner.nn.ObjectField(self.pointer, 16*4, 1) == 68 or runner.nn.ObjectField(self.pointer, 16*4, 1) == 6
    self.IsQuestObjective = self:isQuestObjective()
    self.ObjectiveFor = self:GetObjectiveFor()
    self.DynamicFlags = runner.nn.DynamicFlags(self.pointer)
    self.objectCount = tableCount(runner.Engine.ObjectManager.gameobjects) + tableCount(runner.Engine.ObjectManager.units) + tableCount(runner.Engine.ObjectManager.players)
    self.UpdateRate = self:GetUpdateRate()
    self.NextUpdate = GetTime() + self.UpdateRate
end

function GameObject:GetUpdateRate()
    local multiplier = self.objectCount / 1350 or 1
    if self.Distance < 10 then
        return .15 * multiplier
    end
    if self.Distance < 50 then
        return .75 * multiplier
    end
    if self.Distance < 100 then
        return 1.5 * multiplier
    end
    if self.Distance < 200 then
        return 3 * multiplier
    end
    return 3 * multiplier
end

function GameObject:LOS()
    local x1, y1, z1 = runner.nn.ObjectPosition('player')
    local x2, y2, z2 = runner.nn.ObjectPosition(self.pointer)

    local playerHeight = runner.nn.ObjectHeight('player')
    local unitHeight = self.Height

    local checkHeights = {
        {playerHeight, unitHeight},
        {playerHeight / 2, unitHeight / 2}
    }

    for _, heights in ipairs(checkHeights) do
        local hitX, hitY, hitZ = TraceLine(x1, y1, z1 + heights[1], x2, y2, z2 + heights[2], 0x100111)
        if not hitX then
            return true
        end
    end

    return false
end

function GameObject:isQuestObjective()
    runner.nn.SetMouseover(self.pointer)
    local tooltip = Unlock(C_TooltipInfo.GetUnit, "mouseover")
    if tooltip then
        for k,v in pairs(tooltip.lines) do
            if v.type == 8 or v.type == 17 then
                local texthex = v.leftColor:GenerateHexColor()
                if texthex == "ffffffff" then
                    return true
                end
            end
        end
    else
        local dynamicFlags = runner.nn.DynamicFlags(self.pointer)
        if dynamicFlags then
            if string.find(dynamicFlags, "49") then
                return true
            end
        end
    end
    return false
end

function GameObject:GetObjectiveFor()
    local objectives = {}
    runner.nn.SetMouseover(self.pointer)
    local tooltip = Unlock(C_TooltipInfo.GetUnit, "mouseover")
    if tooltip then
        for k,v in pairs(tooltip.lines) do
            if v.type == 17 then
                table.insert(objectives, v.id)
            end
        end
    end
    return objectives
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
    z = z or self.z
    if not x then
        return 99999
    end
    local x1, y1, z1 = self.x, self.y, self.z
    if not x1 then
        return 99999
    end
    return math.sqrt((x - x1)^2 + (y - y1)^2 + (z - z1)^2) or 99999
end

function GameObject:DistanceFromPlayer2D()
    local x1, y1 = self.x, self.y
    local x2, y2 = ObjectPosition("player")
    if not x2 then
        return 99999
    end
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
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
        if self:DistanceFrom(v) <= range and v.Reaction and v.Reaction <= 4 and not v.isDead and v.CanAttack then
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