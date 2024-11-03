local DebugManager = {
    enabled = false,
    LOG_LEVELS = {
        DEBUG = 1,
        INFO = 2,
        WARNING = 3,
        ERROR = 4
    },
    DEBUG_TYPES = {
        COMBAT = "Combat",
        FORMATION = "Formation",
        FOLLOW = "Follow",
        INTERACTION = "Interaction",
        STATE = "State",
        NAVIGATION = "Navigation",
        GENERAL = "General",
        POSITIONING = "Positioning",
        COMBAT_POS = "Combat Positioning",
        TARGETING = "Targeting",
        ROLE = "Role",
        MASTER = "Master",
        DUNGEON = "Dungeon Routine",
        LOOT = "Looting"
    },
    enabledTypes = {},  
    currentLevel = 1,  -- Default to DEBUG
    filterWindow = nil
}
runner.Engine.DebugManager = DebugManager

-- Initialize enabled types
for type, _ in pairs(DebugManager.DEBUG_TYPES) do
    DebugManager.enabledTypes[type] = true
end

function DebugManager:Toggle()
    self.enabled = not self.enabled
    print("Debugging " .. (self.enabled and "enabled" or "disabled"))
    if self.enabled and not self.filterWindow then
        self:BuildFilterGUI()
    end
    if self.filterWindow then
        if self.enabled then
            self.filterWindow:Show()
        else
            self.filterWindow:Hide()
        end
    end
end

function DebugManager:SetLevel(level)
    if self.LOG_LEVELS[level] then
        self.currentLevel = self.LOG_LEVELS[level]
        print("Debug level set to: " .. level)
    end
end

function DebugManager:ShouldLog(level, debugType)
    if not self.enabled then return false end
    if not self.LOG_LEVELS[level] or self.LOG_LEVELS[level] < self.currentLevel then
        return false
    end
    
    -- If no debug type specified, treat as GENERAL
    debugType = debugType or "GENERAL"
    
    -- Check if this debug type is enabled
    return self.enabledTypes[debugType]
end

function DebugManager:Log(level, module, message, debugType)
    if not self:ShouldLog(level, debugType) then return end
    
    local color
    if level == "ERROR" then color = "FF0000"
    elseif level == "WARNING" then color = "FFA500"
    elseif level == "INFO" then color = "00FF00"
    else color = "FFFFFF" end
    
    local typeStr = debugType and ("[" .. self.DEBUG_TYPES[debugType] .. "]") or ""
    print(string.format("|cff%s[%s]%s[%s] %s|r", color, level, typeStr, module, message))
end

function DebugManager:Debug(module, message, debugType)
    self:Log("DEBUG", module, message, debugType)
end

function DebugManager:Info(module, message, debugType)
    self:Log("INFO", module, message, debugType)
end

function DebugManager:Warning(module, message, debugType)
    self:Log("WARNING", module, message, debugType)
end

function DebugManager:Error(module, message, debugType)
    self:Log("ERROR", module, message, debugType)
end

function DebugManager:BuildFilterGUI()
    -- Create the main frame
    self.filterWindow = CreateFrame("Frame", "DebugFilterWindow", UIParent, "BasicFrameTemplateWithInset")
    self.filterWindow:SetSize(200, 300)
    self.filterWindow:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -100, -100)
    self.filterWindow:SetMovable(true)
    self.filterWindow:EnableMouse(true)
    self.filterWindow:RegisterForDrag("LeftButton")
    self.filterWindow:SetScript("OnDragStart", self.filterWindow.StartMoving)
    self.filterWindow:SetScript("OnDragStop", self.filterWindow.StopMovingOrSizing)
    
    -- Add title
    self.filterWindow.title = self.filterWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.filterWindow.title:SetPoint("LEFT", self.filterWindow.TitleBg, "LEFT", 5, 0)
    self.filterWindow.title:SetText("Debug Filters")
    
    -- Add checkboxes for each debug type
    local yOffset = -30
    local xOffset = 10
    self.filterWindow.checkboxes = {}
    
    -- Select/Deselect All buttons
    local selectAllBtn = CreateFrame("Button", nil, self.filterWindow, "UIPanelButtonTemplate")
    selectAllBtn:SetSize(80, 22)
    selectAllBtn:SetPoint("TOPLEFT", self.filterWindow, "TOPLEFT", xOffset, yOffset)
    selectAllBtn:SetText("Select All")
    selectAllBtn:SetScript("OnClick", function()
        for type, _ in pairs(self.DEBUG_TYPES) do
            self.enabledTypes[type] = true
            self.filterWindow.checkboxes[type]:SetChecked(true)
        end
    end)
    
    local deselectAllBtn = CreateFrame("Button", nil, self.filterWindow, "UIPanelButtonTemplate")
    deselectAllBtn:SetSize(80, 22)
    deselectAllBtn:SetPoint("TOPLEFT", selectAllBtn, "TOPRIGHT", 10, 0)
    deselectAllBtn:SetText("Clear All")
    deselectAllBtn:SetScript("OnClick", function()
        for type, _ in pairs(self.DEBUG_TYPES) do
            self.enabledTypes[type] = false
            self.filterWindow.checkboxes[type]:SetChecked(false)
        end
    end)
    
    yOffset = yOffset - 30
    
    -- Create checkboxes for each debug type
    for type, label in pairs(self.DEBUG_TYPES) do
        local checkbox = CreateFrame("CheckButton", "DebugTypeCheckbox_" .. type, self.filterWindow, "ChatConfigCheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", self.filterWindow, "TOPLEFT", xOffset, yOffset)
        checkbox:SetChecked(self.enabledTypes[type])
        getglobal(checkbox:GetName() .. 'Text'):SetText(label)
        
        checkbox:SetScript("OnClick", function(self)
            DebugManager.enabledTypes[type] = self:GetChecked()
        end)
        
        self.filterWindow.checkboxes[type] = checkbox
        yOffset = yOffset - 25
    end
    
    -- Adjust frame height based on content
    self.filterWindow:SetHeight(math.abs(yOffset) + 40)
    
    if not self.enabled then
        self.filterWindow:Hide()
    end
end

return DebugManager