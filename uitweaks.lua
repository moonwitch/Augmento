------------------------------------------------------------------------
-- Setting up the local scope so we can work in modules
------------------------------------------------------------------------
local _, Augmento = ...

local soundFile = [=[Sound\Interface\ReadyCheck.wav]=]

function Augmento.ApplyUITweaks()
   -- Fix Macro font
   SystemFont_Shadow_Small:SetFont(STANDARD_TEXT_FONT, 12)
end

------------------------------------------------------------------------
-- Slash Commands that shouldn't have been forgotten
SlashCmdList['RELOAD_UI'] = function() ReloadUI() end
SLASH_RELOAD_UI1 = '/rl'

SLASH_TICKETGM1 = '/gm'
SlashCmdList.TICKETGM = ToggleHelpFrame

------------------------------------------------------------------------
-- Filtering on Achievements and Guild
------------------------------------------------------------------------
function Augmento.ADDON_LOADED(addon)
   if(addon == 'Blizzard_AchievementUI') then
      AchievementFrame_SetFilter(3)
   elseif(addon == 'Blizzard_GuildUI') then
      GuildFrame:HookScript('OnShow', function()
         GuildFrameTab2:Click()
      end)
   end
end

------------------------------------------------------------------------
-- Toggle nameplates on while in combat and sound a bell.

function Augmento.PLAYER_REGEN_DISABLED(...)
   SetCVar("nameplateShowEnemies", 1)
   UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end

function Augmento.PLAYER_REGEN_ENABLED(...)
   SetCVar("nameplateShowEnemies", 0)
   UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end

------------------------------------------------------------------------
-- Gimme a sound on :
-- LFG
-- PARTY INVITE
-- RAID BOSS START
------------------------------------------------------------------------

function Augmento.LFG_PROPOSAL_SHOW()
   PlaySoundFile(soundFile, 'Master')
end

ReadyCheckListenerFrame:SetScript('OnShow', function()
   PlaySoundFile(soundFile, 'Master')
end)

function Augmento.PARTY_INVITE_REQUEST()
   PlaySoundFile(soundFile, 'Master')
end

function Augmento.CHAT_MSG_RAID_BOSS_WHISPER(msg, name)
   if(name == UnitName('player') and msg == 'You are next in line!') then
      -- PlaySoundFile(soundFile, 'Master')
   end
end

------------------------------------------------------------------------
-- Enable sound in Cinematics
------------------------------------------------------------------------
function Augmento.CINEMATIC_START(boolean)
   SetCVar('Sound_EnableMusic', 1)
   SetCVar('Sound_EnableAmbience', 1)
   SetCVar('Sound_EnableSFX', 1)
end

function Augmento.CINEMATIC_STOP()
   SetCVar('Sound_EnableMusic', 0)
   SetCVar('Sound_EnableAmbience', 1)
   SetCVar('Sound_EnableSFX', 1)
end


------------------------------------------------------------------------
-- Sell your shit

function Augmento.MERCHANT_SHOW(...)
   print('Merchant show triggered')

   if IsShiftKeyDown() then return end

   local junks, profit = 0, 0
   for bag = 0, 4 do
      for slot = 0, GetContainerNumSlots(bag) do
         local _, quantity, _, _, _, _, link = GetContainerItemInfo(bag, slot)
         if link then
            local _, _, quality, _, _, _, _, _, _, _, value = GetItemInfo(link)
            if quality == ITEM_QUALITY_POOR then
               junks = junks + 1
               profit = profit + value
               UseContainerItem(bag, slot)
            end
         end
      end
   end
   if profit > 0 then
      self:Print("Sold %d junk items for %s.", junks, GetCoinTextureString(profit))
   end

   if CanMerchantRepair() then
      local repairAllCost, canRepair = GetRepairAllCost()
      if canRepair and repairAllCost > 0 then
         if db.repairFromGuild and CanGuildBankRepair() then
            local amount = GetGuildBankWithdrawMoney()
            local guildBankMoney = GetGuildBankMoney()
            if amount == -1 then
               amount = guildBankMoney
            else
               amount = min(amount, guildBankMoney)
            end
            if amount > repairAllCost then
               RepairAllItems(1)
               self:Print("Repaired all items for %s from guild bank funds.", GetCoinTextureString(repairAllCost))
               return
            else
               self:Print("Insufficient guild bank funds to repair!")
            end
         elseif GetMoney() > repairAllCost then
            RepairAllItems()
            self:Print("Repaired all items for %s.", GetCoinTextureString(repairAllCost))
            return
         else
            self:Print("Insufficient funds to repair!")
         end
      end
   end
end