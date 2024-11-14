runner.Behaviors.KillBehavior = runner.Behaviors.BaseBehavior:extend()
local KillBehavior = runner.Behaviors.KillBehavior
runner.Behaviors.KillBehavior = KillBehavior

function KillBehavior:init()
    self.Name = "KillBehavior"
    self.Type = "Kill"
    self.Title = "Kill"
    self.Description = "Kill a specific mob"
    self.MiniTypes = {
        "Dungeon",
        "Quest"
    }
    self.Step = {
        MobName = "",
        children = {}
    }
    self.CanHaveChildren = true
end

function KillBehavior:Run()
    if self.Step.MobName and self.Step.MobName == "" then
        self.IsComplete = true
        return
    else
        local target = runner.Engine.ObjectManager:GetClosestByName(self.Step.MobName)
        if target then
            local mechanic = runner.mechanics["stonevault"]
            if mechanic then
                if mechanic:NeedsMechanic() then
                    mechanic:DoMechanic()
                    self.IsComplete = false
                    return
                end
            end

            if not target.isDead then
                --if self:CheckAreaTriggers(target) then
                --    print("Area trigger issue?")
                --    return
                --end

                if target:DistanceFromPlayer() > runner.rotation.CombatRange or not target:LOS() then
                    runner.Engine.Navigation:MoveTo(target.pointer)
                else
                    Unlock(TargetUnit, target.pointer)
                    runner.Engine.Navigation:FaceUnit(target.pointer)
                    Unlock(MoveForwardStop)
                    if not target.InCombat then
                        runner.rotation:Pull(target)
                    else
                        runner.rotation:Pulse(target)
                    end
                end
                self.IsComplete = false
                return
            else
                print("Killed " .. self.Step.MobName)
                self.IsComplete = true
                return
            end
        else
            print("Could not find " .. self.Step.MobName)
            self.IsComplete = true
            return
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

function KillBehavior:BuildMiniUI(profile)
    local button = runner.AceGUI:Create("Button")
    button:SetText("Add kill")
    button:SetWidth(150)
    button:SetCallback("OnClick", function()
    end)
    table.insert(profile, self)
    return button
end

function KillBehavior:Setup()
    local target = UnitName("target")
    if target then
        self.Step.MobName = target
    end
end

registerBehavior("KillBehavior", KillBehavior)