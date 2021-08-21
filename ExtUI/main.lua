--========================================
-- From：Extended Merchant UI
-- Author：Germbread
--========================================

-- MERCHANT_ITEMS_PER_PAGE默认为10
local ItemsPerSubpage = MERCHANT_ITEMS_PER_PAGE

-- BUYBACK_ITEMS_PER_PAGE默认为12
local BuyBackPerPage = BUYBACK_ITEMS_PER_PAGE

--========================================
-- Rearrange item slot positions
-- 重新排列商品物品槽的位置。
--========================================
local function ExtMerchant_UpdateSlotPositions()
    -- 购买垂直间距为-16，水平间距为12，单位：像素
    local vertSpacing= -16 -- 垂直间距
    local horizSpacing = 12 -- 水平间距
    local buy_slot -- 临时变量
    
    -- 循环物品槽，调整物品槽的锚点和位置。
    -- 参考：
    -- https://wowpedia.fandom.com/wiki/API_Region_SetPoint
    -- https://bbs.nga.cn/read.php?tid=4555096
    -- https://www.townlong-yak.com/framexml/live/MerchantFrame.xml#89
    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        buy_slot = _G["MerchantItem" .. i]
        -- 在暴雪原生UI中，MerchantItem11和MerchantItem12被隐藏了（11和12被用于回购）。需要主动显示全部物品槽。
        buy_slot:Show()
        if ((i % ItemsPerSubpage) == 1) then
            if (i == 1) then
                -- 物品槽1
                buy_slot:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -70)
            else
                -- 第二排
                buy_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - (ItemsPerSubpage - 1))], "TOPRIGHT", 12, 0)
            end
        else
            if ((i % 2) == 1) then
                -- 单数按钮，不包含物品槽1
                buy_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 2)], "BOTTOMLEFT", 0, vertSpacing)
            else
                -- 双数按钮
                buy_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", horizSpacing, 0)
            end
        end
    end

    MerchantFrameLootFilter:Show();
    MerchantExtraCurrencyBg:Show()--金色边框
    MerchantExtraCurrencyInset:Show()--背景颜色
    MerchantMoneyInset:Show()
    MerchantMoneyBg:Show()
    MerchantMoneyFrame:Show()
    MerchantToken1:Show()
end

--========================================
-- Rearrange item slot positions
-- 重新排列回购物品槽的位置。
--========================================
local function ExtMerchant_UpdateBuyBackSlotPositions()

    -- 回购垂直间距为-30，水平间距为50，单位：像素
    local vertSpacing= -30 -- 垂直间距
    local horizSpacing = 50 -- 水平间距
    local buyback_slot -- 临时变量

    -- 循环物品槽，调整物品槽的锚点和位置。
    -- 参考：
    -- https://wowpedia.fandom.com/wiki/API_Region_SetPoint
    -- https://bbs.nga.cn/read.php?tid=4555096
    -- https://www.townlong-yak.com/framexml/live/MerchantFrame.xml#89
    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        buyback_slot = _G["MerchantItem" .. i]
        buyback_slot:Show()
        if (i > BuyBackPerPage) then
            -- 对多余的物品栏进行隐藏
            buyback_slot:Hide()
        else
            -- 回购槽1
            if (i == 1) then
                buyback_slot:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 64, -105);
            else
                -- 下一排
                if ((i % 3) == 1) then
                    buyback_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 3)], "BOTTOMLEFT", 0, vertSpacing);
                else
                    buyback_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", horizSpacing, 0);
                end
            end
        end
    end

    MerchantFrameLootFilter:Show();
    MerchantExtraCurrencyBg:Show()--金色边框
    MerchantExtraCurrencyInset:Show()--背景颜色
    MerchantMoneyInset:Show()
    MerchantMoneyBg:Show()
    MerchantMoneyFrame:Show()
    MerchantToken1:Show()
end

