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
PM.selectedBehavior = nil
PM.selectedProfile = nil
PM.selectedGroup = nil

PM.profileName = nil
PM.profileDescription = nil
PM.profileID = nil
PM.profileLootMode = nil
PM.profilePullMode = nil
PM.profileWanderRange = nil

_G.theprofile = PM.profile

PM.profileType = "Dungeon"

function PM:GetProfiles(folder)
    local path = "/scripts/mainrunner/Profiles/"..folder.."/*.json"
    local files = runner.nn.ListFiles(path)
    local foundProfiles = {}
    if files then
        for k,v in pairs(files) do
            table.insert(foundProfiles, v)
        end
    end
    return foundProfiles
end

function PM:RecursiveProfileBuilder(data)
    local profile = {}
    for k,v in pairs(data) do
        local behavior = runner.behaviors[v.Name:lower()]:new()
        if not behavior.CanHaveChildren then
            table.insert(profile, {
                value = tableCount(profile)+1,
                text = v.Name,
            })
        else
            table.insert(profile, {
                value = tableCount(profile)+1,
                text = v.Name,
                children = PM:RecursiveProfileBuilder(v.Step.children or {})
            })
        end
    end
    return profile
end

function PM:BuildTreeFromProfile()
    local tree = {}
    tree = PM:RecursiveProfileBuilder(PM.profile)
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
    PM.mainFrame:SetCallback("OnClose", function(widget) PM.mainFrame:Hide() end)
    PM.ProfileDrop = runner.AceGUI:Create("Dropdown")
    PM.ProfileDrop:SetLabel("Profile")
    PM.ProfileDrop:SetWidth(200)
    PM.ProfileDrop:SetCallback("OnValueChanged", function(widget, event, value)
        PM.selectedProfile = value
    end)
    local profiles = PM:GetProfiles("Dungeons")
    PM.ProfileDrop:AddItem("DUNGEONS", "DUNGEONS")
    for k,v in pairs(profiles) do
        PM.ProfileDrop:AddItem("Dungeons/"..v, "Dungeons/"..v)
    end
    local profiles = PM:GetProfiles("ProfileRunner")
    PM.ProfileDrop:AddItem("PROFILES", "PROFILES")
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
        local path = "/scripts/mainrunner/Profiles/" .. PM.selectedProfile
        local data = runner.nn.ReadFile(path)
        local decoded = runner.nn.Utils.JSON.decode(data)
        PM.profile = {}
        PM.profileName = decoded.Name
        PM.profileDescription = decoded.Description
        PM.profileID = decoded.ID
        PM.profileLootMode = decoded.LootMode
        PM.profilePullMode = decoded.PullMode
        PM.profileWanderRange = decoded.WanderRange

        for k,v in pairs(decoded.Steps) do
            local behavior = runner.behaviors[v.Name:lower()]:new()
            behavior:Load(v)
            table.insert(PM.profile, behavior)
        end
        PM:BuildTreeFromProfile()
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
        local path = "/scripts/mainrunner/Profiles/" .. PM.saveProfileName:GetText() .. ".json"
        local data = {}
        data.Name = PM.profileName
        data.Description = PM.profileDescription
        data.ID = PM.profileID
        data.LootMode = PM.profileLootMode
        data.PullMode = PM.profilePullMode
        data.WanderRange = PM.profileWanderRange

        data.Steps = {}
        for k,v in pairs(PM.profile) do
            table.insert(data.Steps, v:Save())
        end
        data = runner.nn.Utils.JSON.encode(data)
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
        PM.selectedGroup = split

        PM.selectedBehavior = PM:GetBehaviorBySplit()

        if PM.selectedBehavior then
            PM.scrollFrame:ReleaseChildren()
            PM.selectedBehavior:BuildStepGUI(PM.scrollFrame)
        elseif group:lower() == "root" then
            PM.scrollFrame:ReleaseChildren()
            PM:MakeBaseGUI(PM.scrollFrame)
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
    PM.profileTypeDropdown:AddItem("Control", "Control")
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


function PM:GetBehaviorBySplit()
    if PM.selectedGroup and type(PM.selectedGroup) ~= "table" then
        split = {strsplit("\001", PM.selectedGroup)}
    end
    if not PM.selectedGroup then
        return nil
    end
    local behavior = nil
    for k,v in pairs(PM.selectedGroup) do
        if k == 2 then
            behavior = PM:GetBehaviorByIndex(v)
        end
        if k > 2 then
            behavior = behavior.Step.children[tonumber(v)]
        end
    end
    return behavior
