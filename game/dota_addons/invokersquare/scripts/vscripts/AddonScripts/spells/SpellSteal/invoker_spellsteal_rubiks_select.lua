require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')
require('AddonScripts/EmitSounds')

invoker_spellsteal_rubiks_select = invoker_spellsteal_rubiks_select or class({})


function invoker_spellsteal_rubiks_select:OnRefresh()
    self.sTexture = SyncOnly(self.sTexture)
end

function invoker_spellsteal_rubiks_select:OnToggle()
    --Server code
    local eSpellApply = self:GetCaster():FindAbilityByName('invoker_spellsteal_rubiks_apply')
    eSpellApply.hList:ToggleButtonApply(self.nSpellSlot)
end


function invoker_spellsteal_rubiks_select:SetTarget(eTarget)
    self.eTarget = eTarget
    self:UpdateTexture()
end

function invoker_spellsteal_rubiks_select:UpdateTexture()
    local sFirstTexture = self.sTexture
    local eTargetSpell = self.eTarget:GetAbilityByIndex(self.nSpellSlot)
    if eTargetSpell then
        if eTargetSpell.GetAbilityTextureName then
            self.sTexture = eTargetSpell:GetAbilityTextureName()
        else
            local sTargetSpell = eTargetSpell:GetAbilityName()
            self.sTexture = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")[sTargetSpell].AbilityTextureName
        end
    end
    self.sTexture = self.sTexture or 'invoker_empty1'
    if self.sTexture ~= sFirstTexture then
        --если текстура была изменена, то синхронизировать изменение
        SyncExecByEnt(self,'OnRefresh')
    end
end

function invoker_spellsteal_rubiks_select:GetAbilityTextureName()
    return self.sTexture
end