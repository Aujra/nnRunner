runner.Behaviors.InteractBehavior = runner.Behaviors.BaseBehavior:extend()
local InteractBehavior = runner.Behaviors.InteractBehavior
runner.Behaviors.InteractBehavior = InteractBehavior

function InteractBehavior:init()
    self.Name = "InteractBehavior"
    self.Type = "Interact"
    self.Step = {
        MobName = ""
    }
end

function InteractBehavior:Run()
    if self.Step.MobName and self.Step.MobName == "" then
        self.IsComplete = true
        return
    else
        local target = runner.Engine.ObjectManager:GetClosestByName(self.Step.MobName)
        if target then
            if target then
                if target:DistanceFromPlayer() > 7 then
                    runner.Engine.Navigation:MoveTo(target.pointer)
                else
                    print("Interacting with " .. target.Name)
                    Unlock(MoveForwardStop)
                    runner.Engine.Navigation:FaceUnit(target.pointer)
                    runner.nn.ObjectInteract(target.pointer)
                    if not Unlock(UnitIsInteractable, target.pointer) then
                        self.IsComplete = true
                    end
                end
            else
                self.IsComplete = true
                return
            end
        end
    end
end

function InteractBehavior:Debug()

end

function InteractBehavior:BuildStepGUI(container)
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

registerBehavior("InteractBehavior", InteractBehavior)