end

function PM:BuildRootNode()

end

function PM:MakeBaseGUI(container)
    container:ReleaseChildren()
    local nameEditBox = runner.AceGUI:Create("EditBox")
    nameEditBox:SetLabel("Name")
    nameEditBox:SetWidth(200)
    nameEditBox:SetText(PM.profileName)
    nameEditBox:SetCallback("OnTextChanged", function(widget, event, value)
        PM.profileName = value
    end)
    container:AddChild(nameEditBox)

    local dungeonIDEditBox = runner.AceGUI:Create("EditBox")
    dungeonIDEditBox:SetLabel("Dungeon ID")
    dungeonIDEditBox:SetWidth(200)
    dungeonIDEditBox:SetText(PM.profileID)
    dungeonIDEditBox:SetCallback("OnTextChanged", function(widget, event, value)
        PM.profileID = value
    end)
    container:AddChild(dungeonIDEditBox)

    local lootModeDropdown = runner.AceGUI:Create("Dropdown")
    lootModeDropdown:SetLabel("Loot Mode")
    lootModeDropdown:SetWidth(200)
    lootModeDropdown:AddItem("None", "None")
    lootModeDropdown:AddItem("BossOnly", "BossOnly")
    lootModeDropdown:AddItem("All", "All")
    lootModeDropdown:SetValue(PM.profileLootMode)
    lootModeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        PM.profileLootMode = value
    end)
    container:AddChild(lootModeDropdown)

    local pullModeDropdown = runner.AceGUI:Create("Dropdown")
    pullModeDropdown:SetLabel("Pull Mode")
    pullModeDropdown:SetWidth(200)
    pullModeDropdown:AddItem("Facepull", "Facepull")
    pullModeDropdown:AddItem("Active", "Active")
    pullModeDropdown:SetValue(PM.profilePullMode)
    pullModeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        PM.profilePullMode = value
    end)
    container:AddChild(pullModeDropdown)

    local wanderRange = runner.AceGUI:Create("EditBox")
    wanderRange:SetLabel("Wander Range")
    wanderRange:SetWidth(200)
    wanderRange:SetText(PM.profileWanderRange)
    wanderRange:SetCallback("OnTextChanged", function(widget, event, value)
        PM.profileWanderRange = value
    end)
    container:AddChild(wanderRange)

    local descriptionEditBox = runner.AceGUI:Create("MultiLineEditBox")
    descriptionEditBox:SetLabel("Description")
    descriptionEditBox:SetFullWidth(true)
    descriptionEditBox:SetText(PM.profileDescription or "")
    descriptionEditBox:SetCallback("OnTextChanged", function(widget, event, value)
        PM.profileDescription = value
    end)
    container:AddChild(descriptionEditBox)
end

function PM:RebuildMiniProfileMaker(type)
    PM:GetBehaviorBySplit()
    PM:BuildTreeFromProfile()
    PM.BuilderFrame:ReleaseChildren()
    PM.profileTypeDropdown = runner.AceGUI:Create("Dropdown")
    PM.profileTypeDropdown:SetLabel("Profile Type")
    PM.profileTypeDropdown:SetWidth(150)
    PM.profileTypeDropdown:AddItem("Dungeon", "Dungeon")
    PM.profileTypeDropdown:AddItem("Quest", "Quest")
    PM.profileTypeDropdown:AddItem("Grind", "Grind")
    PM.profileTypeDropdown:AddItem("Control", "Control")
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
                        if PM.selectedBehavior then
                            table.insert(PM.selectedBehavior.Step.children, newbehavior)
                        else
                            table.insert(PM.profile, newbehavior)
                        end
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

    PM.setDungeonButton = runner.AceGUI:Create("Button")
    PM.setDungeonButton:SetText("Set Dungeon")
    PM.setDungeonButton:SetWidth(150)
    PM.setDungeonButton:SetCallback("OnClick", function(widget)
        PM.profileType = "Dungeon"
        PM:BuildRootNode()
    end)

    PM.BuilderFrame:AddChild(PM.setDungeonButton)
    PM.BuilderFrame:AddChild(PM.openProfileViewerButton)
end

function PM:Toggle()
    if not PM.BuilderFrame:IsShown() then
        PM.BuilderFrame:Show()
    else
        PM.BuilderFrame:Hide()
    end
end