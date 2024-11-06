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

local selectedNode = nil

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

function DungeonProfileMaker:GetStepByIndex(index)
    print("Looking for index " .. index)
    for k,v in pairs(profileSteps) do
        if v.index == index then
            print("Found step " .. v.Name)
            return v.step
        end
    end
end

local addBehaviorButton = runner.AceGUI:Create("Button")
addBehaviorButton:SetText("Add Behavior")
addBehaviorButton:SetWidth(200)
addBehaviorButton:SetCallback("OnClick", function()
    if selectedBehavior == nil then
        return
    end

    local behavior = runner.behaviors[selectedBehavior:lower()]()
    behavior.Children = {}

    if selectedNode == nil or tonumber(selectedNode) < 0 then
        if behavior.CanHaveChildren then
            table.insert(treeSteps, {value = #treeSteps, text = behavior.Name, children = {}})
            table.insert(profileSteps, {index = #profileSteps, step = behavior})
        else
            table.insert(treeSteps, {value = #treeSteps, text = behavior.Name})
            table.insert(profileSteps, {index = #profileSteps, step = behavior})
        end
    else
        local split = {strsplit("_", selectedNode)}
        local index = tonumber(split[1])
        local ifbehavior = DungeonProfileMaker:GetStepByIndex(index)
        if ifbehavior.CanHaveChildren then
            table.insert(ifbehavior.Step.children, behavior)
            table.insert(treeSteps[index+1].children, {index = #ifbehavior.Step.children ,value = #ifbehavior.Step.children, text = behavior.Name})
            profileSteps[index+1] = {index = index, step = ifbehavior}
        else
            print("Cannot add child to non-IfBehavior")
        end
    end
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
        local childrenSteps = {}
        if v.step.CanHaveChildren then
            for k2,v2 in pairs(v.step.Step.children) do
                table.insert(childrenSteps, {
                    Name = v2.Name,
                    Step = v2.Step,
                    Index = #childrenSteps
                })
            end
        end
        local thestep = v.step.Step
        if tableCount(childrenSteps) > 0 then
            thestep.children = childrenSteps
        else
            thestep.children = nil
        end

        table.insert(saveSteps, {
            Name = v.step.Name,
            Step = thestep
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
        local treeChildren = {}
        local childSteps = {}
        local behavior = runner.behaviors[v.Name:lower()]()
        _G.behave = behavior
        if v.Step.children then
            for k2,v2 in pairs(v.Step.children) do
                local childBehavior = runner.behaviors[v2.Name:lower()]()
                _G.be = childBehavior
                childBehavior.Step = v2.Step
                table.insert(childSteps, childBehavior)
                table.insert(treeChildren, {value = #treeChildren, text = v2.Name})
            end
        end
        behavior.Step = v.Step
        behavior.Step.children = childSteps
        table.insert(profileSteps, {index = #profileSteps, step = behavior})
        if tableCount(childSteps) > 0 then
            table.insert(treeSteps, {value = #treeSteps, text = v.Name, children = treeChildren})
        else
            table.insert(treeSteps, {value = #treeSteps, text = v.Name})
        end
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
    if group == "Profile" then
        DungeonProfileMaker:MakeBaseGUI(ScrollFrame)
    else
        DungeonProfileMaker:BuildStepGUI(ScrollFrame, group)
    end

    local split = {strsplit("\001", group)}
    local fullnode = split[2]
    local index = fullnode
    if split[3] then
        index = index .. "_" .. split[3]
    end
    selectedNode = index
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
    descriptionEditBox:SetText(profileDescription or "")
    descriptionEditBox:SetCallback("OnTextChanged", function(widget, event, value)
        profileDescription = value
    end)
    container:AddChild(descriptionEditBox)
end

function DungeonProfileMaker:BuildStepGUI(container, key)
    container:ReleaseChildren()
    local split = {strsplit("\001", key)}

    local behavior = DungeonProfileMaker:GetStepByIndex(tonumber(split[2]))

    if split[3] then
        behavior = self:GetStepChildByIndex(tonumber(split[2]), tonumber(split[3]))
    end
    _G.hi = behavior
    behavior:BuildStepGUI(container)
end

function DungeonProfileMaker:GetStepByIndex(index)
    for k,v in pairs(profileSteps) do
        if v.index == index then
            return v.step
        end
    end
end

function DungeonProfileMaker:GetStepChildByIndex(pindex, cindex)
    local parent = DungeonProfileMaker:GetStepByIndex(pindex)
    return parent.Step.children[cindex+1]
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