--========================================
-- Initial load
-- 初始化加载
--========================================
local function ExtMerchant_OnLoad()

    -- 更改商品页面为20
    MERCHANT_ITEMS_PER_PAGE=20

    -- set the new width of the frame
    -- 设置新的框体宽度
    MerchantFrame:SetWidth(690)

    -- create new item buttons as needed
    -- 根据需要创建物品槽组件
    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        if (not _G["MerchantItem" .. i]) then
            CreateFrame("Frame", "MerchantItem" .. i, MerchantFrame, "MerchantItemTemplate")
        end
    end





    -- 创建一个名为SetTab的标签
    --命名只能是MerchantFrameTab3
    CreateFrame("Button", "MerchantFrameTab3", MerchantFrame, "CharacterFrameTabButtonTemplate")
    --设置文本
    MerchantFrameTab3:SetText("设置")
    -- 设置ID为3
    MerchantFrameTab3:SetID(3)
    MerchantFrame.numTabs=3
    --设置锚点
    MerchantFrameTab3:SetPoint("LEFT" , MerchantFrameTab2 , "RIGHT" , -16 , 0)
    PanelTemplates_DeselectTab(MerchantFrameTab3)
    -- 测试用
    -- SetTab1.flag = true
    MerchantFrameTab3:SetScript('OnClick', function()

        --原本商品是12个（显示10个）show方法在这里
        --回购是进行重新排序，但回购里面没有show

        MerchantFrame.selectedTab=3
        -- PanelTemplates_SelectTab(SetTab)

        -- SetTab:OnSelect()
        -- print(MerchantFrameTab2:GetID())
        -- print(SetTab:GetName())
        -- local left = SetTab.Left or _G[SetTab:GetName().."Left"];
        -- local middle = SetTab.Middle or _G[SetTab:GetName().."Middle"];
        -- local right = SetTab.Right or _G[SetTab:GetName().."Right"];
        -- print(left)
        -- print(middle)
        -- print(right)
        -- left:Hide()
        -- right:Hide()
        -- middle:Hide()
        -- PanelTemplates_DeselectTab(SetTab)
        -- SetTab:GetParent()
        -- MerchantFrame_Update()
        print(MerchantFrame.selectedTab)
        PanelTemplates_SetTab(MerchantFrame, MerchantFrameTab3:GetID());
        -- MerchantFrame_Update();

        if ( MerchantFrame.lastTab ~= MerchantFrame.selectedTab ) then
            MerchantFrame_CloseStackSplitFrame();
            MerchantFrame.lastTab = MerchantFrame.selectedTab;
        end
        MerchantFrame_UpdateFilterString()
        if ( MerchantFrame.selectedTab == 1 ) then
            MerchantFrame_UpdateMerchantInfo();
        elseif ( MerchantFrame.selectedTab == 3 ) then
            MerchantNameText:SetText("ExtUI设置");--设置标题
            MerchantFramePortrait:SetTexture("Interface\\MerchantFrame\\UI-BuyBack-Icon");--设置左上角图片

            -- Hide all merchant related items
            buybackButton = _G["MerchantItem"..1];
			SetItemButtonNameFrameVertexColor(buybackButton, 0.5, 0.5, 0.5);--高光
			SetItemButtonSlotVertexColor(buybackButton,0.4, 0.4, 0.4);--高光
            
            -- ItemsPerSubpage=MerchantFrame.lastTab
            for i=1, MERCHANT_ITEMS_PER_PAGE do
                itemButton = _G["MerchantItem"..i];
                _G["MerchantItem"..i.."Name"]:SetText("");
                _G["MerchantItem"..i.."MoneyFrame"]:Hide();
                itemButton:Hide();
            end
            print(GetNumBuybackItems())--获取当前回购里面有多少物品
            print(GetMerchantNumItems())--获取当前商人里面有多少卖在的物品

            MerchantFrameLootFilter:Hide();
            MerchantExtraCurrencyBg:Hide()--金色边框
            MerchantExtraCurrencyInset:Hide()--背景颜色
            MerchantMoneyInset:Hide()
            MerchantMoneyBg:Hide()
            MerchantMoneyFrame:Hide()
            MerchantToken1:Hide()

            BuybackBG:Hide();
            MerchantRepairAllButton:Hide();
            MerchantRepairItemButton:Hide();
            MerchantBuyBackItem:Hide();
            MerchantPrevPageButton:Hide();
            MerchantNextPageButton:Hide();
            MerchantFrameBottomLeftBorder:Hide();
            MerchantFrameBottomRightBorder:Hide();
            MerchantRepairText:Hide();
            MerchantPageText:Hide();
            MerchantGuildBankRepairButton:Hide();
        else
            -- MerchantFrame_UpdateBuybackInfo();
        end





    end)
    -- print(_G[MerchantFrame:GetName().."Tab"..1]:GetName())
    -- print(MerchantFrame.Tabs[1]:GetName())
    -- print(MerchantFrame.Tabs[2]:GetName())
    -- print(MerchantFrame.Tabs[3]:GetName())
    -- SetTab:SetScript("OnEnter", function()
    --     PanelTemplates_SelectTab(SetTab)
    -- end)
    -- SetTab:SetScript("OnLeave", function()
    --     PanelTemplates_DeselectTab(SetTab)
    -- end)


    --取消选取
    -- PanelTemplates_DeselectTab(SetTab)
    --选取
    -- PanelTemplates_SelectTab(SetTab)

    -- 测试
    -- hooksecurefunc("PanelTemplates_SetTab", function() print(frame.selectedTab ) end)




    -- currency insets
    -- 货币的背景
    MerchantExtraCurrencyInset:ClearAllPoints();
    MerchantExtraCurrencyInset:SetPoint("BOTTOMRIGHT", MerchantMoneyInset, "BOTTOMLEFT", 0, 0);
    MerchantExtraCurrencyInset:SetPoint("TOPLEFT", MerchantMoneyInset, "TOPLEFT", -165, 0);
    MerchantExtraCurrencyBg:ClearAllPoints();
    MerchantExtraCurrencyBg:SetPoint("TOPLEFT", MerchantExtraCurrencyInset, "TOPLEFT", 3, -2);
    MerchantExtraCurrencyBg:SetPoint("BOTTOMRIGHT", MerchantExtraCurrencyInset, "BOTTOMRIGHT", -3, 2);

    -- move the next/previous page buttons
    -- 移动下一页/上一页按钮的位置
    MerchantPrevPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOM", 30, 55);
    MerchantPageText:SetPoint("BOTTOM", MerchantFrame, "BOTTOM", 160, 50);
    MerchantNextPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOM", 290, 55);

    -- alter the position of the buyback item slot on the merchant tab
    -- 更改当在商人标签时的回购槽的位置。
    -- 因为锚点是MerchantItem10所以位置会根据MerchantItem10偏移。
    MerchantBuyBackItem:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", -14, -20)


    -- 上一页的钩子函数，同样适用于滚轮
    hooksecurefunc("MerchantPrevPageButton_OnClick", ExtMerchant_UpdateSlotPositions)
    -- 下一页的钩子函数，同样适用于滚轮
    hooksecurefunc("MerchantNextPageButton_OnClick", ExtMerchant_UpdateSlotPositions)

    -- 商品页面钩子函数，同样适用于滚轮。
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", ExtMerchant_UpdateSlotPositions)
    
    -- 回购页面钩子函数，相对商品页面较为稳定，只有进入回购才触发。
    hooksecurefunc("MerchantFrame_UpdateBuybackInfo", ExtMerchant_UpdateBuyBackSlotPositions)
end


--========================================
-- main
--========================================
ExtMerchant_OnLoad()