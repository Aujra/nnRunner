local DebugManager = {
    enabled = false,
    LOG_LEVELS = {
        DEBUG = 1,
        INFO = 2,
        WARNING = 3,
        ERROR = 4
    },
    currentLevel = 1  -- Default to DEBUG
}
runner.Engine.DebugManager = DebugManager

function DebugManager:Toggle()
    self.enabled = not self.enabled
    print("Debugging " .. (self.enabled and "enabled" or "disabled"))
end

function DebugManager:SetLevel(level)
    if self.LOG_LEVELS[level] then
        self.currentLevel = self.LOG_LEVELS[level]
        print("Debug level set to: " .. level)
    end
end

function DebugManager:ShouldLog(level)
    return self.enabled and self.LOG_LEVELS[level] >= self.currentLevel
end

function DebugManager:Log(level, module, message)
    if not self:ShouldLog(level) then return end
    
    local color
    if level == "ERROR" then color = "FF0000"
    elseif level == "WARNING" then color = "FFA500"
    elseif level == "INFO" then color = "00FF00"
    else color = "FFFFFF" end
    
    print(string.format("|cff%s[%s][%s] %s|r", color, level, module, message))
end

function DebugManager:Debug(module, message)
    self:Log("DEBUG", module, message)
end

function DebugManager:Info(module, message)
    self:Log("INFO", module, message)
end

function DebugManager:Warning(module, message)
    self:Log("WARNING", module, message)
end

function DebugManager:Error(module, message)
    self:Log("ERROR", module, message)
end

return DebugManager
