local nn = ...
runner.Engine.ObjectManager = {}
local OM = runner.Engine.ObjectManager
runner.Engine.ObjectManager = OM

local gameobjects, units, players, party, items, areatrigger = {}, {}, {}, {}, {}, {}
OM.gameobjects, OM.units, OM.players, OM.party, OM.items, OM.areatrigger = gameobjects, units, players, party, items, areatrigger

function OM:Update()
    local gameObjects = nn.ObjectManager("GameObject" or 8)
    local Units = nn.ObjectManager("Unit" or 5)

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
end