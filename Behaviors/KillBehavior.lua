runner.Behaviors.KillBehavior = runner.Behaviors.BaseBehavior:extend()
local KillBehavior = runner.Behaviors.KillBehavior
runner.Behaviors.KillBehavior = KillBehavior

function KillBehavior:init()
    self.Name = "KillBehavior"
    self.Type = "MoveTo"
    self.Step = {
        MobName = ""
    }
end

function KillBehavior:Run()
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