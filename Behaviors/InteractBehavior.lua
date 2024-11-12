runner.Behaviors.InteractBehavior = runner.Behaviors.BaseBehavior:extend()
local InteractBehavior = runner.Behaviors.InteractBehavior
runner.Behaviors.InteractBehavior = InteractBehavior

function InteractBehavior:init()
    self.Name = "InteractBehavior"
    self.Type = "Interact"
    self.Title = "Interact"
    self.Description = "Interact with a specific object or NPC"
    self.MiniTypes = {
        "Dungeon",
    }
    self.Step = {
        MobName = "",
        Range = 99999
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

function InteractBehavior:Save()
    return {
        Name = self.Name,
        Type = self.Type,
        MobName = self.Step.MobName
    }
end

function InteractBehavior:Load(data)
    self.Step.MobName = data.MobName
end

function InteractBehavior:Debug()

end

function InteractBehavior:BuildMiniUI(profile)
    local interactButton = runner.AceGUI:Create("Button")
    interactButton:SetText("Interact")
    interactButton:SetWidth(150)
    interactButton:SetCallback("OnClick", function()
        local step = {
            Name = "Interact",
            Type = "Interact",
            MobName = ""
        }
        table.insert(profile, step)
        profile:RefreshUI()
    end)
    return interactButton
end

function InteractBehavior:Setup()
    local targetName = UnitName("target")
    self.Step.MobName = targetName or ""
    self.Step.Range = 4
end

function InteractBehavior:BuildStepGUI(container)
    runner.Behaviors.BaseBehavior.BuildStepGUI(self, container)
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