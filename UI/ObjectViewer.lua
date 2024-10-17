local ScrollingTable = LibStub("ScrollingTable");

runner.UI.ObjectViewer = {}
local OV = runner.UI.ObjectViewer
runner.UI.ObjectViewer = OV

local viewerFrame = nil
local ScrollTable = nil
local searchInput = nil
local cols = {}
local data = {}
local searchStr = ""
local mode = "objects"

function OV:AddColumn(name)
    local column = {
        ["name"] = name,
        ["width"] = 100,
        ["align"] = "LEFT",
        ["color"] = {
            ["r"] = 1.0,
            ["g"] = 1.0,
            ["b"] = 1.0,
            ["a"] = 1.0
        },
        ["colorargs"] = nil,
        ["bgcolor"] = {
            ["r"] = 0.0,
            ["g"] = 0.0,
            ["b"] = 0.0,
            ["a"] = 1.0
        },
        ["DoCellUpdate"] = nil,
    }
    table.insert(cols, column)
end

function OV:SelectGroup(group)
    if group == "objects" then
        OV.mode = "objects"
    end
    if group == "players" then
        OV.mode = "players"
    end
    if group == "units" then
        OV.mode = "units"
    end
    if group == "areatriggers" then
        OV.mode = "areatriggers"
    end
    local str = string.gsub(" "..OV.mode, "%W%l", string.upper):sub(2)
    viewerFrame:SetTitle("Object Manager - " .. str)
end


function OV:Update()
    if not viewerFrame then
        viewerFrame = runner.nn.Utils.AceGUI:Create("Window", "ObjectViewerFrame", UIParent)
        viewerFrame:SetTitle("Unit Viewer")
        viewerFrame:SetLayout("Flow")
        viewerFrame:SetWidth(1024)
        viewerFrame:SetHeight(600)
        viewerFrame:Show()
        if not SearchInput then
            SearchInput = runner.nn.Utils.AceGUI:Create("EditBox")
            SearchInput:SetLabel("Search")
            SearchInput:SetWidth(200)
            SearchInput:SetCallback("OnEnterPressed", function(widget, event, text)
                searchStr = text
                self:Update()
                print("SearchStr: " .. searchStr)
            end)
            viewerFrame:AddChild(SearchInput)
        end

        local objectbutton = runner.nn.Utils.AceGUI:Create("Button")
        objectbutton:SetText("Objects")
        objectbutton:SetWidth(100)
        objectbutton:SetCallback("OnClick", function() self:SelectGroup("objects") end)
        viewerFrame:AddChild(objectbutton)

        local playerbutton = runner.nn.Utils.AceGUI:Create("Button")
        playerbutton:SetText("Players")
        playerbutton:SetWidth(100)
        playerbutton:SetCallback("OnClick", function() self:SelectGroup("players") end)
        viewerFrame:AddChild(playerbutton)

        local unitsbutton = runner.nn.Utils.AceGUI:Create("Button")
        unitsbutton:SetText("Units")
        unitsbutton:SetWidth(100)
        unitsbutton:SetCallback("OnClick", function() self:SelectGroup("units") end)
        viewerFrame:AddChild(unitsbutton)

        local triggers = runner.nn.Utils.AceGUI:Create("Button")
        triggers:SetText("Areatriggers")
        triggers:SetWidth(100)
        triggers:SetCallback("OnClick", function() self:SelectGroup("areatriggers") end)
        viewerFrame:AddChild(triggers)

    end

    self:AddColumn("Name")
    self:AddColumn("Pointer")

    data = {}

    if OV.mode == "objects" then
        for k,v in pairs (runner.Engine.ObjectManager.gameobjects) do
            local row = {
                v.Name,
                v.pointer
            }
            table.insert(data, row)
        end
    end
    if OV.mode == "units" then
        for k,v in pairs (runner.Engine.ObjectManager.units) do
            local row = {
                v.Name,
                v.pointer
            }
            table.insert(data, row)
        end
    end

    if not ScrollTable then
        ScrollTable = ScrollingTable:CreateST(cols, nil, nil, nil, viewerFrame.frame);
        ScrollTable:SetFilter(function(self, row)
            if searchStr == "" then
                return true
            else
                for k,v in pairs(row) do
                    if string.find(tostring(v):lower(), searchStr:lower(), 1, true) then
                        return true
                    end
                end
                return false
            end
        end)
    end
    ScrollTable:SetData(data, true)
end