runner.Classes.MultiboxPlayer = runner.Classes.Player:extend()
local MultiboxPlayer = runner.Classes.MultiboxPlayer
runner.Classes.MultiboxPlayer = MultiboxPlayer

function MultiboxPlayer:init(pointer)
    runner.Classes.Player.init(self, pointer)
    self.isMultiboxEnabled = false
    self.isMaster = false
    self.forcedFollow = false
    self.masterGUID = nil
    self.masterName = nil
    self.masterObject = nil
    
    -- Combat constants
    self.FOLLOW_MIN_DISTANCE = 1
    self.FOLLOW_MAX_DISTANCE = 5
    self.MELEE_RANGE = 5
    self.RANGED_COMBAT_RANGE = 25
end

function MultiboxPlayer:Update()
    runner.Classes.Player.Update(self)
    -- Update master reference if we're a slave
    if not self.isMaster and self.masterGUID then
        self:UpdateMasterReference()
    end
end

function MultiboxPlayer:UpdateMasterReference()
    if not self.masterGUID then return end
    
    for _, player in pairs(runner.Engine.ObjectManager.players) do
        if UnitGUID(player.pointer) == self.masterGUID then
            self.masterObject = player
            return
        end
    end
    self.masterObject = nil
end

function MultiboxPlayer:GetMasterTarget()
    if not self.masterObject then return nil end
    return runner.Engine.ObjectManager:GetByPointer(UnitTarget(self.masterObject.pointer))
end

function MultiboxPlayer:IsPlayerMeleeSpec()
    local specID = GetSpecialization()
    if not specID then return false end
    
    local meleeSpecs = {
        [250] = true, [251] = true, [252] = true, -- Death Knight
        [577] = true, [581] = true, -- Demon Hunter
        [103] = true, [104] = true, -- Druid (Feral, Guardian)
        [268] = true, [269] = true, [270] = true, -- Monk
        [66] = true, [70] = true, [65] = true, -- Paladin
        [259] = true, [260] = true, [261] = true, -- Rogue
        [263] = true, -- Shaman (Enhancement)
        [71] = true, [72] = true, [73] = true -- Warrior
    }
    
    return meleeSpecs[specID] or false
end

function MultiboxPlayer:IsInMeleePosition(target)
    if not target then return false end
    
    local px, py, pz = ObjectPosition(self.pointer)
    local tx, ty, tz = ObjectPosition(target.pointer)
    if not px or not tx then return false end
    
    -- Check distance
    local distance = math.sqrt((px - tx)^2 + (py - ty)^2)
    local desiredRange = self.MELEE_RANGE + target.BoundingRadius
    if math.abs(distance - desiredRange) > 1 then return false end
    
    -- Check if we're in the 90-degree arc behind target
    local targetFacing = ObjectFacing(target.pointer)
    local angleToPlayer = math.atan2(py - ty, px - tx)
    local behindAngle = (targetFacing + math.pi) % (2 * math.pi)
    local angleDiff = math.abs(angleToPlayer - behindAngle)
    if angleDiff > math.pi then
        angleDiff = 2 * math.pi - angleDiff
    end
    
    return angleDiff <= math.pi/2  -- 90 degrees
end

function MultiboxPlayer:IsInRangedPosition(target)
    if not target then return false end
    
    local px, py, pz = ObjectPosition(self.pointer)
    local tx, ty, tz = ObjectPosition(target.pointer)
    if not px or not tx then return false end
    
    -- Check distance
    local distance = math.sqrt((px - tx)^2 + (py - ty)^2)
    local desiredRange = self.RANGED_COMBAT_RANGE + target.BoundingRadius
    if math.abs(distance - desiredRange) > 2 then return false end  -- Allow more variance for ranged
    
    -- Check line of sight
    local hitX, hitY, hitZ = TraceLine(px, py, pz + 2, tx, ty, tz + 2, 0x100111)
    return not hitX
end

function MultiboxPlayer:IsInTankPosition(target)
    if not target then return false end
    
    local distance = self:DistanceFrom(target)
    local desiredRange = target.BoundingRadius * 0.5
    return distance <= desiredRange + 1
end

function MultiboxPlayer:NeedsRepositioning(target)
    if not target then return false end
    
    local isTank = UnitGroupRolesAssigned(self.pointer) == "TANK"
    local isRanged = UnitGroupRolesAssigned(self.pointer) == "RANGED"
    
    if isRanged then
        return not self:IsInRangedPosition(target)
    elseif isTank then
        return not self:IsInTankPosition(target)
    else
        return not self:IsInMeleePosition(target)
    end
end

