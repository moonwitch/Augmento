------------------------------------------------------------------------
-- Localization
------------------------------------------------------------------------
local _, Augmento = ...


------------------------------------------------------------------------
-- Adding a /prof command
------------------------------------------------------------------------
SLASH_PROF1 = '/prof'
SlashCmdList["PROF"] = function()
   ToggleSpellBook(BOOKTYPE_PROFESSION)
end

------------------------------------------------------------------------
-- Adding levels
------------------------------------------------------------------------