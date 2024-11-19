runner.QuestOverrides = {}
local qo = runner.QuestOverrides

qo[59937] = function()
    if runner.LocalPlayer.IsCasting then
        runner.Engine.Navigation:FaceUnit(runner.LocalPlayer.Target)
        return
    end
    local tamable = nil
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Name == "Wandering Boar" or v.Name == "Sharpbeak Hawk" and not v.isDead then
            tamable = v
            break
        end
    end
    if tamable then
        if tamable:DistanceFromPlayer() > 20 or not tamable:LOS() then
            runner.Engine.Navigation:MoveTo(tamable.pointer)
        else
            Unlock(MoveForwardStop)
            Unlock(TargetUnit, tamable.pointer)
            Unlock(CastSpellByName, "Tame Beast")
            return
        end
        return
    end
end

qo[59941] = function()
    local boar = nil
    if runner.LocalPlayer.IsCasting then
        runner.Engine.Navigation:FaceUnit(runner.LocalPlayer.Target)
        return
    end
    for k,v in pairs(runner.Engine.ObjectManager.units) do
        if v.Name == "Wandering Boar" and not v.isDead then
            boar = v
            break
        end
    end
    if boar then
        if boar:DistanceFromPlayer() > 8 or not boar:LOS() then
            runner.Engine.Navigation:MoveTo(boar.pointer)
        else
            Unlock(MoveForwardStop)
            Unlock(TargetUnit, boar.pointer)
            Unlock(C_Item.UseItemByName, "Re-sizer v9.0.1")
            return
        end
        return
    end
end

qo[59942] = function()
    local CLICK_SPOTS = {
        {X=155.7, Y=-2383.3, Z=83.2},
        {X=210.7, Y=-2321.3, Z=83.2},
        {X=179.70, Y=-2371.30, Z=82.72},
        {X=183.61, Y=-2368.32, Z=83.13},
        {X=222.54, Y=-2359.28, Z=83.08},
        {X=222.54, Y=-2365.28, Z=83.08},
        {X=227.54, Y=-2359.28, Z=83.08},
        {X=253.15, Y=-2315.99, Z=80.81},
        {X=180.51, Y=-2316.91, Z=82.78},
        {X=183.47, Y=-2323.10, Z=83.84},
        {X=208.36, Y=-2307.60, Z=80.70},
        {X=215.35, Y=-2275.27, Z=80.86},
        {X=248.39, Y=-2278.97, Z=80.74}
    }

    if not QUEST_59942_CLICK_INDEX then
        QUEST_59942_CLICK_INDEX = math.random(1, #CLICK_SPOTS)
    end

    if HasOverrideActionBar() then
        if not SpellIsTargeting() then
            Unlock(RunBinding, "ACTIONBUTTON1")
        else
            QUEST_59942_CLICK_INDEX = QUEST_59942_CLICK_INDEX + 1
            if QUEST_59942_CLICK_INDEX > #CLICK_SPOTS then
                QUEST_59942_CLICK_INDEX = 1
            end

            local randx = math.random(2, 25)
            local randy = math.random(2, 25)
            local spot = CLICK_SPOTS[QUEST_59942_CLICK_INDEX]
            runner.nn.ClickPosition(spot.X + randx, spot.Y + randy, spot.Z, false)
        end
    end
end

qo[59950] = function()
    local asshole = runner.Engine.ObjectManager:GetByName("Provisioner Jin'hake")
    if asshole then
        if asshole:DistanceFromPlayer() > 5 or not asshole:LOS() then
            runner.Engine.Navigation:MoveTo(asshole.pointer)
        else
            Unlock(MoveForwardStop)
            runner.nn.ObjectInteract(asshole.pointer)
            BuyMerchantItem(1, 1)
        end
    end
end

qo[59949] = function()
    if GetQuestObjectiveInfo(59949, 3, true) ~= nil then
        local attackUnit = runner.Engine.ObjectManager:GetByName("Crenna Earth-Daughter")
        if attackUnit and (attackUnit.Distance > 2) then
            Unlock(TargetUnit, attackUnit.Pointer)
            runner.Engine.Navigation:MoveTo(attackUnit.PosX, attackUnit.PosY, attackUnit.PosZ)
            return
        else
            Unlock(MoveForwardStop)
            runner.nn.ObjectInteract(attackUnit.Pointer)
            runner.mountedWhore = true
            C_Timer.After(60*1.5, function()
                runner.mountedWhore = false
            end)
        end
    end
end