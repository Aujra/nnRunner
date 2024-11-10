runner.Classes.LocalPlayer = runner.Classes.Player:extend()
local LocalPlayer = runner.Classes.LocalPlayer
runner.Classes.LocalPlayer = LocalPlayer

local fields = nil

function LocalPlayer:init(pointer)
    runner.Classes.Player.init(self, pointer)
    self.spec = GetSpecialization()
    self.specName = select(2, GetSpecializationInfo(self.spec))
    self.Yaw = 0
end

function LocalPlayer:Update()
    local lastZ = self.z
    runner.Classes.Player.Update(self)
    if self.z and lastZ then
        self.ZDelta = self.z - lastZ
    else
        self.ZDelta = 0
    end
    self.spec = GetSpecialization()
    self.specName = select(2, GetSpecializationInfo(self.spec))
    self.Yaw = runner.nn.ObjectYaw(self.pointer)
    self.Rotation = runner.nn.ObjectRotation(self.pointer)
    self.ForwardSpeed = select(3, C_PlayerInfo.GetGlidingInfo())
    self.Gliding = select(1, C_PlayerInfo.GetGlidingInfo())

    local fields = {}

    for i=0, 2000, 4 do
        local t = runner.nn.ObjectField(self.pointer, i*4, 4)
        table.insert(fields, i .. " with " .. t)
    end

    self.Fields = fields

end

function LocalPlayer:EquipUpgrades()
    if StaticPopup1Button1 ~= nil and StaticPopup1Button1:IsVisible() then
        print("Accepting upgrade")
        Unlock(RunMacroText, "/click StaticPopup1Button1")
    end
    for i = 0, NUM_BAG_SLOTS do
        for j = 1, C_Container.GetContainerNumSlots(i) do
            local item = C_Container.GetContainerItemInfo(i, j)
            if item then
                local itemLoc = ItemLocation:CreateFromBagAndSlot(i, j)
                local itemLink = C_Item.GetItemLink(itemLoc)
                local isUpgrade = PawnIsItemDefinitivelyAnUpgrade(itemLink, true)
                if isUpgrade then
                    C_Container.UseContainerItem(i, j)
                    if StaticPopup1Button1 ~= nil and StaticPopup1Button1:IsVisible() then
                        print("Accepting upgrade")
                        Unlock(RunMacroText, "/click StaticPopup1Button1")
                    end
                end
            end
        end
    end
end