-- 全局变量
EXTMERCHANT = {
    ItemsPerSubpage = MERCHANT_ITEMS_PER_PAGE, --此处为10，表示左右两个页面为10。每个子页面的物品数量
}

-- overrides default value of base ui, default functions will handle page display accordingly
-- 覆盖原本商人UI显示物品数量的默认值，默认函数将相应地处理页面显示。
-- HACK 这里会照成暴雪的全局变量污染。
MERCHANT_ITEMS_PER_PAGE = 20;

--========================================
-- Initial load routine
-- 初始化加载例程
--========================================
function ExtMerchant_OnLoad(self)

    -- 重构商品界面
    ExtMerchant_RebuildMerchantFrame()

    -- 上一页的钩子函数
    hooksecurefunc("MerchantPrevPageButton_OnClick", ExtMerchant_UpdateSlotPositions)
    -- 下一页的钩子函数
    hooksecurefunc("MerchantNextPageButton_OnClick", ExtMerchant_UpdateSlotPositions)

    -- 商品页面钩子函数
    -- 上下翻页的时候也会触发
    -- 拾取物品(非金币)也会触发
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", ExtMerchant_UpdateSlotPositions)

    -- 回购页面钩子函数
    -- 回购页面的触发相对商品页面较为稳定，只有进入回购才触发。
    hooksecurefunc("MerchantFrame_UpdateBuybackInfo", ExtMerchant_UpdateBuyBackSlotPositions)

    ExtMerchant_UpdateBuyBackItemPositions()
    hooksecurefunc("MerchantFrame_UpdateRepairButtons", ExtMerchant_UpdateSellAllJunkButtonPositions)
    hooksecurefunc("MerchantFrame_UpdateCurrencies", ExtMerchant_UpdateTokenPositions)
end


--========================================
-- Event handler
-- 事件处理程序
--========================================
function ExtMerchant_OnEvent(self, event, ...)
end


--========================================
-- Update handler - handle refresh
-- queueing to limit the merchant frame
-- to no more than 1 refresh per
-- 1/10 seconds
-- 更新处理程序-处理刷新队列，将商人框体限制为每1/10秒不超过1次更新。
--========================================
function ExtMerchant_OnUpdate(self, elapsed)
end


--========================================
-- Rebuilds the merchant frame into
-- the extended design
-- 将商人框体重建成扩展设计
--========================================
function ExtMerchant_RebuildMerchantFrame()
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

    -- move the next/previous page buttons
    -- 移动下一页/上一页按钮的位置
    MerchantPrevPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOM", 30, 55);
    MerchantPageText:SetPoint("BOTTOM", MerchantFrame, "BOTTOM", 160, 50);
    MerchantNextPageButton:SetPoint("CENTER", MerchantFrame, "BOTTOM", 290, 55);

    -- alter the position of the buyback item slot on the merchant tab
    -- 更改当在商人标签时的回购槽的位置。
    -- 因为锚点是MerchantItem10所以位置会根据MerchantItem10偏移。
    MerchantBuyBackItem:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", -14, -20)
    
    -- 隐藏游戏自带的过滤器
    -- MerchantFrameLootFilter:Hide();
end

--========================================
-- Rearrange item slot positions
-- 重新排列商品物品槽的位置。
--========================================
function ExtMerchant_UpdateSlotPositions()
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
        -- 在暴雪原生UI中，MerchantItem11和MerchantItem12被隐藏了。需要主动显示全部物品槽。
        buy_slot:Show()

        if ((i % EXTMERCHANT.ItemsPerSubpage) == 1) then
            if (i == 1) then
                -- 物品槽1
                buy_slot:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -70)
            else
                -- 第二排
                buy_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - (EXTMERCHANT.ItemsPerSubpage - 1))], "TOPRIGHT", 12, 0)
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

    -- 显示按钮。
    local numMerchantItems = securecall("GetMerchantNumItems");
    if ( numMerchantItems <= MERCHANT_ITEMS_PER_PAGE ) then
        MerchantPageText:Show();
        MerchantPrevPageButton:Show();
        MerchantPrevPageButton:Disable();
        MerchantNextPageButton:Show();
        MerchantNextPageButton:Disable();
    end
end

--========================================
-- Rearrange item slot positions
-- 重新排列回购物品槽的位置。
--========================================
function ExtMerchant_UpdateBuyBackSlotPositions()
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

        -- BUYBACK_ITEMS_PER_PAGE默认为12
        if (i > BUYBACK_ITEMS_PER_PAGE) then
            buyback_slot:Hide(); -- 多余的物品栏进行隐藏
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
end

--========================================
-- 重新排列货币的位置
--========================================
function ExtMerchant_UpdateTokenPositions()
    MerchantMoneyBg:SetPoint("TOPRIGHT", MerchantFrame, "BOTTOMRIGHT", -8, 25);
    MerchantMoneyBg:SetPoint("BOTTOMLEFT", MerchantFrame, "BOTTOMRIGHT",-169, 6);

    MerchantExtraCurrencyInset:ClearAllPoints();
    MerchantExtraCurrencyInset:SetPoint("TOPLEFT", MerchantMoneyInset, "TOPLEFT", -171, 0);
    MerchantExtraCurrencyInset:SetPoint("BOTTOMRIGHT", MerchantMoneyInset, "BOTTOMLEFT", 0, 0);

    MerchantExtraCurrencyBg:ClearAllPoints();
    MerchantExtraCurrencyBg:SetPoint("TOPLEFT", MerchantMoneyBg, "TOPLEFT", -171, 0);
    MerchantExtraCurrencyBg:SetPoint("BOTTOMRIGHT", MerchantMoneyBg, "BOTTOMLEFT", -3, 0);

    local currencies = { GetMerchantCurrencies() };
    MerchantFrame.numCurrencies = #currencies;
    for index = 1, MerchantFrame.numCurrencies do
        local tokenButton = _G["MerchantToken"..index];
        tokenButton:ClearAllPoints();
        -- token display order is: 6 5 4 | 3 2 1
        if ( index == 1 ) then
            tokenButton:SetPoint("BOTTOMRIGHT", -16, 8);
        elseif ( index == 4 ) then
            tokenButton:SetPoint("RIGHT", _G["MerchantToken"..index - 1], "LEFT", -15, 0);
        else
            tokenButton:SetPoint("RIGHT", _G["MerchantToken"..index - 1], "LEFT", 0, 0);
        end
    end
end

--========================================
-- 重新排列出售所有垃圾按钮的位置
--========================================
function ExtMerchant_UpdateSellAllJunkButtonPositions()
    if ( not securecall("CanMerchantRepair") ) then
        MerchantSellAllJunkButton:SetPoint("RIGHT", MerchantBuyBackItem, "LEFT", -13, 0);
    end
end

--========================================
-- 重新排列回购按钮的位置
--========================================
function ExtMerchant_UpdateBuyBackItemPositions()
    MerchantBuyBackItem:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", 15, -20);

    MerchantMoneyFrame:Hide();

    MerchantExtraCurrencyBg:Hide();
    MerchantExtraCurrencyInset:Hide();
end

