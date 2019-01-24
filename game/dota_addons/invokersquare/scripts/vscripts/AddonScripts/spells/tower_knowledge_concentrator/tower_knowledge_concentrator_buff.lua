require('AddonScripts/ModifierSync')
require('AddonScripts/ConstUtils')
require('Gamemodes/ClassicMode/QWERSystem')

tower_knowledge_concentrator_buff = tower_knowledge_concentrator_buff or class({})


function tower_knowledge_concentrator_buff:OnRefresh()
	local hQWER = QWERSystem:Apply(self, self:GetCaster(), 'tower_knowledge_concentrator')

	--self.sTextureName = GetConst(GetGameConst().invoker_alacrity_of_zecora.sBuffTextureName, hQWER)
	--self.nDamage = GetConst(GetGameConst().invoker_alacrity_of_zecora.nDamage, hQWER)
	--self.nInDamagePercent = GetConst(GetGameConst().invoker_alacrity_of_zecora.nInDamagePercent, hQWER)
	--self.nOutDamagePercent = GetConst(GetGameConst().invoker_alacrity_of_zecora.nOutDamagePercent, hQWER)

	SpellSystem:RefreshComplete(self, hQWER)
end

function tower_knowledge_concentrator_buff:OnCreated()
	local nBuffIndex = SpellSystem:BuffOnCreated(self)
	
end

function tower_knowledge_concentrator_buff:OnDestroy()
	SpellSystem:BuffOnDestroy(self)
end

function tower_knowledge_concentrator_buff:IsDeBuff()
	return false
end

function tower_knowledge_concentrator_buff:IsBuff()
	return true
end

function tower_knowledge_concentrator_buff:IsHidden()
	return false
end