--========================================
-- 修复暴雪的bug
-- 当你使用购买堆叠框体的时候切换标签会报错
-- 因为尝试调用StackSplitFrameCancel_Click()，但这个函数似乎被删除了。
--========================================
function StackSplitFrameCancel_Click()
    StackSplitCancelButton_OnClick()
end