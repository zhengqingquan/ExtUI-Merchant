--========================================
-- 之后扩展功能，暂时无用
--========================================

function SetTab1:UI_set_onclick(SetTab1)
    print(1)
    -- PanelTemplates_SetTab(MerchantFrame, SetTab1:GetID())

    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
end

EXTUI_SET_DATA = {}
EXTUI_SET_ABOUT={
    Version = GetAddOnMetadata("ExtVendor", "Version"),
}
print("nihao")


--========================================
-- Check configuration setting, and
-- initialize with default value if not
-- present
-- 检查配置设置，如果不存在，则使用默认值初始化
--========================================
function ExtMerchant_CheckSetting(args)
    
end

--========================================
-- 该商人能否修理
--========================================
function Button:UpdatePosition()
	-- 该商人能否修理
	if CanMerchantRepair() then
		local off, scale
		if CanGuildBankRepair and CanGuildBankRepair() then
			off, scale = -3.5, 0.9
			MerchantRepairAllButton:SetPoint('BOTTOMRIGHT', MerchantFrame, 'BOTTOMLEFT', 120, 35)
		else
			off, scale = -1.5, 1
		end

		self:SetPoint('RIGHT', MerchantRepairItemButton, 'LEFT', off, 0)
		self:SetScale(scale)
	else
		self:SetPoint('RIGHT', MerchantBuyBackItem, 'LEFT', -17, 0.5)
		self:SetScale(1.1)
	end

	MerchantRepairText:Hide()
end