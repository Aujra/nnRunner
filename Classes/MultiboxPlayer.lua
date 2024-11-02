runner.Classes.MultiboxPlayer = runner.Classes.LocalPlayer:extend()
local MultiboxPlayer = runner.Classes.MultiboxPlayer
runner.Classes.MultiboxPlayer = MultiboxPlayer

function MultiboxPlayer:init(pointer)
    runner.Classes.Player.init(self, pointer)
    
    -- Initialize multibox properties with defaults
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
    
    -- Follow position tracking
    self.followPosition = nil
    self.followAngle = nil
    self.lastMasterFacing = nil
    self.lastMasterMoving = nil
    self.lastPositionUpdate = 0
    self.POSITION_UPDATE_COOLDOWN = 0.2  -- Seconds before forced position update
    self.DIRECTION_CHANGE_THRESHOLD = math.rad(45)  -- 45 degrees in radians
end

function MultiboxPlayer:Update()
    -- Call parent update
    runner.Classes.LocalPlayer.Update(self)
    
    -- Update master object reference if needed
    if self.masterGUID and not self.masterObject then
        for _, player in pairs(runner.Engine.ObjectManager.players) do
            if UnitGUID(player.pointer) == self.masterGUID then
                self.masterObject = player
                break
            end
        end
    end
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

function MultiboxPlayer:NeedsNewFollowPosition()
    if not self.followPosition then return true end
    if not self.masterObject then return false end
    
    local currentTime = GetTime()
    
    -- Check time-based update
    if currentTime - self.lastPositionUpdate > self.POSITION_UPDATE_COOLDOWN then
        return true
    end
    
    -- Check distance
    local distance = self:GetDistanceFromMaster()
    if distance > self.FOLLOW_MAX_DISTANCE * 1.5 then
        return true
    end
    
    -- Check if master has stopped moving
    local masterMoving = GetUnitSpeed(self.masterObject.pointer) > 0
    if self.lastMasterMoving ~= masterMoving then
        self.lastMasterMoving = masterMoving
        return true
    end
    
    -- Only check facing changes if master is moving
    if masterMoving then
        local masterFacing = ObjectFacing(self.masterObject.pointer)
        if self.lastMasterFacing then
            local facingDiff = math.abs(masterFacing - self.lastMasterFacing)
            if facingDiff > self.DIRECTION_CHANGE_THRESHOLD then
                return true
            end
        end
    end
    
    return false
end

-- function MultiboxPlayer:CalculateFollowPosition()
--     if not self.masterObject then return nil end
    
--     local mx, my, mz = ObjectPosition(self.masterObject.pointer)
--     if not mx then return nil end
    
--     local masterFacing = ObjectFacing(self.masterObject.pointer)
--     local masterMoving = GetUnitSpeed(self.masterObject.pointer) > 0
    
--     -- Calculate base angle (directly behind)
--     local baseAngle = (masterFacing + math.pi) % (2 * math.pi)
    
--     -- If master is stopped, stay directly behind
--     -- If master is moving, use stored angle or calculate new one with offset
--     if not masterMoving then
--         self.followAngle = baseAngle
--     elseif not self.followAngle then
--         local offset = (math.random() - 0.5) * math.pi  -- -90 to +90 degrees
--         self.followAngle = (baseAngle + offset) % (2 * math.pi)
--     end
    
--     -- Use shorter follow distance when master is stopped
--     local distance = masterMoving and 
--         (self.FOLLOW_MIN_DISTANCE + (self.FOLLOW_MAX_DISTANCE - self.FOLLOW_MIN_DISTANCE) * 0.5) or
--         self.FOLLOW_MIN_DISTANCE
    
--     local x = mx + math.cos(self.followAngle) * distance
--     local y = my + math.sin(self.followAngle) * distance
    
--     -- Update tracking variables
--     self.followPosition = {x = x, y = y, z = mz}
--     self.lastMasterFacing = masterFacing
--     self.lastMasterMoving = masterMoving
--     self.lastPositionUpdate = GetTime()
    
--     -- Visual debugging
--     if runner.Draw then
--         -- Draw circle at calculated position
--         runner.Draw:Circle(x, y, mz, 0.5)
        
--         -- Draw text showing position info
--         local status = masterMoving and "Moving" or "Stopped"
--         local angle = math.floor(self.followAngle * 180 / math.pi)
--         runner.Draw:Text(string.format("%s (Angle: %d°)", status, angle), "GAMEFONTNORMAL", x, y, mz + 2)
        
--         -- Draw line from master to follow position
--         runner.Draw:Line(mx, my, mz, x, y, mz, 0, 1, 0, 1)
        
--         -- Draw master's facing direction
--         local facingX = mx + math.cos(masterFacing) * 3
--         local facingY = my + math.sin(masterFacing) * 3
--         runner.Draw:Line(mx, my, mz, facingX, facingY, mz, 1, 0, 0, 1)
        
--         -- Draw circle around master
--         runner.Draw:Circle(mx, my, mz, distance)
--     end
    
--     return self.followPosition
-- end

