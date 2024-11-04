runner.Behaviors.MoveToBehavior = runner.Behaviors.BaseBehavior:extend()
local MoveToBehavior = runner.Behaviors.MoveToBehavior
runner.Behaviors.MoveToBehavior = MoveToBehavior

function MoveToBehavior:init()
    self.Name = "MoveToBehavior"
    self.Type = "MoveTo"
    self.Step = {
        X = 0,
        Y = 0,
        Z = 0,
        Radius = 0,
        DontFight = false
    }
end

function MoveToBehavior:Run()
    if not self.Step.DontFight then
        if self:SelfDefense() then
            return
        end
    end

    local closestEnemy = runner.Engine.ObjectManager:GetClosestEnemy()
    local inRangeOfWaypoint = self:InRange(closestEnemy)

    if runner.routine.CurrentProfile.PullMode == "Active" and closestEnemy and inRangeOfWaypoint then
        if closestEnemy:DistanceFromPlayer() > runner.rotation.PullRange or not closestEnemy:LOS() then
            runner.routine:SetStatus("Moving to kill " .. closestEnemy.Name)
            runner.Engine.Navigation:MoveTo(closestEnemy.pointer)
            return
        else
            runner.routine:SetStatus("Killing " .. closestEnemy.Name)
            Unlock(MoveForwardStop)
            runner.Engine.Navigation:FaceUnit(closestEnemy.pointer)
            Unlock(TargetUnit, closestEnemy.pointer)
            runner.rotation:Pull(closestEnemy)
            return
        end
    end

    if self.Step.X ~= 0 and self.Step.Y ~= 0 and self.Step.Z ~= 0 then
        runner.routine:SetStatus("Moving to waypoint")
        if runner.LocalPlayer:DistanceFromPoint(self.Step.X, self.Step.Y, self.Step.Z) > self.Step.Radius then
        runner.Engine.Navigation:MoveToPoint(self.Step.X, self.Step.Y, self.Step.Z)
        self.IsComplete = false
        else
        Unlock(MoveForwardStop)
        self.IsComplete = true
        end
    end
end

function MoveToBehavior:InRange(unit)
    if self.Step.X ~= 0 and self.Step.Y ~= 0 and self.Step.Z ~= 0 then
        if unit then
            return unit:DistanceFromPoint(self.Step.X, self.Step.Y, self.Step.Z) < tonumber(runner.routine.CurrentProfile.WanderRange)
        end
    end
    return false
end

function MoveToBehavior:Debug()
    if not self.IsComplete then
        runner.Draw:SetColor(0, 255, 0, 255)
        runner.Draw:Circle(self.Step.X, self.Step.Y, self.Step.Z, self.Step.Radius)
    else
        runner.Draw:SetColor(255, 0, 0, 255)
        runner.Draw:Circle(self.Step.X, self.Step.Y, self.Step.Z, self.Step.Radius)
    end
end

function MoveToBehavior:BuildStepGUI(container)
    local xEditBox = runner.AceGUI:Create("EditBox")
    xEditBox:SetLabel("X")
    xEditBox:SetWidth(200)
    xEditBox:SetText(self.Step.X)
    xEditBox:SetCallback("OnEnterPressed", function(_, _, text)
        self.Step.X = tonumber(text)
    end)
    container:AddChild(xEditBox)
    local yEditBox = runner.AceGUI:Create("EditBox")
    yEditBox:SetLabel("Y")
    yEditBox:SetWidth(200)
    yEditBox:SetText(self.Step.Y)
    yEditBox:SetCallback("OnEnterPressed", function(_, _, text)
        self.Step.Y = tonumber(text)
    end)
    container:AddChild(yEditBox)
    local zEditBox = runner.AceGUI:Create("EditBox")
    zEditBox:SetLabel("Z")
    zEditBox:SetText(self.Step.Z)
    zEditBox:SetWidth(200)
    zEditBox:SetCallback("OnEnterPressed", function(_, _, text)
        self.Step.Z = tonumber(text)
    end)
    container:AddChild(zEditBox)
    local radiusEditBox = runner.AceGUI:Create("EditBox")
    radiusEditBox:SetLabel("Radius")
    radiusEditBox:SetWidth(200)
    radiusEditBox:SetText(self.Step.Radius)
    radiusEditBox:SetCallback("OnEnterPressed", function(_, _, text)
        self.Step.Radius = tonumber(text)
    end)
    container:AddChild(radiusEditBox)

    local getPosButton = runner.AceGUI:Create("Button")
    getPosButton:SetText("Get Position")
    getPosButton:SetFullWidth(true)
    getPosButton:SetCallback("OnClick", function()
        local x, y, z = ObjectPosition("player")
        xEditBox:SetText(x)
        yEditBox:SetText(y)
        zEditBox:SetText(z)
        self.Step.X = x
        self.Step.Y = y
        self.Step.Z = z
    end)
    container:AddChild(getPosButton)
    local dontfight = runner.AceGUI:Create("CheckBox")
    dontfight:SetLabel("Don't fight")
    dontfight:SetWidth(200)
    dontfight:SetValue(self.Step.DontFight)
    dontfight:SetCallback("OnValueChanged", function(_, _, value)
        self.Step.DontFight = value
    end)
    container:AddChild(dontfight)
end

registerBehavior("MoveToBehavior", MoveToBehavior)