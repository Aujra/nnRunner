runner.UI.ObjectViewer2 = {}
local OV = runner.UI.ObjectViewer2
runner.UI.ObjectViewer2 = OV

OV.SelectedPointer = nil
local inlineGroup = nil
local ScrollFrame = nil
local sortKey = "Distance"

local mainFrame = runner.nn.Utils.AceGUI:Create("Window", "ObjectViewerFrame", UIParent)
mainFrame:SetTitle("Object Manager")
mainFrame:SetLayout("Flow")
mainFrame:SetWidth(1000)
mainFrame:SetHeight(800)
mainFrame:Show()

local sortDropdown = runner.nn.Utils.AceGUI:Create("Dropdown")
sortDropdown:SetList({
    ["Distance"] = "Distance",
    ["Name"] = "Name",
    ["Reaction"] = "Reaction"
})
sortDropdown:SetValue("Distance")
sortDropdown:SetCallback("OnValueChanged", function(_, _, key)
    sortKey = key
    OV:Update()
end)
mainFrame:AddChild(sortDropdown)

local tree = runner.nn.Utils.AceGUI:Create("TreeGroup")
tree:SetLayout("Fill")
tree:SetFullWidth(true)
tree:SetFullHeight(700)
tree:SetTree(
    {
        {
            value = "Objects",
            text = "Objects",
            children = {
                { value = "Objects", text = "Objects" },
                { value = "Players", text = "Players" },
                { value = "Units", text = "Units" },
                { value = "Area Triggers", text = "Area Triggers" }
            }
        }
    }
)
tree:SetCallback("OnGroupSelected", function(container, _, group)
    tree:ReleaseChildren()
    inlineGroup = runner.nn.Utils.AceGUI:Create("InlineGroup")
    inlineGroup:SetFullWidth(true)
    inlineGroup:SetFullHeight(true)
    inlineGroup:SetLayout("Fill")
    tree:AddChild(inlineGroup)

    ScrollFrame = runner.nn.Utils.AceGUI:Create("ScrollFrame")
    ScrollFrame:SetLayout("Flow")
    ScrollFrame:SetFullWidth(true)
    ScrollFrame:SetFullHeight(true)
    inlineGroup:AddChild(ScrollFrame)

    OV.ScrollFrame = ScrollFrame

    OV:BuildObjectList(ScrollFrame, group)
end)
mainFrame:AddChild(tree)

function OV:SortBy(originalTable, key)
    local tempUnits = {}
    local hasKey = false
    for k,v in pairs(originalTable) do
        if v[key] ~= nil then
            hasKey = true
        end
        table.insert(tempUnits, v)
    end
    if hasKey then
        table.sort(tempUnits, function(a,b) return a[key] < b[key] end)
    end
    return tempUnits
end

function OV:Update()
    local gameobjectData, unitData, playerData, areaTriggerData = {}, {}, {}, {}
    local green, red, blue, yellow = "|cff00ff00", "|cffff0000", "|cff0000ff", "|cffffff00"

    for k,v in pairs(OV:SortBy(runner.Engine.ObjectManager.gameobjects, sortKey)) do
        table.insert(gameobjectData, {
            value = v.pointer,
            text = v.Name
        })
    end
    for k,v in pairs(OV:SortBy(runner.Engine.ObjectManager.units, sortKey)) do
        if v.Reaction < 4 then
            textColor = red
        elseif v.Reaction == 4 then
            textColor = yellow
        else
            textColor = green
        end
        table.insert(unitData, {
            value = v.pointer,
            text = textColor .. v.Name
        })
    end
    for k,v in pairs(runner.Engine.ObjectManager.players) do
        table.insert(playerData, {
            value = v.pointer,
            text = textColor .. v.Name
        })
    end
    table.insert(playerData, {
        value = "player",
        text = green .. "Local Player"
    })

    for k,v in pairs(runner.Engine.ObjectManager.areatrigger) do
        table.insert(areaTriggerData, {
            value = v.pointer,
            text = v.Name
        })
    end

    local target = UnitTarget("player") or "no"

    local treeData = {
        {
            value = "Target",
            text = "Target",
            icon = "Interface\\Icons\\INV_Misc_QuestionMark",
            children = {
                { value = target, text = "Your Target" }
            }
        },
        {
            value = "GameObjects",
            text = "GameObjects",
            icon = "Interface\\Icons\\INV_Drink_05",
            children = gameobjectData
        },
        {
            value = "Units",
            text = "Units",
            children = unitData
        },
        {
            value = "Players",
            text = "Players",
            children = playerData
        },
        {
            value = "AreaTriggers",
            text = "AreaTriggers",
            children = areaTriggerData
        }
    }
    tree:SetTree(treeData)

    if OV.SelectedPointer then
        OV:BuildObjectList(OV.ScrollFrame, nil, OV.SelectedPointer)
    end
end

function OV:BuildObjectList(container, selected, SelectedPointer)
    if selected ~= nil then
        local split = {strsplit("\001", selected)}
        local pointer = split[2]
        OV.SelectedPointer = pointer
    else
        pointer = SelectedPointer
    end
    local object = runner.Engine.ObjectManager:GetByPointer(pointer)
    if pointer == "player" then
        object = runner.LocalPlayer
    end
    if not object then
        return
    end
    container:ReleaseChildren()
    object:Debug()

    for k,v in pairs(object._) do
        if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
            local label = runner.nn.Utils.AceGUI:Create("Label")
            label:SetText(k .. ": " .. tostring(v))
            container:AddChild(label)
        end
    end
end

function OV:Toggle()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end