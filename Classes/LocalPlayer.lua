runner.Classes.LocalPlayer = runner.Classes.Player:extend()
local LocalPlayer = runner.Classes.LocalPlayer
runner.Classes.LocalPlayer = LocalPlayer

function LocalPlayer:init(pointer)
    runner.Classes.Player.init(self, pointer)
    self.spec = GetSpecialization()
    self.specName = select(2, GetSpecializationInfo(self.spec))
end

function LocalPlayer:Update()
    runner.Classes.Player.Update(self)
    self.spec = GetSpecialization()
    self.specName = select(2, GetSpecializationInfo(self.spec))
    self:EquipUpgrades()
end

function LocalPlayer:EquipUpgrades()
    if not C_AddOns.IsAddOnLoaded("Pawn") then
        return
    end

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