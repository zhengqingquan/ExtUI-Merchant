function Cloasebuff(self)

    -- 注册buff出现的事件。
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW");
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_HIDE");

end

function Evend_handle(self, event, ...)
    if ( event == "SPELL_ACTIVATION_OVERLAY_SHOW" ) then
        if ( GetCVarBool("displaySpellActivationOverlays") ) then
            SpellActivationOverlay_HideOverlays(self, spellID)
        end
    end
end
