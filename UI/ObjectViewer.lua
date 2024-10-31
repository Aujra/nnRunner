local ScrollingTable = runner.nn.Utils.LibStub("ScrollingTable");

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
local rebuild = false

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

function OV:ShouldUpdate()
    if not viewerFrame then
        self:Update()
    end
    return viewerFrame:IsVisible()
end

function OV:SelectGroup(group)
    cols = {}
    if group == "objects" then
        OV.mode = "objects"
        for k,v in pairs(runner.GameObjectViewColumns) do
            self:AddColumn(v)
        end
        ScrollTable:SetDisplayCols(cols)
    end
    if group == "players" then
        OV.mode = "players"
        for k,v in pairs(runner.PlayerViewColumns) do
            self:AddColumn(v)
        end
        ScrollTable:SetDisplayCols(cols)
    end
    if group == "units" then
        OV.mode = "units"
        for k,v in pairs(runner.UnitViewColumns) do
            self:AddColumn(v)
        end
        ScrollTable:SetDisplayCols(cols)
    end
    if group == "areatriggers" then
        OV.mode = "areatriggers"
        for k,v in pairs(runner.AreaTriggerViewColumns) do
            self:AddColumn(v)
        end
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

    data = {}

    if OV.mode == "objects" then
        for k,v in pairs (runner.Engine.ObjectManager.gameobjects) do
            table.insert(data, v:ToViewerRow())
        end
    end
    if OV.mode == "units" then
        for k,v in pairs (runner.Engine.ObjectManager.units) do
            table.insert(data, v:ToViewerRow())
        end
    end
    if OV.mode == "players" then
        for k,v in pairs (runner.Engine.ObjectManager.players) do
            table.insert(data, v:ToViewerRow())
        end
    end
    if OV.mode == "areatriggers" then
        for k,v in pairs (runner.Engine.ObjectManager.areatrigger) do
            table.insert(data, v:ToViewerRow())
        end
    end

    if not ScrollTable then
        ScrollTable = ScrollingTable:CreateST(cols, nil, nil, nil, viewerFrame.frame);
        ScrollTable.frame:SetPoint("LEFT", viewerFrame.frame, "LEFT", 50, 100)
        ScrollTable:SetHeight(700)
        ScrollTable:SetWidth(900)
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

function OV:Toggle()
    if viewerFrame:IsVisible() then
        viewerFrame:Hide()
    else
        viewerFrame:Show()
    end
end