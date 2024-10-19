local nn = ...
nn:Require('/scripts/mainrunner/class.lua', runner)

--Main tables
runner = {}
runner.nn = nn
runner.Rotations = {}
runner.Engine = {}
runner.Classes = {}
runner.UI = {}
runner.LocalPlayer = nil
runner.rotations = {}
runner.rotation = nil

--Main Variables
runner.localPlayer = nil
runner.Draw = nil
runner.running = true
runner.lastTick = 0
runner.lastMount = 0
runner.lastDebug = 0
runner.lastAFK = 0

--Require Files
nn:Require('/scripts/mainrunner/ScrollingTable.lua', runner)
nn:Require('/scripts/mainrunner/Engine/ObjectManager.lua', runner)
--Classes
nn:Require('/scripts/mainrunner/Classes/GameObject.lua', runner)
nn:Require('/scripts/mainrunner/Classes/Unit.lua', runner)
nn:Require('/scripts/mainrunner/Classes/Player.lua', runner)
nn:Require('/scripts/mainrunner/Classes/LocalPlayer.lua', runner)
--UI
nn:Require('/scripts/mainrunner/UI/ObjectViewer.lua', runner)
--Rotations
nn:Require('/scripts/mainrunner/Rotations/BaseRotation.lua', runner)
nn:Require('/scripts/mainrunner/Rotations/HunterRotation.lua', runner)

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
    if not runner.Draw then
        runner.Draw = nn.Utils.Draw:New()
    end

    if runner.Draw then
        runner.Draw:ClearCanvas()
    end

    if not runner.LocalPlayer then
        runner.LocalPlayer = runner.Classes.LocalPlayer:new("player")
    else
        runner.LocalPlayer:Update()
    end

    runner.Engine.ObjectManager:Update()
    if runner.UI.ObjectViewer and runner.UI.ObjectViewer:ShouldUpdate() then
        runner.UI.ObjectViewer:Update()
    end

    runner:DrawNearestDisturbedEarth()

    if not runner.rotation then
        if runner.rotations[runner.LocalPlayer.Class:lower()] then
            runner.rotation = runner.rotations[runner.LocalPlayer.Class:lower()]:new()
        end
    else
        runner.rotation:Pulse()
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

local oldprint = print
print = function(...)
    if lastmessage ~= ... then
        lastmessage = ...
        oldprint(...)
    end
end

function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
