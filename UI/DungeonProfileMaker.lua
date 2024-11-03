runner.UI.DungeonProfileMaker = {}
local DungeonProfileMaker = runner.UI.DungeonProfileMaker
runner.UI.DungeonProfileMaker = DungeonProfileMaker

local inlineGroup = nil
local ScrollFrame = nil

local selectedBehavior = nil
local profileSteps = {}
local treeSteps = {}
local profileToLoad = nil

local mainFrame = runner.AceGUI:Create("Window")
mainFrame:SetTitle("Dungeon Profile Maker")
mainFrame:SetLayout("Flow")
mainFrame:SetWidth(1000)
mainFrame:SetHeight(800)
mainFrame:Show()

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
    for k,v in pairs(profileSteps) do
        table.insert(saveTable, {
            Name = v.step.Name,
            Step = v.step.Step
        })
    end
    local json = runner.nn.Utils.JSON.encode(saveTable)
    local name = saveProfileName:GetText()
    runner.nn.WriteFile("/scripts/mainrunner/Profiles/DungeonsNew/" .. name .. ".json", json)
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
    for k,v in pairs(profile) do
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
    DungeonProfileMaker:BuildStepGUI(ScrollFrame, group)
end)

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