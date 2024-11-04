local nn = ...
runner.Engine.ObjectManager = {}
local OM = runner.Engine.ObjectManager
runner.Engine.ObjectManager = OM

local gameobjects, units, players, party, items, areatrigger = {}, {}, {}, {}, {}, {}
OM.gameobjects, OM.units, OM.players, OM.party, OM.items, OM.areatrigger = gameobjects, units, players, party, items, areatrigger

function OM:Update()
    local gameObjects = nn.ObjectManager("GameObject" or 8)
    local Units = nn.ObjectManager("Unit" or 5)
    local Players = nn.ObjectManager("Player" or 6)
    local AreaTriggers = nn.ObjectManager("AreaTrigger" or 11)

    self.party = {}

    for k,v in pairs(self.gameobjects) do
        if not runner.nn.ObjectExists(v.pointer) then
            self.gameobjects[k] = nil
        end
    end
    for k,v in pairs(self.units) do
        if not runner.nn.ObjectExists(v.pointer) then
            self.units[k] = nil
        end
    end
    for k,v in pairs(self.players) do
        if not runner.nn.ObjectExists(v.pointer) then
            self.players[k] = nil
        end
    end
    for k,v in pairs(self.areatrigger) do
        if not runner.nn.ObjectExists(v.pointer) or v.x == 0 then
            self.areatrigger[k] = nil
        end
    end

    for index,pointer in pairs(gameObjects) do
        if not self.gameobjects[pointer] then
            self.gameobjects[pointer] = runner.Classes.GameObject:new(pointer)
        else
            self.gameobjects[pointer]:Update()
        end
    end
    for index,pointer in pairs(Units) do
        if not self.units[pointer] then
            self.units[pointer] = runner.Classes.Unit:new(pointer)
        else
            if Unlock(UnitInParty, pointer) then
                table.insert(self.party, self.units[pointer])
            end
            self.units[pointer]:Update()
        end
    end
    for index,pointer in pairs(Players) do
        if not self.players[pointer] then
            self.players[pointer] = runner.Classes.Player:new(pointer)
        else
            if Unlock(UnitInParty, pointer) then
                table.insert(self.party, self.units[pointer])
            end
            self.players[pointer]:Update()
        end
    end
    for index,pointer in pairs(AreaTriggers) do
        if not self.areatrigger[pointer] then
            self.areatrigger[pointer] = runner.Classes.AreaTrigger:new(pointer)
        else
            self.areatrigger[pointer]:Update()
        end
    end
end

function OM:GetClosestGatherable()
    local closest = nil
    local closestDistance = 9999
    for k,v in pairs(self.gameobjects) do
        if v.CanGather then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closest = v
                closestDistance = distance
            end
        end
    end
    return closest
end

function OM:GetByPointer(pointer)
    pointer = tonumber(pointer)
    if self.gameobjects[pointer] then
        return self.gameobjects[pointer]
    end
    if self.units[pointer] then
        return self.units[pointer]
    end
    if self.players[pointer] then
        return self.players[pointer]
    end
    if self.areatrigger[pointer] then
        return self.areatrigger[pointer]
    end
    return nil
end

function OM:GetByName(name)
    for k,v in pairs(self.gameobjects) do
        if v.Name == name then
            return v
        end
    end
    for k,v in pairs(self.units) do
        if v.Name == name then
            return v
        end
    end
    for k,v in pairs(self.players) do
        if v.Name == name then
            return v
        end
    end
    return nil
end

function OM:GetClosestByName(name)
    local closest = nil
    local closestDistance = 9999
    for k,v in pairs(self.gameobjects) do
        if v.Name == name then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closest = v
                closestDistance = distance
            end
        end
    end
    for k,v in pairs(self.units) do
        if v.Name == name then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closest = v
                closestDistance = distance
            end
        end
    end
    for k,v in pairs(self.players) do
        if v.Name == name then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closest = v
                closestDistance = distance
            end
        end
    end
    return closest
end

function OM:GetTank()
    for k,v in pairs(self.units) do
        if v.Role == "TANK" then
            return v
        end
    end
    return nil
end

function OM:GetClosestLootable()
    local closest = nil
    local closestDistance = 9999
    for k,v in pairs(self.units) do
        if v.Lootable then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closest = v
                closestDistance = distance
            end
        end
    end
    return closest
end

function OM:GetClosestEnemy()
    local closest = nil
    local closestDistance = 9999
    for k,v in pairs(self.units) do
        if v.Reaction and v.Reaction < 4 and not v.isDead and v.CanAttack then
            local distance = v:DistanceFromPlayer()
            if distance < closestDistance then
                closest = v
                closestDistance = distance
            end
        end
    end
    return closest
end