-- function MultiboxPlayer:GetFormationPosition()
--     print("Starting GetFormationPosition")
    
--     local numFollowers = (IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()) - 1
--     print("Number of followers:", numFollowers)
--     if numFollowers <= 0 then 
--         print("No followers found")
--         return nil 
--     end
    
--     local myIndex = 0
--     for i = 1, numFollowers do
--         local unit = IsInRaid() and ("raid"..i) or ("party"..i)
--         if UnitIsUnit(unit, "player") then
--             myIndex = i
--             break
--         end
--     end
--     print("My index in formation:", myIndex)
--     if myIndex == 0 then 
--         print("Failed to find player index")
--         return nil 
--     end
    
--     local mx, my, mz = ObjectPosition(self.masterObject.pointer)
--     print("Master position:", mx, my, mz)
--     if not mx then 
--         print("Failed to get master position")
--         return nil 
--     end
    
--     local masterFacing = ObjectFacing(self.masterObject.pointer)
--     local baseAngle = masterFacing + math.pi
--     print("Master facing:", masterFacing, "Base angle:", baseAngle)
    
--     local arcWidth = math.pi * 2/3
--     local angleStep = arcWidth / (numFollowers + 1)
--     local myAngle = baseAngle - (arcWidth/2) + (myIndex * angleStep)
--     print("Arc width:", arcWidth, "Angle step:", angleStep, "My angle:", myAngle)
    
--     local baseDistance = self.FOLLOW_MIN_DISTANCE
--     local distanceVar = (self.FOLLOW_MAX_DISTANCE - self.FOLLOW_MIN_DISTANCE) * ((myIndex - 1) / numFollowers)
--     local distance = baseDistance + distanceVar
--     print("Base distance:", baseDistance, "Distance variation:", distanceVar, "Final distance:", distance)
    
--     local x = mx + math.cos(myAngle) * distance
--     local y = my + math.sin(myAngle) * distance
--     local z = mz
--     print("Calculated position:", x, y, z)
    
--     -- Visual debugging
--     if runner.Draw then
--         runner.Draw:Circle(x, y, z, 0.5)
        
--         local masterMoving = GetUnitSpeed(self.masterObject.pointer) > 0
--         local status = masterMoving and "Moving" or "Stopped"
--         local angleDegrees = math.floor(myAngle * 180 / math.pi)
--         runner.Draw:Text(string.format("%s (Angle: %d°)", status, angleDegrees), "GAMEFONTNORMAL", x, y, z + 2)
        
--         runner.Draw:Line(mx, my, mz, x, y, z, 0, 1, 0, 1)
        
--         local facingX = mx + math.cos(masterFacing) * 3
--         local facingY = my + math.sin(masterFacing) * 3
--         runner.Draw:Line(mx, my, mz, facingX, facingY, mz, 1, 0, 0, 1)
        
--         runner.Draw:Circle(mx, my, mz, distance)
        
--         -- Additional debug visuals
--         runner.Draw:Text(string.format("Index: %d/%d", myIndex, numFollowers), "GAMEFONTNORMAL", x, y, z + 3)
--         runner.Draw:Text(string.format("Dist: %.1f", distance), "GAMEFONTNORMAL", x, y, z + 4)
--     end
    
--     return {x = x, y = y, z = z}
-- end

-- function MultiboxPlayer:GetFollowPosition()
--     if self:NeedsNewFollowPosition() then
--         return self:CalculateFollowPosition()
--     end
--     return self.followPosition
-- end

function MultiboxPlayer:IsAtFollowPosition()
    if not self.followPosition then return false end
    
    local px, py, pz = ObjectPosition(self.pointer)
    if not px then return false end
    
    local distance = math.sqrt(
        (px - self.followPosition.x)^2 + 
        (py - self.followPosition.y)^2
    )
    
    -- Visual debugging
    if runner.Draw then
        -- Draw circle at current position
        runner.Draw:Circle(px, py, pz, 0.5)
        runner.Draw:Text(string.format("Distance to target: %.1f", distance), "GAMEFONTNORMAL", px, py, pz + 2)
    end
    
    return distance <= 2  -- Within half a yard of target position
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

function MultiboxPlayer:GetClosestLootable()
    local closestLootable = nil
    local closestDistance = 9999
    
    -- Check all game objects (includes units and chests since they inherit from GameObject)
    -- for _, obj in pairs(runner.Engine.ObjectManager.gameobjects) do
    --     if obj.CanLoot then
    --         local distance = obj:DistanceFromPlayer()
    --         if distance < closestDistance then
    --             closestLootable = obj
    --             closestDistance = distanceShouldFollowMaster
    --         end
    --     end
    -- end
    
    -- Also check units specifically since they're in a separate collection
    for _, unit in pairs(runner.Engine.ObjectManager.units) do
        if unit.Reaction and unit.Reaction < 4 and unit.CanLoot then
            local distance = unit:DistanceFromPlayer()
            if distance < closestDistance then
                closestLootable = unit
                closestDistance = distance
            end
        end
    end
    
    return closestLootable
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
