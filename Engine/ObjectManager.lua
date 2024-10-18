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
            self.units[pointer]:Update()
        end
    end
    for index,pointer in pairs(Players) do
        if not self.players[pointer] then
            self.players[pointer] = runner.Classes.Player:new(pointer)
        else
            self.players[pointer]:Update()
        end
    end
end

function OM:GetByPointer(pointer)
    if self.gameobjects[pointer] then
        return self.gameobjects[pointer]
    end
    if self.units[pointer] then
        return self.units[pointer]
    end
    if self.players[pointer] then
        return self.players[pointer]
    end
    return nil
end