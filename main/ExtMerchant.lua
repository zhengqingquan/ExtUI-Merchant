-- 全局变量
EXTMERCHANT = {
    ItemsPerSubpage = MERCHANT_ITEMS_PER_PAGE, --每个子页面的物品数量
}

-- overrides default value of base ui, default functions will handle page display accordingly
-- 覆盖原本商人UI显示物品数量的默认值，默认函数将相应地处理页面显示。
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
    -- 上下翻页的时候也会触发MerchantFrame_UpdateMerchantInfo
    -- 拾取物品也会触发
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", ExtMerchant_UpdateSlotPositions)
    -- 回购页面钩子函数
    hooksecurefunc("MerchantFrame_UpdateBuybackInfo", ExtMerchant_UpdateBuyBackSlotPositions)

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
    -- 根据需要创建物品部件
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
    -- 设置商店标签上物品回购槽的位置。在进行其他操作的时候位置可能会改变。
    -- 因为锚点是MerchantItem10所以位置会根据MerchantItem10偏移。
    -- MerchantBuyBackItem的左上角被固定在了，MerchantItem10的左下角，在Y轴移动过了-53的像素点。
    -- 可用修改为固定在整体界面的某个位置
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
    
    -- 根据暴雪原生的UI，应该只要调整MerchantItem1的位置就可用改变后面11个的位置。
    --try

    -- 循环物品，稍微调整物品槽的位置。
    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        buy_slot = _G["MerchantItem" .. i]

        -- 在暴雪原生UI中，MerchantItem11和MerchantItem12被隐藏了。需要主动显示。
        buy_slot:Show()

        -- ItemsPerSubpage1
        if ((i % EXTMERCHANT.ItemsPerSubpage) == 1) then
            if (i == 1) then
                -- 按钮1
                buy_slot:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 24, -70)
            else
                -- 第二排
                buy_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - (EXTMERCHANT.ItemsPerSubpage - 1))], "TOPRIGHT", 12, 0)
            end
        else
            if ((i % 2) == 1) then
                -- 单数按钮，不包含1
                buy_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 2)], "BOTTOMLEFT", 0, vertSpacing)
            else
                -- 双数按钮
                buy_slot:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", horizSpacing, 0)
            end
        end
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

    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        buyback_slot = _G["MerchantItem" .. i]

        if (i > BUYBACK_ITEMS_PER_PAGE) then
            buyback_slot:Hide(); -- 隐藏
        else
            if (i == 1) then
                -- 设置UI组件的附着点。
                -- 参考https://wowpedia.fandom.com/wiki/API_Region_SetPoint
                buyback_slot:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 64, -105);
            else
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
-- Show and update merchant page
-- 展示并更新商人页面
--========================================
function ExtMerchant_UpdateMerchantInfo(isPageScroll)

end


--========================================
-- Slash command handler
-- 斜杠命令处理程序
--========================================
-- 目前用来测试某个功能。
function ExtMerchant_CommandHandler()

    -- 输入斜杠命令后更新商品界面
    ExtMerchant_UpdateSlotPositions()


end


--========================================
-- Previous page button handler
-- (also used for wheel scrolling)
-- 前一页按钮处理器（同样被用在滚轮滚动）
--========================================
function ExtMerchant_PrevPageButton()
    -- ExtMerchant_UpdateSlotPositions()
    print("前一页被点击")
end

--========================================
-- Next page button handler
-- (also used for wheel scrolling)
-- 下一页按钮处理器（同样被用在滚轮滚动）
--========================================
function ExtMerchant_NextPageButton()
    -- ExtMerchant_UpdateSlotPositions()
    print("下一页被点击")
end

--========================================
-- Hooked merchant frame OnShow
-- 钩住商人框体的OnShow方法
--========================================
function ExtMerchant_OnShow()
    -- 重新排列物品位置
    -- ExtMerchant_UpdateSlotPositions()
end

--========================================
-- Hooked merchant frame OnHide
-- 钩住商人框体的OnHide方法
--========================================
function ExtMerchant_OnHide()
end