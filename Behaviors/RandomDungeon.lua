runner.Behaviors.DungeonRunner = runner.Behaviors.BaseBehavior:extend()
local DungeonRunner = runner.Behaviors.DungeonRunner
runner.Behaviors.DungeonRunner = DungeonRunner

function DungeonRunner:init()
    self.Name = "DungeonRunner"
    self.Type = "DungeonRunner"
    self.CanHaveChildren = false
    self.Step = {
        DungeonList = {},
        RunStyle = "Random"
    }
    self.DungeonRunner = nil
end

function DungeonRunner:Run()
    if self.DungeonRunner == nil then
        self.DungeonRunner = runner.routines["dungeonroutine2"]
    end
    if runner.LocalPlayer.Level >= tonumber(self.Step.ToLevel) then
        self.IsComplete = true
        return
    end

    local profile = nil
    if self.Step.RunStyle == "Random" then
        profile = runner:randomTable(self.Step.DungeonList)
    else
        for k,v in pairs(self.Step.DungeonList) do
            if not v.ran then
                profile = v
                break
            end
        end
    end
    self.DungeonRunner:LoadProfileByName(profile.dropdown:GetValue())
    profile.ran = true
    self.DungeonRunner:Run()
end

function DungeonRunner:Save()
    local data = {
        Name = self.Name,
        Type = self.Type,
        Step = {
            DungeonList = {},
            RunStyle = self.Step.RunStyle
        }
    }

    for k,v in pairs(self.Step.DungeonList) do
        table.insert(data.Step.DungeonList, {dropdown = v.dropdown:GetValue(), ran = v.ran})
    end

    return data
end

function DungeonRunner:Load(data)
    self.Step.RunStyle = data.Step.RunStyle
    for k,v in pairs(data.Step.DungeonList) do
        table.insert(self.Step.DungeonList, {dropdown = v.dropdown, ran = v.ran})
    end
end

function DungeonRunner:Debug()

end

function DungeonRunner:BuildStepGUI(container)
    container:ReleaseChildren()

    local runStyleDropdown = runner.AceGUI:Create("Dropdown")
    runStyleDropdown:SetLabel("Run Style")
    runStyleDropdown:SetWidth(125)
    runStyleDropdown:AddItem("Random", "Random")
    runStyleDropdown:AddItem("Sequential", "Sequential")
    runStyleDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self.Step.RunStyle = value
    end)
    container:AddChild(runStyleDropdown)

    local addDungeonButton = runner.AceGUI:Create("Button")
    addDungeonButton:SetText("Add Dungeon")
    addDungeonButton:SetWidth(150)
    addDungeonButton:SetCallback("OnClick", function(widget)
        self:AddDungeonGUI(container)
    end)
    container:AddChild(addDungeonButton)

    local dumpProfileButton = runner.AceGUI:Create("Button")
    dumpProfileButton:SetText("Dump Profile")
    dumpProfileButton:SetWidth(150)
    dumpProfileButton:SetCallback("OnClick", function(widget)
        local profile = runner:randomTable(self.Step.DungeonList)
        print("Running " .. profile.dropdown:GetValue())
        self:Run()
    end)
    container:AddChild(dumpProfileButton)
end

function DungeonRunner:AddDungeonGUI(container)
    local labelBreak = runner.AceGUI:Create("Label")
    labelBreak:SetText(" ")
    labelBreak:SetFullWidth(true)
    labelBreak:SetHeight(1)
    container:AddChild(labelBreak)

    local profileDropDown = runner.AceGUI:Create("Dropdown")
    profileDropDown:SetLabel("Profile")
    profileDropDown:SetWidth(175)
    local path = "/scripts/mainrunner/Profiles/DungeonsNew/*.json"
    local files = runner.nn.ListFiles(path)
    for k,v in pairs(files) do
        profileDropDown:AddItem(
                v,v
        )
    end

    container:AddChild(profileDropDown)
    table.insert(self.Step.DungeonList, {dropdown = profileDropDown, ran = false})
end

registerBehavior("DungeonRunner", DungeonRunner)