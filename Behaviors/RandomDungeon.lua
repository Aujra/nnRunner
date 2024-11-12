runner.Behaviors.DungeonRunner = runner.Behaviors.BaseBehavior:extend()
local DungeonRunner = runner.Behaviors.DungeonRunner
runner.Behaviors.DungeonRunner = DungeonRunner

function DungeonRunner:init()
    self.Name = "DungeonRunner"
    self.Type = "DungeonRunner"
    self.Title = "Dungeon Runner"
    self.Description = "Run a set of dungeons"
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
    local profile = nil
    if not IsInInstance() then
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
        local loadedProfile = self.DungeonRunner:LoadProfileByName(profile.dropdown)
    end

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
        table.insert(data.Step.DungeonList, {dropdown = v.dropdown, profile = v.valueSelected, ran = v.ran})
    end

    return data
end

function DungeonRunner:Load(data)
    self.Step.RunStyle = data.Step.RunStyle
    local sf = runner.UI.DungeonProfileMaker:GetScrollFrame()
    for k,v in pairs(data.Step.DungeonList) do
        table.insert(self.Step.DungeonList, {dropdown = v.dropdown, ran = v.ran})
    end
end

function DungeonRunner:Debug()

end

function DungeonRunner:BuildStepGUI(container)
    runner.Behaviors.BaseBehavior.BuildStepGUI(self, container)

    local runStyleDropdown = runner.AceGUI:Create("Dropdown")
    runStyleDropdown:SetLabel("Run Style")
    runStyleDropdown:SetWidth(125)
    runStyleDropdown:AddItem("Random", "Random")
    runStyleDropdown:AddItem("Sequential", "Sequential")
    runStyleDropdown:SetValue(self.Step.RunStyle)
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

    for k,v in pairs(self.Step.DungeonList) do
        self:AddDungeonGUI(container, v.dropdown)
    end

    container:AddChild(addDungeonButton)
end

function DungeonRunner:AddDungeonGUI(container, val)
    val = val or nil
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

    local valueSelected = nil

    if val then
        profileDropDown:SetValue(val)
    end

    profileDropDown:SetCallback("OnValueChanged", function(widget, event, value)
        valueSelected = value
    end)

    container:AddChild(profileDropDown)
    if not val then
        table.insert(self.Step.DungeonList, {dropdown = profileDropDown, profile = valueSelected, ran = false})
    end
end

registerBehavior("DungeonRunner", DungeonRunner)