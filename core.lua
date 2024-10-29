local nn = ...
nn:Require('/scripts/mainrunner/class.lua', runner)
nn:Require('/scripts/mainrunner/LibStub.lua', runner)

--Main tables
runner = {}
runner.nn = nn
runner.Rotations = {}
runner.Engine = {}
runner.Classes = {}
runner.Routines = {}
runner.UI = {}
runner.UI.menuFrame = {}
runner.LocalPlayer = nil
runner.rotations = {}
runner.rotation = nil
runner.routines = {}
runner.routine = nil

--Main Variables
runner.localPlayer = nil
runner.Draw = nil
runner.running = true
runner.lastTick = 0
runner.lastMount = 0
runner.lastDebug = 0
runner.lastAFK = 0
runner.lastEnter = 0

runner.profiles = {}

runner.waypoints = {}

function registerRotation(rotation)
    local rot = rotation()
    runner.rotations[rot.Name:lower()] = rot
end

function registerRoutine(routine)
    local rot = routine()
    runner.routines[rot.Name:lower()] = rot
end

function registerProfile(profile)
    print("Registering profile: " .. profile.Name)
    table.insert(runner.profiles, profile)
end

function deep_copy( original, copies )
    if type( original ) ~= 'table' then return original end

    -- original is a table.
    copies = copies or {} -- this is a cache of already copied tables.

    -- This table has been copied previously.
    if copies[original] then return copies[original] end

    -- We need to deep copy the table not deep copied previously.
    local copy = {}
    copies[original] = copy -- store a reference to copied table in the cache.
    for key, value in pairs( original ) do
        local dc_key, dc_value = deep_copy( key, copies ), deep_copy( value, copies )
        copy[dc_key] = dc_value
    end
    setmetatable(copy, deep_copy( getmetatable( original ), copies) )
    return copy
end

--Require Files
nn:Require('/scripts/mainrunner/ScrollingTable.lua', runner)
nn:Require('/scripts/mainrunner/Engine/ObjectManager.lua', runner)
nn:Require('/scripts/mainrunner/Engine/Navigation.lua', runner)
nn:Require('/scripts/mainrunner/Engine/MultiboxManager.lua', runner)
--Classes
nn:Require('/scripts/mainrunner/Classes/GameObject.lua', runner)
nn:Require('/scripts/mainrunner/Classes/AreaTrigger.lua', runner)
nn:Require('/scripts/mainrunner/Classes/Unit.lua', runner)
nn:Require('/scripts/mainrunner/Classes/Player.lua', runner)
nn:Require('/scripts/mainrunner/Classes/MultiboxPlayer.lua', runner)
nn:Require('/scripts/mainrunner/Classes/LocalPlayer.lua', runner)
--UI
nn:Require('/scripts/mainrunner/UI/ObjectViewer.lua', runner)
nn:Require('/scripts/mainrunner/UI/Menu.lua', runner)
--Rotations
local path = "/scripts/mainrunner/Rotations/*.lua"
local files = nn.ListFiles(path)
for k,v in pairs(files) do
    nn:Require("/scripts/mainrunner/Rotations/" .. v, runner)
end
--Routines
nn:Require('/scripts/mainrunner/Routine/BaseRoutine.lua', runner)
nn:Require('/scripts/mainrunner/Routine/RotationRoutine.lua', runner)
nn:Require('/scripts/mainrunner/Routine/DungeonRoutine.lua', runner)
nn:Require('/scripts/mainrunner/Routine/MultiboxRoutine.lua', runner)
--Profiles
local path = "/scripts/mainrunner/Profiles/Dungeons/*.lua"
local files = nn.ListFiles(path)
for k,v in pairs(files) do
    nn:Require("/scripts/mainrunner/Profiles/Dungeons/" .. v, runner)
end

--Main Loop
runner.frame = CreateFrame("Frame")
runner.frame:SetScript("OnUpdate", function(self, elapsed)
    if GetTime() - runner.lastTick < .2 then
        return
    end

    if GetTime() - runner.lastAFK > 60 then
        LastHardwareAction(GetTime()*1000)
        runner.lastAFK = GetTime()
    end

    runner.lastTick = GetTime()
    if not runner.running then
        return
    end

    if not runner.routine then
        runner.routine = runner.routines["rotationroutine"]
    end
    if not runner.rotation then
        runner.rotation = runner.rotations[select(1, UnitClass("player")):lower()]
    end

    runner.UI.menuFrame:UpdateMenu()

    if not runner.Draw then
        runner.Draw = nn.Utils.Draw:New()
    end

    if runner.Draw then
        runner.Draw:ClearCanvas()
    end

    if not runner.LocalPlayer then
        runner.LocalPlayer = runner.Classes.MultiboxPlayer:new("player")
    else
        runner.LocalPlayer:Update()
    end

    runner.Engine.ObjectManager:Update()
    if runner.UI.ObjectViewer and runner.UI.ObjectViewer:ShouldUpdate() then
        runner.UI.ObjectViewer:Update()
    end

    runner:DrawNearestDisturbedEarth()

    if runner.routine then
        runner.routine:Run()
    end
end)

runner.frame:SetScript("OnKeyDown", function(self, key)
    if key == "`" then
        print("Hotkey toggling bot " .. (runner.running and "off" or "on"))
        runner.running = not runner.running
    end
    runner.frame:SetPropagateKeyboardInput(true)
end)

function runner:DrawNearestDisturbedEarth()
    local nearest = nil
    local nearestDistance = 9999
    for k,v in pairs(runner.Engine.ObjectManager.gameobjects) do
        if v.Name == "Disturbed Earth" then
            local distance = v:DistanceFromPlayer()
            if distance < nearestDistance then
                nearest = v
                nearestDistance = distance
            end
        end
    end
    if nearest then
        local x,y,z = ObjectPosition(nearest.pointer)
        local px,py,pz = ObjectPosition("player")
        runner.Draw:SetColor(255,0,0,255)
        runner.Draw:Line(px, py, pz, x, y, z, 1, 0, 0, 1)
    end
end

function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
