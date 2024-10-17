local nn = ...

--Main tables
runner = {}
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
nn:Require('/scripts/mainrunner/Engine/ObjectManager.lua', runner)


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

end)