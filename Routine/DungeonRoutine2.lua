runner.Routines.DungeonRoutine2 = runner.Routines.BaseRoutine:extend()
local DungeonRoutine2 = runner.Routines.DungeonRoutine2
runner.Routines.DungeonRoutine2 = DungeonRoutine2

function DungeonRoutine2:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "DungeonRoutine2"
    self.Description = "DungeonRoutine2"
    self.BlackList = {
        "Vent Stalker", "Speaker Mechhand", "Reinforce Stalker", "Eternal Flame", "Dummy Stalker", "Mini-Boss Stalker"
    }

    self.SettingsGUI = nil
    self.Steps = {}
end

function DungeonRoutine2:Run()
    if self.Steps == nil or #self.Steps == 0 then
        local json = runner.nn.ReadFile("/scripts/mainrunner/profile.json")
        local profile = runner.nn.Utils.JSON.decode(json)
        profileSteps = {}
        for k,v in pairs(profile) do
            local behavior = runner.behaviors[v.Name:lower()]()
            behavior.Step = v.Step
            table.insert(profileSteps, {index = #profileSteps, step = behavior})
        end
    end
end

function DungeonRoutine2:getBestTarget()
    local bestTarget = nil
    local bestScore = -999999
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Reaction and v.Reaction <= 4 and not v.isDead and not self:BlackListed(v.Name) then
            local score = v:GetScore()
            if score > bestScore then
                bestScore = score
                bestTarget = v
            end
        end
    end
    return bestTarget
end

function DungeonRoutine2:BlackListed(name)
    for k,v in pairs(self.BlackList) do
        if name == v then
            return true
        end
    end
    return false
end

function DungeonRoutine2:ShowGUI()

end
function DungeonRoutine2:HideGUI()
end

function DungeonRoutine2:Debug()
    runner.Draw:SetColorRaw(0, 1, 0, 1)
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v:DistanceFromPlayer() < 150 and Unlock(UnitCanAttack, "player", v.pointer) then
            runner.Draw:Text(string.format("%.2f" ,v:GetScore()), "GameFontNormalLarge", v.x, v.y, v.z+3)
        end
    end
end

registerRoutine(DungeonRoutine2)