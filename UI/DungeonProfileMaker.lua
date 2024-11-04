runner.UI.DungeonProfileMaker = {}
local DungeonProfileMaker = runner.UI.DungeonProfileMaker
runner.UI.DungeonProfileMaker = DungeonProfileMaker

local inlineGroup = nil
local ScrollFrame = nil

local selectedBehavior = nil
local profileSteps = {}
local treeSteps = {}
local profileToLoad = nil

local profileName = nil
local profileDescription = nil
local profileID = nil
local profileLootMode = nil
local profilePullMode = nil
local profileWanderRange = nil

local mainFrame = runner.AceGUI:Create("Window")
mainFrame:SetTitle("Dungeon Profile Maker")
mainFrame:SetLayout("Flow")
mainFrame:SetWidth(1000)
mainFrame:SetHeight(800)
mainFrame:Hide()

function DungeonProfileMaker:ShowGUI()
    mainFrame:Show()
end
function DungeonProfileMaker:HideGUI()
    mainFrame:Hide()
end

local behaviorDropdown = runner.AceGUI:Create("Dropdown")
for k,v in pairs(runner.behaviors) do
    behaviorDropdown:AddItem(
        k,k
    )
end
behaviorDropdown:SetLabel("Behavior")
behaviorDropdown:SetWidth(200)
behaviorDropdown:SetCallback("OnValueChanged", function(widget, event, value)
    selectedBehavior = value
end)
mainFrame:AddChild(behaviorDropdown)

