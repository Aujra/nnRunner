local nn = ...
runner.Engine.ObjectManager = {}
local OM = runner.Engine.ObjectManager
runner.Engine.ObjectManager = OM

local gameobjects, units, players, party, items, areatrigger = {}, {}, {}, {}
OM.gameobjects, OM.units, OM.players, OM.party, OM.items, OM.areatrigger = gameobjects, units, players, party, items, areatrigger

function OM:Clean()

end

function OM:Update()
    local gameObjects = nn:ObjectManager("GameObject" or 8)
    local units = nn:ObjectManager("Units" or 5)
    local players = nn:ObjectManager("Players" or 6)
    local items = nn:ObjectManager("Items" or 1)
    local areaTriggers = nn:ObjectManager("AreaTriggers" or 11)
end