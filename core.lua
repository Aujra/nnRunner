local nn = ...

--Main tables
runner = {}
runner.nn = nn
runner.Rotations = {}
runner.Engine = {}
runner.Classes = {}
runner.Routines = {}
runner.Behaviors = {}
runner.UI = {}
runner.Mechanics = {}
runner.UI.menuFrame = {}
runner.LocalPlayer = nil
runner.rotations = {}
runner.rotation = nil
runner.routines = {}
runner.routine = nil
runner.behaviors = {}

runner.AceGUI = LibStub("AceGUI-3.0")
runner.ScrollingTable = LibStub("ScrollingTable")

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
runner.mechanics = {}

runner.waypoints = {}

runner.mountedWhore = false

runner.frame = CreateFrame("Frame")

_G.runner = runner

function registerMechanic(name, mechanic)
    local mech = mechanic()
    runner.mechanics[name:lower()] = mech
end

function registerRotation(rotation)
    local rot = rotation()
    runner.rotations[rot.Name:lower()] = rot
end

function registerRoutine(routine)
    local rot = routine()
    runner.routines[rot.Name:lower()] = rot
end

function registerProfile(profile)
    table.insert(runner.profiles, profile)
end

function registerBehavior(name, behavior)
    runner.behaviors[name:lower()] = behavior
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

--Main Loop
runner.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
runner.frame:SetScript("OnUpdate", function(self, elapsed)
    if GetTime() - runner.lastTick > .15 then
        if GetTime() - runner.lastAFK > 60 then
            LastHardwareAction(GetTime()*1000)
            runner.lastAFK = GetTime()
        end

        runner.lastTick = GetTime()

        if not runner.LocalPlayer then
            runner.LocalPlayer = runner.Classes.MultiboxPlayer:new("player")
        else
            runner.LocalPlayer:Update()
        end

        runner.Engine.ObjectManager:Update()
        if runner.UI.ObjectViewer2 then
            runner.UI.ObjectViewer2:Update()
        end
        if runner.UI.ObjectViewer then
            runner.UI.ObjectViewer:Update()
        end

        if not runner.Draw then
            runner.Draw = nn.Utils.Draw:New()
        end

        if runner.Draw then
            runner.Draw:ClearCanvas()
        end

        if not runner.running then
            return
        end

        runner.InteractionManager:HandleAll()

        if not runner.routine then
            runner.routine = runner.routines["rotationroutine"]
        end
        if not runner.rotation then
            runner.rotation = runner.rotations[select(1, UnitClass("player")):lower()]
        end

        runner.UI.menuFrame:UpdateMenu()

        runner:DrawNearestDisturbedEarth()

        if runner.routine then
            runner.routine:Run()
        end
    end
end)

runner.frame:SetScript("OnKeyDown", function(self, key)
    if key == "`" then
        print("Hotkey toggling bot " .. (runner.running and "off" or "on"))
        runner.running = not runner.running
    end

    if key == "2" then
        local target = UnitTarget("player")
        print("Target: " .. (target or "none"))
        if target then
            for i = 0, 300, 4 do
                local f = runner.nn.ObjectField(target, i*4, 1)
                print("Field " .. i .. ": " .. (f or "nil"))
            end
            print("============================")
        end
    end

    Unlock(runner.frame.SetPropagateKeyboardInput, runner.frame, true)
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
    if not t then return 0 end
    for _ in pairs(t) do count = count + 1 end
    return count
end

function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function runner:randomBetween(min, max)
    return math.random() * (max - min) + min
end

function runner:randomTable(table)
    local randomIndex = math.random(1, #table)
    return table[randomIndex]
end