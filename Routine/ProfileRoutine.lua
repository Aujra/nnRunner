runner.Routines.ProfileRoutine = class({}, "ProfileRoutine")
local ProfileRoutine = runner.Routines.ProfileRoutine
runner.Routines.ProfileRoutine = ProfileRoutine

function ProfileRoutine:init()
    self.Name = "ProfileRoutine"
    self.Description = "ProfileRoutine"
    self.SettingsGUI = {}
    self.IsComplete = false
    self.Profile = {}
end

function ProfileRoutine:Run()

end

function ProfileRoutine:ShowGUI()
    local loadProfileDropdown = runner.AceGUI:Create("Dropdown")
    loadProfileDropdown:SetLabel("Load Profile")
    loadProfileDropdown:SetWidth(300)
    local loadProfileDropdown = runner.AceGUI:Create("Dropdown")
    loadProfileDropdown:SetLabel("Load Profile")
    local path = "/scripts/mainrunner/Profiles/ProfileRunner/*.json"
    local files = runner.nn.ListFiles(path)
    for k,v in pairs(files) do
        loadProfileDropdown:AddItem(
                v,v
        )
    end
    loadProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self:LoadProfileByName(value)
    end)
    self.SettingsGUI:AddChild(loadProfileDropdown)
end

function ProfileRoutine:LoadProfileByName(name)
    local json = runner.nn.ReadFile("/scripts/mainrunner/Profiles/ProfileRunner/"..name)
    local profile = runner.nn.Utils.JSON.decode(json)
    profileSteps = {}
    for k,v in pairs(profile.Steps) do
        local behavior = runner.behaviors[v.Name:lower()]()
        behavior.Name = v.Name
        behavior.Type = v.Type
        behavior.Step = v.Step
        table.insert(profileSteps, {index = #profileSteps, step = behavior})
    end
end

function ProfileRoutine:HideGUI()
end

registerRoutine(ProfileRoutine)

function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
