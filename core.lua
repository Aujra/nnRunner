local nn = ...

--Main tables
runner = {}
runner.nn = nn
runner.Rotations = {}
runner.Engine = {}
runner.Classes = {}
runner.UI = {}

--Main Variables
runner.localPlayer = nil
runner.Draw = nil
runner.running = true
runner.lastTick = 0
runner.lastMount = 0
runner.lastDebug = 0

--Require Files
nn:Require('/scripts/mainrunner/class.lua', runner)
nn:Require('/scripts/mainrunner/ScrollingTable.lua', runner)
nn:Require('/scripts/mainrunner/Engine/ObjectManager.lua', runner)
--Classes
nn:Require('/scripts/mainrunner/Classes/GameObject.lua', runner)
nn:Require('/scripts/mainrunner/Classes/Unit.lua', runner)
--UI
nn:Require('/scripts/mainrunner/UI/ObjectViewer.lua', runner)

--Main Loop
runner.frame = CreateFrame("Frame")
runner.frame:SetScript("OnUpdate", function(self, elapsed)

    if GetTime() - runner.lastTick < 0.1 then
        return
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

    runner.Engine.ObjectManager:Update()
    if runner.UI.ObjectViewer then
        runner.UI.ObjectViewer:Update()
    end
end)

runner.frame:SetScript("OnKeyDown", function(self, key)
    if key == "`" then
        print("Hotkey toggling bot " .. (runner.running and "off" or "on"))
        runner.running = not runner.running
    end
    runner.frame:SetPropagateKeyboardInput(true)
end)

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