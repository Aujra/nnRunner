local FormationManager = {}
runner.Engine.FormationManager = FormationManager

-- Formation constants
FormationManager.MIN_DISTANCE = 2  -- Minimum follow distance
FormationManager.MAX_DISTANCE = 5  -- Maximum follow distance
FormationManager.MIN_SPACING = 1   -- Minimum space between followers
FormationManager.ARC_WIDTH = math.pi * 0.55  -- .55 is 100 degrees centered behind master

-- Track active followers and their positions
FormationManager.followers = {}
FormationManager.positions = {}
FormationManager.lastMasterPos = nil
FormationManager.lastMasterFacing = nil

function FormationManager:AddFollower(player)
    local guid = UnitGUID(player.pointer)
    
    -- Only add if not already in formation
    for _, follower in ipairs(self.followers) do
        if follower.guid == guid then 
            runner.Engine.DebugManager:Debug("FormationManager", string.format(
                "Follower already exists: %s", UnitName(player.pointer)
            ))
            return 
        end
    end
    
    -- Add new follower
    runner.Engine.DebugManager:Debug("FormationManager", string.format(
        "Adding follower: GUID=%s, Name=%s",
        guid,
        UnitName(player.pointer)
    ))
    
    table.insert(self.followers, {
        guid = guid,
        name = UnitName(player.pointer),
        player = player
    })
end

function FormationManager:RemoveFollower(guid)
    for i, follower in ipairs(self.followers) do
        if follower.guid == guid then
            runner.Engine.DebugManager:Debug("FormationManager", string.format(
                "Removing follower: %s", follower.name
            ))
            table.remove(self.followers, i)
            self.positions[guid] = nil
            break
        end
    end
end

function FormationManager:CheckPosition(x, y, masterX, masterY)
    -- Check distance from master
    local masterDist = math.sqrt((x - masterX)^2 + (y - masterY)^2)
    if masterDist < self.MIN_DISTANCE or masterDist > self.MAX_DISTANCE then
        runner.Engine.DebugManager:Debug("FormationManager", string.format(
            "Position invalid - Master distance: %.2f (min: %d, max: %d)",
            masterDist, self.MIN_DISTANCE, self.MAX_DISTANCE
        ))
        return false
    end
    
    -- Check distance from other followers
    for guid, pos in pairs(self.positions) do
        local dist = math.sqrt((x - pos.x)^2 + (y - pos.y)^2)
        if dist < self.MIN_SPACING then
            runner.Engine.DebugManager:Debug("FormationManager", string.format(
                "Position invalid - Too close to %s (%.2f < %d)",
                self:GetFollowerName(guid), dist, self.MIN_SPACING
            ))
            return false
        end
    end
    
    return true
end

function FormationManager:GetFollowerName(guid)
    for _, follower in ipairs(self.followers) do
        if follower.guid == guid then
            return follower.name
        end
    end
    return "Unknown"
end

function FormationManager:AssignPositions(masterX, masterY, masterZ, masterFacing)
    -- Clear current positions
    self.positions = {}
    
    -- Organize followers in a semi-circle behind master
    local numFollowers = #self.followers
    if numFollowers == 0 then return end
    
    -- Calculate arc segments for even spacing
    local arcStep = self.ARC_WIDTH / (numFollowers + 1)
    local baseDistance = (self.MIN_DISTANCE + self.MAX_DISTANCE) / 2
    
    runner.Engine.DebugManager:Debug("FormationManager", string.format(
        "Assigning positions for %d followers", numFollowers
    ))
    
    -- Assign positions systematically
    for i, follower in ipairs(self.followers) do
        -- Calculate position in formation
        local angle = masterFacing + math.pi - (self.ARC_WIDTH/2) + (i * arcStep)
        local distance = baseDistance
        
        -- Calculate final position
        local x = masterX + math.cos(angle) * distance
        local y = masterY + math.sin(angle) * distance
        
        -- Store position
        self.positions[follower.guid] = {
            x = x,
            y = y,
            z = masterZ,
            angle = angle - masterFacing - math.pi,  -- Store relative angle
            distance = distance
        }
        
        runner.Engine.DebugManager:Debug("FormationManager", string.format(
            "Assigned position for %s: angle=%.2f, distance=%.2f",
            follower.name, angle - masterFacing - math.pi, distance
        ))
    end
end

