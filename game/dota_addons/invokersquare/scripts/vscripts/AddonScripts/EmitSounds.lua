require('BarebonesLib/timers')
local sGroupName_bIsCooldown = {}

--[[
  Названия стандартных звуков брать отсюда:
  https://github.com/SteamDatabase/GameTracking-Dota2/tree/master/game/dota/pak01_dir/soundevents/game_sounds_heroes
]]

function ApplySound(eUnit, sGroupName, hSounds, nCooldown)
  if not sGroupName_bIsCooldown[sGroupName] then
    --если нет Cooldown
    if nCooldown then
      sGroupName_bIsCooldown[sGroupName] = true
      Timers:CreateTimer(nCooldown, 
        function()
          sGroupName_bIsCooldown[sGroupName] = nil
        end
      )
    end
    
    local nSound_hSound = {}
    local nSumChanse = 0.0
    for sSoundName, nChanse in pairs(hSounds) do
      nSound_hSound[#nSound_hSound + 1] = {
        sSoundName = sSoundName,
        nChanse = nChanse
      }
      nSumChanse = nSumChanse + nChanse
    end
    local nRand = RandomFloat(0, nSumChanse)

    local nCurrentChanse = 0.0
    for _, hSound in ipairs(nSound_hSound) do
      nCurrentChanse = nCurrentChanse + hSound.nChanse
      if nRand <= nCurrentChanse then
        eUnit:EmitSound(hSound.sSoundName)
        break
      end
    end
  end
end



--[[
enigma pack:


enigma_enig_ability_black_03 = 1, --взгляни в бездну
enigma_enig_ability_demon_01 = 1, --я есть контроль
enigma_enig_ability_demon_02 = 1,  --оттдайся пустоте

enigma_enig_cast_02 = 1,  --неумолимое наступление
enigma_enig_death_06 = 1,  --сознание есть форма

enigma_enig_deny_04 = 1,  --моё

enigma_enig_drop_common_01 = 1,  --из ничего возникло нечто
enigma_enig_drop_medium_01 = 1,  --благополучное воплощение производности

enigma_enig_fastres_01 = 1,  --тайны бытия не знают конца

enigma_enig_kill_05 = 1,  --твоё путешествие окончено

enigma_enig_purch_02 = 1,  --сфера влияния расширяется

enigma_enig_respawn_06 = 1,  - и вновь моя форма обретает бытие
enigma_enig_spawn_04 = 1,  -- моя форма обретает бытие

enigma_enig_rival_10 = 1,  -- сила тебя не спасла
enigma_enig_rival_12 = 1,  -- даже сильные умирают

enigma_enig_ally_17 = 1,  --те, что стояли у самых истоков - снова здесь
enigma_enig_kill_08 = 1,  --закат бытия
enigma_enig_rival_21 = 1,  --даже время следует законам притяжения

Возможно:
Arc Warden


Shadow Demon
Terrorblade
Outworld Devourer
Undying
]]