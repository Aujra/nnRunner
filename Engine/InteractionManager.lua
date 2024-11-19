runner.InteractionManager = {}
local InteractionManager = runner.InteractionManager

function InteractionManager:CancelCinematic()
    if InCinematic() or IsInCinematicScene() then
        StopCinematic()
    end
    if IsInCinematicScene() then
        CancelScene()
    end
end

function InteractionManager:SelectFirstGossip()
    if #C_GossipInfo.GetOptions() then
        for k,v in pairs(C_GossipInfo.GetOptions()) do
            if v.status == 0 then
                C_GossipInfo.SelectOption(v.gossipOptionID)
            end
        end
    end
end

function InteractionManager:AcceptAllQuests()
    if QuestFrame:IsVisible() or GossipFrame:IsVisible() then
        for i = 1, GetNumAvailableQuests() do
            SelectAvailableQuest(i)
        end
        for k,v in pairs(C_GossipInfo.GetAvailableQuests()) do
            C_GossipInfo.SelectAvailableQuest(v.questID)
        end
    end
end

function InteractionManager:QuestContinue()
    if QuestFrameAcceptButton:IsVisible() then
        QuestFrameAcceptButton:Click()
    end
    if QuestFrameCompleteButton:IsVisible() then
        QuestFrameCompleteButton:Click()
    end
    if QuestFrameCompleteQuestButton:IsVisible() then
        QuestFrameCompleteQuestButton:Click()
    end
end

function InteractionManager:CompleteQuest()
    if QuestFrame:IsVisible() then
        for i = 1, GetNumActiveQuests() do
            SelectActiveQuest(i)
        end
    end
    if QuestFrameCompleteQuestButton:IsVisible() then
        CompleteQuest()
    end
end

function InteractionManager:BuyFirstVendorItem()
    if MerchantFrame:IsVisible() then
        MerchantSellAllJunkButton:Click()
        for i = 1, GetMerchantNumItems() do
            if select(3, GetMerchantItemInfo(i)) == 0 then
                BuyMerchantItem(i)
                return
            end
        end
    end
end

function InteractionManager:StaticPopUp()
    if StaticPopup1Button1:IsVisible() then
        StaticPopup1Button1:Click()
    end
end

function InteractionManager:HandleAll()
    InteractionManager:CancelCinematic()
    InteractionManager:SelectFirstGossip()
    InteractionManager:AcceptAllQuests()
    InteractionManager:QuestContinue()
    InteractionManager:CompleteQuest()
    InteractionManager:BuyFirstVendorItem()
    InteractionManager:StaticPopUp()
end