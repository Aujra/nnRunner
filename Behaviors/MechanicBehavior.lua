runner.Behaviors.MechanicBehavior = runner.Behaviors.BaseBehavior:extend()
local MechanicBehavior = runner.Behaviors.MechanicBehavior
runner.Behaviors.MechanicBehavior = MechanicBehavior

function MechanicBehavior:init()
    self.Name = "MechanicBehavior"
    self.Type = "Mechanic"
    self.Title = "Mechanic"
    self.Description = "Perform a mechanic"
    self.MiniTypes = {
        "Dungeon",
        "Quest"
    }
    self.Step = {
        MechanicName = "",
        Mechanics = {},
    }
    self.CanHaveChildren = false
end

function MechanicBehavior:Run()
    if self.Step.MechanicName and self.Step.MechanicName == "" then
        self.IsComplete = true
        return
    else
        print("Performing mechanic: " .. self.Step.MechanicName)
        self.IsComplete = true
        return
    end
end

function MechanicBehavior:BuildStepGUI(container)
    runner.Behaviors.BaseBehavior.BuildStepGUI(self, container)

    local ifstatments = {}
    local thenstatments = {}

    local addMechanicButton = runner.AceGUI:Create("Button")
    addMechanicButton:SetText("Add Mechanic")
    addMechanicButton:SetFullWidth(true)
    addMechanicButton:SetCallback("OnClick", function()
        local mdrop, mname, mmob = self:AddMechanicDropdown(container)
        table.insert(ifstatments, mdrop)
        table.insert(ifstatments, mname)
        table.insert(ifstatments, mmob)
    end)

    local iftab = runner.AceGUI:Create("TabGroup")
    iftab:SetLayout("Flow")
    iftab:SetFullWidth(true)
    iftab:SetTabs({{text="If", value="if"}, {text="Then", value="then"}})
    iftab:SetCallback("OnGroupSelected", function(widget, event, group)
        iftab:ReleaseChildren()
        if group == "if" then
            for k,v in pairs(ifstatments) do
                iftab:AddChild(v)
            end
        else
            print("then")
        end
    end)

    container:AddChild(addMechanicButton)
    container:AddChild(iftab)
end

function MechanicBehavior:AddMechanicDropdown(container)
    local dropdown = runner.AceGUI:Create("Dropdown")
    dropdown:SetList(runner.Engine.Mechanics)
    for k,v in pairs(self:GetMechanics()) do
        dropdown:AddItem(v, v)
    end
    dropdown:SetWidth(200)
    dropdown:SetCallback("OnValueChanged", function(widget, event, key)
        self.Step.MechanicName = key
    end)

    local mobNameEditBox = runner.AceGUI:Create("EditBox")
    mobNameEditBox:SetLabel("Mob Name")
    mobNameEditBox:SetWidth(200)
    mobNameEditBox:SetText(self.Step.MobName)
    mobNameEditBox:SetCallback("OnEnterPressed", function(_, _, text)
        self.Step.MobName = text
    end)

    local auraNameEditBox = runner.AceGUI:Create("EditBox")
    auraNameEditBox:SetLabel("Aura Name")
    auraNameEditBox:SetWidth(200)
    auraNameEditBox:SetText(self.Step.AuraName)
    auraNameEditBox:SetCallback("OnEnterPressed", function(_, _, text)
        self.Step.AuraName = text
    end)
    return dropdown, mobNameEditBox, auraNameEditBox
end

function MechanicBehavior:GetMechanics()
    return {
        "UnitAura",
        "MoveTo",
        "InteractWith"
    }
end

function MechanicBehavior:BuildMiniUI(profile)

end

function MechanicBehavior:Save()
    return {
        Name = self.Name,
        Type = self.Type,
        MechanicName = self.Step.MechanicName
    }
end

function MechanicBehavior:Load(data)
    self.Step.MechanicName = data.MechanicName
end

function MechanicBehavior:Debug()

end

registerBehavior("MechanicBehavior", MechanicBehavior)