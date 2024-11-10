runner.Routines.ProfileRoutine = runner.Routines.BaseRoutine:extend()
local ProfileRoutine = runner.Routines.ProfileRoutine
runner.Routines.ProfileRoutine = ProfileRoutine

function ProfileRoutine:init()
    self.Name = "ProfileRoutine"
    self.Description = "ProfileRoutine"
    self.SettingsGUI = {}
    self.IsComplete = false
    self.Profile = {}
    self:BuildGUI()
end

function ProfileRoutine:Run()
    if self.Profile then
        for k,v in pairs(self.Profile) do
            local current = nil
            for k,v in pairs(self.Profile) do
                v.step:Debug()
                if not v.step.IsComplete then
                    current = v
                end
                if current then
                    current.CurrentStep = true
                end
            end
            if current then
                current.step:Run()
                current.step:Debug()
            else
                print("Profile Complete")
            end
        end
    end
end

function ProfileRoutine:BuildGUI()
    self.SettingsGUI = runner.AceGUI:Create("Frame")
    self.SettingsGUI:SetTitle(self.Name)
    self.SettingsGUI:SetStatusText(self.Description)
    self.SettingsGUI:SetLayout("Flow")
    self.SettingsGUI:SetCallback("OnClose", function(widget)
        runner.Routines.ProfileRoutine:HideGUI()
    end)
    self.SettingsGUI:SetWidth(300)
    self.SettingsGUI:SetHeight(200)
    local loadProfileDropdown = runner.AceGUI:Create("Dropdown")
    loadProfileDropdown:SetLabel("Load Profile")
    loadProfileDropdown:SetWidth(200)
    local path = "/scripts/mainrunner/Profiles/ProfileRunner/*.json"
    local files = runner.nn.ListFiles(path)
    if files then
        for k,v in pairs(files) do
            loadProfileDropdown:AddItem(
                    v,v
            )
        end
    end
    loadProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self:LoadProfileByName(value)
    end)
    self.SettingsGUI:AddChild(loadProfileDropdown)
end

function ProfileRoutine:ShowGUI()
    self.SettingsGUI:Show()
end

function ProfileRoutine:HideGUI()
    self.SettingsGUI:Hide()
end

function ProfileRoutine:LoadProfileByName(name)
    local json = runner.nn.ReadFile("/scripts/mainrunner/Profiles/ProfileRunner/"..name)
    local profile = runner.nn.Utils.JSON.decode(json)
    profileSteps = {}
    for k,v in pairs(profile.Steps) do
        local behavior = runner.behaviors[v.Name:lower()]()
        behavior:Load(v)
        table.insert(self.Profile, {index = #self.Profile, step = behavior})
    end
end

function ProfileRoutine:HideGUI()
end

function ProfileRoutine:SetStatus(status)
    if self.SettingsGUI then
        self.SettingsGUI:SetStatusText(status)
    end
end

registerRoutine(ProfileRoutine)

function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
