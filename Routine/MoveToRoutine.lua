runner.Routines.MoveToRoutine = class({}, "BaseRoutine")
local MoveToRoutine = runner.Routines.MoveToRoutine
runner.Routines.BaseRoutine = MoveToRoutine

function MoveToRoutine:init()
    self.Name = "MoveTo"
    self.Description = "Move to a location"
    self.currentX = 0
    self.currentY = 0
    self.currentZ = 0

    self.destX = 0
    self.destY = 0
    self.destZ = 0

    self.tempX = 0
    self.tempY = 0
    self.tempZ = 0

    self.hasClimbed = false

    self.waypointsTo = {}
end

function MoveToRoutine:Run()
    if WorldMapFrame:IsVisible() and IsControlKeyDown() and IsMouseButtonDown("LeftButton") then
        local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        local continentID, worldPosition = C_Map.GetWorldPosFromMapPos(WorldMapFrame:GetMapID(), CreateVector2D(x, y))
        self.destX, self.destY = worldPosition:GetXY()
        self.destZ = select(3, runner.nn.TraceLine(WX, WY, 10000, WX, WY, -10000, 0x110))
    end

    if IsFlyableArea() then
        if self.destX ~= 0 and self.destY ~= 0 and self.destZ ~= 0 then
            runner.Engine.Navigation:FlyToPoint(self.destX, self.destY, self.destZ)
        end
    end

    if not IsFlyableArea() then
        if not self.destZ then
            local diffx, diffy = self.destX - runner.LocalPlayer.x, self.destY - runner.LocalPlayer.y
            if abs(diffx) > 50 then
                if diffx > 0 then
                    diffx = 100
                else
                    diffx = 100
                end
                self.currentX = runner.LocalPlayer.x + diffx
            else
                self.currentX = runner.LocalPlayer.x
            end
            if abs(diffy) > 50 then
                if diffy > 0 then
                    diffy = 100
                else
                    diffy = 100
                end
                self.currentY = runner.LocalPlayer.y + diffy
            else
                self.currentY = runner.LocalPlayer.y
            end

            local tempZ = select(3, runner.nn.TraceLine(self.currentX, self.currentY, 10000, self.currentX, self.currentY, -10000, 0x110))
            self.currentZ = tempZ
        else
            self.currentX = self.destX
            self.currentY = self.destY
            self.currentZ = self.destZ
        end

        if self.currentX ~= 0 and self.currentY ~= 0 and self.currentZ ~= 0 then
            runner.Draw:Circle(self.currentX, self.currentY, self.currentZ, 10)
            if runner.LocalPlayer:DistanceFromPoint(self.destX, self.destY, self.destZ) < 10 then
                Unlock(MoveForwardStop)
                return
            else
                runner.Engine.Navigation:MoveToPoint(self.currentX, self.currentY, self.currentZ)
            end
        end
    end
end

function MoveToRoutine:Distance2D(x1, y1, x2, y2)
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function MoveToRoutine:ShowGUI()
end

function MoveToRoutine:HideGUI()
end

registerRoutine(MoveToRoutine)
