require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')
require('AddonScripts/EmitSounds')


invoker_spellsteal_rubiks_apply = invoker_spellsteal_rubiks_apply or class({})

function invoker_spellsteal_rubiks_apply:OnSpellStart()
    local eCaster = self:GetCaster()
    --[[
    ApplySound(eCaster, 'invoker_spellsteal_rubiks_apply', {
            invoker_invo_ability_invoke_12 = 1,	--превосходное заклятие
            invoker_invo_invis_03 = 1,			--для этого у меня есть сферы
            invoker_invo_lasthit_05 = 1,		--какая.. самоотверженность
            invoker_invo_level_03 = 2,			--богадство, мудрость принадлежат мне
            invoker_invo_rare_01 = 2,			--всё может быть познано, познано мной
            invoker_invo_respawn_07 = 2,		--всё знание параллельно

            invoker_invo_thanks_03 = 2,			--Б'лагодарю (чуток саракастично)
            invoker_invo_level_09 = 1,			--блаженство понимания

            enigma_enig_deny_04 = 1,            --[enigma] моё
        }, 1
    )    
    ]]

    local nSpellSlot_eSpell = self.hList.nSpellSlot_eSpell
    local nToggleIndex_nSpellSlot = self.hList.nToggleIndex_nSpellSlot or {}
    local eTarget = self.hList.eTarget
    SpellSystem:UnRegisterSpellListToUnit(eCaster, self.hList.nIndex)   --возвращаем приоритет

    --Timers:CreateTimer(2, 
    --    function()
            local hSystemSpells = eCaster:FindAbilityByName('invoker_reconstruction')
            if hSystemSpells then
                --добавить выбранные Spell'ы
        
                for _, nSpellSlot in ipairs(nToggleIndex_nSpellSlot) do
                    local eTargetSpell = eTarget:GetAbilityByIndex(nSpellSlot)
                    local sTargetSpell = eTargetSpell and eTargetSpell.GetAbilityName and eTargetSpell:GetAbilityName()
        
                    if sTargetSpell then
                        hSystemSpells:ApplySpell({
                                sSpell = sTargetSpell,
        
                                sReplic_nON = {
                                    invoker_invo_ability_invoke_12 = 1,	--превосходное заклятие
                                    invoker_invo_invis_03 = 1,			--для этого у меня есть сферы
                                    invoker_invo_lasthit_05 = 1,		--какая.. самоотверженность
                                    invoker_invo_level_03 = 2,			--богадство, мудрость принадлежат мне
                                    invoker_invo_rare_01 = 2,			--всё может быть познано, познано мной
                                    invoker_invo_respawn_07 = 2,		--всё знание параллельно
                        
                                    invoker_invo_thanks_03 = 2,			--Б'лагодарю (чуток саракастично)
                                    invoker_invo_level_09 = 1,			--блаженство понимания
                        
                                    enigma_enig_deny_04 = 1,            --[enigma] моё
                                }
                            }
                        )
                    end
                end
            end
    --    end
    --)
end


--[[
ApplySound(eCaster, 'invoker_spellsteal_rubiks', {
        invoker_invo_ability_invoke_12 = 1,	--превосходное заклятие
        invoker_invo_invis_03 = 1,			--для этого у меня есть сферы
        invoker_invo_lasthit_05 = 1,		--какая.. самоотверженность
        invoker_invo_level_03 = 2,			--богадство, мудрость принадлежат мне
        invoker_invo_rare_01 = 2,			--всё может быть познано, познано мной
        invoker_invo_respawn_07 = 2,		--всё знание параллельно

        invoker_invo_thanks_03 = 2,			--Б'лагодарю (чуток саракастично)
        invoker_invo_level_09 = 1,			--блаженство понимания
    }, 1
)
]]