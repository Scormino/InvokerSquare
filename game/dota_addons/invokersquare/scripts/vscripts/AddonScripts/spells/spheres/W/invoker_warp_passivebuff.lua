require('AddonScripts/ConstUtils')
require('AddonScripts/SpellSystem')

invoker_warp_passivebuff = invoker_warp_passivebuff or class({})

function invoker_warp_passivebuff:OnRefresh()
	local hQWER = QWERSystem:Apply(self, self:GetCaster())
	self.nMana = GetConst(GetGameConst().warp.nMana, hQWER)

	SpellSystem:RefreshComplete(self, hQWER)
end

function invoker_warp_passivebuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS
	}
end

function invoker_warp_passivebuff:GetModifierManaBonus()
	return self.nMana
end

function invoker_warp_passivebuff:OnCreated()
	SpellSystem:BuffOnCreated(self)
end

function invoker_warp_passivebuff:IsDeBuff()
	return false
end

function invoker_warp_passivebuff:IsBuff()
	return true
end

function invoker_warp_passivebuff:IsHidden()
	return true
end

function invoker_warp_passivebuff:IsPermanent()
	return true
end