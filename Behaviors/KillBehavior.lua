runner.Behaviors.KillBehavior = runner.Behaviors.BaseBehavior:extend()
local KillBehavior = runner.Behaviors.KillBehavior
runner.Behaviors.KillBehavior = KillBehavior

function KillBehavior:init()
    self.Name = "KillBehavior"
    self.Type = "Kill"
    self.Step = {
        MobName = ""
    }
end

function KillBehavior:Run()
    if self.Step.MobName and self.Step.MobName == "" then
        self.IsComplete = true
        return
    else
        local target = runner.Engine.ObjectManager:GetClosestByName(self.Step.MobName)
        if target then
            if not target.isDead then
                if target:DistanceFromPlayer() > runner.rotation.CombatRange then
                    runner.Engine.Navigation:MoveTo(target.pointer)
                else
                    Unlock(TargetUnit, target.pointer)
                    runner.Engine.Navigation:FaceUnit(target.pointer)
                    Unlock(MoveForwardStop)
                    runner.rotation:Pulse(target)
                end
                self.IsComplete = false
                return
            else
                self.IsComplete = true
                return
            end
        end
    end
end

function KillBehavior:Save()
    return {
        Name = self.Name,
        Type = self.Type,
        MobName = self.Step.MobName
    }
end

function KillBehavior:Load(data)
    self.Step.MobName = data.MobName
end

function KillBehavior:Debug()

end

function KillBehavior:BuildStepGUI(container)
    local mobNameEditBox = runner.AceGUI:Create("EditBox")
    mobNameEditBox:SetLabel("Mob Name")
    mobNameEditBox:SetWidth(200)
    mobNameEditBox:SetText(self.Step.MobName)
    mobNameEditBox:SetCallback("OnEnterPressed", function(_, _, text)
        self.Step.MobName = text
    end)
    local getTargetNameButton = runner.AceGUI:Create("Button")
    getTargetNameButton:SetText("Get Target Name")
    getTargetNameButton:SetWidth(200)
    getTargetNameButton:SetCallback("OnClick", function()
        local target = UnitName("target")
        mobNameEditBox:SetText(target)
        self.Step.MobName = target
    end)
    container:AddChild(mobNameEditBox)
    container:AddChild(getTargetNameButton)
end

registerBehavior("KillBehavior", KillBehavior)