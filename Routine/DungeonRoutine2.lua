runner.Routines.DungeonRoutine2 = runner.Routines.BaseRoutine:extend()
local DungeonRoutine2 = runner.Routines.DungeonRoutine2
runner.Routines.DungeonRoutine2 = DungeonRoutine2

function DungeonRoutine2:init()
    runner.Routines.BaseRoutine.init(self)
    self.Name = "DungeonRoutine2"
    self.Description = "DungeonRoutine2"
    self.BlackList = {
        "Vent Stalker", "Speaker Mechhand", "Reinforce Stalker", "Eternal Flame", "Dummy Stalker", "Mini-Boss Stalker"
    }
    self.SettingsGUI = {}
    self:BuildGUI()
    self.CurrentProfile = {}

    self.ProfileDropDowns = {}
    self.ProfileList = {}
end

function DungeonRoutine2:Run()
    runner.Behaviors.BaseBehavior:Run(self)
    if runner.rotation:OutOfCombat() then
        return
    end
    if StaticPopup1Button1 ~= nil and StaticPopup1Button1:IsVisible() then
        Unlock(RunMacroText, "/click StaticPopup1Button1")
    end

    runner.LocalPlayer:EquipUpgrades()

    if not IsInInstance() then
        if self.CurrentProfile then
            for k,v in pairs(self.CurrentProfile.Steps) do
                v.step.IsComplete = false
            end
        end
        self:MountAndRepair()
        self:QueueAndEnterDungeon()
    else
        if self.CurrentProfile then
            local current = nil
            for i = tableCount(self.CurrentProfile.Steps), 1, -1 do
                v = self.CurrentProfile.Steps[i]
                if not v.step.IsComplete then
                    current = v
                end
                v.step:Debug()
            end
            local lootable = runner.Engine.ObjectManager:GetClosestLootable()
            if self.CurrentProfile.LootMode ~= "None" and lootable and not UnitAffectingCombat("player") then
                if self.CurrentProfile.LootMode == "All" then
                    if lootable:DistanceFromPlayer() < 5 then
                        self:SetStatus("Looting " .. lootable.Name)
                        runner.Engine.Navigation:FaceUnit(lootable.pointer)
                        Unlock(MoveForwardStop)
                        Unlock(RunBinding, "INTERACTTARGET")
                    else
                        self:SetStatus("Moving to loot " .. lootable.Name)
                        runner.Engine.Navigation:MoveTo(lootable.pointer)
                    end
                    return
                end
                if self.CurrentProfile.LootMode == "BossOnly" and lootable.Level - runner.LocalPlayer.Level >= 2 then
                    if lootable:DistanceFromPlayer() < 5 then
                        self:SetStatus("Looting " .. lootable.Name)
                        runner.Engine.Navigation:FaceUnit(lootable.pointer)
                        Unlock(MoveForwardStop)
                        Unlock(RunBinding, "INTERACTTARGET")
                    else
                        self:SetStatus("Moving to loot " .. lootable.Name)
                        runner.Engine.Navigation:MoveTo(lootable.pointer)
                    end
                    return
                end
            end
            if current then
                current.step:Run()
                if current.step.IsComplete then
                end
            else
                C_PartyInfo.LeaveParty()
            end
        end
    end
end

function DungeonRoutine2:MountAndRepair()
    if not IsIndoors() and not IsMounted() then
        C_MountJournal.SummonByID(284)
    end
    local repair = runner.Engine.ObjectManager:GetClosestByName("Drix Blackwrench")
    if repair then
        if repair:DistanceFromPlayer() < 10 then
            runner.nn.ObjectInteract(repair.pointer)
        else
            runner.Engine.Navigation:MoveTo(repair.pointer)
        end
        if MerchantRepairAllButton:IsVisible() then
            MerchantRepairAllButton:Click()
        end
        if MerchantSellAllJunkButton:IsVisible() then
            MerchantSellAllJunkButton:Click()
        end
    end
end

function DungeonRoutine2:QueueAndEnterDungeon()
    if (select(1,GetLFGQueueStats(LE_LFG_CATEGORY_LFD))) == nil then
        print("Queueing for LFD")
        ClearAllLFGDungeons(1)
        SetLFGDungeon(1, tonumber(self.CurrentProfile.DungeonID))
        Unlock(JoinLFG, 1)
    end
    if (select(1, GetLFGProposal()) == true) then
        Unlock(AcceptProposal)
    end
end

function DungeonRoutine2:getBestTarget()
    local bestTarget = nil
    local bestScore = -999999
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Reaction and v.Reaction <= 4 and not v.isDead and not self:BlackListed(v.Name) then
            local score = v:GetScore()
            if score > bestScore then
                bestScore = score
                bestTarget = v
            end
        end
    end
    return bestTarget
end

