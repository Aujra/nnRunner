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
PM.ProfileDrop = nil
PM.saveProfileButton = nil
PM.saveProfileName = nil
PM.deleteFileButton = nil
PM.loadProfileButton = nil

--Data
PM.profile = {}
PM.treeStruct = {}
PM.selectedProfile = nil

_G.theprofile = PM.profile

PM.profileType = "Dungeon"

function PM:GetProfiles()
    local path = "/scripts/mainrunner/Profiles/ProfileRunner/*.json"
    local files = runner.nn.ListFiles(path)
    local foundProfiles = {}
    for k,v in pairs(files) do
        table.insert(foundProfiles, v)
    end
    return foundProfiles
end

function PM:BuildTreeFromProfile()
    local tree = {}
    for k,v in pairs(PM.profile) do
        local node = {
            value = tableCount(tree)+1,
            text = v.Name
        }
        table.insert(tree, node)
    end
    PM.treeView:SetTree(
        {
            {
                value = "root",
                text = "Root",
                children = tree
            }
        }
    )
end

function PM:GetBehaviorByIndex(index)
    index = tonumber(index)
    for k,v in pairs(PM.profile) do
        if k == index then
            return v
        end
    end
    return nil
end

if not PM.mainFrame then
    PM.mainFrame = runner.AceGUI:Create("Window")
    PM.mainFrame:SetTitle("Profile Maker")
    PM.mainFrame:SetLayout("Flow")
    PM.mainFrame:SetWidth(800)
    PM.mainFrame:SetHeight(600)
    PM.mainFrame:EnableResize(true)
    PM.mainFrame:SetCallback("OnClose", function(widget) PM:Close() end)
    PM.mainFrame:Hide()

    PM.ProfileDrop = runner.AceGUI:Create("Dropdown")
    PM.ProfileDrop:SetLabel("Profile")
    PM.ProfileDrop:SetWidth(200)
    PM.ProfileDrop:SetCallback("OnValueChanged", function(widget, event, value)
        PM.selectedProfile = value
    end)
    local profiles = PM:GetProfiles()
    for k,v in pairs(profiles) do
        PM.ProfileDrop:AddItem(v, v)
    end

    PM.loadProfileButton = runner.AceGUI:Create("Button")
    PM.loadProfileButton:SetText("Load Profile")
    PM.loadProfileButton:SetWidth(125)
    PM.loadProfileButton:SetCallback("OnClick", function(widget)
        if not PM.selectedProfile then
            print("No Profile Selected")
            return
        end
        print("Load Profile " .. PM.selectedProfile)
        local path = "/scripts/mainrunner/Profiles/ProfileRunner/" .. PM.selectedProfile
        local data = runner.nn.ReadFile(path)
        print("Data " .. data)
    end)

    PM.deleteFileButton = runner.AceGUI:Create("Button")
    PM.deleteFileButton:SetText("Delete File")
    PM.deleteFileButton:SetWidth(125)
    PM.deleteFileButton:SetCallback("OnClick", function(widget)
        if not PM.selectedProfile then
            print("No Profile Selected")
            return
        end
        print("Delete File " .. PM.selectedProfile)
        local path = "/scripts/mainrunner/Profiles/ProfileRunner/" .. PM.selectedProfile
        runner.nn.DeleteFile(path)
    end)

    PM.saveProfileName = runner.AceGUI:Create("EditBox")
    PM.saveProfileName:SetLabel("Profile Name")
    PM.saveProfileName:SetWidth(125)

    PM.saveProfileButton = runner.AceGUI:Create("Button")
    PM.saveProfileButton:SetText("Save Profile")
    PM.saveProfileButton:SetWidth(125)
    PM.saveProfileButton:SetCallback("OnClick", function(widget)
        if PM.saveProfileName:GetText() == "" then
            print("No Profile Name Provided")
            return
        end
        print("Save Profile " .. PM.saveProfileName:GetText())
        local path = "/scripts/mainrunner/Profiles/ProfileRunner/" .. PM.saveProfileName:GetText() .. ".json"
        local data = "test saving data"
        runner.nn.WriteFile(path, data)
    end)

    PM.mainFrame:AddChild(PM.ProfileDrop)
    PM.mainFrame:AddChild(PM.loadProfileButton)
    PM.mainFrame:AddChild(PM.deleteFileButton)
    PM.mainFrame:AddChild(PM.saveProfileName)
    PM.mainFrame:AddChild(PM.saveProfileButton)

    PM.treeView = runner.AceGUI:Create("TreeGroup")
    PM.treeView:SetLayout("Fill")
    PM.treeView:SetFullWidth(true)
    PM.treeView:SetFullHeight(true)

    PM.inlineFrame = runner.AceGUI:Create("InlineGroup")
    PM.inlineFrame:SetLayout("Flow")
    PM.inlineFrame:SetFullWidth(true)
    PM.inlineFrame:SetFullHeight(true)
    PM.treeView:AddChild(PM.inlineFrame)

    PM.scrollFrame = runner.AceGUI:Create("ScrollFrame")
    PM.scrollFrame:SetLayout("Flow")
    PM.scrollFrame:SetFullWidth(true)
    PM.scrollFrame:SetFullHeight(true)
    PM.inlineFrame:AddChild(PM.scrollFrame)

    PM.treeView:SetCallback("OnGroupSelected", function(widget, event, group)
        local split =  {strsplit("\001", group)}
        local selected = PM:GetBehaviorByIndex(split[2])
        if selected then
            PM.scrollFrame:ReleaseChildren()
            selected:BuildStepGUI(PM.scrollFrame)
        end
    end)
    PM.mainFrame:AddChild(PM.treeView)
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
    PM.BuilderFrame:AddChild(PM.openProfileViewerButton)
end

function PM:RebuildMiniProfileMaker(type)
    PM:BuildTreeFromProfile()
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
        b = v()
        if b.MiniTypes then
            for k2,v2 in pairs(b.MiniTypes) do
                if v2 == PM.profileType then
                    local but = runner.AceGUI:Create("Button")
                    but:SetText(b.Name)
                    but:SetWidth(150)
                    but:SetCallback("OnClick", function()
                        local newbehavior = v()
                        newbehavior:Setup()
                        table.insert(PM.profile, newbehavior)
                        PM:BuildTreeFromProfile()
                    end)
                    PM.BuilderFrame:AddChild(but)
                end
            end
        end
    end

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
    PM.BuilderFrame:AddChild(PM.openProfileViewerButton)
end