local addBehaviorButton = runner.AceGUI:Create("Button")
addBehaviorButton:SetText("Add Behavior")
addBehaviorButton:SetWidth(200)
addBehaviorButton:SetCallback("OnClick", function()
    if selectedBehavior == nil then
        return
    end
    local behavior = runner.behaviors[selectedBehavior:lower()]()
    table.insert(profileSteps, {index = #profileSteps, step = behavior})
    table.insert(treeSteps, {value = #treeSteps, text = behavior.Name})
    DungeonProfileMaker:BuildProfileTree()
end)
mainFrame:AddChild(addBehaviorButton)

local saveProfileName = runner.AceGUI:Create("EditBox")
saveProfileName:SetLabel("Save Profile Name")
saveProfileName:SetWidth(200)
mainFrame:AddChild(saveProfileName)

local saveProfileButton = runner.AceGUI:Create("Button")
saveProfileButton:SetText("Save Profile")
saveProfileButton:SetWidth(200)
saveProfileButton:SetCallback("OnClick", function()
    local saveTable = {}
    local saveSteps = {}
    saveTable.Name = profileName
    saveTable.Description = profileDescription
    saveTable.DungeonID = profileID
    saveTable.LootMode = profileLootMode
    saveTable.PullMode = profilePullMode
    saveTable.WanderRange = profileWanderRange

    for k,v in pairs(profileSteps) do
        table.insert(saveSteps, {
            Name = v.step.Name,
            Step = v.step.Step
        })
    end
    saveTable.Steps = saveSteps
    local json = runner.nn.Utils.JSON.encode(saveTable)
    local name = saveProfileName:GetText()
    runner.nn.WriteFile("/scripts/mainrunner/Profiles/DungeonsNew/" .. name .. ".json", json)
    DungeonProfileMaker:RefreshProfiles()
end)
mainFrame:AddChild(saveProfileButton)

local loadProfileDropdown = runner.AceGUI:Create("Dropdown")
local path = "/scripts/mainrunner/Profiles/DungeonsNew/*.json"
local files = runner.nn.ListFiles(path)
for k,v in pairs(files) do
    loadProfileDropdown:AddItem(
        v,v
    )
end
loadProfileDropdown:SetLabel("Load Profile")
loadProfileDropdown:SetWidth(200)
loadProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value)
    profileToLoad = value
end)

mainFrame:AddChild(loadProfileDropdown)

local loadProfileButton = runner.AceGUI:Create("Button")
loadProfileButton:SetText("Load Profile")
loadProfileButton:SetWidth(200)
loadProfileButton:SetCallback("OnClick", function()
    local json = runner.nn.ReadFile("/scripts/mainrunner/Profiles/DungeonsNew/"..profileToLoad)
    local profile = runner.nn.Utils.JSON.decode(json)
    profileSteps = {}
    treeSteps = {}
    profileName = profile.Name
    profileDescription = profile.Description
    profileID = profile.DungeonID
    profileLootMode = profile.LootMode
    profilePullMode = profile.PullMode
    profileWanderRange = profile.WanderRange

    for k,v in pairs(profile.Steps) do
        local behavior = runner.behaviors[v.Name:lower()]()
        behavior.Step = v.Step
        table.insert(profileSteps, {index = #profileSteps, step = behavior})
        table.insert(treeSteps, {value = #treeSteps, text = v.Name})
    end
    DungeonProfileMaker:BuildProfileTree()
end)
mainFrame:AddChild(loadProfileButton)

local profileTree = runner.AceGUI:Create("TreeGroup")
profileTree:SetLayout("Fill")
profileTree:SetFullWidth(true)
profileTree:SetFullHeight(true)
mainFrame:AddChild(profileTree)

profileTree:SetCallback("OnGroupSelected", function(container, _, group)
    profileTree:ReleaseChildren()
    inlineGroup = runner.AceGUI:Create("InlineGroup")
    inlineGroup:SetFullWidth(true)
    inlineGroup:SetFullHeight(true)
    inlineGroup:SetLayout("Fill")
    profileTree:AddChild(inlineGroup)
    ScrollFrame = runner.AceGUI:Create("ScrollFrame")
    ScrollFrame:SetLayout("Flow")
    ScrollFrame:SetFullWidth(true)
    ScrollFrame:SetFullHeight(true)
    inlineGroup:AddChild(ScrollFrame)
    print(tostring(group == "Profile"))
    if group == "Profile" then
        DungeonProfileMaker:MakeBaseGUI(ScrollFrame)
    else
        DungeonProfileMaker:BuildStepGUI(ScrollFrame, group)
    end
end)

function DungeonProfileMaker:MakeBaseGUI(container)
    container:ReleaseChildren()
    local nameEditBox = runner.AceGUI:Create("EditBox")
    nameEditBox:SetLabel("Name")
    nameEditBox:SetWidth(200)
    nameEditBox:SetText(profileName)
    nameEditBox:SetCallback("OnTextChanged", function(widget, event, value)
        profileName = value
    end)
    container:AddChild(nameEditBox)

    local dungeonIDEditBox = runner.AceGUI:Create("EditBox")
    dungeonIDEditBox:SetLabel("Dungeon ID")
    dungeonIDEditBox:SetWidth(200)
    dungeonIDEditBox:SetText(profileID)
    dungeonIDEditBox:SetCallback("OnTextChanged", function(widget, event, value)
        profileID = value
    end)
    container:AddChild(dungeonIDEditBox)

    local lootModeDropdown = runner.AceGUI:Create("Dropdown")
    lootModeDropdown:SetLabel("Loot Mode")
    lootModeDropdown:SetWidth(200)
    lootModeDropdown:AddItem("None", "None")
    lootModeDropdown:AddItem("BossOnly", "BossOnly")
    lootModeDropdown:AddItem("All", "All")
    lootModeDropdown:SetValue(profileLootMode)
    lootModeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        profileLootMode = value
    end)
    container:AddChild(lootModeDropdown)

    local pullModeDropdown = runner.AceGUI:Create("Dropdown")
    pullModeDropdown:SetLabel("Pull Mode")
    pullModeDropdown:SetWidth(200)
    pullModeDropdown:AddItem("Facepull", "Facepull")
    pullModeDropdown:AddItem("Active", "Active")
    pullModeDropdown:SetValue(profilePullMode)
    pullModeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        profilePullMode = value
    end)
    container:AddChild(pullModeDropdown)

    local wanderRange = runner.AceGUI:Create("EditBox")
    wanderRange:SetLabel("Wander Range")
    wanderRange:SetWidth(200)
    wanderRange:SetText(profileWanderRange)
    wanderRange:SetCallback("OnTextChanged", function(widget, event, value)
        profileWanderRange = value
    end)
    container:AddChild(wanderRange)

    local descriptionEditBox = runner.AceGUI:Create("MultiLineEditBox")
    descriptionEditBox:SetLabel("Description")
    descriptionEditBox:SetFullWidth(true)
    descriptionEditBox:SetText(profileDescription)
    descriptionEditBox:SetCallback("OnTextChanged", function(widget, event, value)
        profileDescription = value
    end)
    container:AddChild(descriptionEditBox)
end

function DungeonProfileMaker:BuildStepGUI(container, key)
    container:ReleaseChildren()
    local split = {strsplit("\001", key)}
    local behavior = DungeonProfileMaker:GetStepByIndex(tonumber(split[#split]))
    behavior:BuildStepGUI(container)
end

function DungeonProfileMaker:GetStepByIndex(index)
    for k,v in pairs(profileSteps) do
        if v.index == index then
            return v.step
        end
    end
end

function DungeonProfileMaker:BuildProfileTree()
    profileTree:SetTree(
        {
            {
                value = "Profile",
                text = "Profile",
                children = treeSteps
            }
        }
    )
end

function DungeonProfileMaker:RefreshProfiles()
    local path = "/scripts/mainrunner/Profiles/DungeonsNew/*.json"
    local files = runner.nn.ListFiles(path)
    loadProfileDropdown:SetList({})
    for k,v in pairs(files) do
        loadProfileDropdown:AddItem(
            v,v
        )
    end
end

function DungeonProfileMaker:Toggle()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end