function DungeonRoutine2:BlackListed(name)
    for k,v in pairs(self.BlackList) do
        if name == v then
            return true
        end
    end
    return false
end

function DungeonRoutine2:SetStatus(text)
    if self.SettingsGUI then
        self.SettingsGUI:SetStatusText(text)
    end
end

function DungeonRoutine2:AddProfileGUI()

end

function DungeonRoutine2:LoadProfileByName(name)
    local json = runner.nn.ReadFile("/scripts/mainrunner/Profiles/DungeonsNew/"..name)
    local profile = runner.nn.Utils.JSON.decode(json)
    profileSteps = {}
    for k,v in pairs(profile.Steps) do
        local behavior = runner.behaviors[v.Name:lower()]()
        behavior.Name = v.Name
        behavior.Type = v.Type
        behavior.Step = v.Step
        table.insert(profileSteps, {index = #profileSteps, step = behavior})
    end
    self.CurrentProfile.Name = profile.Name
    self.CurrentProfile.Description = profile.Description
    self.CurrentProfile.DungeonID = profile.DungeonID
    self.CurrentProfile.LootMode = profile.LootMode
    self.CurrentProfile.PullMode = profile.PullMode
    self.CurrentProfile.WanderRange = profile.WanderRange

    self.CurrentProfile.Steps = profileSteps
end

function DungeonRoutine2:BuildGUI()
    self.SettingsGUI = runner.AceGUI:Create("Frame")
    self.SettingsGUI:SetTitle(self.Name)
    self.SettingsGUI:SetStatusText(self.Description)
    self.SettingsGUI:SetLayout("Flow")
    self.SettingsGUI:SetCallback("OnClose", function(widget)
        runner.Routines.DungeonRoutine2:HideGUI()
    end)
    self.SettingsGUI:SetWidth(300)
    self.SettingsGUI:SetHeight(200)

    local loadProfileDropdown = runner.AceGUI:Create("Dropdown")
    loadProfileDropdown:SetLabel("Load Profile")
    local path = "/scripts/mainrunner/Profiles/DungeonsNew/*.json"
    local files = runner.nn.ListFiles(path)
    for k,v in pairs(files) do
        loadProfileDropdown:AddItem(
                v,v
        )
    end

    local addProfileButton = runner.AceGUI:Create("Button")
    addProfileButton:SetText("Add Profile")
    addProfileButton:SetWidth(100)
    addProfileButton:SetCallback("OnClick", function(widget)
        self:AddProfileGUI()
    end)
    self.SettingsGUI:AddChild(addProfileButton)

    local dumpProfileButton = runner.AceGUI:Create("Button")
    dumpProfileButton:SetText("Dump Profile")
    dumpProfileButton:SetWidth(100)
    dumpProfileButton:SetCallback("OnClick", function(widget)
        for k,v in pairs(self.ProfileDropDowns) do
            print("Profile " .. v.dropdown:GetValue() .. " To Level " .. v.tolevel:GetText())
        end
    end)
    self.SettingsGUI:AddChild(dumpProfileButton)

    loadProfileDropdown:SetWidth(400)
    loadProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        local json = runner.nn.ReadFile("/scripts/mainrunner/Profiles/DungeonsNew/"..value)
        local profile = runner.nn.Utils.JSON.decode(json)
        profileSteps = {}
        for k,v in pairs(profile.Steps) do
            local behavior = runner.behaviors[v.Name:lower()]()
            behavior.Name = v.Name
            behavior.Type = v.Type
            behavior.Step = v.Step
            table.insert(profileSteps, {index = #profileSteps, step = behavior})
        end
        self.CurrentProfile.Name = profile.Name
        self.CurrentProfile.Description = profile.Description
        self.CurrentProfile.DungeonID = profile.DungeonID
        self.CurrentProfile.LootMode = profile.LootMode
        self.CurrentProfile.PullMode = profile.PullMode
        self.CurrentProfile.WanderRange = profile.WanderRange

        self.CurrentProfile.Steps = profileSteps
    end)
    self.SettingsGUI:AddChild(loadProfileDropdown)
end

function DungeonRoutine2:ShowGUI()
    if self.SettingsGUI == nil then
        self:BuildGUI()
    else
        self.SettingsGUI:Show()
    end
end

function DungeonRoutine2:HideGUI()
    if self.SettingsGUI then
        self.SettingsGUI:Hide()
    end
end

function DungeonRoutine2:Debug()
    runner.Draw:SetColorRaw(0, 1, 0, 1)
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v:DistanceFromPlayer() < 150 and Unlock(UnitCanAttack, "player", v.pointer) then
            runner.Draw:Text(string.format("%.2f" ,v:GetScore()), "GameFontNormalLarge", v.x, v.y, v.z+3)
        end
    end
end

registerRoutine(DungeonRoutine2)