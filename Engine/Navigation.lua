runner.Engine.Navigation = {}
local Navigation = runner.Engine.Navigation
runner.Engine.Navigation = Navigation

local lastPOSCheck = 0
local lastPOSX, lastPOSY, lastPOSZ = 0, 0, 0
local currentPath = nil
local currentPathIndex = nil

local lastSurge = 0

local function Distance3D(x1, y1, z1, x2, y2, z2)
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
    local px, py, pz = ObjectPosition("player")
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

function Navigation:MoveTo(unit)
    if unit then
        local x, y, z = ObjectPosition(unit)
        local px, py, pz = ObjectPosition("player")
        
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
                if stuckdist < 5 then
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
        if runner.LocalPlayer.z - groundZ < 30 then
            Unlock(CastSpellByName, "Skyward Ascent")
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
        if runner.LocalPlayer.z - groundZ > 5 then
            SetCVar("cameraPitchMoveSpeed", 90)
            Unlock(PitchUpStop)
            Unlock(PitchDownStart)
        end
    end
end

function Navigation:Distance2D(x1, y1, x2, y2)
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function Navigation:MoveToPoint(x, y, z)
    local px, py, pz = ObjectPosition("player")
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