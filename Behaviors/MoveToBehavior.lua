runner.Behaviors.MoveToBehavior = runner.Behaviors.BaseBehavior:extend()
local MoveToBehavior = runner.Behaviors.MoveToBehavior
runner.Behaviors.MoveToBehavior = MoveToBehavior

function MoveToBehavior:init()
    self.Name = "MoveToBehavior"
    self.Type = "MoveTo"
    self.MiniTypes = {
        "Dungeon",
        "Grind"
    }
    self.Step = {
        X = 0,
        Y = 0,
        Z = 0,
        Radius = 0,
        DontFight = false
    }
    self.Adjusted = false
end

function MoveToBehavior:Run()
    if not self.Step.DontFight then
        if self:SelfDefense() then
            return
        end
    end

    local closestEnemy = runner.Engine.ObjectManager:GetClosestEnemy()
    local inRangeOfWaypoint = false

    if closestEnemy and inRangeOfWaypoint then
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
        local offsetX = runner.randomBetween(self, -3, 3)
        local offsetY = runner.randomBetween(self, -3, 3)
        if not self.Adjusted then
            self.Step.X = self.Step.X + offsetX
            self.Step.Y = self.Step.Y + offsetY
            self.Adjusted = true
        end
        if runner.LocalPlayer:DistanceFromPoint(self.Step.X, self.Step.Y, self.Step.Z) > (self.Step.Radius-1) then
            runner.Engine.Navigation:MoveToPoint(self.Step.X, self.Step.Y, self.Step.Z)
            self.IsComplete = false
        else
            Unlock(MoveForwardStop)
            self.IsComplete = true
        end
    end
end

--function MoveToBehavior:InRange(unit)
--    if self.Step.X ~= 0 and self.Step.Y ~= 0 and self.Step.Z ~= 0 then
--        if unit then
--            return unit:DistanceFromPoint(self.Step.X, self.Step.Y, self.Step.Z) < tonumber(runner.routine.CurrentProfile.WanderRange)
--        end
--    end
--    return false
--end

function MoveToBehavior:Save()
    return {
        Name = self.Name,
        Type = self.Type,
        X = self.Step.X,
        Y = self.Step.Y,
        Z = self.Step.Z,
        Radius = self.Step.Radius,
        DontFight = self.Step.DontFight
    }
end

function MoveToBehavior:Load(data)
    self.Step.X = data.X
    self.Step.Y = data.Y
    self.Step.Z = data.Z
    self.Step.Radius = data.Radius
    self.Step.DontFight = data.DontFight
end

function MoveToBehavior:Debug()
    if not self.IsComplete then
        runner.Draw:SetColor(0, 255, 0, 255)
        runner.Draw:Circle(self.Step.X, self.Step.Y, self.Step.Z, self.Step.Radius)
    end
    if self.IsComplete then
        runner.Draw:SetColor(255, 0, 0, 255)
        runner.Draw:Circle(self.Step.X, self.Step.Y, self.Step.Z, self.Step.Radius)
    end
    if self.CurrentStep then
        runner.Draw:SetColor(0, 0, 255, 255)
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

function MoveToBehavior:BuildMiniUI(profile)
    local button = runner.AceGUI:Create("Button")
    button:SetText("Move To")
    button:SetWidth(150)
    button:SetCallback("OnClick", function()
        local x, y, z = ObjectPosition("player")
        self.Step.X = x
        self.Step.Y = y
        self.Step.Z = z
        self.Step.Radius = 5
        table.insert(profile, self)
    end)
    return button
end

function MoveToBehavior:Setup()
    local x, y, z = ObjectPosition("player")
    self.Step.X = x
    self.Step.Y = y
    self.Step.Z = z
    self.Step.Radius = 5
    self.Step.DontFight = false
end

registerBehavior("MoveToBehavior", MoveToBehavior)