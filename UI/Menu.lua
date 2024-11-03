local menuFrame = runner.UI.menuFrame
runner.UI.menuFrame = menuFrame
local isMoving = false
local mainFrame = nil

function menuFrame:UpdateMenu()
    if not mainFrame then
        mainFrame = CreateFrame("Frame", "MenuFrame", UIParent, "BackdropTemplate")
        mainFrame:SetMovable(true)
        mainFrame:EnableMouse(true)
        mainFrame:SetResizable(true)
        mainFrame:SetWidth(UIParent:GetWidth()/2)
        mainFrame:SetHeight(30)
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0,150)
        mainFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                               edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                               tile = true, tileSize = 16, edgeSize = 16,
                               insets = { left = 4, right = 4, top = 4, bottom = 4 }});
        mainFrame:SetBackdropColor(0,0,0,1);

        mainFrame:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and not self.isMoving then
                self:StartMoving();
                self.isMoving = true;
            end
        end)
        mainFrame:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
            end
        end)

        local br = CreateFrame("Button", nil, mainFrame)
        br:EnableMouse("true")
        br:SetPoint("BOTTOMRIGHT")
        br:SetSize(16,16)
        br:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        br:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        br:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        br:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:GetParent():StartSizing("BOTTOMRIGHT")
            end
        end)
        br:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                self:GetParent():StopMovingOrSizing("BOTTOMRIGHT")
            end
        end)
        mainFrame:Show()

        -- Pause button
        local pauseButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        pauseButton:SetSize(79, 30)
        pauseButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
        pauseButton:SetText("Pause")
        pauseButton:SetScript("OnClick", function()
            runner.running = not runner.running
            if runner.running then
                pauseButton:SetText("Pause")
            else
                pauseButton:SetText("Resume")
            end
        end)
        pauseButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Toggle Runner")
            GameTooltip:Show()
        end)
        pauseButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- Mark waypoint button
        local markWaypoint = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        markWaypoint:SetSize(30, 30)
        markWaypoint:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 500, 0)
        markWaypoint:SetNormalTexture("Interface/ICONS/INV_Misc_Map_01")
        markWaypoint:SetScript("OnClick", function()
            table.insert(runner.waypoints, {x = runner.LocalPlayer.x, y = runner.LocalPlayer.y, z = runner.LocalPlayer.z})
        end)
        markWaypoint:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Mark Current Position")
            GameTooltip:Show()
        end)
        markWaypoint:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        --markWaypoint:Hide()

        -- Show waypoints button
        local showWaypoints = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        showWaypoints:SetSize(30, 30)
        showWaypoints:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 550, 0)
        showWaypoints:SetNormalTexture("Interface/ICONS/INV_Misc_Book_02")
        showWaypoints:SetScript("OnClick", function()
            local waypoint_string = ""
            for k,v in pairs(runner.waypoints) do
                waypoint_string = waypoint_string .. '{ ["Name"] = "Move to main room",\n'
                waypoint_string = waypoint_string .. '["Task"] = "move_to",\n'
                waypoint_string = waypoint_string .. '["Locations"] = {{'
                waypoint_string = waypoint_string .. '["X"] = ' .. v.x .. ', ["Y"] = ' .. v.y .. ', ["Z"] = ' .. v.z .. ', ["Radius"] = 3, }}\n}, \n\n'
            end
            runner.nn.WriteFile("/scripts/mainrunner/waypoints.json", waypoint_string)
        end)

    showWaypoints:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Save Waypoints")
            GameTooltip:Show()
        end)
        showWaypoints:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- Object Manager toggle
        local OMToggle = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        OMToggle:SetSize(30, 30)
        OMToggle:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 800, 0)
        OMToggle:SetNormalTexture("Interface/ICONS/INV_Misc_Eye_02")
        OMToggle:SetScript("OnClick", function()
            runner.UI.ObjectViewer2:Toggle()
        end)
        OMToggle:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Toggle Object Viewer")
            GameTooltip:Show()
        end)
        OMToggle:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- Debug button
        local debugButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        debugButton:SetSize(30, 30)
        debugButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 750, 0)
        debugButton:SetNormalTexture("Interface/ICONS/INV_Misc_Note_02")
        debugButton:SetScript("OnClick", function()
            runner.Engine.DebugManager:Toggle()
        end)
        debugButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Toggle Debug Output")
            GameTooltip:Show()
        end)
        debugButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- Debug level dropdown
        local debugLevelDropdown = CreateFrame("Frame", "debugLevelMenu", mainFrame, "UIDropDownMenuTemplate")
        debugLevelDropdown:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 830, 0)
        UIDropDownMenu_SetWidth(debugLevelDropdown, 80)
        UIDropDownMenu_Initialize(debugLevelDropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            for level, _ in pairs(runner.Engine.DebugManager.LOG_LEVELS) do
                info.text = level
                info.func = function()
                    runner.Engine.DebugManager:SetLevel(level)
                    UIDropDownMenu_SetText(debugLevelDropdown, level)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetText(debugLevelDropdown, "DEBUG")
        --showWaypoints:Hide()

        local dropDown = CreateFrame("Frame", "rotationMenu", mainFrame, "UIDropDownMenuTemplate")
        dropDown:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 40, 0)
        UIDropDownMenu_SetWidth(dropDown, 100)
        UIDropDownMenu_Initialize(dropDown, rotationMenu_Initialize)
        UIDropDownMenu_SetText(dropDown, "Select Rotation")

        local dropDownRoutine = CreateFrame("Frame", "routineMenu", mainFrame, "UIDropDownMenuTemplate")
        dropDownRoutine:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 150, 0)
        UIDropDownMenu_SetWidth(dropDownRoutine, 150)
        UIDropDownMenu_Initialize(dropDownRoutine, routineMenu_Initialize)
        UIDropDownMenu_SetText(dropDownRoutine, "Select Routine")

        local OMToggle = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
        OMToggle:SetSize(30, 30)
        OMToggle:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 800, 0)
        OMToggle:SetNormalTexture("Interface/ICONS/INV_Misc_PocketWatch_01")
        OMToggle:SetScript("OnClick", function()
            runner.UI.ObjectViewer2:Toggle()
        end)

        mainFrame.pauseButton = pauseButton
        mainFrame.dropDown = dropDown
        mainFrame.dropDownRoutine = dropDownRoutine

        local statusFrame = CreateFrame("Frame", "StatusFrame", UIParent, "BackdropTemplate")
        statusFrame:SetMovable(true)
        statusFrame:EnableMouse(true)
        statusFrame:SetResizable(true)
        statusFrame:SetWidth(UIParent:GetWidth()/2)
        statusFrame:SetHeight(30)
        statusFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)
        statusFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                               edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                               tile = true, tileSize = 16, edgeSize = 16,
                               insets = { left = 4, right = 4, top = 4, bottom = 4 }});
        statusFrame:SetBackdropColor(0,0,0,1);
        statusFrame:Show()
        local statusText = statusFrame:CreateFontString("StatusText", "OVERLAY", "GameFontNormal")
        statusText:SetPoint("CENTER", statusFrame, "CENTER", 0, 0)
        statusText:SetText("Status: Running")
        statusFrame.text = statusText
        mainFrame.statusFrame = statusFrame

    end
    if runner.rotation then
        menuFrame:SetDropdownText(runner.rotation.Name)
    end
    if runner.routine then
        menuFrame:SetRoutineDropdownText(runner.routine.Name)
    end
end

function menuFrame:UpdateStatusText(text)
    mainFrame.statusFrame.text:SetText("Status: " .. text)
end

function rotationMenu_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for k,v in pairs(runner.rotations) do
        if v.Class:lower() == select(1, UnitClass("player")):lower() or v.Class:lower() == "any" then
            info.text = v.Name
            info.func = function() runner.rotation = v end
            UIDropDownMenu_AddButton(info)

        end
    end
end

function routineMenu_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for k,v in pairs(runner.routines) do
        if v.Name ~= "BaseRoutine" then
            info.text = v.Name
            info.func = function()
                runner.routine = v
                for k,v in pairs(runner.routines) do
                    if v.Name == runner.routine.Name then
                        v:ShowGUI()
                    else
                        v:HideGUI()
                    end
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end
end

function menuFrame:SetDropdownText(text)
    UIDropDownMenu_SetText(mainFrame.dropDown, text)
end

function menuFrame:SetRoutineDropdownText(text)
    UIDropDownMenu_SetText(mainFrame.dropDownRoutine, text)
end
