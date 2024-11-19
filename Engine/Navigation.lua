runner.Engine.Navigation = {}
local Navigation = runner.Engine.Navigation
runner.Engine.Navigation = Navigation

local lastPOSCheck = 0
local lastPOSX, lastPOSY, lastPOSZ = 0, 0, 0
local currentPath = nil
local currentPathIndex = nil

local lastSurge = 0

local function Distance3D(x1, y1, z1, x2, y2, z2)
    if not x1 or not y1 or not z1 or not x2 or not y2 or not z2 then
        return 999999
    end

    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function GenerateStraightLinePath(startX, startY, startZ, endX, endY, endZ)
    runner.Engine.DebugManager:Debug("Navigation", "Generating straight line path")
    local path = {}
    local totalDistance = Distance3D(startX, startY, startZ, endX, endY, endZ)
    local maxGap = 2 -- Never allow points to be more than 2 yards apart
    
    -- Calculate steps needed to maintain max gap
    local steps = math.ceil(totalDistance / maxGap)
    steps = math.max(2, steps) -- Ensure at least 2 points
    
    runner.Engine.DebugManager:Debug("Navigation", string.format(
        "Path generation:\n" ..
        "- Total distance: %.2f yards\n" ..
        "- Maximum allowed gap: %d yards\n" ..
        "- Required steps: %d\n" ..
        "- Actual gap between points: %.2f yards",
        totalDistance,
        maxGap,
        steps,
        totalDistance / steps
    ))
    
    for i = 0, steps do
        local t = i / steps
        local x = startX + (endX - startX) * t
        local y = startY + (endY - startY) * t
        local z = startZ + (endZ - startZ) * t
        table.insert(path, {x = x, y = y, z = z})
        
        if i > 0 then
            local lastPoint = path[#path-1]
            local pointDistance = Distance3D(lastPoint.x, lastPoint.y, lastPoint.z, x, y, z)
            runner.Engine.DebugManager:Debug("Navigation", string.format(
                "Point %d/%d - Distance from previous: %.2f yards",
                i, steps, pointDistance
            ))
        end
    end
    
    return path
end

function Navigation:FacePoint(x, y, z)
    local px, py, pz = runner.LocalPlayer.x, runner.LocalPlayer.y, runner.LocalPlayer.z
    if not px or not py or not pz then
        return
    end
    z = z or pz
    local dx, dy, dz = px-x, py-y, pz-z
    local radians = math.atan2(-dy, -dx)
    if radians < 0 then radians = radians + math.pi * 2 end
    runner.nn.SetPlayerFacing(radians)
end

local function GeneratePath(startX, startY, startZ, endX, endY, endZ)
    local _, _, _, _, _, _, _, mapId = GetInstanceInfo()
    
    -- Try with nav server first
    local path = runner.nn.GenerateLocalPath(mapId, startX, startY, startZ, endX, endY, endZ)
    
    runner.Engine.DebugManager:Debug("Navigation", string.format(
        "Attempting path generation from (%.2f, %.2f, %.2f) to (%.2f, %.2f, %.2f)",
        startX, startY, startZ, endX, endY, endZ
    ))
    
    -- Check if path is invalid (nil, empty, or contains 0,0,0)
    if not path or #path <= 1 then
        runner.Engine.DebugManager:Warning("Navigation", "Map-based path generation failed")
        path = GenerateStraightLinePath(startX, startY, startZ, endX, endY, endZ)
    else
        local firstPoint = path[1]
        if firstPoint.x == 0 and firstPoint.y == 0 and firstPoint.z == 0 then
            runner.Engine.DebugManager:Warning("Navigation", "Map returned invalid coordinates (0,0,0)")
            path = GenerateStraightLinePath(startX, startY, startZ, endX, endY, endZ)
        end
    end
    
    return path
end

function Navigation:waypointAwayFrom(x, y, z, distance)
    local possible = {}
    for i = 1, 20 do
        table.insert(possible, runner.Classes.Point:new(x + math.random(-distance*1.2, distance*1.2), y + math.random(-distance*1.2, distance*1.2), z))
    end
    local best = nil
    for k,v in pairs(possible) do
        if Navigation:PointHasPath(v.X, v.Y, v.Z) then
            if not best then
                best = v
            else
                if best:DistanceFromXYZ(x,y,z) > distance*1 then
                    if v:DistanceFromPlayer() < best:DistanceFromPlayer() then
                        best = v
                    end
                end
            end
        end
    end
    return best
end

function Navigation:IsBehindTarget(target)
    if not target then return false end

    local px, py, pz = ObjectPosition("player")
    local tx, ty, tz = ObjectPosition(target.pointer)
    if not px or not tx then return false end

    -- Check distance
    local distance = math.sqrt((px - tx)^2 + (py - ty)^2)

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

function Navigation:MoveBehindUnit(target)
    local targetFacing = ObjectFacing(target.pointer)
    local tx, ty, tz = ObjectPosition(target.pointer)
    if not targetFacing or not tx then return nil end

    -- Calculate angle directly behind target
    local behindAngle = (targetFacing + math.pi) % (2 * math.pi)

    -- Add random offset within 90-degree arc (45 degrees each side)
    local randomOffset = (math.random() - 0.5) * math.pi/2  -- -45 to +45 degrees
    local finalAngle = (behindAngle + randomOffset) % (2 * math.pi)

    -- Calculate position at melee range plus target's bounding radius
    local radius = 5 + target.BoundingRadius
    return {
        x = tx + math.cos(finalAngle) * radius,
        y = ty + math.sin(finalAngle) * radius,
        z = tz
    }
end

function Navigation:PointHasPath(x,y,z)
    local _, _, _, _, _, _, _, mapId = GetInstanceInfo()
    local path = runner.nn.GenerateLocalPath(mapId,runner.LocalPlayer.x,runner.LocalPlayer.y,runner.LocalPlayer.z,x,y,z)
    return path and #path > 1
end

function Navigation:MoveTo(unit)
    if unit then
        local x, y, z = ObjectPosition(unit)
        local px, py, pz = ObjectPosition("player")

        local distance = Distance3D(px, py, pz, x, y, z)

        if distance > 20 and runner.LocalPlayer.Class == "SHAMAN" then
            if not runner.LocalPlayer:HasAura("Ghost Wolf", "HELPFUL") then
                Unlock(CastSpellByName, "Ghost Wolf")
            end
        end

        local path = GeneratePath(px, py, pz, x, y, z)
        currentPath = path
        currentPathIndex = 2

        if #path > 1 then
            local pathIndex = 2
            local tx = tonumber(path[pathIndex].x)
            local ty = tonumber(path[pathIndex].y)
            local tz = tonumber(path[pathIndex].z)
            local distance = Distance3D(px, py, pz, tx, ty, tz)
            if distance < 2 then
                pathIndex = pathIndex + 1
                currentPathIndex = pathIndex
                if pathIndex > #path then
                    Unlock(MoveForwardStop)
                    currentPath = nil
                    currentPathIndex = nil
                    return
                end
            end
            tx = tonumber(path[pathIndex].x)
            ty = tonumber(path[pathIndex].y)
            tz = tonumber(path[pathIndex].z)
            local dx, dy, dz = px-tx, py-ty, pz-tz
            local radians = math.atan2(-dy, -dx)
            if radians < 0 then radians = radians + math.pi * 2 end
            runner.nn.SetPlayerFacing(radians)
            Unlock(MoveForwardStart)

            -- Stuck detection
            if GetTime() - lastPOSCheck > 2 then
                local playerX, playerY, playerZ = ObjectPosition("player")
                local stuckdist = Distance3D(playerX, playerY, playerZ, lastPOSX, lastPOSY, lastPOSZ)
                if stuckdist < 1 then
                    runner.Engine.DebugManager:Warning("Navigation", "Detected stuck state, attempting jump")
                    Unlock(JumpOrAscendStart)
                end
                lastPOSCheck = GetTime()
                lastPOSX, lastPOSY, lastPOSZ = ObjectPosition("player")
            end
        end
    end
end

function Navigation:FlyToPoint(x,y,z)
    if not IsFlyableArea() then
        return
    end

    if GetShapeshiftForm() ~= 3 then
        Unlock(CastSpellByName, "Travel Form")
    end

    runner.Engine.Navigation:FacePoint(x, y, z)
    local groundZ = select(3, runner.nn.TraceLine(runner.LocalPlayer.x, runner.LocalPlayer.y, 10000, runner.LocalPlayer.x, runner.LocalPlayer.y, -10000, 0x110))

    runner.Draw:Text("Distance left " .. self:Distance2D(runner.LocalPlayer.x, runner.LocalPlayer.y, x, y) , "GAMEFONTNORMAL", runner.LocalPlayer.x, runner.LocalPlayer.y, runner.LocalPlayer.z + 3)

    if self:Distance2D(runner.LocalPlayer.x, runner.LocalPlayer.y, x, y) > 20 then
        if runner.LocalPlayer.z - groundZ < 90 then
            Unlock(CastSpellByName, "Skyward Ascent")
            return
        end

        if runner.LocalPlayer.Pitch <= .1 then
            if not IsMouselooking() then
                Unlock(MouselookStart)
                Unlock(MoveViewDownStart, 2)
                Unlock(MouselookStop)
            end
            print("Moving pitch down "  .. tostring(IsMouselooking()))

            return
        end
        if runner.LocalPlayer.Pitch > .1 and runner.LocalPlayer.Pitch < .3 then
            print("Pitch is good")
            Unlock(MoveViewDownStop)
            Unlock(MouselookStop)
            return
        end

        if runner.LocalPlayer.Vigor < 4 then
            Unlock(CastSpellByName, "Second Wind")
        end
        if not runner.LocalPlayer:HasAura("Ohn'ahra's Gusts" , "HELPFUL") and runner.LocalPlayer.z - groundZ > 80
                or not runner.LocalPlayer:HasAura("Thrill of the Sky", "HELPFUL") and runner.LocalPlayer.Vigor > 2
        and GetTime() - lastSurge > 4 then
            Unlock(CastSpellByName, "Surge Forward")
            lastSurge = GetTime()
        end
    else
        print("We need to land")
        if runner.LocalPlayer.z - groundZ > 5 then
            Unlock(PitchDownStart)
        else
            Unlock(PitchDownStop)
        end
    end
end

function Navigation:Distance2D(x1, y1, x2, y2)
    if not x1 or not y1 or not x2 or not y2 then
        return 999999
    end
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function Navigation:MoveToPoint(x, y, z)
    local px, py, pz = ObjectPosition("player")
    if IsFlyableArea() then
        local distance = Navigation:Distance2D(px, py, pz, x, y, z)
        if distance > 200 then
            Navigation:FlyToPoint(x, y, z)
            return
        end
    end

    local distance = Distance3D(px, py, pz, x, y, z)

    if distance > 20 and runner.LocalPlayer.Class == "SHAMAN" then
        if not runner.LocalPlayer:HasAura("Ghost Wolf", "HELPFUL") then
            Unlock(CastSpellByName, "Ghost Wolf")
        end
    end

    local path = GeneratePath(px, py, pz, x, y, z)
    currentPath = path
    currentPathIndex = 2

    if #path > 1 then
        self:Debug(path)
        local pathIndex = 2
        local tx = tonumber(path[pathIndex].x)
        local ty = tonumber(path[pathIndex].y)
        local tz = tonumber(path[pathIndex].z)
        local distance = Distance3D(px, py, pz, tx, ty, tz)
        if distance < 2 then
            pathIndex = pathIndex + 1
            currentPathIndex = pathIndex
            if pathIndex > #path then
                Unlock(MoveForwardStop)
                currentPath = nil
                currentPathIndex = nil
                return
            end
        end
        tx = tonumber(path[pathIndex].x)
        ty = tonumber(path[pathIndex].y)
        tz = tonumber(path[pathIndex].z)
        local dx, dy, dz = px-tx, py-ty, pz-tz
        local radians = math.atan2(-dy, -dx)
        if radians < 0 then radians = radians + math.pi * 2 end
        runner.nn.SetPlayerFacing(radians)
        Unlock(MoveForwardStart)
    end
end

function Navigation:GetCurrentPath()
    return currentPath
end

function Navigation:GetCurrentPathIndex()
    return currentPathIndex
end

function Navigation:Debug(path)
    for i = 1, #path-1 do
        local x1, y1, z1 = tonumber(path[i].x), tonumber(path[i].y), tonumber(path[i].z)
        local x2, y2, z2 = tonumber(path[i+1].x), tonumber(path[i+1].y), tonumber(path[i+1].z)
        runner.Draw:Line(x1, y1, z1, x2, y2, z2)
    end
end

function Navigation:FaceUnit(unit)
    if unit then
        local x, y, z = ObjectPosition(unit)
        local px, py, pz = ObjectPosition("player")
        local dx, dy, dz = px-x, py-y, pz-z
        local radians = math.atan2(-dy, -dx)
        if radians < 0 then radians = radians + math.pi * 2 end
        runner.nn.SetPlayerFacing(radians)
    end
end

function Navigation:PathDistance(unit)
    if unit then
        local x, y, z = ObjectPosition(unit)
        local px, py, pz = ObjectPosition("player")
        local _, _, _, _, _, _, _, mapId = GetInstanceInfo()
        local path = runner.nn.GenerateLocalPath(mapId,px,py,pz,x,y,z)
        local distance = 0
        for i = 1, #path-1 do
            local x1, y1, z1 = tonumber(path[i].x), tonumber(path[i].y), tonumber(path[i].z)
            local x2, y2, z2 = tonumber(path[i+1].x), tonumber(path[i+1].y), tonumber(path[i+1].z)
            distance = distance + Distance3D(x1, y1, z1, x2, y2, z2)
        end
        runner.Engine.DebugManager:Debug("Navigation", string.format(
            "Path distance to %s: %.2f yards",
            UnitName(unit), distance
        ))
        return distance
    end
    return 0
end