function FormationManager:ShouldUpdatePositions(masterX, masterY, masterFacing)
    -- Only update if this is our first position or if master has moved significantly
    if not self.lastMasterPos then
        self.lastMasterPos = {x = masterX, y = masterY}
        self.lastMasterFacing = masterFacing
        return true
    end
    
    local distMoved = math.sqrt(
        (masterX - self.lastMasterPos.x)^2 + 
        (masterY - self.lastMasterPos.y)^2
    )
    
    -- Update if master has moved more than 1 unit
    if distMoved > 1 then
        self.lastMasterPos = {x = masterX, y = masterY}
        self.lastMasterFacing = masterFacing
        return true
    end
    
    return false
end

function FormationManager:DumpDebugState()
    runner.Engine.DebugManager:Debug("FormationManager", "=== Formation State Dump ===")
    runner.Engine.DebugManager:Debug("FormationManager", string.format("Followers: %d", #self.followers))
    for i, follower in ipairs(self.followers) do
        runner.Engine.DebugManager:Debug("FormationManager", string.format(
            "Follower %d: GUID=%s, Name=%s",
            i, follower.guid, follower.name
        ))
    end
    
    local posCount = 0
    for guid, pos in pairs(self.positions) do
        posCount = posCount + 1
        runner.Engine.DebugManager:Debug("FormationManager", string.format(
            "Position for %s: x=%.2f, y=%.2f, z=%.2f",
            self:GetFollowerName(guid), pos.x, pos.y, pos.z
        ))
    end
    runner.Engine.DebugManager:Debug("FormationManager", string.format("Total Positions: %d", posCount))
    runner.Engine.DebugManager:Debug("FormationManager", "========================")
end

function FormationManager:BroadcastPositions()
    if not IsInGroup() then return end
    
    -- Prepare position data for each follower
    local positionData = {}
    for guid, pos in pairs(self.positions) do
        table.insert(positionData, string.format("%s:%.2f:%.2f:%.2f", guid, pos.x, pos.y, pos.z))
    end
    
    -- Broadcast position data
    local message = "FORMATION:" .. table.concat(positionData, "|")
    runner.Engine.DebugManager:Debug("FormationManager", string.format(
        "Broadcasting formation data (%d positions)", #positionData
    ))
    
    if IsInRaid() then
        C_ChatInfo.SendAddonMessage("MBXR", message, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage("MBXR", message, "PARTY")
    end
end

function FormationManager:GetFollowerPosition(guid)
    return self.positions[guid]
end

function FormationManager:DrawDebug()
    if not runner.Draw then return end
    
    -- Find master
    local master
    for _, follower in ipairs(self.followers) do
        if follower.player.masterObject then
            master = follower.player.masterObject
            break
        end
    end
    
    if master then
        local mx, my, mz = ObjectPosition(master.pointer)
        local mf = ObjectFacing(master.pointer)
        
        if mx then
            -- Draw master position and facing
            runner.Draw:SetColor(255, 0, 0, 255)  -- Pure red
            runner.Draw:Circle(mx, my, mz, 1)
            
            local fx = mx + math.cos(mf) * 3
            local fy = my + math.sin(mf) * 3
            runner.Draw:Line(mx, my, mz, fx, fy, mz)
            
            -- Draw formation boundaries
            local leftAngle = mf + math.pi - self.ARC_WIDTH/2
            local rightAngle = mf + math.pi + self.ARC_WIDTH/2
            local lx = mx + math.cos(leftAngle) * self.MAX_DISTANCE
            local ly = my + math.sin(leftAngle) * self.MAX_DISTANCE
            local rx = mx + math.cos(rightAngle) * self.MAX_DISTANCE
            local ry = my + math.sin(rightAngle) * self.MAX_DISTANCE
            
            runner.Draw:SetColor(0, 255, 255, 128)  -- Cyan with 50% opacity
            runner.Draw:Line(mx, my, mz, lx, ly, mz)
            runner.Draw:Line(mx, my, mz, rx, ry, mz)
            
            -- Draw assigned positions
            runner.Draw:SetColor(0, 255, 0, 255)  -- Pure green
            for guid, pos in pairs(self.positions) do
                runner.Draw:Circle(pos.x, pos.y, pos.z, 0.5)
                local followerName = self:GetFollowerName(guid)
                runner.Draw:Text(followerName, "GAMEFONTNORMAL", pos.x, pos.y, pos.z + 2)
            end
            
            -- Draw actual follower positions and lines
            runner.Draw:SetColor(255, 255, 0, 255)  -- Yellow
            for _, follower in ipairs(self.followers) do
                local px, py, pz = ObjectPosition(follower.player.pointer)
                if px then
                    runner.Draw:Circle(px, py, pz, 0.5)
                    local pos = self.positions[follower.guid]
                    if pos then
                        runner.Draw:SetColor(0, 255, 0, 255)  -- Green
                        runner.Draw:Line(px, py, pz, pos.x, pos.y, pos.z)
                    end
                end
            end
        end
    end
end