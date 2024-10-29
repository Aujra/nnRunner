runner.Engine.Navigation = {}
local Navigation = runner.Engine.Navigation
runner.Engine.Navigation = Navigation

local lastPOSCheck = 0
local lastPOSX, lastPOSY, lastPOSZ = 0, 0, 0

function Navigation:MoveTo(unit)
    if unit then
        local x, y, z = ObjectPosition(unit)
        local px, py, pz = ObjectPosition("player")
        local _, _, _, _, _, _, _, mapId = GetInstanceInfo()
        local path = runner.nn.GenerateLocalPath(mapId,px,py,pz,x,y,z)

        if #path > 1 then
            local pathIndex = 2
            local function distance3D(x1, y1, z1, x2, y2, z2)
                local dx = x2 - x1
                local dy = y2 - y1
                local dz = z2 - z1
                return math.sqrt(dx*dx + dy*dy + dz*dz)
            end
            local tx = tonumber(path[pathIndex].x)
            local ty = tonumber(path[pathIndex].y)
            local tz = tonumber(path[pathIndex].z)
            local distance = distance3D(px, py, pz, tx, ty, tz)
            if distance < 3 then
                pathIndex = pathIndex + 1
                if pathIndex > #path then
                    Unlock(MoveForwardStop)
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
            if GetTime() - lastPOSCheck > .5 then
                local playerX, playerY, playerZ = ObjectPosition("player")
                if playerX == lastPOSX and playerY == lastPOSY then
                    print("Stuck, jumping")
                    Unlock(JumpOrAscendStart)
                end
                lastPOSCheck = GetTime()
                lastPOSX, lastPOSY, lastPOSZ = ObjectPosition("player")
            end
        end
    end
end

function Navigation:MoveToPoint(x,y,z)
    local px, py, pz = ObjectPosition("player")
    local _, _, _, _, _, _, _, mapId = GetInstanceInfo()
    local path = runner.nn.GenerateLocalPath(mapId,px,py,pz,x,y,z)

    if #path > 1 then
        local pathIndex = 2
        local function distance3D(x1, y1, z1, x2, y2, z2)
            local dx = x2 - x1
            local dy = y2 - y1
            local dz = z2 - z1
            return math.sqrt(dx*dx + dy*dy + dz*dz)
        end
        local tx = tonumber(path[pathIndex].x)
        local ty = tonumber(path[pathIndex].y)
        local tz = tonumber(path[pathIndex].z)
        local distance = distance3D(px, py, pz, tx, ty, tz)
        if distance < 3 then
            pathIndex = pathIndex + 1
            if pathIndex > #path then
                Unlock(MoveForwardStop)
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
            distance = distance + math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
        end
        print("Distance to unit " .. UnitName(unit) .. " is " .. distance)
        return distance
    end
    return 0
end