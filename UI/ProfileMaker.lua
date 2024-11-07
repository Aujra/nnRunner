runner.UI.ProfileMaker = {}
local PM = runner.UI.ProfileMaker
runner.UI.ProfileMaker = PM

--UI Elements
PM.mainFrame = nil
PM.BuilderFrame = nil


PM.treeView = nil
PM.inlineFrame = nil
PM.scrollFrame = nil
--Controls
PM.addProfileButton = nil
PM.addBehaviorButton = nil
PM.addBehaviorDropdown = nil
PM.loadProfileDropdown = nil
PM.saveProfileButton = nil
PM.saveProfileName = nil
PM.deleteFileButton = nil
PM.loadProfileButton = nil

--Data
PM.profile = nil
PM.treeStruct = nil

PM.profileType = "Dungeon"

if not PM.mainFrame then
    PM.mainFrame = runner.AceGUI:Create("Window")
    PM.mainFrame:SetTitle("Profile Maker")
    PM.mainFrame:SetLayout("Flow")
    PM.mainFrame:SetWidth(800)
    PM.mainFrame:SetHeight(600)
    PM.mainFrame:EnableResize(false)
    PM.mainFrame:SetCallback("OnClose", function(widget) PM:Close() end)
    PM.mainFrame:Hide()

    PM.addBehaviorDropdown = runner.AceGUI:Create("Dropdown")
    PM.addBehaviorDropdown:SetLabel("Add Behavior")
    PM.addBehaviorDropdown:SetWidth(0)
    PM.addBehaviorDropdown:SetHeight(0)
    for k,v in pairs(runner.behaviors) do
        PM.addBehaviorDropdown:AddItem(
                k,k
        )
    end
    PM.addBehaviorDropdown.frame:Hide()
    PM.addBehaviorDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        PM.addBehaviorDropdown.frame:Hide()
        PM.addBehaviorDropdown:SetWidth(0)
    end)

    PM.addBehaviorButton = runner.AceGUI:Create("Button")
    PM.addBehaviorButton:SetText("+")
    PM.addBehaviorButton:SetWidth(20)
    PM.addBehaviorButton:SetCallback("OnClick", function(widget)
        if PM.addBehaviorDropdown.frame:GetWidth() < 1 then
            PM.addBehaviorDropdown:SetWidth(200)
            PM.addBehaviorDropdown:SetHeight(30)
            PM.addBehaviorDropdown.frame:Show()
        else
            PM.addBehaviorDropdown:SetWidth(0)
            PM.addBehaviorDropdown:SetHeight(0)
            PM.addBehaviorDropdown.frame:Hide()
        end
    end)

    PM.saveProfileButton = runner.AceGUI:Create("Button")
    PM.saveProfileButton:SetText("Save")
    PM.saveProfileButton:SetWidth(80)
    PM.saveProfileButton:SetCallback("OnClick", function(widget)

    end)

    PM.loadProfileButton = runner.AceGUI:Create("Button")
    PM.loadProfileButton:SetText("Load")
    PM.loadProfileButton:SetWidth(80)
    PM.loadProfileButton:SetCallback("OnClick", function(widget)
        if PM.loadProfileDropdown.frame:GetWidth() < 1 then
            PM.loadProfileDropdown:SetWidth(200)
            PM.loadProfileDropdown:SetHeight(30)
            PM.loadProfileDropdown.frame:Show()
        else
            PM.loadProfileDropdown:SetWidth(0)
            PM.loadProfileDropdown:SetHeight(0)
            PM.loadProfileDropdown.frame:Hide()
        end
    end)

    PM.deleteFileButton = runner.AceGUI:Create("Button")
    PM.deleteFileButton:SetText("Delete")
    PM.deleteFileButton:SetWidth(80)
    PM.deleteFileButton:SetCallback("OnClick", function(widget)

    end)

    PM.loadProfileDropdown = runner.AceGUI:Create("Dropdown")
    PM.loadProfileDropdown:SetLabel("Load Profile")
    PM.loadProfileDropdown:SetWidth(0)
    PM.loadProfileDropdown:SetHeight(0)
    local path = "/scripts/mainrunner/Profiles/ProfileRunner/*.json"
    local files = runner.nn.ListFiles(path)
    if files then
        for k,v in pairs(files) do
            PM.loadProfileDropdown:AddItem(
                    v,v
            )
        end
    end
    PM.loadProfileDropdown.frame:Hide()
    PM.loadProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value)

    end)

    PM.mainFrame:AddChild(PM.addBehaviorDropdown)
    PM.mainFrame:AddChild(PM.loadProfileDropdown)
    PM.mainFrame:AddChild(PM.addBehaviorButton)
    PM.mainFrame:AddChild(PM.saveProfileButton)
    PM.mainFrame:AddChild(PM.loadProfileButton)
    PM.mainFrame:AddChild(PM.deleteFileButton)
end

if not PM.BuilderFrame then
    PM.BuilderFrame = runner.AceGUI:Create("Frame")
    PM.BuilderFrame:SetTitle("Profile Builder")
    PM.BuilderFrame:SetLayout("Flow")
    PM.BuilderFrame:SetWidth(150)
    PM.BuilderFrame:SetHeight(500)
    PM.BuilderFrame:EnableResize(false)
    PM.BuilderFrame:Show()

    PM.profileTypeDropdown = runner.AceGUI:Create("Dropdown")
    PM.profileTypeDropdown:SetLabel("Profile Type")
    PM.profileTypeDropdown:SetWidth(150)
    PM.profileTypeDropdown:AddItem("Dungeon", "Dungeon")
    PM.profileTypeDropdown:AddItem("Quest", "Quest")
    PM.profileTypeDropdown:AddItem("Grind", "Grind")
    PM.profileTypeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        PM.profileType = value
        PM:RebuildMiniProfileMaker(value)
    end)

    PM.openProfileViewerButton = runner.AceGUI:Create("Button")
    PM.openProfileViewerButton:SetText("Profile Viewer")
    PM.openProfileViewerButton:SetWidth(150)
    PM.openProfileViewerButton:SetCallback("OnClick", function(widget)
        if not PM.mainFrame:IsShown() then
            PM.mainFrame:Show()
        else
            PM.mainFrame:Hide()
        end
    end)

    PM.BuilderFrame:AddChild(PM.profileTypeDropdown)
end

function PM:RebuildMiniProfileMaker(type)
    PM.BuilderFrame:ReleaseChildren()
    PM.profileTypeDropdown = runner.AceGUI:Create("Dropdown")
    PM.profileTypeDropdown:SetLabel("Profile Type")
    PM.profileTypeDropdown:SetWidth(150)
    PM.profileTypeDropdown:AddItem("Dungeon", "Dungeon")
    PM.profileTypeDropdown:AddItem("Quest", "Quest")
    PM.profileTypeDropdown:AddItem("Grind", "Grind")
    PM.profileTypeDropdown:SetValue(type)
    PM.profileTypeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        PM.profileType = value
        PM:RebuildMiniProfileMaker(value)
    end)
    PM.BuilderFrame:AddChild(PM.profileTypeDropdown)

    for k,v in pairs(runner.behaviors) do
        local beh = v()
        if beh.MiniTypes then
            for k2,v2 in pairs(beh.MiniTypes) do
                if v2 == PM.profileType then
                    local but = beh:BuildMiniUI()
                    if but then
                        PM.BuilderFrame:AddChild(but)
                    end
                end
            end
        end
    end
end