function MultiboxPlayer:CalculateRangedPosition(target)
    local px, py, pz = ObjectPosition(self.pointer)
    local tx, ty, tz = ObjectPosition(target.pointer)
    if not px or not tx then return nil end
    
    -- Calculate direction vector from target to player
    local dx, dy = px - tx, py - ty
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist == 0 then return nil end
    
    -- Scale the vector to desired range, accounting for target's bounding radius
    local desiredDistance = self.RANGED_COMBAT_RANGE + target.BoundingRadius
    local scale = desiredDistance / dist
    return {
        x = tx + dx * scale,
        y = ty + dy * scale,
        z = tz
    }
end

function MultiboxPlayer:CalculateMeleePosition(target)
    local targetFacing = ObjectFacing(target.pointer)
    local tx, ty, tz = ObjectPosition(target.pointer)
    if not targetFacing or not tx then return nil end
    
    -- Calculate angle directly behind target
    local behindAngle = (targetFacing + math.pi) % (2 * math.pi)
    
    -- Add random offset within 90-degree arc (45 degrees each side)
    local randomOffset = (math.random() - 0.5) * math.pi/2  -- -45 to +45 degrees
    local finalAngle = (behindAngle + randomOffset) % (2 * math.pi)
    
    -- Calculate position at melee range plus target's bounding radius
    local radius = self.MELEE_RANGE + target.BoundingRadius
    return {
        x = tx + math.cos(finalAngle) * radius,
        y = ty + math.sin(finalAngle) * radius,
        z = tz
    }
end

function MultiboxPlayer:GetCombatPosition(target)
    if not target then return nil end
    if not self:NeedsRepositioning(target) then return nil end
    
    local isTank = UnitGroupRolesAssigned(self.pointer) == "TANK"
    local isRanged = UnitGroupRolesAssigned(self.pointer) == "RANGED"
    
    if isRanged then
        return self:CalculateRangedPosition(target)
    elseif not isTank then
        return self:CalculateMeleePosition(target)
    else
        -- Tanks move to target's position plus a small offset for bounding radius
        local tx, ty, tz = ObjectPosition(target.pointer)
        -- Add a small offset to prevent clipping into the target
        local offset = target.BoundingRadius * 0.5
        return {x = tx + offset, y = ty + offset, z = tz}
    end
end

function MultiboxPlayer:GetCombatRange()
    if UnitGroupRolesAssigned(self.pointer) == "RANGED" then
        return self.RANGED_COMBAT_RANGE
    end
    return self.MELEE_RANGE
end

function MultiboxPlayer:ShouldFollowMaster()
    if self.isMaster then return false end
    if not self.isMultiboxEnabled then return false end
    if not self.masterObject then return false end
    
    return self.forcedFollow or not UnitAffectingCombat(self.masterObject.pointer)
end

function MultiboxPlayer:GetDistanceFromMaster()
    if not self.masterObject then return 999999 end
    return self:DistanceFrom(self.masterObject)
end

function MultiboxPlayer:IsSafeToAttack(targetObject)
    if not targetObject then return false end
    
    local isTank = UnitGroupRolesAssigned(self.pointer) == "TANK"
    if isTank then return true end
    
    -- For non-tanks, only attack if the target is in combat
    return UnitAffectingCombat(targetObject.pointer)
end

function MultiboxPlayer:GetClosestLootableEnemy()
    local closestEnemy = nil
    local closestDistance = 9999
    
    for _, enemy in pairs(runner.Engine.ObjectManager.units) do
        if enemy.CanLoot then
            local distance = enemy:DistanceFromPlayer()
            if distance < closestDistance then
                closestEnemy = enemy
                closestDistance = distance
            end
        end
    end
    return closestEnemy
end

function MultiboxPlayer:GetClosestChest()
    local closestChest = nil
    local closestDistance = 9999
    
    for _, obj in pairs(runner.Engine.ObjectManager.gameobjects) do
        -- Filter for common chest names in dungeons
        if obj.Name and (obj.Name:lower():find("chest") or 
                        obj.Name:lower():find("cache") or 
                        obj.Name:lower():find("coffer") or 
                        obj.Name:lower():find("strongbox")) then
            local distance = obj:DistanceFromPlayer()
            if distance < closestDistance then
                closestChest = obj
                closestDistance = distance
            end
        end
    end
    return closestChest
end

function MultiboxPlayer:GetClosestInteractable()
    -- First check for chests as they're higher priority
    local chest = self:GetClosestChest()
    if chest then return chest end
    
    -- Then check for lootable enemies
    return self:GetClosestLootableEnemy()
end

function MultiboxPlayer:ShouldLoot()
    return not UnitAffectingCombat(self.pointer)
end

function MultiboxPlayer:ToViewerRow()
    local baseRow = runner.Classes.Player.ToViewerRow(self)
    table.insert(baseRow, self.isMaster and "Master" or "Slave")
    table.insert(baseRow, self.masterName or "None")
    return baseRow
end
